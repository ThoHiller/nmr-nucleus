function fitdata = fitDataLSQ(time,signal,parameter)
%fitDataLSQ is a control routine that fits NMR data multi-exponentially;
%if the Optimization Toolbox is available the user can select LSQLIN,
%otherwise the default built-in LSQNONNEG is used; the 'Regularization Toolbox'
%from P. Hansen can be used for automatic regularization based on the SVD
%
% The physical signal and kernel are kept unchanged. Error weighting and
% numerical scaling are applied only to the inversion system.
%
% Syntax:
%       fitdata = fitDataLSQ(time,signal,parameter)
%
% Inputs:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       parameter - struct that holds additional settings:
%                   T1T2     : flag between 'T1' or 'T2' inversion
%                   T1IRfac  : either '1' or '2' depending on T1 method
%                   Tb       : bulk relaxation time
%                   Td       : diffusion relaxation time
%                   Tint     : relaxation times [log10(tmin) log10(tmax) Ndec]
%                   regMethod: 'manual', 'gcv_tikh', 'gcv_trunc',
%                              'gcv_damp', 'discrep'
%                   Lorder   : smoothness constraint (derivative matrix)
%                   lambda   : regularization parameter (for 'manual')
%                   noise    : noise level needed for 'discrep' discrepancy
%                              principle
%                   W        : error weighting matrix (optional)
%                   solver   : LSQ solver ('optimTB' or 'internal')
%                   EchoFlag : Echo flag ('on' or 'off')
%                   bounds   : predefined lower and upper bounds and start
%                              model (optional and only for 'lsqlin')
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%                   fit_t      : time vector for plotting
%                   fit_s      : signal vector for plotting
%                   T1T2me     : relaxation time values
%                   T1T2f      : relaxation time spectrum
%                   Tlgm       : T log-mean
%                   E0         : initial amplitude at t=0 (T2) or t=inf (T1)
%                   resnorm    : residual norm
%                   residual   : vector of residuals
%                   chi2       : chi square error
%                   rms        : RMS error
%                   lambda_out : regularization parameter lambda determined
%                                by the different options from the 'regu'
%                                toolbox
%                   KK         : Kernel matrix
%                   L          : derivative matrix
%                   xn         : model norm |L*x|_2
%                   rn         : residual norm |A*x-b|_2
%
% Example:
%       [fitdata] = fitDataLSQ(t,s,parameter)
%
% Other m-files required:
%       Optimization Toolbox from Mathworks (optional)
%       Regularization Toolbox
%       applyRegularization
%       createKernelMatrix
%       getFitErrors
%       getTLogMean
%       lsqnonneg
%       lsqlin (optional)
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)
%
%------------- BEGIN CODE --------------

%% input vectors
time = time(:);
signal = signal(:);

if length(time) ~= length(signal)
    error('time and signal must have the same number of elements.');
end
if any(~isfinite(time)) || any(~isfinite(signal))
    error('time and signal must contain finite values only.');
end

% physical data
t = time;
g = signal;

%% input parameters
flag      = parameter.T1T2;
T1IRfac   = parameter.T1IRfac;
Tb        = parameter.Tb;
Td        = parameter.Td;
tstart    = parameter.Tint(1);
tend      = parameter.Tint(2);
N         = parameter.Tint(3);
regMethod = parameter.regMethod;
order     = parameter.Lorder;
lambda    = parameter.lambda;
noise     = parameter.noise;

%% relaxation-time vector
nT = round((tend-tstart)*N);
if nT < 2
    error('Relaxation-time discretization must contain at least 2 points.');
end
T1T2me = logspace(tstart,tend,nT);
T1T2me = T1T2me(:);

%% physical kernel matrix
% If gated data are supplied, create the kernel first on the original
% time vector and apply exactly the same arithmetic gating operator as
% used for the measured NMR signal.
hasGates = isfield(parameter,'gate') && ~isempty(parameter.gate);
if hasGates
    gate = parameter.gate;
    if ~isfield(gate,'time_raw') || isempty(gate.time_raw)
        error('parameter.gate.time_raw is required for kernel gating.');
    end
    if ~isfield(gate,'indices') || isempty(gate.indices)
        error('parameter.gate.indices is required for kernel gating.');
    end

    time_raw = gate.time_raw(:);
    % physical kernel on original echo times
    Kraw = createKernelMatrix(time_raw,T1T2me,Tb,Td,flag,T1IRfac);

    nGates = length(gate.indices);
    if nGates ~= length(g)
        error(['Number of gates does not match the number ', ...
               'of input data points.']);
    end
    K = zeros(nGates,length(T1T2me));
    % apply exactly the same arithmetic gating to kernel
    for i = 1:nGates
        ind = gate.indices{i};
        K(i,:) = mean(Kraw(ind,:),1);
    end
else
    K = createKernelMatrix(t,T1T2me,Tb,Td,flag,T1IRfac);
end

%% bounds for LSQLIN
if strcmp(parameter.solver,'optimTB')
    if isfield(parameter,'bounds') && ~isempty(parameter.bounds)
        f0    = parameter.bounds.f0(:);
        f0_lb = parameter.bounds.lb(:);
        f0_ub = parameter.bounds.ub(:);
    else
        f0    = zeros(size(T1T2me));
        f0_lb = zeros(size(T1T2me));
        % upper bound in physical signal units
        f0_ub = 1.5*max(abs(g))*ones(size(T1T2me));
        % optionally suppress relaxation times below TE/5 or TR/5
        if strcmp(parameter.EchoFlag,'on')
            f0_ub(T1T2me < time(1)/5) = 0;
        end
    end
end

%% derivative / smoothness matrix
L = get_l(length(T1T2me),order);

%% prepare inversion system - statistical weighting / scaling
% K and g always remain physical
% Kinv and ginv are used only by the inversion
hasWeights = isfield(parameter,'W') && ~isempty(parameter.W);
if hasWeights
    % error-weighted / whitened inversion
    % W contains the standard error of each gated data point:
    % sigma_k = e / sqrt(N_k)
    % with
    % e = standard deviation of the raw NMR noise
    % N_k = number of raw data points averaged in gate k
    sigma = diag(parameter.W);
    sigma = sigma(:);

    if length(sigma) ~= length(g)
        error(['Number of standard deviations in parameter.W does not ', ...
               'match the number of NMR data points.']);
    end
    if any(~isfinite(sigma)) || any(sigma <= 0)
        error('All standard deviations must be finite and > 0.');
    end
    % whiten data and kernel
    ginv = g ./ sigma;
    Kinv = K ./ sigma;
    % no additional amplitude scaling after whitening
    scale = 1;
    % expected standard deviation of whitened residual
    noise_inv = 1;
else
    % unweighted inversion
    sigma = [];
    % constant numerical scaling derived from physical data
    scale = max(abs(g));
    if ~isfinite(scale) || scale <= 0
        scale = 1;
    end
    ginv = g ./ scale;
    Kinv = K ./ scale;
    % scale global noise estimate consistently
    noise_inv = noise ./ scale;
end


%% Regularization
% applyRegularization receives exactly the system that will be solved.
[KK,lambda_out] = applyRegularization(Kinv,ginv,L,lambda,regMethod,order,noise_inv);

%% extended data vector
gg = [ginv; zeros(size(L,1),1)];

%% solve least-squares problem
switch parameter.solver
    case 'optimTB'
        % For older vrsions "Algorithm" maybe needs to be set to "interior-point" 
        options = optimoptions('lsqlin','Algorithm','active-set', ...
            'Display',parameter.info,'OptimalityTolerance',1e-10, ...
            'StepTolerance',1e-12,'MaxIterations',2000);

        f = lsqlin(KK,gg,[],[],[],[],f0_lb,f0_ub,f0,options);

    case 'internal'
        options = optimset('Display',parameter.info,'TolX',1e-12);

        f = lsqnonneg(KK,gg,options);
    otherwise
        error('Unknown LSQ solver "%s".',parameter.solver);
end

%% physical fitted signal
% K and f are both in physical amplitude units.
% No weighting or scaling is applied here.
s_fit = K*f;

%% error measures in physical signal space
if hasWeights
    out = getFitErrors(signal,s_fit,noise,parameter.W);
else
    out = getFitErrors(signal,s_fit,noise);
end

%% L-curve quantities
% model norm
xn = norm(L*f,2);
% residual norm in the metric actually used by the inversion
if hasWeights
    res_inv = (K*f-g) ./ sigma;
else
    res_inv = (K*f-g) ./ scale;
end
% rn = norm(res_inv,2);
rn = norm(Kinv*f - ginv,2);

%% initial / equilibrium amplitude E0
switch flag
    case 'T1'
        K0 = createKernelMatrix(10*time(end),T1T2me,Tb,Td,flag,T1IRfac);
    case 'T2'
        K0 = createKernelMatrix(0,T1T2me,Tb,Td,flag,T1IRfac);
end
E0 = K0*f;

%% output struct
fitdata.fit_t = time;
fitdata.fit_s = s_fit;
fitdata.T1T2me = T1T2me;
fitdata.T1T2f = f;
fitdata.Tlgm = getTLogMean(T1T2me,f);
fitdata.E0 = E0;
fitdata.ciE0 = NaN;
fitdata.resnorm = out.resnorm;
fitdata.residual = out.residual;
fitdata.chi2 = out.chi2;
fitdata.rms = out.rms;
fitdata.lambda_out = lambda_out;
% regularized inversion kernel
fitdata.KK = KK;
% physical kernel
fitdata.K = K;
fitdata.L = L;
fitdata.xn = xn;
fitdata.rn = rn;
fitdata.invtype = 'NNLS';
fitdata.invparams = parameter;
% inversion diagnostics
fitdata.scale = scale;

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2018 Thomas Hiller
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.