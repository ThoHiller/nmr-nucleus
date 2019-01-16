function [Acorner, Pcorner] = getCornerSaturation(radius,angles)
%getCornerSaturation calculates the area and active perimeter for all water
%filled corners in a triangle or polygon after
%Tuller et al. 1999, WWR, 35(7), 1949-1964 Appendix B
%
% Syntax:
%       getCornerSaturation(radius,angles)
%
% Inputs:
%       radius - pressure dependent capillary radius
%       angles - all angles in triangle or polygon
%
% Outputs:
%       Acorner - area of the corresponding corner
%       Pcorner - active perimeter of the corresponding corner
%
% Example:
%       [Acorner, Pcorner] = getCornerSaturation(radius,angles)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

Acorner = zeros(size(angles));
Pcorner = zeros(size(angles));
for i = 1: length(angles)
    x1 = radius / tand (angles(i)/2);
    % active perimeter of the ith wedge
    Pcorner(i) = 2 * x1;
    % water filled area of the ith wedge
    Acorner(i) = (radius * x1) - ( (radius^2*pi*(180-angles(i))) / 360 );
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