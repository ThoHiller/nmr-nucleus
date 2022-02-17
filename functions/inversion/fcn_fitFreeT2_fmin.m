function SSE = fcn_fitFreeT2_fmin(x,t,s,e)
%fcn_fitFreeT2_fmin is the objective function for T2 mono- and free exponential
%inversion that is minimized with 'fminsearchbnd' (hence the SSE output)
%
% Syntax:
%       fcn_fitFreeT2_fmin(x,t,s)
%
% Inputs:
%       x - parameter vector
%           x(2*i-1) = E (amplitude)
%           x(2*i) = T (relaxation time)
%       t - time vector
%       s - signal vector
%       e - noise vector (after gating; is "1" without gating)
%
% Outputs:
%       SSE - squared sum of errors
%
% Example:
%       ses = fcn_fitFreeT2_fmin(params,t,s)
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

F = 0;
for i = 1:length(x)/2
	tmp = x(2*i-1)*exp(-t./x(2*i));
	F = F + tmp;
end

err = e.*(F - s);
SSE = sum(err.^2);

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