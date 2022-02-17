function geom = getGeometryParameter(geom)
%getGeometryParameter calculates geometric parameters for the three possible
%pore shapes: 'cyl', 'ang' and 'poly'. For the types 'ang' & 'poly' the
%'radius' is used to calculate an equivalent area and subsequently,
%according to the given 'angles' ('ang') or number of polygon sides 'polyN'
%('poly'), the side lengths and other parameters are calculated.
%
% Syntax:
%       getGeometryParameter(geom)
%
% Inputs:
%       geom - struct with fields:
%           type   : 'cyl','ang' or,'poly'
%           radius : radius
%           angles : angles (only needed for 'ang')
%
% Outputs:
%       geom - struct with fields:
%           A0       : area
%           P0       : perimeter
%           a        : NMR geometry parameter
%           side(s)  : (only 'ang' and 'poly')
%           inRadius : inscribing circle radius (only 'ang' and 'poly')
%           AngulFac : angularity factor (only 'ang' and 'poly')
%           ShapeFac : shape factor (only 'ang' and 'poly')
%           Points   : coordinates of corner points (only 'ang' and 'poly')
%
% Example:
%       geom = getGeometryParameter(geom)
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

switch geom.type    
    case 'cyl'
        % cross sectional area A0 and perimeter P0
        geom.A0 = geom.radius.^2*pi;
        geom.P0 = 2.*geom.radius.*pi;
        geom.a = 2;
        
    case 'ang'
        % cross sectional equivalent area A0
        geom.A0 = geom.radius.^2*pi;
        
        % check if the sum of angles is really 180°
        if sum(geom.angles) == 180
            
            % the three inner angles
            alpha = geom.angles(1);
            beta  = geom.angles(2);
            gamma = geom.angles(3);
            
            % the triangle sides
            a = sqrt((2*geom.A0*sind(alpha))/(sind(beta) *sind(gamma)));
            b = sqrt((2*geom.A0*sind(beta)) /(sind(alpha)*sind(gamma)));
            c = sqrt((2*geom.A0*sind(gamma))/(sind(alpha)*sind(beta)));
            geom.sides = [a(:) b(:) c(:)];
            
            % perimeter P0
            geom.P0 = sum(geom.sides,2);
            
            % NMR geometry parameter a
            geom.a = (geom.P0(1)/geom.A0(1)) * geom.radius(1);
            
            % inscribing circle radius
            geom.inRadius = (2.*geom.A0) ./ (geom.P0);
            
            % the angularity factor for all angles
            geom.AngulFac = getAngularityFactor(geom.angles);
            
            % triangle shape factor
            geom.ShapeFac = getShapeFactor(geom.A0(1),geom.P0(1));
            
            % for plotting get the coordinates of the three corner points
            geom.Points = getPointCoordinates(geom);
            
        else
            errordlg('Check angles! sum(angles)~=180°','getGeomParams: Error!');
        end
        
    case 'poly'        
        % cross sectional equivalent area A0
        geom.A0 = geom.radius.^2*pi;
        
        % only for polygons with 3 to 12 sides
        if geom.polyN >= 3 && geom.polyN <= 12            
            % inscribing circle radius / apothem
            geom.inRadius = sqrt((geom.A0./geom.polyN) ./ tand(180./geom.polyN));
            
            % side length
            geom.side = (2.*geom.A0)./(geom.polyN.*geom.inRadius);
            
            % perimeter P0
            geom.P0 = geom.side.*geom.polyN;
            
            % NMR geometry parameter a
            geom.a = (geom.P0(1)/geom.A0(1)) * geom.radius(1);
            
            % the interior angles
            geom.angles = (((geom.polyN-2)/geom.polyN) * 180) .* ones(1,geom.polyN);
            
            % the angularity factor for all angles
            geom.AngulFac = getAngularityFactor(geom.angles);
            
            % polygon shape factor
            geom.ShapeFac = getShapeFactor(geom.A0,geom.P0);
            
            % for plotting get the coordinates of the three corner points
            geom.Points = getPointCoordinates(geom);
        else
            errordlg('Check polygon No. polyN! polyN~=[3 12]','getGeomParams: Error!');
        end
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