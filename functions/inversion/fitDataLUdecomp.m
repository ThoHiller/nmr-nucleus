function fitdata = fitDataLUdecomp(time,signal,parameter)
%fitDataLUdecomp retrieves an NMR relaxation-time distribution using
%regularized normal equations followed by a projected-gradient iteration
%to enforce non-negativity.
%
% Syntax:
%       fitDataLUdecomp(time,signal,parameter)
%
% Inputs:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       parameter - struct that hold additional settings:
%                   T1T2    : flag between 'T1' or 'T2' inversion
%                   T1IRfac : either '1' or '2' depending on T1 method
%                   Tb      : bulk relaxation time
%                   Td      : diffusion relaxation time
%                   Tint    : relaxation times [log10(tmin) log10(tmax) Ndec]
%                   Lorder  : smoothness constraint (derivative matrix)
%                   lambda  : regularization parameter (if -1 automatic
%                             regularization)
%                   noise   : noise level
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%                   fit_t      : time vector for plotting
%                   fit_s      : signal vector for plotting
%                   T1T2me     : relaxation time values
%                   T1T2f      : relaxation time spectrum
%                   Tlgm       : T logmean
%                   E0         : initial amplitude at t=0 (T2) or t=max (T1)
%                   resnorm    : residual norm
%                   residual   : vector of residuals
%                   chi2       : chi square error
%                   rms        : RMS error
%                   lambda_out : regularization parameter lambda                  
%                   KK         : inversion kernel matrix
%                   L          : derivative matrix
%                   xn         : model norm |L*x|_2
%                   rn         : residual norm |A*x-b|_2
%
% Example:
%       [fitdata] = fitDataLUdecomp(t,s,parameter)
%
% Other m-files required:
%       createKernelMatrix
%       getFitErrors
%       getTLogMean
%       get_l (from 'Regularization Toolbox')
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
% NOTE: I harvested this routine partly from the Internet but forgot where
% I found the routines ... so there is no warranty at all

%------------- BEGIN CODE --------------

%% input vectors
time   = time(:);
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

%% parameters
flag    = parameter.T1T2;
T1IRfac = parameter.T1IRfac;
Tb      = parameter.Tb;
Td      = parameter.Td;
tstart = parameter.Tint(1);
tend   = parameter.Tint(2);
N      = parameter.Tint(3);
order  = parameter.Lorder;
lambda = parameter.lambda;
noise  = parameter.noise;

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

%% regularization (derivative / smoothness) matrix
m = length(T1T2me);
L = get_l(m,order);
H = L'*L;

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
else
    % unweighted inversion
    sigma = [];
    % sigma = noise * ones(size(g));
    % constant numerical scaling derived from physical data
    scale = max(abs(g));
    if ~isfinite(scale) || scale <= 0
        scale = 1;
    end
    ginv = g ./ scale;
    Kinv = K ./ scale;
    % whitened inversion system
    % ginv = g ./ sigma;
    % Kinv = K ./ sigma;
end

%% automatic regularization
if lambda == -1
    lambda = trace(Kinv'*Kinv) / trace(H);
end


%% regularized normal equations
% (K'K + lambda L'L) f = K'g
A = Kinv'*Kinv + lambda*H;
y = Kinv'*ginv;

%% initial regularized solution
[Llu,Ulu] = lu(A);
f = Ulu\(Llu\y);

% positivity iteration
% Important:
% regularization is intentionally only used for the start solution
Als = Kinv'*Kinv;
% Keep original step-size concept for now
e = 2/max(eig(A));
iter = 1000;
for i = 1:iter
    % project negative values to zero
    f = max(f,0);
    % unregularized LS iteration
    f = (eye(m)-e*Als)*f + e*y;
end
f = max(f,0);

%% physical fitted signal
% K and f are both in physical amplitude units.
% No weighting or scaling is applied here.
s_fit = K*f;

%% fit errors in physical data space
if hasWeights
    out = getFitErrors(signal,s_fit,noise,parameter.W);
else
    out = getFitErrors(signal,s_fit,noise);
end

%% L-curve quantities
% model norm
xn = norm(L*f,2);
% residual norm in the metric actually used by inversion
if hasWeights
    res_inv = (K*f-g)./sigma;
else
    res_inv = (K*f-g)./scale;
end
rn = norm(res_inv,2);

%% initial / equilibrium amplitude E0
if strcmp(flag,'T1')
    K2 = createKernelMatrix(10*time(end),T1T2me,Tb,Td,flag,T1IRfac);

elseif strcmp(flag,'T2')
    K2 = createKernelMatrix(0,T1T2me,Tb,Td,flag,T1IRfac);
end
E0 = K2*f;

%% output
fitdata.fit_t = time;
fitdata.fit_s = s_fit;
fitdata.T1T2me = T1T2me;
fitdata.T1T2f = f;
fitdata.Tlgm = getTLogMean(T1T2me,f);
fitdata.E0 = E0;
fitdata.residual = out.residual;
fitdata.chi2 = out.chi2;
fitdata.rms = out.rms;
fitdata.lambda_out = lambda;
% inversion kernel
fitdata.KK = Kinv;
% physical kernel
fitdata.K = K;
fitdata.L = L;
fitdata.xn = xn;
fitdata.rn = rn;
fitdata.scale = scale;
fitdata.iterations = iter;
fitdata.invtype = 'LU';
fitdata.invparams = parameter;

return

%------------- END OF CODE --------------