function points = getPointCoordinates(geom)
%getPointCoordinates calculates the coordinates of the N corner points
%depending on the pore shape 'ang' or 'poly'. The routine assumes that the
%center of the cross-sectional shape is at [0,0].
%
% Syntax:
%       getPointCoordinates(geom)
%
% Inputs:
%       geom - geometry structure (output from 'getGeometryParameters')
%
% Outputs:
%       points - list of N point coordinates (2D)
%
% Example:
%       points = getPointCoordinates(geom)
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

%% switch depending on shape
switch geom.type    
    case 'ang'        
        % inscribing circle radius
        r = (2.*geom.A0) ./ (geom.P0);
        % 1. angle
        alpha = geom.angles(1)./2;
        x = r ./ tand(alpha);
        % 1. point
        P1 = [-x(:) -r(:)];
        % 2. point
        P2 = [geom.sides(:,3)-x(:) -r(:)];
        h  = geom.sides(:,2).*sind(geom.angles(1));
        x1 = sqrt(geom.sides(:,2).^2-h.^2);
        % 3. point
        if geom.angles(1)>90
            P3 = [P1(1)-x1 h-r];
        else
            P3 = [P1(1)+x1 h-r];
        end
        
        points = zeros(numel(geom.radius),3,2);
        for i = 1:numel(geom.radius)
            points(i,1,:)  = P1(i,:);
            points(i,2,:)  = P2(i,:);
            points(i,3,:)  = P3(i,:);
        end
        points = squeeze(points);
        
    case 'poly'
        % side length
        a = geom.side;
        % radius of circumcircle
        ro = (a./2).*csc(pi/geom.polyN);
        % midpoint angle
        mu = 360/geom.polyN;
        
        P = zeros(numel(geom.radius),geom.polyN,2);
        for i = 1:geom.polyN
            mu1 = i*mu;
            P(:,i,1) = ro.*cosd(mu1);
            P(:,i,2) = ro.*sind(mu1);
        end
        points = squeeze(P);
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