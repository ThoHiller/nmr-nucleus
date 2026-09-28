function [fitdata] = fitDataMultiModal(time,signal,parameter)
%fitDataMultiModal Fit NMR data using a superposition of multiple
%relaxation-time distributions.
%
% The RTD is represented by nModes Gaussian distributions on a
% logarithmically equidistant relaxation-time axis.
%
% The nonlinear model parameters of each mode are
%
%   x(3*i-2) = log(mu_i)   logarithm of modal relaxation time
%   x(3*i-1) = sigma_i     width in log(T) space
%   x(3*i)   = E_i         amplitude
%
% The routine uses either LSQNONLIN or FMINSEARCHBND.
%
% Syntax:
%       fitdata = fitDataMultiModal(time,signal,parameter)
%
% Inputs:
%       time      - time vector
%       signal    - NMR signal vector
%
%       parameter - struct containing:
%           nModes   : number of distributions
%           T1T2     : 'T1' or 'T2'
%           T1IRfac  : T1 saturation/inversion recovery factor
%           Tb       : bulk relaxation time
%           Td       : diffusion relaxation time
%           Tint     : [log10(tmin) log10(tmax) Ndec]
%           noise    : raw noise level
%           solver   : 'optimTB' or 'internal'
%           W        : optional diagonal matrix containing standard
%                      errors sigma_k of the data points
%           gate     : optional gate structure containing
%                      gate.indices and gate.time_raw
%           info     : optimizer display option (optional)
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%                   fit_t   : time vector for plotting
%                   fit_s   : signal vector for plotting
%                   T1T2me  : relaxation time values
%                   T1T2f   : relaxation time spectrum
%                   Tlgm    : T log-mean
%                   E0      : initial amplitude at t=0 (T2) or t=max (T1)
%                   ciE     : E0 confidence interval (NaN as placeholder)
%                   resnorm : residual norm
%                   residual: vector of residuals
%                   errnorm : error norm
%                   lambda_out : dummy 0
%                   rms     : RMS error
%                   chi2    : chi square error
%                   reducedchi2 : reduced chi square error
%                   ci      : confidence interval
%                   T       : relaxation times per mode
%                   S       : width per mode
%                   E       : amplitude per mode;
%                   x       : all parameters combined
%                   lb      : lower bounds
%                   ub      : upper bounds
%                   output  : output struct (output from 'lsqnonlin' or
%                             'fminsearchbnd')
%                  exitflag : inversion solver exit flag
%                   invtype : 'MUMO'
%                 invparams : used inversion parameter
%
% Other m-files required:
%       createKernelMatrix
%       estimateJacobian
%       fcn_fitMultiModal
%       fitDataFree
%       fminsearchbnd
%       getFitErrors
%       getConfInterval
%       getTLogMean
%       lsqnonlin (Optimization Toolbox)
%
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License

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
s = signal;

% number of modes
nModes = parameter.nModes;

% NMR flags & parameter
flag = parameter.T1T2;
T1IRfac = parameter.T1IRfac;
Tb = parameter.Tb;
Td = parameter.Td;

% relaxation time distribution parameter
tstart = parameter.Tint(1);
tend = parameter.Tint(2);
N = parameter.Tint(3);

% if 'info' is not there, switch it off
if ~isfield(parameter,'info')
    parameter.info = 'off';
end

%% relaxation-time vector
nT = round((tend-tstart)*N);
if nT < 2
    error('Relaxation-time discretization must contain at least 2 points.');
end
T1T2me = logspace(tstart,tend,nT);
T1T2me = T1T2me(:);

%% initial estimate using free exponential fit
param0.T1IRfac = T1IRfac;
param0.noise = parameter.noise;
param0.solver = parameter.solver;
param0.Tfixed_bool = [0 0 0 0 0];
param0.Tfixed_val = [0 0 0 0 0];
if isfield(parameter,'W')
    param0.W = parameter.W;
end
invstd0 = fitDataFree(t,s,flag,param0,nModes);

%% initial values and bounds
x0 = zeros(3*nModes,1);
lb = zeros(3*nModes,1);
ub = zeros(3*nModes,1);

for i = 1:nModes
    T0 = invstd0.x(2*i);
    E0 = invstd0.x(2*i-1);
    % initial values for T, sigma and E
    x0(3*i-2) = log(T0);
    x0(3*i-1) = 1;
    x0(3*i)   = E0;
    % lower bounds
    lb(3*i-2) = log(T0/100);
    lb(3*i-1) = 0.01;
    lb(3*i)   = 0;
    % upper bounds
    ub(3*i-2) = log(T0*100);
    ub(3*i-1) = 3.5;
    ub(3*i)   = max(invstd0.E0)*1.5;
end

%% physical forward kernel
% K always remains physical and unweighted.
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

    nGates = numel(gate.indices);
    if nGates ~= length(s)
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

%% prepare inversion system - statistical weighting / scaling
% parameter.W contains the standard error sigma_k of each data point:
%  sigma_k = e_raw / sqrt(N_k)
% Hence the inversion residual is
%  r_k = (s_model,k - s_data,k) / sigma_k
% No weighting is applied to the physical signal or kernel.
hasWeights = isfield(parameter,'W') && ~isempty(parameter.W);
if hasWeights
    sigma = diag(parameter.W);
    sigma = sigma(:);
    if length(sigma) ~= length(s)
        error('Size of parameter.W does not agree with signal length.');
    end
    if any(~isfinite(sigma)) || any(sigma <= 0)
        error('parameter.W contains invalid standard errors.');
    end
    scale = 1;
else
    sigma = [];
    scale = max(abs(s));
    if isempty(scale) || ~isfinite(scale) || scale <= 0
        scale = 1;
    end
end

%% parameters passed to objective function
iparam.solver = parameter.solver;
iparam.nModes = nModes;
iparam.s = s;
iparam.T = T1T2me;
% physical kernel
iparam.K = K;
% inversion weighting/scaling
iparam.sigma = sigma;
iparam.scale = scale;

%% nonlinear optimization
switch parameter.solver
    case 'optimTB'
        % LSQNONLIN
        options = optimoptions('lsqnonlin','Algorithm','levenberg-marquardt', ...
            'Display',parameter.info,'FunctionTolerance',1e-12, ...
            'StepTolerance',1e-10,'MaxIterations',500, ...
            'MaxFunctionEvaluations',5000,'ScaleProblem','jacobian');

        [x,resnorm_opt,residual_opt,exitflag,output,~,jacobian] = ...
            lsqnonlin(@(x) fcn_fitMultiModal(x,iparam),x0,lb,ub,options);
    case 'internal'
        % FMINSEARCHBND
        options = optimset('Display',parameter.info, ...
            'MaxFunEvals',10000,'MaxIter',2000,'TolFun',1e-12,'TolX',1e-10);

        [x,~,exitflag,output] = ...
            fminsearchbnd(@(x) fcn_fitMultiModal(x,iparam),x0,lb,ub,options);

        % Calculate numerical Jacobian of the residual vector.
        % therefore we need to switch the 'solver' to get the correct
        % output of 'fcn_fitMultiModal'
        iparam.solver = 'optimTB';
        jacobian = estimateJacobian(@(x) fcn_fitMultiModal(x,iparam),x);
        residual_opt = fcn_fitMultiModal(x,iparam);
        % Make sure resnorm has exactly the same definition as for
        % LSQNONLIN.
        resnorm_opt = sum(residual_opt.^2);
end

%% assemble final multimodal RTD
Tdist = zeros(size(T1T2me));
for i = 1:nModes
    mu = exp(x(3*i-2));
    sig = x(3*i-1);
    amp = x(3*i);

    % Gaussian distribution in log(T) space
    tmp = 1./(sig*sqrt(2*pi)) .* ...
        exp(-((log(T1T2me)-log(mu))./(sqrt(2)*sig)).^2);

    stmp = sum(tmp);
    if ~isfinite(stmp) || stmp <= 0
        error('Invalid RTD generated for mode %d.',i);
    end

    % discrete normalization on logarithmically equidistant T classes
    tmp = tmp ./ stmp;
    % scale to modal amplitude
    tmp = tmp .* amp;
    % add mode to total RTD
    Tdist = Tdist + tmp;
end
f = Tdist;

%% physical fitted signal
fit_t = t;
fit_s = K*f;

%% fit errors in physical signal units
if hasWeights
    out = getFitErrors(signal,fit_s,parameter.noise,parameter.W);
else
    out = getFitErrors(signal,fit_s,parameter.noise);
end

%% confidence intervals in optimization parameter space
% x consists of:
%  log(T), sigma, E
% Therefore the CI belonging to x(3*i-2) is a CI in log(T), NOT in the
% physical relaxation-time unit.
try
    ci_x = getConfInterval(resnorm_opt,jacobian,0.05);
catch
    ci_x = NaN(size(x));
end
ci_x = ci_x(:);

%% extract modal parameters
T = exp(x(1:3:end));
S = x(2:3:end);
E = x(3:3:end);

% CI half-widths in optimization coordinates
ciT_log = ci_x(1:3:end);
ciS     = ci_x(2:3:end);
ciE     = ci_x(3:3:end);

%% transform log(T) confidence intervals to physical T
%  x_T = log(T)
% If
%  x_T +/- CI_log
% is the confidence interval in optimization space, then the corresponding
% physical bounds are
%  T_lower = exp(x_T - CI_log)
%  T_upper = exp(x_T + CI_log)
% consequently the confidence interval in T is asymmetric.
logT = x(1:3:end);
T_ci_lower = exp(logT - ciT_log);
T_ci_upper = exp(logT + ciT_log);

%% sort modes by increasing relaxation time
[T,idx] = sort(T);

S = S(idx);
E = E(idx);
ciT_log = ciT_log(idx);
ciS = ciS(idx);
ciE = ciE(idx);
T_ci_lower = T_ci_lower(idx);
T_ci_upper = T_ci_upper(idx);

% also retain the complete CI vector in the same mode order.
ci = zeros(size(ci_x));
ci(1:3:end) = ciT_log;
ci(2:3:end) = ciS;
ci(3:3:end) = ciE;

%% initial / equilibrium amplitude E0
switch flag
    case 'T1'
        % Approximation of equilibrium signal.
        K0 = createKernelMatrix(10*time(end),T1T2me,Tb,Td,flag,T1IRfac);
    case 'T2'
        % Signal at t = 0.
        K0 = createKernelMatrix(0,T1T2me,Tb,Td,flag,T1IRfac);
end
E0 = K0*f;

%% norms and inversion statistics
% RTD norm
xn = norm(f,2);
% physical residual
res_phys = fit_s-s;
% residual in inversion metric
if ~isempty(sigma)
    res_inv = res_phys ./ sigma;
else
    res_inv = res_phys ./ scale;
end
rn = norm(res_inv,2);

% degrees of freedom
nData = length(res_inv);
nParam = length(x);
dof = nData-nParam;

% reduced chi-square / normalized residual variance
if dof > 0
    reducedchi2 = sum(res_inv.^2)/dof;
else
    reducedchi2 = NaN;
end

%% output structure
fitdata.fit_t = fit_t;
fitdata.fit_s = fit_s;
fitdata.T1T2me = T1T2me;
fitdata.T1T2f = f;
fitdata.Tlgm = getTLogMean(T1T2me,f);
fitdata.E0 = E0;
fitdata.ciE0 = NaN;
% physical fit-error quantities
fitdata.resnorm  = out.resnorm;
fitdata.residual = out.residual;
fitdata.errornorm = out.errnorm1;
fitdata.rms = out.rms;
fitdata.chi2 = out.chi2;
% inversion-space quantities
fitdata.rn = rn;
fitdata.xn = xn;
fitdata.reducedchi2 = reducedchi2;
% no regularization parameter
fitdata.lambda_out = 0;
% modal parameters
fitdata.T = T;
fitdata.S = S;
fitdata.E = E;
% Confidence intervals
% fitdata.ci:
%  half-widths in the actual optimization coordinates
% fitdata.ciT_log:
%  half-width for log(T)
% fitdata.T_ci_lower / upper:
%  actual physical confidence limits for T
% fitdata.ciS / ciE:
%  symmetric CI half-widths for sigma and amplitude
fitdata.ci = ci;
fitdata.ciT_log = ciT_log;
fitdata.T_ci_lower = T_ci_lower;
fitdata.T_ci_upper = T_ci_upper;
fitdata.ciS = ciS;
fitdata.ciE = ciE;
% optimizer parameters
fitdata.x = x;
fitdata.lb = lb;
fitdata.ub = ub;
fitdata.exitflag = exitflag;
fitdata.output = output;
% optimizer residual information
fitdata.optim_resnorm = resnorm_opt;
fitdata.optim_residual = residual_opt;
fitdata.invtype = 'MUMO';
fitdata.invparams = parameter;

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2022 Thomas Hiller
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