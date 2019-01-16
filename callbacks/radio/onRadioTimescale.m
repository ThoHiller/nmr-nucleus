function onRadioTimescale(src,~)
%onRadioTimescale selects wether the time scale should be "s" or "ms"
%
% Syntax:
%       onRadioTimescale
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onRadioTimescale(src,~)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

 % which radiobutton ('s' or 'ms')
str = get(src,'String');
% get the current selected NMR signal
id = get(gui.listbox_handles.signal,'Value');

% proceed only if there is actual data
if ~isempty(id)
    % remove temporary data fields
    data = removeInversionFields(data);
    
    % change all relevant settings depending on the chosen radio button
    switch str
        case 's'
            data.process.timescale = 's';
            if data.process.timefac == 1000                
                data.process.timefac = 1;
                data.invstd.time = data.invstd.time ./ 1000;
                data.invstd.Tbulk = data.invstd.Tbulk ./ 1000;
            end
            
        case 'ms'
            data.process.timescale = 'ms';
            if data.process.timefac == 1                
                data.process.timefac = 1000;
                data.invstd.time = data.invstd.time .* 1000;
                data.invstd.Tbulk = data.invstd.Tbulk .* 1000;
            end
    end

    % update GUI data
    setappdata(fig,'data',data);
    % update interface
    NUCLEUSinv_updateInterface;    
    % process NMR signal
    processNMRDataControl(fig,id);
    % update plots
    updatePlotsSignal;
    % clear axes
    clearSingleAxis(gui.axes_handles.rtd);
    clearSingleAxis(gui.axes_handles.psd);
    % set focus on data
    set(gui.plots.SignalPanel,'Selection',1);
    
else
    % reset to defaults
    data.process.timescale = 's';
    % update GUI data
    setappdata(fig,'data',data);
    % update interface
    NUCLEUSinv_updateInterface;
    helpdlg('Nothing to do because no data set is selected!',...
        'onRadioTimescale: Select NMR data first.');
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