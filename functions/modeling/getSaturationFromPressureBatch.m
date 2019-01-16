function SAT = getSaturationFromPressureBatch(GEOM,pressure,inpsd,constants,wbopts)
%getSaturationFromPressure calculates the full or partial saturation state
%at a given pressure P for the three possible pore shapes: 'cyl', 'ang'
%and 'poly'.
%
% Syntax:
%       getSaturationFromPressureBatch(GEOM,pressure,inpsd,constants,wbopts)
%
% Inputs:
%       GEOM - geometry structure (output from 'getGeometryParameters')
%       pressure - pressure values in [Pa]
%       inpsd - structure containing fields:
%           r   : x-values of the PSD
%           psd : amplitudes of the PSD%           
%           NOTE: if psd = 1 and r is a scalar value then a single pore
%                 is assumed
%       constants - physical constants (output from 'getConstants')
%       wbopts - show a waitbar or not
%
% Outputs:
%       SAT - output sruct with fields:
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

radius = GEOM.radius';
tmp_geom.type = GEOM.type;

if strcmp(GEOM.type,'ang') || strcmp(GEOM.type,'poly')
    tmp_geom.angles = GEOM.angles;
    tmp_geom.ShapeFac = GEOM.ShapeFac;
    tmp_geom.AngulFac = GEOM.AngulFac;
end

% some informative waitbar ;-)
if wbopts.show
    hwb = waitbar(0,'processing ...','Name','Calculate Saturation','Visible','off');
    steps = numel(pressure);
    fig = findobj('Tag',wbopts.tag);
    if ~isempty(fig)
        posf = get(fig,'Position');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    end
    set(hwb,'Visible','on');
end

% looping over all pressures and radii
% looping through backwards has the advantage that output-variables like
% e.g. Aad already have the correct dimensions, because at high pressures
% the pores are likely to be partially saturated
for p = numel(pressure):-1:1
    for r = numel(radius):-1:1        
        % local geometry variable
        tmp_geom.radius = GEOM.radius(r);
        tmp_geom.A0     = GEOM.A0(r);
        tmp_geom.P0     = GEOM.P0(r);
        if strcmp(GEOM.type,'ang')
            tmp_geom.sides = GEOM.sides(r,:);
        elseif strcmp(GEOM.type,'poly')
            tmp_geom.side = GEOM.side(r,:);
        end
        
        % get the saturation state depending on shape and pressure
        Sat_state = getSaturationFromPressure(tmp_geom,pressure(p),constants);
        
        % gather the data for the current radius
        if strcmp(GEOM.type,'cyl')
            SatData_tmp.isfullsati(r,1) = Sat_state.isfullsati;
            SatData_tmp.Pci(r) = Sat_state.Pci;
            SatData_tmp.WCi(r) = Sat_state.WCi;
            SatData_tmp.Si(r) = Sat_state.Si;
            SatData_tmp.Aai(r) = Sat_state.Aai;
            SatData_tmp.Pai(r) = Sat_state.Pai;
            
            SatData_tmp.isfullsatd(r,1) = Sat_state.isfullsatd;
            SatData_tmp.Pcd(r) = Sat_state.Pcd;
            SatData_tmp.WCd(r) = Sat_state.WCd;
            SatData_tmp.Sd(r) = Sat_state.Sd;
            SatData_tmp.Aad(r) = Sat_state.Aad;
            SatData_tmp.Pad(r) = Sat_state.Pad;
            
        elseif strcmp(GEOM.type,'ang') || strcmp(GEOM.type,'poly')
            SatData_tmp.isfullsati(r) = Sat_state.isfullsati;
            SatData_tmp.Pci(r) = Sat_state.Pci;
            SatData_tmp.R0i(r) = Sat_state.R0i;
            SatData_tmp.WCi(r) = Sat_state.WCi;
            SatData_tmp.Si(r) = Sat_state.Si;
            SatData_tmp.Aai(r,:) = Sat_state.Aai;
            SatData_tmp.Pai(r,:) = Sat_state.Pai;
            
            SatData_tmp.isfullsatd(r) = Sat_state.isfullsatd;
            SatData_tmp.Pcd(r) = Sat_state.Pcd;
            SatData_tmp.R0d(r) = Sat_state.R0d;
            SatData_tmp.WCd(r) = Sat_state.WCd;
            SatData_tmp.Sd(r) = Sat_state.Sd;
            SatData_tmp.Aad(r,:) = Sat_state.Aad;
            SatData_tmp.Pad(r,:) = Sat_state.Pad;
        end
    end
    
    % gather the data for the current pressure
    SAT.isfullsati(p,:) = SatData_tmp.isfullsati;
    SAT.WCi(p,:) = SatData_tmp.WCi;
    SAT.Si(p,:) = SatData_tmp.Si;
    SAT.Sifull(p,:) = SatData_tmp.Si .* inpsd.psd;
    SAT.Aai(p,:,:) = SatData_tmp.Aai;
    SAT.Pai(p,:,:) = SatData_tmp.Pai;
    
    SAT.isfullsatd(p,:) = SatData_tmp.isfullsatd;
    SAT.WCd(p,:) = SatData_tmp.WCd;
    SAT.Sd(p,:) = SatData_tmp.Sd;
    SAT.Sdfull(p,:) = SatData_tmp.Sd .* inpsd.psd;
    SAT.Aad(p,:,:) = SatData_tmp.Aad;
    SAT.Pad(p,:,:) = SatData_tmp.Pad;
    
    if wbopts.show
        waitbar((steps-p) / steps,hwb,['processing ...',num2str(steps-p),' / ',num2str(steps),' pressure steps']);
    end
end
if wbopts.show
    delete(hwb);
end

%% finalize global output saturation data
SAT.A0  = GEOM.A0;
SAT.Aai = squeeze(SAT.Aai);
SAT.Pai = squeeze(SAT.Pai);
SAT.Aad = squeeze(SAT.Aad);
SAT.Pad = squeeze(SAT.Pad);
if numel(radius) > 1
    SAT.Sifull = sum(SAT.Sifull,2);
    SAT.Sdfull = sum(SAT.Sdfull,2);
end
SAT.pressure = pressure(:);

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