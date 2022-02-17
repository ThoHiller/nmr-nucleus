function J = estimateJacobian(f,x)
%estimateJacobian numerically estimates (in a very simple manner) a
%Jacobian at point x for a given function f
%
% Syntax:
%       estimateJacobian
%
% Inputs:
%       f - function handle
%       x - point on function f
%
% Outputs:
%       J - Jacobian
%
% Example:
%       estimateJacobian(@(x)fcn_fitMultiModal(x,iparam),x);
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
% See also: NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% define increment
delta = 1e-7*sqrt(norm(x));
% evaluate function at point x
y = feval(f,x);
% get dimensions of J
n = length(y);
m = length(x);
% initialize J
J = zeros(n,m);
% loop over paramters
for i = 1:m
    dx = zeros(1,m);
    dx(i) = delta/2;
    % evaluate single parameters at x+dx and x-dx
    % and divide the differenece by the increment
    col = (feval(f,x+dx)-feval(f,x-dx))/delta;
    % save result
    J(:,i) = col;
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