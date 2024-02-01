function enableGUIelements(importtype)
%enableGUIelements activates all necessary GUI elements after successful
%data import
%
% Syntax:
%       enableGUIelements(importtype)
%
% Inputs:
%       importtype - char being either 'ASCII', 'EXCEL', 'MOD' or 'NMR'
%
% Outputs:
%       none
%
% Example:
%       enableGUIelements('NMR')
%
% Other m-files required:
%       onMenuExpert
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

%% switch depending on import type/format
switch importtype
    case {'ASCII','EXCEL','MOD'}
        % process panel
        data.process.end = 0;
        data.process.gatetype = 'raw';       
    case 'NMR'
        % process panel
        data.process.end = 0;
        switch data.import.fileformat
            case {'dart','field','helios'}
                data.process.gatetype = 'raw';
            otherwise
                data.process.gatetype = 'log';
        end
end

% process panel - contd
data.process.norm = 0;
data.process.timescale = 's';
data.process.timefac = 1;

% invstd panel
data.invstd.invtype = 'NNLS';
data.invstd.regtype = 'manual';
data.invstd.lambda = 1;
data.invstd.Lorder = 1;
set(gui.push_handles.invstd_run,'Enable','on');

% petro panel
data.param.calibVol = 1;
data.param.calibAmp = 1;
% RAW plot panel
data.param.sampVol = 1;
data.invstd.porosity = 1;
data.calib.vol = data.param.calibVol;
data.calib.amp = data.param.calibAmp;
data.calib.fac = 1;
data.calib.name = '';

% PROC plot panel
set(gui.cm_handles.axes_proc_xaxis,'Enable','on');
set(gui.cm_handles.axes_proc_yaxis,'Enable','on');
% RAW plot panel
set(gui.cm_handles.axes_raw_xaxis,'Enable','on');
set(gui.cm_handles.axes_raw_yaxis,'Enable','on');
% ALL plot panel
set(gui.cm_handles.axes_all_xaxis,'Enable','on');
set(gui.cm_handles.axes_all_yaxis,'Enable','on');
% RTD plot panel
set(gui.cm_handles.axes_rtd_view,'Enable','on');
% PSD plot panel
set(gui.cm_handles.axes_psd_view,'Enable','on');
% PSDJ plot panel
set(gui.cm_handles.axes_psdj_view,'Enable','on');
% INFO fields
set(gui.listbox_handles.info_signal,'String',' ');
set(gui.listbox_handles.info_dist,'String',' ');
set(gui.listbox_handles.info_cps,'String',' ');

% update GUI data
setappdata(fig,'data',data);
setappdata(fig,'gui',gui);

switch data.info.ExpertMode
    case 'on'
        set(gui.menu.extra_expert,'Checked','off');
    case 'off'
        set(gui.menu.extra_expert,'Checked','on');
end
onMenuExpert(gui.menu.extra_expert);


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