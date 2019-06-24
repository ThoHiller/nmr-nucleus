function gui = NUCLEUSinv_createMenus(gui)
%NUCLEUSinv_createMenus creates all GUI menus
%
% Syntax:
%       gui = NUCLEUSinv_createMenus(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       gui = NUCLEUSinv_createMenus(gui)
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

%% 1. File
gui.menu.file = uimenu(gui.figh,...
    'Label','File','Enable','off');

% 1.1 Import
gui.menu.file_import = uimenu(gui.menu.file,...
    'Label','Import');
%
lastimport = gui.myui.inidata.lastimport;
ind = strfind(lastimport,'_');
tag = lastimport(1:ind-1);
label = lastimport(ind+1:end);
gui.menu.file_import_lastimport = uimenu(gui.menu.file_import,...
    'Label',label,'Tag',tag,'Callback',@onMenuImport);
% 1.1.1 Lab
gui.menu.file_import_lab = uimenu(gui.menu.file_import,...
    'Label','Lab');
% 1.1.1.1 BAM
gui.menu.file_import_lab_bam = uimenu(gui.menu.file_import_lab,...
    'Label','BAM');
% 1.1.1.1.1 BAM TOM
gui.menu.file_import_lab_bam_tom = uimenu(gui.menu.file_import_lab_bam,...
    'Label','BAM TOM','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2 BGR
gui.menu.file_import_lab_bgr = uimenu(gui.menu.file_import_lab,...
    'Label','BGR');
% 1.1.1.2.1 BGR std
gui.menu.file_import_lab_bgr_std = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','BGR std','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.2 BGR org
gui.menu.file_import_lab_bgr_org = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','BGR org','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.3 BGR mat
gui.menu.file_import_lab_bgr_mat = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','BGR mat','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.3 CoreLab ascii
gui.menu.file_import_lab_corelab = uimenu(gui.menu.file_import_lab,...
    'Label','CoreLab ascii','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.4 LIAG
gui.menu.file_import_lab_liag = uimenu(gui.menu.file_import_lab,...
    'Label','LIAG');
% 1.1.1.4.1 LIAG
gui.menu.file_import_lab_liag_single = uimenu(gui.menu.file_import_lab_liag,...
    'Label','LIAG single','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.4.2 LIAG
gui.menu.file_import_lab_liag_project = uimenu(gui.menu.file_import_lab_liag,...
    'Label','LIAG from project','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.5 MOUSE
gui.menu.file_import_lab_mouse = uimenu(gui.menu.file_import_lab,...
    'Label','MOUSE','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.6 RWTH
gui.menu.file_import_lab_rwth = uimenu(gui.menu.file_import_lab,...
    'Label','RWTH');
% 1.1.1.6.1 RWTH ascii
gui.menu.file_import_lab_rwth_ascii = uimenu(gui.menu.file_import_lab_rwth,...
    'Label','RWTH ascii','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.6.2 RWTH field
gui.menu.file_import_lab_rwth_field = uimenu(gui.menu.file_import_lab_rwth,...
    'Label','RWTH field','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.6.3 Dart
gui.menu.file_import_lab_rwth_dart = uimenu(gui.menu.file_import_lab_rwth,...
    'Label','Dart','Tag','Lab','Callback',@onMenuImport);

% 1.1.2 Ascii
gui.menu.file_import_ascii = uimenu(gui.menu.file_import,...
    'Label','Ascii');
% 1.1.2.1 T1
gui.menu.file_import_lab_ascii_T1 = uimenu(gui.menu.file_import_ascii,...
    'Label','T1','Tag','Ascii','Callback',@onMenuImport);
% 1.1.2.2 T2
gui.menu.file_import_lab_ascii_T2 = uimenu(gui.menu.file_import_ascii,...
    'Label','T2','Tag','Ascii','Callback',@onMenuImport);

% 1.1.3 Excel
gui.menu.file_import_excel = uimenu(gui.menu.file_import,...
    'Label','Excel');
% 1.1.3.1 T1
gui.menu.file_import_lab_excel_T1 = uimenu(gui.menu.file_import_excel,...
    'Label','T1','Tag','Excel','Callback',@onMenuImport);
% 1.1.3.2 T2
gui.menu.file_import_lab_excel_T2 = uimenu(gui.menu.file_import_excel,...
    'Label','T2','Tag','Excel','Callback',@onMenuImport);

% 1.1.4 NUCLEUSinv
gui.menu.file_import_nmrinv = uimenu(gui.menu.file_import,...
    'Label','NUCLEUSinv','Separator','on');
% 1.1.4.1 NUCLEUSinv session file
gui.menu.file_import_nmrinv_file = uimenu(gui.menu.file_import_nmrinv,...
    'Label','Session','Tag','NUCLEUSinv','Callback',@onMenuImport);

% 1.1.5 NUCLEUSmod
gui.menu.file_import_nmrmod = uimenu(gui.menu.file_import,...
    'Label','NUCLEUSmod');
% 1.1.5.1 NUCLEUSmod from file
gui.menu.file_import_nmrmod_file = uimenu(gui.menu.file_import_nmrmod,...
    'Label','File','Tag','NUCLEUSmod','Callback',@onMenuImport);
% 1.1.5.2 NUCLEUSmod from GUI
gui.menu.file_import_nmrmod_gui = uimenu(gui.menu.file_import_nmrmod,....
    'Label','GUI','Tag','NUCLEUSmod','Callback',@onMenuImport);

% 1.2 Export
gui.menu.file_export = uimenu(gui.menu.file,...
    'Label','Export');
% 1.2.1 Data
gui.menu.file_export_data = uimenu(gui.menu.file_export,...
    'Label','Data');
% 1.2.1.1 GUI raw data mat-file
gui.menu.file_export_data_GUImat = uimenu(gui.menu.file_export_data,...
    'Label','NUCLEUSinv (raw)','Callback',@onMenuExportData);
% 1.2.1.2 GUI session mat-file
gui.menu.file_export_data_GUImat = uimenu(gui.menu.file_export_data,...
    'Label','NUCLEUSinv (session)','Callback',@onMenuExportData);
% 1.2.1.3 Inversion results single xls
gui.menu.file_export_data_invstd_excel = uimenu(gui.menu.file_export_data,...
    'Label','EXCEL single (std)','Separator','on','Callback',@onMenuExportData);
% 1.2.1.4 Inversion results single mat-file
gui.menu.file_export_data_invstd_mat_single = uimenu(gui.menu.file_export_data,...
    'Label','MAT single (std)','Callback',@onMenuExportData);
% 1.2.1.5 Inversion results all mat-file
gui.menu.file_export_data_invstd_mat_all = uimenu(gui.menu.file_export_data,...
    'Label','MAT all (std)','Callback',@onMenuExportData);
% 1.2.1.6 Joint Inversion results xls
gui.menu.file_export_data_invjoint_excel = uimenu(gui.menu.file_export_data,...
    'Label','EXCEL all (joint)','Separator','on','Enable','off',...
    'Callback',@onMenuExportData);
% 1.2.1.7 Joint Inversion results mat-file
gui.menu.file_export_data_invjoint_mat = uimenu(gui.menu.file_export_data,...
    'Label','MAT all (joint)','Enable','off','Callback',@onMenuExportData);
% 1.2.1.8 LIAG archive
gui.menu.file_export_data_liag_archive = uimenu(gui.menu.file_export_data,...
    'Label','LIAG archive','Separator','on','Callback',@onMenuExportData);
% 1.2.1.9 LIAG CSV T2
gui.menu.file_export_data_liag_csvT2 = uimenu(gui.menu.file_export_data,...
    'Label','LIAG CSV T2','Callback',@onMenuExportData);

% 1.2.2 Graphics
gui.menu.file_export_graphics = uimenu(gui.menu.file_export,...
    'Label','Graphics');
% 1.2.2.1 Layout
gui.menu.file_export_graphics_layout = uimenu(gui.menu.file_export_graphics,...
    'Label','Layout');
% 1.2.2.1.1 Layout vertical
gui.menu.file_export_graphics_layout_vert = uimenu(gui.menu.file_export_graphics_layout,...
    'Label','vert','Checked','on','Callback',@onMenuExportGraphics);
% 1.2.2.1.2 Layout horizontal
gui.menu.file_export_graphics_layout_horz = uimenu(gui.menu.file_export_graphics_layout,...
    'Label','horz','Callback',@onMenuExportGraphics);
% 1.2.2.2 fig
gui.menu.file_export_graphics_fig = uimenu(gui.menu.file_export_graphics,...
    'Label','FIG','Callback',@onMenuExportGraphics);
% 1.2.2.3 png
gui.menu.file_export_graphicspng = uimenu(gui.menu.file_export_graphics,...
    'Label','PNG','Callback',@onMenuExportGraphics);
% 1.2.2.4 tiff
gui.menu.file_export_graphicstiff = uimenu(gui.menu.file_export_graphics,...
    'Label','TIFF','Callback',@onMenuExportGraphics);
% 1.2.2.5 eps
gui.menu.file_export_graphicseps = uimenu(gui.menu.file_export_graphics,...
    'Label','EPS','Callback',@onMenuExportGraphics);

% 1.3 Restart
gui.menu.file_restart = uimenu(gui.menu.file,...
    'Label','Restart','Separator','on','Callback',@onMenuRestartQuit);

% 1.4 Quit
gui.menu.file_quit = uimenu(gui.menu.file,...
    'Label','Quit','Separator','on','Callback',@onMenuRestartQuit);

%% 2. Extras
gui.menu.extra = uimenu(gui.figh,...
    'Label','Extra','Enable','off');

% 2.1 expert mode (on/off)
gui.menu.extra_expert = uimenu(gui.menu.extra,...
    'Label','Expert Mode');
gui.menu.extra_expert_on = uimenu(gui.menu.extra_expert,...
    'Label','On','Callback',@onMenuExpert);
gui.menu.extra_expert_off = uimenu(gui.menu.extra_expert,...
    'Label','Off','Callback',@onMenuExpert);
switch gui.myui.inidata.expertmode
    case 'on'
        set(gui.menu.extra_expert_on,'Checked','on');
    case 'off'
        set(gui.menu.extra_expert_off,'Checked','on');
end

% 2.2 joint inversion (on/off)
switch gui.myui.inidata.expertmode
    case 'on'
        gui.menu.extra_joint = uimenu(gui.menu.extra,...
            'Label','Joint Inversion','Enable','on');
    case 'off'
        gui.menu.extra_joint = uimenu(gui.menu.extra,...
            'Label','Joint Inversion','Enable','off');
end
gui.menu.extra_joint_on = uimenu(gui.menu.extra_joint,...
    'Label','On','Callback',@onMenuJointInversion);
gui.menu.extra_joint_off = uimenu(gui.menu.extra_joint,...
    'Label','Off','Checked','on','Callback',@onMenuJointInversion);


% 2.3 settings
gui.menu.extra_settings = uimenu(gui.menu.extra,...
    'Label','Settings');

% 2.3.1 inversion info (on/off)
gui.menu.extra_settings_invinfo = uimenu(gui.menu.extra_settings,...
    'Label','Inversion Display');
gui.menu.extra_settings_invinfo_on = uimenu(gui.menu.extra_settings_invinfo,...
    'Label','On','Callback',@onMenuExtraShow);
gui.menu.extra_settings_invinfo_off = uimenu(gui.menu.extra_settings_invinfo,...
    'Label','Off','Callback',@onMenuExtraShow);
switch gui.myui.inidata.invinfo
    case 'on'
        set(gui.menu.extra_settings_invinfo_on,'Checked','on');
    case 'off'
        set(gui.menu.extra_settings_invinfo_off,'Checked','on');
end

% 2.3.2 tooltips (on/off)
gui.menu.extra_settings_tooltips = uimenu(gui.menu.extra_settings,...
    'Label','Tooltips');
gui.menu.extra_settings_tooltips_on = uimenu(gui.menu.extra_settings_tooltips,...
    'Label','On','Callback',@onMenuExtraShow);
gui.menu.extra_settings_tooltips_off = uimenu(gui.menu.extra_settings_tooltips,...
    'Label','Off','Callback',@onMenuExtraShow);
switch gui.myui.inidata.tooltips
    case 'on'
        set(gui.menu.extra_settings_tooltips_on,'Checked','on');
    case 'off'
        set(gui.menu.extra_settings_tooltips_off,'Checked','on');
end

% 2.3.3 INFO fields in plot panels (on/off)
gui.menu.extra_settings_infofields = uimenu(gui.menu.extra_settings,...
    'Label','INFO fields');
gui.menu.extra_settings_infofields_on = uimenu(gui.menu.extra_settings_infofields ,...
    'Label','On','Callback',@onMenuExtraShow);
gui.menu.extra_settings_infofields_off = uimenu(gui.menu.extra_settings_infofields,...
    'Label','Off','Checked','on','Callback',@onMenuExtraShow);

% 2.3.4 color theme
gui.menu.extra_settings_theme = uimenu(gui.menu.extra_settings,...
    'Label','Color Theme');
% 2.3.4.1 default color theme
gui.menu.extra_settings_theme_standard = uimenu(gui.menu.extra_settings_theme,...
    'Label','standard','Callback',@onMenuExtraColor);
% 2.3.4.2 basic color theme
gui.menu.extra_settings_theme_basic = uimenu(gui.menu.extra_settings_theme,...
    'Label','basic','Callback',@onMenuExtraColor);
% 2.3.4.3 dark color theme
gui.menu.extra_settings_theme_dark = uimenu(gui.menu.extra_settings_theme,...
    'Label','dark','Callback',@onMenuExtraColor);
switch gui.myui.inidata.colortheme
    case 'standard'
        set(gui.menu.extra_settings_theme_standard,'Checked','on');
    case 'basic'
        set(gui.menu.extra_settings_theme_basic,'Checked','on');
    case 'dark'
        set(gui.menu.extra_settings_theme_dark,'Checked','on');
end

% 2.3.5 joint inversion settings
gui.menu.extra_settings_joint = uimenu(gui.menu.extra_settings,...
    'Label','Joint Inversion','Enable','off','Separator','on');
% 2.3.5.1 joint inversion settings
gui.menu.extra_settings_joint_rhobounds = uimenu(gui.menu.extra_settings_joint,...
    'Label','Surface relaxivity bounds','Callback',@onMenuExtraRhoBounds);

% 2.4 figures
gui.menu.extra_graphics = uimenu(gui.menu.extra,...
    'Label','Figures');
% 2.4.1 parameter file info
gui.menu.extra_graphics_parinfo = uimenu(gui.menu.extra_graphics,...
    'Label','Parameter Info','Callback',@onMenuExtraShow);
% 2.4.2 fit statistics
gui.menu.extra_graphics_stats = uimenu(gui.menu.extra_graphics,...
    'Label','Fit statistics','Callback',@onMenuExtraGraphics);
switch gui.myui.inidata.expertmode
    case 'on'
        % 2.4.3 amplitude over time
        gui.menu.extra_graphics_amp = uimenu(gui.menu.extra_graphics,...
            'Label','AMP-TLGM-SNR','Callback',@onMenuExtraGraphics);
        % 2.4.4 amplitude vs tlgm
        gui.menu.extra_graphics_amp2 = uimenu(gui.menu.extra_graphics,...
            'Label','AMP vs TLGM','Callback',@onMenuExtraGraphics);
        % 2.4.5 relaxation time distribution over time
        gui.menu.extra_graphics_rtd = uimenu(gui.menu.extra_graphics,...
            'Label','RTD','Callback',@onMenuExtraGraphics);
    case 'off'
        % 2.4.3 amplitude over time
        gui.menu.extra_graphics_amp = uimenu(gui.menu.extra_graphics,...
            'Label','AMP-TLGM-SNR','Enable','off','Callback',@onMenuExtraGraphics);
        % 2.4.4 amplitude vs tlgm
        gui.menu.extra_graphics_amp2 = uimenu(gui.menu.extra_graphics,...
            'Label','AMP vs TLGM','Enable','off','Callback',@onMenuExtraGraphics);
        % 2.4.5 relaxation time distribution over time
        gui.menu.extra_graphics_rtd = uimenu(gui.menu.extra_graphics,...
            'Label','RTD','Enable','off','Callback',@onMenuExtraGraphics);
end

% 2.5 PhaseView
gui.menu.extra_phaseview = uimenu(gui.menu.extra,...
    'Label','PhaseView','Callback',@PhaseView);

%% 3. Help
gui.menu.help = uimenu(gui.figh,...
    'Label','Help','Enable','off');

% 3.1 About
gui.menu.help_about = uimenu(gui.menu.help,...
    'Label','About','Callback',@onMenuHelp);

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