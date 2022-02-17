function updateNMRsignals
%updateNMRsignals adds noise to the forward NMR signals and scales the
%signals by porosity (if any)
%
% Syntax:
%       updateNMRsignals
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updateNMRsignals
%
% Other m-files required:
%       addNoiseToSignal
%       updatePlotsNMR
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
data = getappdata(fig,'data');

%% first check what is the noise type

switch data.nmr.noisetype
    case 'level'
        noise = data.nmr.noise;
    case 'SNR'
        SNR = data.nmr.noise;
        noise = 1./SNR;
end

%% only proceed if the noise is larger than 0
if noise > 0
    switch data.nmr.noisetype
        case 'level'
            % scale noise by porosity
            noise = noise/data.nmr.porosity;
            % add noise to NMR signals
            [data.results.NMR.EiT1,~] = addNoiseToSignal(data.results.NMR.raw.EiT1,0,noise);
            [data.results.NMR.EdT1,~] = addNoiseToSignal(data.results.NMR.raw.EdT1,0,noise);
            [data.results.NMR.EiT2,~] = addNoiseToSignal(data.results.NMR.raw.EiT2,0,noise);
            [data.results.NMR.EdT2,~] = addNoiseToSignal(data.results.NMR.raw.EdT2,0,noise);
            noiseM = noise*ones(size(data.results.NMR.EiT1,2),4);
        case 'SNR'
            SNR = data.nmr.noise;
            noiseM(:,1) = data.results.NMR.EiT1(:,end)./SNR;
            [data.results.NMR.EiT1,~] = addNoiseToSignal(data.results.NMR.raw.EiT1,0,noiseM(:,1));
            noiseM(:,2) = data.results.NMR.EdT1(:,end)./SNR;
            [data.results.NMR.EdT1,~] = addNoiseToSignal(data.results.NMR.raw.EdT1,0,noiseM(:,2));
            noiseM(:,3) = data.results.NMR.EiT2(:,1)./SNR;
            [data.results.NMR.EiT2,~] = addNoiseToSignal(data.results.NMR.raw.EiT2,0,noiseM(:,3));
            noiseM(:,4) = data.results.NMR.EdT2(:,1)./SNR;
            [data.results.NMR.EdT2,~] = addNoiseToSignal(data.results.NMR.raw.EdT2,0,noiseM(:,4));            
    end
else
    % reset the NMR signals with the raw data (without noise)
    data.results.NMR.EiT1 = data.results.NMR.raw.EiT1;
    data.results.NMR.EdT1 = data.results.NMR.raw.EdT1;
    data.results.NMR.EiT2 = data.results.NMR.raw.EiT2;
    data.results.NMR.EdT2 = data.results.NMR.raw.EdT2;
    noiseM = zeros(size(data.results.NMR.EiT1,2),4);
end

% scale NMR signals by porosity
data.results.NMR.EiT1 = data.nmr.porosity.*data.results.NMR.EiT1;
data.results.NMR.EdT1 = data.nmr.porosity.*data.results.NMR.EdT1;
data.results.NMR.EiT2 = data.nmr.porosity.*data.results.NMR.EiT2;
data.results.NMR.EdT2 = data.nmr.porosity.*data.results.NMR.EdT2;

% save the noise matrix values
data.results.NMR.noise = noiseM;
% save the porosity value
data.results.NMR.porosity = data.nmr.porosity;
% update the GUI data
setappdata(fig,'data',data);
% update the NMR plot window
updatePlotsNMR;

end

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