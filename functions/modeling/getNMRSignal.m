function nmr = getNMRSignal(nmr,type,SatData,psdData,wbopts)
%getNMRSignal calculates the NMR signal of a fully or partially saturated
%pore or pore size distribution depending on the shape 'cyl', 'ang' and 'poly'.
%
% Syntax:
%       getNMRSignal(nmr,type,SatData,psdData,wbopts)
%
% Inputs:
%       nmr - structure containing fields:
%           t   : time vector [s]
%           Tb  : bulk relaxation time [s]
%           rho : surface relaxivity [m/s]
%       type - either 'cyl', 'ang' and 'poly'
%       SatData - structure (output from 'getSaturationfromPressure')
%       psdData - structure containing fields:
%           psd : amplitudes of the distribution
%           r   : sample points of the distribution
%                 if psd = 1 and r is a scalar value then a single pore
%                 is assumed
%       wbopts - show a wait-bar
%
% Outputs:
%       nmr - structure containing new fields:
%           EiT1 : T1 NMR signal for imbibition
%           EiT2 : T2 NMR signal for imbibition
%           EdT1 : T1 NMR signal for drainage
%           EdT2 : T2 NMR signal for drainage
%           with NMR signals for each available pressure / saturation step
%
% Example:
%       nmr = getNMRSignal(nmr,type,SatData,psdData,wbopts)
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

%% allocate the output NMR signals:
% T1 and T2 for imbibition / drainage
EiT1 = zeros(size(SatData.Sifull,1),numel(nmr.t));
EiT2 = zeros(size(SatData.Sifull,1),numel(nmr.t));
EdT1 = zeros(size(SatData.Sdfull,1),numel(nmr.t));
EdT2 = zeros(size(SatData.Sdfull,1),numel(nmr.t));

% get general parameters
t = nmr.t;
Tb = nmr.Tb;
rho = nmr.rho;

%% some informative wait-bar ;-)
if wbopts.show
    hwb = waitbar(0,'processing ...','Name','Calculate NMR','Visible','off');
    steps = numel(SatData.pressure);
    % position the wait-bar to the NMRMOD GUI if it is present (assuming the call came
    % from the GUI)
    fig = findobj('Tag',wbopts.tag);
    if ~isempty(fig)
        posf = get(fig,'Position');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    end
    set(hwb,'Visible','on');
end

%% NMR signals depending on geometry type
switch type
    case 'cyl'
        % surface to volume ratio (2/radius)
        SVi = SatData.Pai./SatData.Aai;
        SVd = SatData.Pad./SatData.Aad;
        SVi(isnan(SVi)) = 0; % get rid of NaNs
        SVd(isnan(SVd)) = 0; % get rid of NaNs
        
        % for all pressure steps
        for p = 1:numel(SatData.pressure)
            % for all time steps
            for j = 1:length(t)
                EiT1(p,j) = sum(SatData.Si(p,:) .* psdData.psd .* ...
                    (1-exp(-t(j) .* (1./Tb+rho.*SVi(p,:)) )));
                EiT2(p,j) = sum(SatData.Si(p,:) .* psdData.psd .* ...
                    exp(-t(j) .* (1./Tb+rho.*SVi(p,:)) ) );
                EdT1(p,j) = sum(SatData.Sd(p,:) .* psdData.psd .* ...
                    (1-exp(-t(j) .* (1./Tb+rho.*SVd(p,:)) )));
                EdT2(p,j) = sum(SatData.Sd(p,:) .* psdData.psd .* ...
                    exp(-t(j) .* (1./Tb+rho.*SVd(p,:)) ) );
            end
            if wbopts.show
                waitbar(p / steps,hwb,['processing ... ',num2str(p),' / ',...
                    num2str(steps),' pressure steps']);
            end
        end
        
        % NMR signals for triangular and polygon capillaries
    case {'ang','poly'}
        % No of water-filled corners
        Ncorners = size(SatData.Aai,ndims(SatData.Aai));
        
        % for all pressure steps
        for p = 1:numel(SatData.pressure)            
            % area of water-filled corners is later used for NMR amplitude
            % calculation
            Aai = squeeze(SatData.Aai(p,:,:));
            Aad = squeeze(SatData.Aad(p,:,:));
            
            % surface to volume ratio (S/V) for imbibition / drainage
            SVi = squeeze(SatData.Pai(p,:,:)./SatData.Aai(p,:,:));
            SVd = squeeze(SatData.Pad(p,:,:)./SatData.Aad(p,:,:));
            
            % temporary NMR signals
            sigiT1 = zeros(size(SVi,1),numel(t));
            sigiT2 = zeros(size(SVi,1),numel(t));
            sigdT1 = zeros(size(SVd,1),numel(t));
            sigdT2 = zeros(size(SVd,1),numel(t));
            
            % for all pore sizes
            for j = 1:numel(psdData.r)                
                % --- imbibition ---
                if SatData.isfullsati(p,j) == 1 % if fully saturated -> Ampl = 1
                    sigiT1(j,:) = (1-exp(-t .* (1./Tb + rho.*SVi(j,1)) ));
                    sigiT2(j,:) =    exp(-t .* (1./Tb + rho.*SVi(j,1)) );
                else
                    % partially saturated pore -> account for corners
                    for jj = 1:Ncorners
                        Ampl = Aai(j,jj) / SatData.A0(j);
                        sigiT1(j,:) = sigiT1(j,:) + (Ampl * (1-exp(-t .* ...
                            (1./Tb + rho.*SVi(j,jj)))) );
                        sigiT2(j,:) = sigiT2(j,:) + (Ampl *    exp(-t .* ...
                            (1./Tb + rho.*SVi(j,jj)))  );
                    end
                end
                
                % --- drainage ---
                if SatData.isfullsatd(p,j) == 1 % if fully saturated -> Ampl = 1
                    sigdT1(j,:) = (1-exp(-t .* (1./Tb + rho.*SVd(j,1)) ));
                    sigdT2(j,:) =    exp(-t .* (1./Tb + rho.*SVd(j,1)) );
                else
                    % partially saturated pore -> account for corners
                    for jj = 1:Ncorners
                        Ampl = Aad(j,jj) / SatData.A0(j);
                        sigdT1(j,:) = sigdT1(j,:) + (Ampl * (1-exp(-t .* ...
                            (1./Tb + rho.*SVd(j,jj)))) );
                        sigdT2(j,:) = sigdT2(j,:) + (Ampl *    exp(-t .* ...
                            (1./Tb + rho.*SVd(j,jj)))  );
                    end
                end
                
                % account for pore size distribution
                sigiT1(j,:) = sigiT1(j,:) * psdData.psd(j);
                sigiT2(j,:) = sigiT2(j,:) * psdData.psd(j);
                sigdT1(j,:) = sigdT1(j,:) * psdData.psd(j);
                sigdT2(j,:) = sigdT2(j,:) * psdData.psd(j);
            end
            
            % sum up all pores into one NMR signal for the current pressure /
            % saturation step
            if numel(psdData.psd) > 1
                EiT1(p,:) = sum(sigiT1);
                EiT2(p,:) = sum(sigiT2);
                EdT1(p,:) = sum(sigdT1);
                EdT2(p,:) = sum(sigdT2);
            else
                % single pore case
                EiT1(p,:) = sigiT1;
                EiT2(p,:) = sigiT2;
                EdT1(p,:) = sigdT1;
                EdT2(p,:) = sigdT2;
            end
            
            % update wait-bar
            if wbopts.show
                waitbar(p / steps,hwb,['processing ... ',num2str(p),' / ',num2str(steps),' pressure steps']);
            end
        end
end
%% delete wait-bar
if wbopts.show
    delete(hwb);
end

%% output data
nmr.EiT1 = EiT1;
nmr.EiT2 = EiT2;
nmr.EdT1 = EdT1;
nmr.EdT2 = EdT2;

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