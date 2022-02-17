function clearInversion(id)
%clearInversion removes inversion results from the internal data structure
%
% Syntax:
%       clearInversion
%
% Inputs:
%       id - index of the calling NMR signal in the file list
%
% Outputs:
%       none
%
% Example:
%       clearInversion(1)
%
% Other m-files required:
%       removeInversionFields
%       NUCLEUSinv_updateInterface
%       updatePlotsSignal
%       clearSingleAxis
%       clearAllAxes
%       checkIfInversionExists
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

if isnumeric(id) && ~isempty(INVdata) % clear single inversion
    
    if ~isempty(INVdata{id})
        % remove the data set
        INVdata{id} = [];
        
        % remove temporary data fields
        data = removeInversionFields(data);
        
        % remove the colored background
        strL = get(gui.listbox_handles.signal,'String');
        str1 = data.import.NMR.filesShort{id};
        strL{id} = str1;
        set(gui.listbox_handles.signal,'String',strL);
        
        setappdata(fig,'data',data);
        setappdata(fig,'INVdata',INVdata);
        % update interface
        NUCLEUSinv_updateInterface;
        % update the data plot axes
        updatePlotsSignal;
        
        % clear inversion axes
        clearSingleAxis(gui.axes_handles.rtd);
        clearSingleAxis(gui.axes_handles.psd);
        % clear the info fields
        set(gui.listbox_handles.info_signal,'String',' ');
        set(gui.listbox_handles.info_dist,'String',' ');
        set(gui.listbox_handles.info_cps,'String',' ');
        
    else
        helpdlg('Cannot CLEAR inversion because there is no inversion set!',...
            'clearInversion: Run inversion first.');
    end
    
else % clear all inversions
    
    % if all inversions are deleted also all axes can be cleared
    clearAllAxes(fig);
    
    % check if there is at least one inversion set
    foundINV = checkIfInversionExists(INVdata);
    
    if foundINV        
        INVdata = cell(length(data.import.NMR.filesShort),1);
        
        % remove temporary data fields
        data = removeInversionFields(data);
        % remove the green color
        strL = data.import.NMR.filesShort';
        set(gui.listbox_handles.signal,'String',strL);
        
        setappdata(fig,'data',data);
        setappdata(fig,'INVdata',INVdata);
        % update interface
        NUCLEUSinv_updateInterface;
        % update the data plot axes
        updatePlotsSignal;
                
        % clear inversion axes
        clearSingleAxis(gui.axes_handles.rtd);
        clearSingleAxis(gui.axes_handles.psd);
        % clear the info fields
        set(gui.listbox_handles.info_signal,'String',' ');
        set(gui.listbox_handles.info_dist,'String',' ');
        set(gui.listbox_handles.info_cps,'String',' ');
        
    else
        helpdlg('Cannot CLEAR inversions because there is no inversion set!',...
            'removeInversionSetAll: Run inversion first.');
    end
    
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