function out = getCornerNMRparameter(geometry,SatData,indt,imbdrain)
%getCornerNMRparameter calculates corner parameters (amplitude surface to
%volume ratios) needed for the NMR signal calculation of a fully or
%partially saturated pore. Only used for angular or polygonal pores.
%
% Syntax:
%       getCornerNMRparameter(geometry,SatData,indt,imbdrain)
%
% Inputs:
%       geometry - structure containing geometry information
%       SatData - structure (output from 'getSaturationfromPressure')
%       indt - number of echoes/points per NMR signal
%       imbdrain - string indicating if a NMR signal is from the drainage
%                  or imbibition branch (e.g. 'DDID')
%
% Outputs:
%       out - output struct with fields:
%           SVF : surface-to-volume ratio for full saturation
%           Ampl : amplitudes of the partially filled corners
%           SVC :  surface-to-volume ratio for the partially filled corners
%
% Example:
%       out = getCornerNMRparameter(geometry,SatData,[1000 900 900 700],'DDID')
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

%% full saturation surface to volume ratio for all shapes
SVF = geometry.P0./geometry.A0;
out.SVF = SVF';

%% only for shapes with corners the calculation is performed
if strcmp(geometry.type,'ang') || strcmp(geometry.type,'poly')
    % amplitude of water filled corner
    Ampl = zeros(size(SatData.Pad,3),sum(indt),size(SatData.Pad,2));
    % surface to volume ratio of water filled corner
    SVC  = zeros(size(SatData.Pad,3),sum(indt),size(SatData.Pad,2));
    for i = 1:numel(imbdrain)
        % check for drainage and imbibition
        if strcmp(imbdrain(i),'D') % drainage
            index = find(SatData.Sd(i,:)~=1,1,'first');
            if isempty(index)
                SVc = ones(size(SatData.Pad,3),1);
            else
                SVc = squeeze(SatData.Pad(i,index,:)./SatData.Aad(i,index,:));
            end
            tmp = squeeze(SatData.Aad(i,:,:))./repmat(SatData.A0,[1 size(SatData.Pad,3)]);
        elseif strcmp(imbdrain(i),'I') % imbibition
            index = find(SatData.Si(i,:)~=1,1,'first');
            if isempty(index)
                SVc = ones(size(SatData.Pai,3),1);
            else
                SVc = squeeze(SatData.Pai(i,index,:)./SatData.Aai(i,index,:));
            end
            tmp = squeeze(SatData.Aai(i,:,:))./repmat(SatData.A0,[1 size(SatData.Pai,3)]);
        end
        
        % indices for all chosen NMR signals
        if i == 1
            si = 1;
            ei = indt(i);
        else
            si = sum(indt(1:i-1))+1;
            ei = sum(indt(1:i-1))+indt(i);
        end
        % assemble the amplitude and surface to volume data
        for j = 1:size(tmp,2)
            Ampl(j,si:ei,:) = repmat(tmp(:,j)',[indt(i) 1]);
            SVC(j,si:ei,:) = repmat(SVc(j),[indt(i) size(tmp,1)]);
        end
    end
    
    % output data
    out.Ampl = Ampl;
    out.SVC = SVC;
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