function [fitdata] = fitDataMultiModal(time,signal,parameter,nModes)
%fitDataMultiModal is a control routine that uses either 'lsqnonlin' or
%'fminsearchbnd' to fit NMR data with 'nModes' multi modal relaxation time
%distributions (T1 or T2)
%
% Syntax:
%       fitDataMultiModal(time,signal,flag,parameter,nExp)
%
% InputsR:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       parameter - struct that holds additional settings:
%                   T1T2     : flag between 'T1' or 'T2' inversion
%                   T1IRfac  : either '1' or '2' depending on T1 method
%                   Tb       : bulk relaxation time
%                   Td       : diffusion relaxation time
%                   Tint     : relaxation times [log10(tmin) log10(tmax) Ndec]
%                   noise    : noise level needed for 'discrep' discrepancy
%                              principle
%                   optim    : 'on' or 'off' (Optimization Toolbox)
%                   W        : error weighting matrix (optional)
%       nModes - No. of free distributions
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
%                   ci      : confidence interval
%                   T       : relaxation times per mode
%                   S       : width per mode
%                   E       : amplitude per mode;
%                   x       : all parameters combined
%                   lb      : lower bounds
%                   ub      : upper bounds
%                   output  : output struct (output from 'lsqnonlin' or
%                             'fminsearchbnd')
%
% Example:
%       [fitdata] = fitDataMultiModal(t,s,parameter,2)
%
% Other m-files required:
%       createKernelMatrix
%       estimateJacobian
%       fcn_fitMultiModal
%       fitDataFree
%       fminsearchbnd
%       getFitErrors
%       getFitFreeJacobian
%       getConfInterval
%       lsqnonlin (Optimization Toolbox)
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

%------------- BEGIN CODE --------------

% make column vector
t = time(:);
s = signal(:);

% error weights after gating
if isfield(parameter,'W')
    e = diag(parameter.W);
    iparam.e = sqrt(e);
end

% get the input parameters
% T1/T2 switch
flag = parameter.T1T2;
% T1 Sat/Inv Recovery factor
T1IRfac = parameter.T1IRfac;
% bulk relaxation time
Tb = parameter.Tb;
% diffusion relaxation time
Td = parameter.Td;
% smallest value in RTD (log10 value)
tstart = parameter.Tint(1);
% largest value in RTD (log10 value)
tend = parameter.Tint(2);
% N per decade in RTD
N = parameter.Tint(3);

% get boundary values for mu, sigma and amp by first applying a free
% exponential fit
param0.T1IRfac = T1IRfac;
param0.noise = parameter.noise;
param0.optim = parameter.optim;
if isfield(parameter,'W')
    param0.W = parameter.W;
end
% free exponential fit to get some reasonable start values
invstd0 = fitDataFree(t,s,flag,param0,nModes);

% start values for E and T
x0 = zeros(1,3*nModes);
lb = zeros(1,3*nModes);
ub = zeros(1,3*nModes);
for i = 1:nModes
    % initial values for T, sigma and E
    x0(3*i-2) = log(invstd0.x(2*i));
    x0(3*i-1) = 1;
    x0(3*i) = invstd0.x(2*i-1);
    
    % lower bounds for T, sigma and E
    lb(3*i-2) = log(1e-6);%log(invstd0.x(2*i)*0.8);%log(invstd0.x(2*i) - 10*invstd0.ci(2*i));
    lb(3*i-1) = 0.01;
    lb(3*i) = invstd0.x(2*i-1)*0.8;%invstd0.x(2*i-1) - 10*invstd0.ci(2*i-1);
    
    % upper bounds for T, sigma and E
    ub(3*i-2) = log(10);%log(invstd0.x(2*i) + 50*invstd0.ci(2*i));
    ub(3*i-1) = 3.5;
    ub(3*i) = max(invstd0.E0)*1.1;%invstd0.x(2*i-1) + 50*invstd0.ci(2*i-1);
end

% switch off output if no option is given via 'parameter'
if ~isfield(parameter,'info')
    parameter.info = 'off';
end

% create the relaxation time vector
T1T2me = logspace(tstart,tend,(tend-tstart)*N);

% just needed for debugging the Optimization Toolbox availability
% parameter.optim = 'off';

switch parameter.optim
    case 'on'
        % solver options
        options = optimoptions('lsqnonlin');
        options.Algorithm = 'levenberg-marquardt';
        options.Display = parameter.info;
        options.OptimalityTolerance = 1e-12;
        options.StepTolerance = 1e-12;
        
        iparam.optim = parameter.optim;
        iparam.flag = flag;
        iparam.T1IRfac = T1IRfac;
        iparam.nModes = nModes;
        iparam.t = t;
        iparam.s = s;
        iparam.T = T1T2me;
        iparam.Tb = Tb;
        iparam.Td = Td;
        [x,~,~,~,output,~,jacobian] = lsqnonlin(@(x)fcn_fitMultiModal(x,iparam),...
            x0,lb,ub,options);
        
    case 'off'
        % solver options
        options = optimset('Display',parameter.info,'MaxFunEvals',10^6,...
            'MaxIter',5000,'TolFun',1e-12,'TolX',1e-12);
        
        iparam.optim = parameter.optim;
        iparam.flag = flag;
        iparam.T1IRfac = T1IRfac;
        iparam.nModes = nModes;
        iparam.t = t;
        iparam.s = s;
        iparam.T = T1T2me;
        iparam.Tb = Tb;
        iparam.Td = Td;
        [x,~,~,output] = fminsearchbnd(@(x) fcn_fitMultiModal(x,iparam),...
            x0,lb,ub,options);
        
        % get Jacobian
        % therefore we need to switch the 'optim' on to get the correct
        % output of 'fcn_fitMultiModal'
        iparam.optim = 'on';
        jacobian = estimateJacobian(@(x)fcn_fitMultiModal(x,iparam),x);
end

% assemble the final RTD
Tdist = 0;
for i = 1:length(x)/3
    mu = exp(x(3*i-2)); % T
    sigma = x(3*i-1); % S
    amp = x(3*i); % E
    
    tmp = 1./( sigma*sqrt(2*pi)).*exp(-((log(T1T2me) - log(mu))/ sqrt(2)/sigma).^2);
    
    % scale to amplitude
    tmp = (tmp/sum(tmp)) * amp;
    % add the tmp per mu to Tdist
    Tdist = Tdist + tmp;
end
f = Tdist;
% the fitted signal
K = createKernelMatrix(t,T1T2me,Tb,Td,flag,1);
si = K*f';

% get the fit
fit_t = t;
fit_s = si;

% get residuals and error measures
if isfield(parameter,'W')
    % when signal gating was used the error estimates need to be adjusted
    out = getFitErrors(signal,fit_s,parameter.noise,parameter.W);
else
    out = getFitErrors(signal,fit_s,parameter.noise);
end

% confidence interval
ci = getConfInterval(out.resnorm,jacobian,0.05);

% sort the relaxation times in ascending order and adjust the confidence
% interval accordingly
T = exp(x(1:3:end));
S = x(2:3:end);
E = x(3:3:end);
[T,idx] = sort(T);
S  = S(idx);
E  = E(idx);
ciT = ci(1:3:end);
ciS = ci(2:3:end);
ciE = ci(3:3:end);
ciT = ciT(idx);
ciS = ciS(idx);
ciE = ciE(idx);
ci(1:3:end) = ciT;
ci(2:3:end) = ciS;
ci(3:3:end) = ciE;

% get "initial" value E0
switch flag
    case 'T1'
        K0 = createKernelMatrix(10*time(end),T1T2me,Tb,Td,flag,T1IRfac);
    case 'T2'
        K0 = createKernelMatrix(0,T1T2me,Tb,Td,flag,T1IRfac);
end
E0 = K0*f';

% output struct
fitdata.fit_t = fit_t;
fitdata.fit_s = fit_s;
fitdata.T1T2me = T1T2me(:);
fitdata.T1T2f = f(:);
fitdata.Tlgm = getTLogMean(T1T2me,f);
fitdata.E0 = E0;
fitdata.ciE0 = NaN;
fitdata.resnorm = out.resnorm;
fitdata.residual = out.residual;
fitdata.errornorm = out.errnorm1;
fitdata.lambda_out = 0;
fitdata.rms = out.rms;
fitdata.chi2 = out.chi2;
fitdata.ci = ci;
fitdata.T = T;
fitdata.S = S;
fitdata.E = E;
fitdata.x = x;
fitdata.lb = lb;
fitdata.ub = ub;
fitdata.output = output;

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