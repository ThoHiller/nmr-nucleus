function calculateNMR
%calculateNMR calculates the NMR signals for the full and partially saturated
%pores
%
% Syntax:
%       calculateNMR
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       calculateNMR
%
% Other m-files required:
%       displayStatusText
%       calculateNMRnoise
%       getNMRTimeVector
%       getNMRSignal
%       updatePlotsNMR
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

%% only proceed if there is CPS data available
if isfield(data.results,'SAT')
    
    % generate a time vector from the echo time 'TE' and number of echoes 'echosN'
    nmr.t = getNMRTimeVector(data.nmr.TE,'µs','N',data.nmr.echosN);
    nmr.Tb = data.nmr.Tbulk;
    nmr.rho = data.nmr.rho/1e6; % µm/s to m/s
    
    % wait-bar option
    wbopts.show = true;
    wbopts.tag = 'MOD';
    
    % disable the RUN button to indicate a running calculation
    set(gui.push_handles.nmr_RUN,'String','RUNNING ...','Enable','inactive'); 
    
    % calculate the NMR signals for ALL pressure / saturation steps
    displayStatusText(gui,'Calculating NMR signals ... ');
    NMR = getNMRSignal(nmr,data.geometry.type,data.results.SAT,data.results.psddata,wbopts);
    % always keep a copy of the raw data (without noise)
    NMR.raw = NMR;
    
    % update the global GUI data
    data.results.NMR = NMR;
    setappdata(fig,'data',data);
    
    % add noise to the NMR signals
    calculateNMRnoise;
    displayStatusText(gui,'Calculating NMR signals ... done');
    updatePlotsNMR;
    % enable the RUN button again
    set(gui.push_handles.nmr_RUN,'String','RUN','Enable','on');
    
else
    helpdlg({'calculateNMR:','Create CPS data first.'});
end

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