function onPopupNMRNoiseType(src,~)
%onPopupNMRNoiseType selects the noise type to be aplied to the forward
%modelled NMR data
%
% Syntax:
%       onPopupNMRNoiseType
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupNMRNoiseType(src,~)
%
% Other m-files required:
%       clearSingleAxis.m
%       updateCPSTable.m
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
gui = getappdata(fig,'gui');

% get the value of the popup menu
value = get(src,'Value');

% change settings accordingly
switch value
    case 1 % noise level
        data.nmr.noisetype = 'level';
        if data.nmr.noise > 0
            data.nmr.noise = 1/data.nmr.noise;
        end        
    case 2 % signal-to-noise ratio (SNR)
        data.nmr.noisetype = 'SNR';
        if data.nmr.noise == 0
            data.nmr.noise = inf;
        else
            data.nmr.noise = 1/data.nmr.noise;
        end        
end
% update the corresponding edit field
set(gui.edit_handles.noise,'String',num2str(data.nmr.noise));

% update GUI data
setappdata(fig,'data',data);
% update NMR data (if available)
if isfield(data.results,'NMR')
    updateNMRsignals;
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2021 Thomas Hiller
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