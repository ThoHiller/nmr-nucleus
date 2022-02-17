function [F,J] = fcn_fitFreeT2w(x,iparam)
%fcn_fitFreeT2w is the objective function for T2 mono- and free exponential
%fitting that is minimized with 'lsqnonlin'
%
% Syntax:
%       fcn_fitFreeT2(x,iparam)
%
% Inputs:
%       x - parameter vector
%           x(2*i-1) = E (amplitude)
%           x(2*i) = T (relaxation time)
%       iparam - struct that holds additional settings:
%                t : time vector
%                s : signal vector
%                e : noise vector / error weights (optional)
%
% Outputs:
%       F - residual
%       J - Jacobian (optional)
%
% Example:
%       [F,J] = fcn_fitFreeT2(x,params)
%
% Other m-files required:
%       getFitFreeJacobian
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
t = iparam.t;
s = iparam.s;

SI = 0;
for i = 1:length(x)/2
	tmp = x(2*i-1)*exp(-t./x(2*i));
	SI = SI + tmp;
end

% get error weights if available
if isfield(iparam,'e')
    e = iparam.e;
else
    e = ones(size(s));
end

% scale the residual
F = e .* (SI - s);

J = 0;
if nargout > 1
    J = e .* getFitFreeJacobian(x,t,'T2',1);
end

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