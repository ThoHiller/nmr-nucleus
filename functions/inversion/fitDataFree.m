function [fitdata] = fitDataFree(time,signal,flag,parameter,nExp)
%fitDataFree is a control routine that uses 'lsqcurvefit' to fit NMR data
%with 'nExp' free relaxation times (T1 or T2)
%
% Syntax:
%       fitDataFree(time,signal,flag,parameter,nExp)
%
% InputsR:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       flag - either 'T1' or 'T2'
%       parameter - struct that hold additional settings:
%                   info : command line output switch
%                   noise: NMR data noise
%                   W    : error weighting matrix (optional)
%                   optim: switch for Optimization Toolbox
%       nExp - No. of free exponential(s)
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%                   E0      : initial amplitude at t=0 (T2) or t=max (T1)
%                   T1 / T2 : relaxation time(s)
%                   fit_t   : time vector for plotting
%                   fit_s   : signal vector for plotting
%                   resnorm : residual norm
%                   residual: vector of residuals
%                   errnorm : error norm
%                   rms     : RMS error
%                   chi2    : chi square error
%                   ci      : confidence interval
%                   output  : output struct (output from lsqcurvefit &
%                             lsqnonlin)
%
% Example:
%       [fitdata] = fitDataFree(t,s,'T2',parameter,2)
%
% Other m-files required:
%       lsqcurvefit (Optimization Toolbox)
%       lsqnonlin (Optimization Toolbox)
%       getFitErrors
%       getFitFreeJacobian
%       fcn_fitFreeT1
%       fcn_fitFreeT1_fmin
%       fcn_fitFreeT2
%       fcn_fitFreeT2w
%       fcn_fitFreeT2_fmin
%       fminsearchbnd
%       getConfInterval
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

% T1 saturation/inversion recovery factor
IRfac = parameter.T1IRfac;

% error weights after gating
if isfield(parameter,'W')
    e = diag(parameter.W);
    iparam.e = sqrt(e);
else
    e = ones(size(s));
end

% switch off output if no option is given via 'parameter'
if ~isfield(parameter,'info')
    parameter.info = 'off';
end

% check if any relaxation time is fixed
if any(parameter.Tfixed_bool)

    % start values for E and T
    x0 = zeros(1,2*nExp);
    for i = 1:nExp
        x0(2*i-1) = i*max(signal)/nExp;
        if parameter.Tfixed_bool(i)
            x0(2*i) = parameter.Tfixed_val(i);
        else
            x0(2*i) = i*max(t)/nExp;
        end
    end

    % bounds for E and T
    lb = zeros(1,2*nExp);
    ub = zeros(1,2*nExp);
    for i = 1:nExp
        lb(2*i-1) = 0;
        ub(2*i-1) = 2*i*max(signal);
        if parameter.Tfixed_bool(i)
            lb(2*i) = parameter.Tfixed_val(i);
            ub(2*i) = parameter.Tfixed_val(i);
        else
            lb(2*i) = 0;        
            ub(2*i) = 2*i*max(t);
        end        
    end

else % if not proceed with the standard version

    % start values for E and T
    x0 = zeros(1,2*nExp);
    for i = 1:nExp
        x0(2*i-1) = i*max(signal)/nExp;
        x0(2*i) = i*max(t)/nExp;
    end

    % bounds for E and T
    lb = zeros(1,2*nExp);
    ub = zeros(1,2*nExp);
    for i = 1:nExp
        lb(2*i-1) = 0;
        ub(2*i-1) = 2*i*max(signal);
        lb(2*i) = 0;        
        ub(2*i) = 2*i*max(t);
    end
end

switch parameter.optim
    case 'on'
        switch flag
            case 'T1'
                % solver options
                options = optimoptions('lsqcurvefit');
                options.Display = parameter.info;
%                 options.OptimalityTolerance = 1e-18;
%                 options.StepTolerance = 1e-18;
%                 options.MaxIterations = 1e3;
                [x,~,~,~,output,~,jacobian] = lsqcurvefit(@(x,t)fcn_fitFreeT1(x,t,IRfac),...
                    x0,t,s,lb,ub,options);
            case 'T2'
                % solver options
                options = optimoptions('lsqnonlin');
                options.Display = parameter.info;
%                 options.OptimalityTolerance = 1e-18;
%                 options.StepTolerance = 1e-18;
%                 options.MaxIterations = 1e3;
                
                iparam.t = t;
                iparam.s = s;
                [x,~,~,~,output,~,jacobian] = lsqnonlin(@(x)fcn_fitFreeT2w(x,iparam),...
                    x0,lb,ub,options);
%                 [x,~,~,~,output,~,jacobian] = lsqcurvefit(@fcn_fitFreeT2,...
%                     x0,t,s,zeros(size(x0)),[],options);
        end
    case 'off'
        % solver options
        options = optimset('Display',parameter.info,'MaxFunEvals',10^6,...
            'MaxIter',5000,'TolFun',1e-12,'TolX',1e-12);        
        switch flag
            case 'T1'
                % set all start values to 0 (if something is not working as expected, comment it and try again)
                x0 = zeros(size(lb));
                [x,~,~,output] = fminsearchbnd(@(x) fcn_fitFreeT1_fmin(x,t,s,IRfac),...
                    x0,lb,ub,options);
            case 'T2'
                [x,~,~,output] = fminsearchbnd(@(x) fcn_fitFreeT2_fmin(x,t,s,e),...
                    x0,lb,ub,options);
        end
end

% get the fit
fit_t = t;
switch flag
    case 'T1'
        fit_s = fcn_fitFreeT1(x,fit_t,IRfac);
    case 'T2'
        fit_s = fcn_fitFreeT2(x,fit_t);
end

% get residuals and error measures
if isfield(parameter,'W')
    % when signal gating was used the error estimates need to be adjusted
    out = getFitErrors(signal,fit_s,parameter.noise,parameter.W);
else
    out = getFitErrors(signal,fit_s,parameter.noise);
end

% get Jacobian
switch parameter.optim
    case 'on'
        % nothing to do because the Optim. Toolbox gives the jacobian as
        % output
    case 'off'        
        jacobian = getFitFreeJacobian(x,t,flag,IRfac);
end

% confidence interval
ci = getConfInterval(out.resnorm,jacobian,0.05);

% sort the relaxation times in ascending order
E0 = x(1:2:end);
T = x(2:2:end);
if any(parameter.Tfixed_bool)
    idx = 1:1:nExp;
else
    [T,idx] = sort(T);
end
E0  = E0(idx);
ciT = ci(2:2:end);
ciE = ci(1:2:end);
ciT = ciT(idx);
ciE = ciE(idx);
ci(2:2:end) = ciT;
ci(1:2:end) = ciE;

% output struct
fitdata.E0 = E0;
switch flag
    case 'T1'
        fitdata.T1 = T;
    case 'T2'
        fitdata.T2 = T;
end
fitdata.T = T;
fitdata.fit_t = fit_t;
fitdata.fit_s = fit_s;
fitdata.resnorm = out.resnorm;
fitdata.residual = out.residual;
fitdata.errornorm = out.errnorm1;
fitdata.rms = out.rms;
fitdata.chi2 = out.chi2;
fitdata.ci = ci;
fitdata.x = x;
fitdata.output = output;

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