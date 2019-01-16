function [Pci,Pcd,R0i,R0d] = getCriticalPressure(geom,constants)
%getCriticalPressure calculates the critical pressure and radii (only for
%'ang' & 'poly') for imbibition and drainage for the three possible shapes:
%'cyl', 'ang' and 'poly'.
%
% Syntax:
%       getCriticalPressure(geom,constants)
%
% Inputs:
%       geom - geometry structure (output from 'getGeometryParameter')
%       constants - physical constants
%
% Outputs:
%       Pci - critical capillary pressure for imbibition
%       Pcd - critical capillary pressure for drainage
%       R0i - critical radius for imbibition (only 'ang' and 'poly')
%       R0d - critical radius for drainage (only 'ang' and 'poly')
%
% Example:
%       [Pci,Pcd,R0i,R0d] = getCriticalPressure(geom,constants)
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

if strcmp(geom.type,'cyl')    
    Pci = (constants.sigfac.*constants.sigma.*cosd(constants.theta)) ./ geom.radius';
    Pcd = 2.*Pci;    
elseif strcmp(geom.type,'ang') || strcmp(geom.type,'poly')    
    % from Tuller et. al 1999 we get the critical radii depending on the pore shape
    % for imbibition (eq. B4)
    R0i = 2.*geom.A0 ./ geom.P0;
    % for drainage (eq. B8)
    R0d = geom.P0 ./ ( 2*(geom.AngulFac+pi) + 2*(sqrt(pi*(geom.AngulFac+pi))) );
    % from these radii the critical pressures can be calculated
    Pci = (constants.sigfac*constants.sigma*cosd(constants.theta)) ./ R0i;
    Pcd = (constants.sigfac*constants.sigma*cosd(constants.theta)) ./ R0d; 
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