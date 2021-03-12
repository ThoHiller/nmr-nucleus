function An = getAreaFactor(n)
%getAreaFactor calculates the area factor An for polygon according to
%An = n/4*cot(pi/4);
%
% Syntax:
%       getAreaFactor(n)
%
% Inputs:
%       n - number of corners
%
% Outputs:
%       An - area factor
%
% Example:
%       An = getAreaFactor(n)
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
%   Tuller & Or, 2001, WRR, Vol. 37(5), 1257-1276
% Author: Stepahn Costabel
% email: stephan.costabel[at]bgr.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% effectively this is simply the area of a regular polygon
% of side length a=1
An = n/4*cot(pi/n);

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Stephan Costabel
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