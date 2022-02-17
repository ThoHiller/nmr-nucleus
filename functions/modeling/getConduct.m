function K = getConduct(geom,constants,varargin)
%getConduct calculates hydraulic conductivity for water-filled
%circular or angular capillaries or meniscus water
%
% Syntax:
%       getConduct(geom,constants,varargin)
%
% Inputs:
%       geom - geometry structure (output from 'getGeometryParameter')
%       constants -  physical constants
%       varargin - only in the case of partial saturation:
%           varargin{1} = radius of the arc menisci
%           varargin{2} = water filled corner area
%
% Outputs:
%       K - hydraulic conductivity [m/s]
%
% Example:
%       Ki = getConduct(geom,constants)
%       Ki = getConduct(geom,constants,r_AM,Aai);
%
% Other m-files required:
%       getAreaFactor
%       getRaRaEps
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also:
%   Tuller & Or, 2001, WRR, Vol. 37(5), 1257-1276
%   Patzek & Silin, 2001, JColIntSci, Vol. 236(2), 295-304
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% lumped physical constants
C = constants.density * constants.gravity / constants.dynvisc;

if nargin == 2 % full ducts:
    switch geom.type
        case 'cyl' % circular cross-section
            K = C * 1/8 * geom.radius^2;
            
        case 'ang' % right angular triangle
            K = C * 3/5 * geom.ShapeFac * geom.A0;
            % strictly speaking, the formula is only correct for
            % equilateral triangle, however, according to Patzek & Silin (2001)
            % a reliable approximation also for a rectangular triangle
            
        case 'poly'  % equilateral triangle & polygons
            if numel(geom.angles) == 3 % equilateral triangle
                K = C * 1/80 * geom.side^2;
            else
                % maybe this is only true for large number of corners
                % (not clear from Tuller & Or,2001)!!!
                % => consider further case separation for square, hexagon, etc.
                K = C * getAreaFactor(numel(geom.angles))*geom.side^2/(8*pi);
            end
    end
else  % meniscus water in the corners of a desaturated angular pore:
    % radius
    r_AM = varargin{1};
    % water filled corner area
    Aa = varargin{2};
    % hydraulic conductivity initialization
    Kn = zeros(size(geom.angles));
    
    % individual K values for each corner:
    for n = 1:numel(geom.angles)
        Kn(n) = C * (r_AM^2/getRaRaEps(geom.angles(n)));
    end
    % bulk K value for entire desaturated pore is calculated by the sum
    % of the individual values weighted by the proportion of the residual
    % meniscus water with respect to pore cross-sectional area
    K = sum(Aa.*Kn)/geom.A0;
end

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