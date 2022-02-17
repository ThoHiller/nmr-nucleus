function onRadioNormalize(src,~)
%onRadioNormalize selects whether to normalize a NMR signal to 1
%
% Syntax:
%       onRadioNormalize
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioNormalize(src,~)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%       processNMRDataControl
%       removeInversionFields
%       updatePlotsSignal
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% which radiobutton ('on' or 'off')
str = get(src,'String');
% get the current selected NMR signal
id = get(gui.listbox_handles.signal,'Value');

% proceed only if there is actual data
if ~isempty(id)    
    % remove temporary data fields
    data = removeInversionFields(data);
    
    switch str
        case 'on'
            data.process.norm = 1;
        case 'off'
            data.process.norm = 0;
    end
    
    % update GUI data
    setappdata(fig,'data',data);
    % update interface
    NUCLEUSinv_updateInterface;
    % process NMR signal
    processNMRDataControl(fig,id);
    % update plots
    updatePlotsSignal;
    updateInfo(src);
    % clear axes
    clearSingleAxis(gui.axes_handles.rtd);
    clearSingleAxis(gui.axes_handles.psd);
    % set focus on data
    set(gui.plots.SignalPanel,'Selection',1);
    
else
    % reset to defaults
    data.process.norm = 0;
    % update GUI data
    setappdata(fig,'data',data);
    % update interface
    NUCLEUSinv_updateInterface;
    helpdlg('Nothing to do because no data set is selected!',...
        'onRadioNormalize: Select NMR data first.');
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