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
%       wbopts - show a wait-bar or not
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
%           K(i,d)  : hydraulic conductivity
%
% Example:
%       out = getSaturationFromPressure(geom,P,constants)
%
% Other m-files required:
%       getCriticalPressure
%       getConduct
%       getCornerSaturation
%       getGeometryParameter
%       getSaturationFromPressure
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

radius = GEOM.radius';
tmp_geom.type = GEOM.type;

if strcmp(GEOM.type,'ang') || strcmp(GEOM.type,'poly')
    tmp_geom.angles = GEOM.angles;
    tmp_geom.ShapeFac = GEOM.ShapeFac;
    tmp_geom.AngulFac = GEOM.AngulFac;
end

% some informative wait-bar ;-)
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
            SatData_tmp.Ki(r) = Sat_state.Ki;
            
            SatData_tmp.isfullsatd(r,1) = Sat_state.isfullsatd;
            SatData_tmp.Pcd(r) = Sat_state.Pcd;
            SatData_tmp.WCd(r) = Sat_state.WCd;
            SatData_tmp.Sd(r) = Sat_state.Sd;
            SatData_tmp.Aad(r) = Sat_state.Aad;
            SatData_tmp.Pad(r) = Sat_state.Pad;
            SatData_tmp.Kd(r) = Sat_state.Kd;
            
        elseif strcmp(GEOM.type,'ang') || strcmp(GEOM.type,'poly')
            SatData_tmp.isfullsati(r) = Sat_state.isfullsati;
            SatData_tmp.Pci(r) = Sat_state.Pci;
            SatData_tmp.R0i(r) = Sat_state.R0i;
            SatData_tmp.WCi(r) = Sat_state.WCi;
            SatData_tmp.Si(r) = Sat_state.Si;
            SatData_tmp.Aai(r,:) = Sat_state.Aai;
            SatData_tmp.Pai(r,:) = Sat_state.Pai;
            SatData_tmp.Ki(r) = Sat_state.Ki;
            
            SatData_tmp.isfullsatd(r) = Sat_state.isfullsatd;
            SatData_tmp.Pcd(r) = Sat_state.Pcd;
            SatData_tmp.R0d(r) = Sat_state.R0d;
            SatData_tmp.WCd(r) = Sat_state.WCd;
            SatData_tmp.Sd(r) = Sat_state.Sd;
            SatData_tmp.Aad(r,:) = Sat_state.Aad;
            SatData_tmp.Pad(r,:) = Sat_state.Pad;
            SatData_tmp.Kd(r) = Sat_state.Kd;
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
    
    % --- START: hydraulic conductivity AddOn ---
    
    % we consider two different approaches for K upscaling, ...
    
    %% FIRST
    % (physically correct and simplest implementation):
    % gather individual K values for each full duct and sum them.
    % In doing so, consider their individual proportions in the psd:    
    SAT.Kifull(p,:) = SatData_tmp.Ki .* SAT.Sifull(p,:);
    SAT.Kdfull(p,:) = SatData_tmp.Kd .* SAT.Sdfull(p,:);
    % Note: the actual summarization is done below along with Sifull and
    % Sdfull (Line 273 ff)
    % ---
    
    %% SECOND
    % (because the fit to real data is often better, at least for S=1!):
    % estimate the mean log (= effective) pore size for all full ducts
    % at each pressure step and calculate the corresponding K = f(r_eff) PLUS
    % in case of angular pore shape take residual K values of meniscus
    % water into account:    
    tmp_geom.type = GEOM.type;
    % if shape is ang or poly, we need the angles and number of corners
    if ~strcmp(GEOM.type,'cyl')
        tmp_geom.angles = GEOM.angles;
        if strcmp(GEOM.type,'poly')
            tmp_geom.polyN = GEOM.polyN;
        end
    end
    
    % find all full ducts (imbibition path)
    dummyi = find(SAT.Si(p,:) < 1,1,'first');
    % calculate mean log of full duct range to get effective equivalent radius
    ri_eff = 10.^(sum(SAT.Sifull(p,1:dummyi-1)/sum(SAT.Sifull(p,1:dummyi-1)) ...
        .* log10(radius(1:dummyi-1))));
    % save effective radius in temporal geom structure
    tmp_geomi = tmp_geom;
    tmp_geomi.radius = ri_eff;
    
    % find all full ducts (drainage path)
    dummyd = find(SAT.Sd(p,:) < 1,1,'first');
    % calculate mean log of full duct range to get effective equivalent radius
    rd_eff = 10.^(sum(SAT.Sdfull(p,1:dummyd-1)/sum(SAT.Sdfull(p,1:dummyd-1))...
        .* log10(radius(1:dummyd-1))));
    % save effective radius in temporal geom structure
    tmp_geomd = tmp_geom;
    tmp_geomd.radius = rd_eff;
    
    % calculate the K from effective radius for recent pressure step
    Ki_ducts = getConduct(getGeometryParameter(tmp_geomi),constants) *...
        sum(SAT.Sifull(p,1:dummyi-1));
    Kd_ducts = getConduct(getGeometryParameter(tmp_geomd),constants) *...
        sum(SAT.Sdfull(p,1:dummyd-1));
    
    % calculate K for residual meniscus water in case of having 'ang' or
    % 'poly' shape
    if ~strcmp(GEOM.type,'cyl')
        % get water-filled area in cross-section first
        r_AM = (constants.sigfac * constants.sigma * cosd(constants.theta))...
            / pressure(p);
        [Aa,~] = getCornerSaturation(r_AM,tmp_geom.angles);
        % lumped physical constants
        C = constants.density * constants.gravity / constants.dynvisc;
        K_corners = zeros(size(tmp_geom.angles));
        % Note that the K response from a specific corner of a
        % desaturated angular pore is independent from pore size!
        % Thus, main loop is over the corners:
        for n = 1:numel(tmp_geom.angles)
            % individual K values for meniscus in each corner
            K_corners(n) = C * (r_AM^2/getRaRaEps(tmp_geom.angles(n)));
            % weight the individual K values using the proportion of
            % residual water in meniscus (with respect to bulk pore area)
            % Loop over pore size is not really necessary, but easier to
            % understand the process...
            for r = dummyi : numel(radius)
                tmp_Ki_corners(r) = K_corners(n) * Aa(n) / GEOM.A0(r);
            end
            for r = dummyd : numel(radius)
                tmp_Kd_corners(r) = K_corners(n) * Aa(n) / GEOM.A0(r);
            end
            % summarize all K values from n-th corner for entire PSD (and
            % weight them using their proportion in PSD!)
            Ki_corners(n) = sum(tmp_Ki_corners(dummyi:end) .* SAT.Sifull(p,dummyi:end));
            Kd_corners(n) = sum(tmp_Kd_corners(dummyd:end) .* SAT.Sdfull(p,dummyd:end));
            
            % these two lines do the same job like the two loops above and
            % are faster, but its too difficult to explain why ;-) ...
            % Ki_corners(n) = sum(K_corners(n) * Aa(n) * SAT.Sifull(p,dummyi:end) ./ GEOM.A0(dummyi:end)');
            % Kd_corners(n) = sum(K_corners(n) * Aa(n) * SAT.Sdfull(p,dummyd:end) ./ GEOM.A0(dummyd:end)');
        end
    else
        % no corners in cylindrical pores
        Ki_corners = 0;
        Kd_corners = 0;
    end
    
    % save individual contribution of ducts and corners
    SAT.Ki_ducts(p) = Ki_ducts;
    SAT.Ki_corners(p) = sum(Ki_corners);
    SAT.Kd_ducts(p) = Kd_ducts;
    SAT.Kd_corners(p) = sum(Kd_corners);
    
    % now bring ducts and corners together
    Ki_eff = Ki_ducts + sum(Ki_corners);
    Kd_eff = Kd_ducts + sum(Kd_corners);
    
    SAT.ri_eff(p) = ri_eff;
    SAT.Ki_eff(p) = Ki_eff;
    SAT.rd_eff(p) = rd_eff;
    SAT.Kd_eff(p) = Kd_eff;
    % --- END: hydraulic conductivity AddOn ---
    
    %%
    if wbopts.show
        waitbar((steps-p) / steps,hwb,['processing ...',num2str(steps-p),...
            ' / ',num2str(steps),' pressure steps']);
    end
end
if wbopts.show
    delete(hwb);
end

%% finalize global output saturation data
SAT.A0  = GEOM.A0;
if numel(radius) > 1
    SAT.Sifull = sum(SAT.Sifull,2);
    SAT.Sdfull = sum(SAT.Sdfull,2);
    SAT.Kifull = sum(SAT.Kifull,2);
    SAT.Kdfull = sum(SAT.Kdfull,2);
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