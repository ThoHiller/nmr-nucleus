function pdf = getMultivariateGaussian(X,mu,sigma)
%MULTIVARIATEGAUSSIAN Computes the probability density function of the
%multivariate gaussian distribution.%
%
% Syntax:
%       pdf = getMultivariateGaussian(X,mu,sigma)
%
% Inputs:
%       X - n x d -> (x,y,...) vectors
%       mu - 1 x d -> mean values
%       sigma - d x d covariance matrix
%
% Outputs:
%       pdf - probability density function
%
% Example:
%       p = getMultivariateGaussian([-1 0;0 0;1 0],[0 0],[1 0;0 1])
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

% get dimension
d = length(mu);

if (size(sigma, 2) == 1) || (size(sigma, 1) == 1)
    sigma = diag(sigma);
end

% subtract mu to shift everything to (0,0)
X = bsxfun(@minus, X, mu(:)');

% calculate p
pdf = 1 / ( sqrt(det(sigma)*((2*pi)^d)) ) * ...
    exp(-0.5 * sum(bsxfun(@times, X * pinv(sigma), X), 2));

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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