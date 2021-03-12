function RaRaEps = getRaRaEps(gamma)
%getRaRaEps calculates the flow resistance parameter acc. to Tuller&Or (2001)
%epsilon (Tuller&Or, 2001) = beta (Ransohoff&Radke, 1988)
%NOTE: the angle gamma should be in the interval 10° to 150° to give
%reliable estimates
%
% Syntax:
%       RaRaEps = getRaRaEps(gamma)
%
% Inputs:
%       gamma - angle [deg]
%
% Outputs:
%       RaRaEps - flow resistance
%
% Example:
%       RaRaEps = getRaRaEps(geom.angles(n))
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
%   Ransohoff & Radke, 1988, JColIntSci, Vol. 121(2), 392-401
% Author: Stepahn Costabel
% email: stephan.costabel[at]bgr.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% constants
b = 2.124;
c = -0.00415;
d = 0.00783;

% flow resistance
RaRaEps = exp((b+d*gamma)/(1+c*gamma));

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