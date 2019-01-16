function out = getSaturationFromPressure(geom,P,constants)
%getSaturationFromPressure calculates the full or partial saturation state
%at a given pressure P for the three possible pore shapes: 'cyl', 'ang'
%and 'poly'.
%
% Syntax:
%       getSaturationFromPressure(geom,P,constants)
%
% Inputs:
%       geom - geometry structure (output from 'getGeometryParameters')
%       P - single pressure value P [Pa]
%       constants - physical constants (output from 'getConstants')
%
% Outputs:
%       out - output sruct with fields:
%           isfullsat(i,d) : full saturation marker (i and d refer to
%                            imbibition and drainage)
%           WC(i,d) : water content
%           S(i,d)  : saturation
%           Aa(i,d) : water filled area
%           Pa(i,d) : NMR active perimeter
%           Pc(i,d) : critical capillary pressure
%           R0(i,d) : critical radius for (only 'ang' and 'poly')
%
% Example:
%       out = getSaturationFromPressure(geom,P,constants)
%
% Other m-files required:
%       getCriticalPressure
%       getCornerSaturation
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

%% prepare the standard output variables
% 'i' indicates imbibition
% 'd' indicates drainage
isfullsati = 0;
WCi = 0;
Si = 0;
Aai = 0;
Pai = 0;
isfullsatd = 0;
WCd = 0;
Sd = 0;
Aad = 0;
Pad = 0;

%% switch depending on shape
switch geom.type
    case 'cyl'        
        % get the critical pressures
        [Pci,Pcd] = getCriticalPressure(geom,constants);
        
        if P <= Pci
            % pore is fully saturated
            isfullsati = 1;
            WCi = geom.A0;
            Si = 1;
            Aai = geom.A0;
            Pai = geom.P0;
        end
        
        if P <= Pcd
            % pore is fully saturated
            isfullsatd = 1;
            WCd = geom.A0;
            Sd = 1;
            Aad = geom.A0;
            Pad = geom.P0;
        end
        
        out.Pci = Pci;
        out.isfullsati = isfullsati;
        out.WCi = WCi;
        out.Si = Si;
        out.Aai = Aai;
        out.Pai = Pai;
        
        out.Pcd = Pcd;
        out.isfullsatd = isfullsatd;
        out.WCd = WCd;
        out.Sd = Sd;
        out.Aad = Aad;
        out.Pad = Pad;
        
    case {'ang','poly'}
        % get the critical pressures and radii
        [Pci,Pcd,R0i,R0d] = getCriticalPressure(geom,constants);
        
        % capillary radius of the arc menisci
        r_AM = (constants.sigfac*constants.sigma*cosd(constants.theta)) / P;
        
        % in the case of imbibition
        if P <= Pci
            % pore is fully saturated
            isfullsati = 1;
            WCi = geom.A0;
            Si = 1;
            % instead of just a single value for
            % Aai = geom.A0;
            % Pai = geom.P0;
            % we duplicate A0 and P0 so that the size of the vector conforms
            % with the number of corners
            % this has implications in "getCornerNMRparameter.m" when
            % calculating the amplitudes of the corners
            Aai = geom.A0.*ones(size(geom.angles));
            Pai = geom.P0.*ones(size(geom.angles));
        else
            % pore is partially saturated
            % from Tuller et. al 1999 (eq. B2)
            WCi = geom.AngulFac * r_AM^2;
            Si = WCi / geom.A0;
            [Aai,Pai] = getCornerSaturation(r_AM,geom.angles);
        end
        
        % in the case of drainage
        if P < Pcd
            % pore is fully saturated
            isfullsatd = 1;
            WCd = geom.A0;
            Sd = 1;
            % instead of just a single value for
            % Aad = geom.A0;
            % Pad = geom.P0;
            % we duplicate A0 and P0 so that the size of the vector conforms
            % with the number of corners
            % this has implications in "getCornerNMRparameter.m" when
            % calculating the amplitudes of the corners
            Aad = geom.A0.*ones(size(geom.angles));
            Pad = geom.P0.*ones(size(geom.angles));
        else
            % pore is partially saturated
            % from Tuller et. al 1999 (eq. B2)
            WCd = geom.AngulFac * r_AM^2;
            Sd = WCd / geom.A0;
            [Aad,Pad] = getCornerSaturation(r_AM,geom.angles);
        end
        
        out.Pci = Pci;
        out.R0i = R0i;
        out.isfullsati = isfullsati;
        out.WCi = WCi;
        out.Si = Si;
        out.Aai = Aai;
        out.Pai = Pai;
        
        out.Pcd = Pcd;
        out.R0d = R0d;
        out.isfullsatd = isfullsatd;
        out.WCd = WCd;
        out.Sd = Sd;
        out.Aad = Aad;
        out.Pad = Pad;
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