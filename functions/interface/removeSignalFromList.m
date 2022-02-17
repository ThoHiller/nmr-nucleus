function removeSignalFromList(id)
%removeSignalFromList removes the chosen NMR signal from the GUI
%
% Syntax:
%       removeSignalFromList
%
% Inputs:
%       id - index of selected NMR data file
%
% Outputs:
%       none
%
% Example:
%       removeSignalFromList(id)
%
% Other m-files required:
%       clearAllAxes
%       NUCLEUSinv_updateInterface
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
INVdata = getappdata(fig,'INVdata');

% number of total measurements in list
nINVdata = size(INVdata,1);

% only continue if there is data (INVdata is an easy indicator if data
% was actually imported)
if ~isempty(INVdata)    
    % now apply changes - remove selected data
    data.import.NMR.data(id) = [];
    data.import.NMR.para(id) = [];
    data.import.NMR.files(id) = [];
    data.import.NMR.filesShort(id) = [];
    INVdata(id) = [];
    
    % empty all axes
    clearAllAxes(fig);
    
    % update the listbox entries
    shownames = data.import.NMR.filesShort;
    set(gui.listbox_handles.signal,'String',shownames);
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
    
    % color the list entries that already have an inversion result
    strL = get(gui.listbox_handles.signal,'String');
    for i = 1:size(INVdata,1)
        if isstruct(INVdata{i})
            str1 = strL{i};
            str2 = ['<HTML><BODY bgcolor="rgb(',...
                    sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',...
                    str1,'</BODY></HTML>'];
            strL{i} = str2;
        end
    end
    set(gui.listbox_handles.signal,'String',strL);
    
    % if there are as many CPS data points as NMR files remove the
    % corresponding CPS point as well
    ntable = size(data.pressure.table,1);
    if nINVdata == ntable
        data.pressure.table(id,:) = [];
    end    
    
else
    % if there is no data to sort throw a help dialog
    helpdlg('Nothing to do because there is no data loaded!',...
        'removeSignalFromList: Load NMR data first.');
end

% update GUI data and interface
setappdata(fig,'data',data);
setappdata(fig,'INVdata',INVdata);
NUCLEUSinv_updateInterface;

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