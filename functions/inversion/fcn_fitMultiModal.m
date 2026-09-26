function F = fcn_fitMultiModal(x,iparam)
%fcn_fitMultiModal is the objective function for multimodal RTD fitting
%with 'lsqnonlin'.
%
% Syntax:
%       fcn_fitMultiModal(x,iparam)
%
% Inputs:
%       x - parameter vector
%           x(3*i-2) = mu (relaxation time)
%           x(3*i-1) = sigma (width of distribution)
%           x(3*i) = amp (relative amplitude)
%       iparam - struct that holds additional settings:
%                t : time vector
%                s : signal vector
%                T : relaxation times
%                K : relaxivity kernel
%            sigma : standard error
%
% Outputs:
%       For lsqnonlin:
%       F = weighted/scaled residual vector
%
%       For fminsearchbnd:
%       F = sum of squared weighted/scaled residuals
%
% Example:
%       F = fcn_fitMultiModal(x,params)
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
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% input parameters
nModes = iparam.nModes;
s = iparam.s;
T = iparam.T;
K = iparam.K;

% make sure orientation is consistent
s = s(:);
T = T(:);

%% assemble multimodal RTD
Tdist = zeros(size(T));
for i = 1:nModes
    mu = exp(x(3*i-2));
    sigma = x(3*i-1);
    amp = x(3*i);

    % Gaussian distribution in log(T) space
    tmp = 1./(sigma*sqrt(2*pi)) .* ...
        exp(-((log(T)-log(mu))./(sqrt(2)*sigma)).^2);

    % normalize discrete distribution and scale to amplitude
    tmp = tmp ./ sum(tmp);
    tmp = tmp .* amp;
    % add mode to total RTD
    Tdist = Tdist + tmp;
end

%% forward model -- always physical/unweighted
si = K*Tdist;

% physical residual
res = si - s;

%% weighting / scaling for inversion only
if ~isempty(iparam.sigma)
    % sigma contains standard error of each gated data point
    res = res./iparam.sigma;
else
    % constant data-derived scaling
    res = res./iparam.scale;
end

%% solver-dependent output
switch iparam.solver
    case 'optimTB' % lsqnonlin
    F = res;
    case 'internal' % fminsearchbnd
    F = sum(res.^2);
end

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