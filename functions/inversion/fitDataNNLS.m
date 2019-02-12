function fitdata = fitDataNNLS(time,signal,parameter)
%fitDataNNLS is a control routine that uses the 'Regularization Toolbox'
%from P. Hansen and 'lsqlin' to fit NMR data multi-exponentially
%
% Syntax:
%       fitDataNNLS(time,signal,parameter)
%
% Inputs:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       parameter - struct that holds additional settings:
%                   T1T2     : flag between 'T1' or 'T2' inversion
%                   T1IRfac  : either '1' or '2' depending on T1 method
%                   Tb       : bulk relaxation time
%                   Tint     : relaxation times [log10(tmin) log10(tmax) Ndec]
%                   regMethod: 'manual', 'gcv_tikh', 'gcv_trunc',
%                              'gcv_damp', 'discrep'
%                   Lorder   : smoothness constraint (derivative matrix)
%                   lambda   : regularization parameter (for 'manual')
%                   noise    : noise level needed for 'discrep' discrepancy
%                              principle
%                   W        : error weighting matrix (optional)
%                   optim    : switch for Optimization Toolbox
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%                   fit_t      : time vector for plotting
%                   fit_s      : signal vector for plotting
%                   T1T2me     : relaxation time values
%                   T1T2f      : relaxation time spectrum
%                   Tlgm       : T logmean
%                   E0         : initial amplitude at t=0 (T2) or t=inf (T1)
%                   resnorm    : residual norm
%                   residual   : vector of residuals
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
%       [fitdata] = fitDataNNLS(t,s,parameter)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% make input column vectors
time = time(:);
signal = signal(:);

% get the maximum value of the signal to scale the signal for the inversion
% to 1
maxS = max(signal);

% temporary variables
t = time;
g = signal./maxS;

% get the input parameters
flag = parameter.T1T2;           % T1/T2 switch
T1IRfac = parameter.T1IRfac;     % T1 Sat/Inv Recovery factor
Tb = parameter.Tb;               % bulk relaxation time
tstart = parameter.Tint(1);      % log10 value
tend = parameter.Tint(2);        % log10 value
N = parameter.Tint(3);           % N per decade
regMethod = parameter.regMethod; % regularization method
order = parameter.Lorder;        % smoothness constraint
lambda = parameter.lambda;       % regularization parameter
noise = parameter.noise;         % noise

% create the relaxation time vector
T1T2me = logspace(tstart,tend,(tend-tstart)*N);

% create the Kernel matrix for inversion
K = createKernelMatrix(t,T1T2me,Tb,flag,T1IRfac);

if strcmp(parameter.optim,'on')
    % initial T2 amplitudes
    f0 = zeros(size(T1T2me));
    f0_lb = f0;
    f0_ub = 1.5*max(g)*ones(size(T1T2me));
end

% derivative matrix
L = get_l(length(T1T2me),order);

% scale the noise and error matrix W accordingly
noise = noise./maxS;
if isfield(parameter,'W')
    e = diag(parameter.W);
    e = e./maxS;
    W = diag(e);
end

% apply error weight matrix
if isfield(parameter,'W')
    g = W*g;
    K = W*K;
end

% extend K and apply regularization
% 'manual' | 'gcv_tikh' | 'gcv_trunc' | 'gcv_damp' | 'discrep'
[KK,lambda_out] = applyRegularization(K,g,L,lambda,regMethod,order,noise);

% extend g accordingly
gg = g;
gg(length(g)+1:length(g)+size(L,1),1) = 0;

switch parameter.optim
    case 'on'
        options = optimset('Display',parameter.info,'TolFun',1e-12,...
            'TolX',1e-12,'Jacobian','off',...
            'LargeScale','on','MaxFunEvals',1000000,...
            'MaxIter',200);
        [f,~,~,~,~,~] = lsqlin(KK,gg,[],[],[],[],...
            f0_lb,f0_ub,f0,options);
    case 'off'
        options = optimset('Display',parameter.info,'TolX',1e-12);
        [f,~,~,~,~,~] = lsqnonneg(KK,gg,options);
end

% rescale f so that the sum(f)= unscaled E0
f = (f.*maxS);

% the 'inverted' signal
gg_fit = KK*f;
% cut off the end which was needed for regularization
s_fit = gg_fit(1:length(t),1);

% get residuals and error measures
if isfield(parameter,'W')
    % normalize the fit because the signal was error weighted for the
    % inversion
    e = diag(W);
    einv = 1./e;
    Winv = diag(einv);
    s_fit = Winv * s_fit;
    
    % because signal and s_fit are unscaled the initial values for noise
    % and W are used to get the error estimates
    out = getFitErrors(signal,s_fit,parameter.noise,parameter.W);
else
    out = getFitErrors(signal,s_fit,parameter.noise);
end

% L-curve parameter
% model norm |L*x|_2
xn = norm(L*f,2);
% residual norm |A*x-b|_2
rn = norm(out.residual,2);

% get "initial" value E0
if strcmp(flag,'T1')
    t2 = 10*time(end);
    K2 = createKernelMatrix(t2,T1T2me,Tb,flag,T1IRfac);
elseif strcmp(flag,'T2')
    t2 = 0;
    K2 = createKernelMatrix(t2,T1T2me,Tb,flag,T1IRfac);
end
E0 = K2*f;

% output struct
fitdata.fit_t = time(:);
fitdata.fit_s = s_fit(:);
fitdata.T1T2me = T1T2me(:);
fitdata.T1T2f = f(:);
fitdata.Tlgm = getTLogMean(T1T2me,f);
fitdata.E0 = E0;
fitdata.resnorm = out.resnorm;
fitdata.residual = out.residual;
fitdata.chi2 = out.chi2;
fitdata.rms = out.rms;
fitdata.lambda_out = lambda_out;
fitdata.KK = KK;
fitdata.L = L;
fitdata.xn = xn;
fitdata.rn = rn;

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