function CI = getConfInterval(resnorm,J,alpha)
%getConfInterval calculates the confidence interval for the inversion
%result from 'fitDataFree'
%NOTE: for an increased number of free relaxation times 'T' and corresponding
%amplitudes 'Ex' the individual CI for the 'Ex' will get larger (e.g. worse).
%With more free parameters the fit is much more 'sensitive' and therefore
%the combined sum of CI('Ex') for 'E0' can become quite large.
%
% Syntax:
%       getConfInterval(resnorm,Jac,alpha)
%
% Inputs:
%       resnorm - residual norm (output from lsqcurvefit)
%       J - Jacobian matrix (output from lsqcurvefit)
%       alpha - alpha value for student distribution
%
% Outputs:
%       CI - confidence interval for the individual fit parameters
%
% Example:
%       CI = getConfInterval(resnorm,J,alpha)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: "Parameter Estimation and Inverse Problems", 2nd Ed.
%           by Aster et. al p.32 ff
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% degrees of freedom DOF
[i,j]    = size(J);
deg_free = i-j;

%% mean squared error MSE:
mse = sqrt(resnorm/deg_free);

%% covariance matrix:
cov = mse^2*inv(J'*J); %#ok<*MINV>

%% diagonal elements of covariance matrix
diag_cov = diag(full(cov));

%% check if 'Statistical Toolbox' is installed
vv = ver;
StatBox = 0;
for i = 1:size(vv,2)
    if strfind(vv(i).Name,'Statistics')
        StatBox = 1;
        break;
    end
end

%% correction factor for the error estimation of the parameter
% alpha 0.025 -> 97.5%
% alpha 0.05  -> 95.0%
% if yes use 'tinv' directly
% if not use my own function to calculate the Student's t inverse CDF
if StatBox == 1
    stud_fac = tinv(1-alpha,deg_free);
else
    if deg_free <= 1000
        stud_fac = getStudentInvCDF(1-alpha,deg_free);
    else
        stud_fac = NaN;
    end
end

%% confidence intervals:
CI = sqrt(diag_cov)*stud_fac;

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