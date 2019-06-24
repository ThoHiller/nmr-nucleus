function uncheckImportMenus
%uncheckImportMenus unchecks all import menus in NUCLEUSinv
%
% Syntax:
%       uncheckImportMenus
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       uncheckImportMenus
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
% See also: NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');

% uncheck all import menus
set(gui.menu.file_import_lastimport,'Checked','off');
set(gui.menu.file_import_lab_rwth_ascii,'Checked','off');
set(gui.menu.file_import_lab_rwth_field,'Checked','off');
set(gui.menu.file_import_lab_rwth_dart,'Checked','off');
set(gui.menu.file_import_lab_corelab,'Checked','off');
set(gui.menu.file_import_lab_mouse,'Checked','off');
set(gui.menu.file_import_lab_liag_single,'Checked','off');
set(gui.menu.file_import_lab_liag_project,'Checked','off');
set(gui.menu.file_import_lab_bgr_std,'Checked','off');
set(gui.menu.file_import_lab_bgr_org,'Checked','off');
set(gui.menu.file_import_lab_bgr_mat,'Checked','off');
set(gui.menu.file_import_lab_bam_tom,'Checked','off');
set(gui.menu.file_import_lab_ascii_T1,'Checked','off');
set(gui.menu.file_import_lab_ascii_T2,'Checked','off');
set(gui.menu.file_import_lab_excel_T1,'Checked','off');
set(gui.menu.file_import_lab_excel_T2,'Checked','off');
set(gui.menu.file_import_nmrinv_file,'Checked','off');
set(gui.menu.file_import_nmrmod_file,'Checked','off');
set(gui.menu.file_import_nmrmod_gui,'Checked','off');

% update GUI data
setappdata(fig,'gui',gui);

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