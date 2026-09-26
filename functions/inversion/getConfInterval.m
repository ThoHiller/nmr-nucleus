function CI = getConfInterval(resnorm,J,alpha)
%getConfInterval Calculates approximate confidence intervals from the
%Jacobian of a nonlinear least-squares problem.
%NOTE: for an increased number of free relaxation times 'T' and corresponding
%amplitudes 'Ex' the individual CI for the 'Ex' will get larger (e.g. worse).
%With more free parameters the fit is much more 'sensitive' and therefore
%the combined sum of CI('Ex') for 'E0' can become quite large.
%
% Syntax:
%       CI = getConfInterval(resnorm,J,alpha)
%
% Inputs:
%       resnorm - sum of squared residuals
%       J       - Jacobian of the same residual vector
%       alpha   - significance level
%                 alpha = 0.05 -> 95% confidence interval
%
% Outputs:
%       CI      - half-width of confidence interval for each parameter
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
% Notes:
% The calculation is based on a local linearization of the model around
% the optimum.
%
% If weighted residuals
%       r_k = (model_k-data_k)/sigma_k
% are used, both resnorm and J must refer to these weighted residuals.
%
% See also: "Parameter Estimation and Inverse Problems", 2nd Ed.
%           by Aster et. al p.32 ff
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% dimensions and degrees of freedom
[nData,nParam] = size(J);
deg_free = nData - nParam;
if deg_free <= 0
    warning('Cannot calculate confidence intervals: non-positive degrees of freedom.');
    CI = NaN(nParam,1);
    return
end

%% residual variance estimate
% resnorm = sum(r.^2)
s2 = resnorm / deg_free;

%% covariance matrix
% Use SVD instead of explicitly calculating inv(J''*J).
[~,S,V] = svd(J,'econ');
sv = diag(S);

% numerical rank tolerance
tol = max(size(J)) * eps(max(sv));
valid = sv > tol;
if sum(valid) < nParam
    warning(['Jacobian is rank deficient. Confidence intervals may ', ...
             'not be uniquely defined.']);
end

% covariance from pseudo-inverse of J''*J
Vv = V(:,valid);
sv = sv(valid);

covariance = s2 * Vv * diag(1./sv.^2) * Vv';

%% parameter standard errors
var_param = diag(covariance);

% protect against tiny negative values due to round-off
var_param(var_param < 0) = 0;

SE = sqrt(var_param);

%% Student-t factor for two-sided confidence interval
% alpha 0.025 -> 97.5%
% alpha 0.05  -> 95.0%
% if yes use 'tinv' directly
% if not use my own function to calculate the Student's t inverse CDF
vv = ver;
StatBox = false;
for k = 1:length(vv)
    if contains(vv(k).Name,'Statistics')
        StatBox = true;
        break
    end
end
if StatBox
    stud_fac = tinv(1-alpha/2,deg_free);
else
    if deg_free <= 1000
        stud_fac = getStudentInvCDF(1-alpha/2,deg_free);
    else
        % normal approximation for large DOF
        stud_fac = 1.96;
    end
end

%% confidence interval half-width
CI = SE * stud_fac;

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