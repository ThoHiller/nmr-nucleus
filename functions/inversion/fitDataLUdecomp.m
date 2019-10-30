function fitdata = fitDataLUdecomp(time,signal,parameter)
%fitDataLUdecomp is a control routine that uses a LU decomposition and the
%Matlab "\"-operator to fit NMR data multi-exponentially
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
%                   lambda_out : regularization parameter lambda determined
%                                by the different options from the 'regu'
%                                toolbox                   
%                   KK         : Kernel matrix
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% NOTE: I harvested this routine partly from the Internet but forgot where
% I found the routines ... so there is no warranty at all

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
flag = parameter.T1T2;       % T1/T2 switch
T1IRfac = parameter.T1IRfac; % T1 Sat/Inv Recovery factor
Tb = parameter.Tb;           % bulk relaxation time
tstart = parameter.Tint(1);  % log10 value
tend = parameter.Tint(2);    % log10 value
N = parameter.Tint(3);       % N per decade
order = parameter.Lorder;    % smoothness constraint
lambda = parameter.lambda;   % regularization parameter
noise = parameter.noise;     % noise 

% create the relaxation time vector
T1T2me = logspace(tstart,tend,(tend-tstart)*N);

% create the Kernel matrix
K = createKernelMatrix(t,T1T2me,Tb,flag,T1IRfac);

% calculate reg matrix H
m  = length(T1T2me);
B = get_l(m,order);
H = B'*B;

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

% automatic regularization
if lambda == -1
    lambda = trace(K'*K)/trace(H);
end

% calculate A = K'*K + lambda*H
A = K'*K + lambda*H;
% calculate y = K'*g
y = K'*g;
% calculate f by LU decomposition
[L,U] = lu(A);
f = U\(L\y);

% now iterate, mapping negative values to zero.
e = 2/max(eig(A));
A = K'*K;  % no regularization now
for i = 1:1000
    f = (f>0).*f; % map neg to zero
    f =(eye(m)-e*A)*f+e*y;
end
f = (f>0).*f; % map neg to zero again

% rescale f so that the sum(f)= unscaled E0
f = (f.*maxS);

% the inverted signal
s_fit = K*f;
s_fit = s_fit(1:length(t),1);

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

% derivative matrix
L = get_l(length(T1T2me),order);
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
fitdata.residual = out.residual;
fitdata.chi2 = out.chi2;
fitdata.rms = out.rms;
fitdata.lambda_out = lambda;
fitdata.KK = A;
fitdata.L = L;
fitdata.xn = xn;
fitdata.rn = rn;

return

%------------- END OF CODE --------------