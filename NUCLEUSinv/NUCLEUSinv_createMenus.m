function gui = NUCLEUSinv_createMenus(data,gui)
%NUCLEUSinv_createMenus creates all GUI menus
%
% Syntax:
%       gui = NUCLEUSinv_createMenus(gui,data)
%
% Inputs:
%       data - figure data structure
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% 1. File
gui.menu.file = uimenu(gui.figh,...
    'Label','File','Enable','off');

% 1.1 Import
gui.menu.file_import = uimenu(gui.menu.file,...
    'Label','Import');
% 1.1.0 Last import
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
% 1.1.1.2.2 BGR mat
gui.menu.file_import_lab_bgr_mat = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','BGR mat','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.3 Mouse CPMG data, single data subfolders from CPMG
gui.menu.file_import_lab_bgr_mouse_cpmg = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','MouseCPMG','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.4 Mouse plus Lift, all data subfolders from t1test,...
% cpmgfastautotest, or (old Prospa Versions) cpmgfastauto
gui.menu.file_import_lab_bgr_mouse_lift = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','MouseLift','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.5 Helios CPMG standard data, single subfolders with individual data files
gui.menu.file_import_lab_bgr_helios_cpmg = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','HeliosCPMG','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.2.6 Helios series of CPMG data, several files of a series in the target
% folder, as used e.g. for T1 measurements
gui.menu.file_import_lab_bgr_helios_series = uimenu(gui.menu.file_import_lab_bgr,...
    'Label','HeliosSeries','Tag','Lab','Callback',@onMenuImport);

% 1.1.1.3 LIAG
gui.menu.file_import_lab_liag = uimenu(gui.menu.file_import_lab,...
    'Label','LIAG');
% 1.1.1.3.1 LIAG
gui.menu.file_import_lab_liag_single = uimenu(gui.menu.file_import_lab_liag,...
    'Label','LIAG single','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.3.2 LIAG
gui.menu.file_import_lab_liag_project = uimenu(gui.menu.file_import_lab_liag,...
    'Label','LIAG from project','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.3.3 LIAG
gui.menu.file_import_lab_liag_core = uimenu(gui.menu.file_import_lab_liag,...
    'Label','LIAG core','Tag','Lab','Callback',@onMenuImport);

% 1.1.1.4 RWTH
gui.menu.file_import_lab_rwth = uimenu(gui.menu.file_import_lab,...
    'Label','RWTH');
% 1.1.1.4.1 IBAC
gui.menu.file_import_lab_ibac = uimenu(gui.menu.file_import_lab_rwth,...
    'Label','IBAC');
% 1.1.1.4.1.1 IBAC
gui.menu.file_import_lab_ibac_pm5 = uimenu(gui.menu.file_import_lab_ibac,...
    'Label','PM5','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.4.1.2 IBAC
gui.menu.file_import_lab_ibac_pm25 = uimenu(gui.menu.file_import_lab_ibac,...
    'Label','PM25','Tag','Lab','Callback',@onMenuImport);

% 1.1.1.4.2 GGE
gui.menu.file_import_lab_gge = uimenu(gui.menu.file_import_lab_rwth,...
    'Label','GGE');
% 1.1.1.4.2.1 GGE ascii
gui.menu.file_import_lab_gge_ascii = uimenu(gui.menu.file_import_lab_gge,...
    'Label','GGE ascii','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.4.2.2 GGE field
gui.menu.file_import_lab_gge_field = uimenu(gui.menu.file_import_lab_gge,...
    'Label','GGE field','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.4.2.3 GGE Dart
gui.menu.file_import_lab_gge_dart = uimenu(gui.menu.file_import_lab_gge,...
    'Label','GGE Dart','Tag','Lab','Callback',@onMenuImport);

% 1.1.1.5 OTHER
gui.menu.file_import_lab_other = uimenu(gui.menu.file_import_lab,...
    'Label','OTHER');
% 1.1.1.5.1 CoreLab ascii
gui.menu.file_import_lab_corelab = uimenu(gui.menu.file_import_lab_other,...
    'Label','CoreLab ascii','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.5.2 MOUSE
gui.menu.file_import_lab_mouse = uimenu(gui.menu.file_import_lab_other,...
    'Label','MOUSE','Tag','Lab','Callback',@onMenuImport);
% 1.1.1.5.3 DART (University of Vienna)
gui.menu.file_import_lab_dart = uimenu(gui.menu.file_import_lab_other,...
    'Label','DART','Tag','Lab','Callback',@onMenuImport);

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
% 1.2.0 Last export
lastexport = gui.myui.inidata.lastexport;
gui.menu.file_export_lastexport = uimenu(gui.menu.file_export,...
    'Label',lastexport,'Callback',@onMenuExportData);
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
% 1.2.1.10 BGR data repository ascii
gui.menu.file_export_data_bgr_repo = uimenu(gui.menu.file_export_data,...
    'Label','BGR repository','Callback',@onMenuExportData);

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
    'Label','Quit','Callback',@onMenuRestartQuit);

%% 2. View
gui.menu.view = uimenu(gui.figh,...
    'Label','View','Enable','off');

% 2.1 tooltips (on/off)
gui.menu.view_tooltips = uimenu(gui.menu.view,...
    'Label','Tooltips','Checked','off','Callback',@onMenuView);
switch gui.myui.inidata.tooltips
    case 'on'
        set(gui.menu.view_tooltips,'Checked','on');
    case 'off'
        set(gui.menu.view_tooltips,'Checked','off');
end
% 2.2 Figure Toolbar
gui.menu.view_toolbar = uimenu(gui.menu.view,...
    'Label','Figure Toolbar','Callback',@onMenuView);

% 2.3 INFO fields in plot panels (on/off)
gui.menu.view_infofields = uimenu(gui.menu.view,...
    'Label','INFO fields','Separator','on','Callback',@onMenuView);

% 2.4 inversion info on command line (on/off)
gui.menu.view_invinfo = uimenu(gui.menu.view,...
    'Label','CLI Inv. Info','Callback',@onMenuView);
switch gui.myui.inidata.invinfo
    case 'on'
        set(gui.menu.view_invinfo,'Checked','on');
    case 'off'
        set(gui.menu.view_invinfo,'Checked','off');
end

% 2.5 figures
gui.menu.extra_graphics = uimenu(gui.menu.view,...
    'Label','Figures','Separator','on');
% 2.5.1 parameter file info
gui.menu.extra_graphics_parinfo = uimenu(gui.menu.extra_graphics,...
    'Label','Parameter Info','Callback',@onMenuViewFigures);
% 2.5.2 fit statistics
gui.menu.extra_graphics_stats = uimenu(gui.menu.extra_graphics,...
    'Label','Fit statistics','Callback',@onMenuViewFigures);
switch gui.myui.inidata.expertmode
    case 'on'
        % 2.5.3 amplitude over time
        gui.menu.extra_graphics_amp = uimenu(gui.menu.extra_graphics,...
            'Label','AMP-TLGM-SNR','Callback',@onMenuViewFigures);
        % 2.5.4 amplitude vs tlgm
        gui.menu.extra_graphics_amp2 = uimenu(gui.menu.extra_graphics,...
            'Label','AMP vs TLGM','Callback',@onMenuViewFigures);
        % 2.5.5 relaxation time distribution over time
        gui.menu.extra_graphics_rtd = uimenu(gui.menu.extra_graphics,...
            'Label','RTD','Callback',@onMenuViewFigures);
    case 'off'
        % 2.5.3 amplitude over time
        gui.menu.extra_graphics_amp = uimenu(gui.menu.extra_graphics,...
            'Label','AMP-TLGM-SNR','Enable','off','Callback',@onMenuViewFigures);
        % 2.5.4 amplitude vs tlgm
        gui.menu.extra_graphics_amp2 = uimenu(gui.menu.extra_graphics,...
            'Label','AMP vs TLGM','Enable','off','Callback',@onMenuViewFigures);
        % 2.5.5 relaxation time distribution over time
        gui.menu.extra_graphics_rtd = uimenu(gui.menu.extra_graphics,...
            'Label','RTD','Enable','off','Callback',@onMenuViewFigures);   
end

% 2.6 PhaseView GUI
gui.menu.extra_phaseview = uimenu(gui.menu.view,...
    'Label','PhaseView GUI','Enable','off','Separator','on','Callback',@onMenuSubGUIs);
% 2.7 ConductVew GUI -> hydraulic conductivity
gui.menu.extra_conduct = uimenu(gui.menu.view,...
    'Label','ConductView GUI','Enable','off','Callback',@onMenuSubGUIs);
% 2.8 FixedTimeView GUI
gui.menu.extra_fixedtime = uimenu(gui.menu.view,...
    'Label','FixedTimeView GUI','Enable','off','Callback',@onMenuSubGUIs);
% 2.9 UncertaintyVIEW GUI
gui.menu.extra_uncert = uimenu(gui.menu.view,...
    'Label','UncertView GUI','Enable','off','Callback',@onMenuSubGUIs);

%% 3. Extras
gui.menu.extra = uimenu(gui.figh,...
    'Label','Extra','Enable','off');

% 3.1 expert mode (on/off)
gui.menu.extra_expert = uimenu(gui.menu.extra,...
    'Label','Expert Mode','Callback',@onMenuExpert);
switch gui.myui.inidata.expertmode
    case 'on'
        set(gui.menu.extra_expert,'Checked','on');
    case 'off'
        set(gui.menu.extra_expert,'Checked','of');
end

% 3.2 optimization toolbox (on/off)
switch gui.myui.inidata.expertmode
    case 'on'
        switch data.info.has_optim
            case 'on'
                gui.menu.extra_solver = uimenu(gui.menu.extra,...
                    'Label','LSQ Solver','Enable','on');
            case 'off'
                gui.menu.extra_solver = uimenu(gui.menu.extra,...
                    'Label','LSQ Solver','Enable','off');
        end        
    case 'off'
        gui.menu.extra_solver = uimenu(gui.menu.extra,...
            'Label','LSQ Solver','Enable','off');
end
gui.menu.extra_solver_lsqlin = uimenu(gui.menu.extra_solver,...
    'Label','LSQLIN (Optim. TB)','Callback',@onMenuSolver);
gui.menu.extra_solver_lsqnonneg = uimenu(gui.menu.extra_solver,...
    'Label','LSQNONNEG (default)','Checked','on','Callback',@onMenuSolver);

% 3.3 flag for LSQLIN option to set RTs smaller than min(TE)/5 to 0
gui.menu.extra_lsqlin_echoflag = uimenu(gui.menu.extra,...
    'Label','RTD<TE/5=0','Enable','off',...
    'Callback',@onMenuExtraEchoFlag);

% 3.4 joint inversion (on/off)
gui.menu.extra_joint = uimenu(gui.menu.extra,...
    'Label','Joint Inversion','Checked','off','Separator','on',...
    'Callback',@onMenuJointInversion);
switch gui.myui.inidata.expertmode
    case 'on'
        set(gui.menu.extra_joint,'Enable','on');
    case 'off'
        set(gui.menu.extra_joint,'Enable','off');
end

% 3.5 set inversion bounds for surface relaxivity rho
gui.menu.extra_joint_rhobounds = uimenu(gui.menu.extra,...
    'Label','Surface relaxivity bounds','Enable','off',...
    'Callback',@onMenuExtraRhoBounds);


%% 4. Color theme
gui.menu.color_theme = uimenu(gui.figh,...
    'Label','Color Theme','Enable','off');

% 4.1 default color theme
gui.menu.color_theme_standard = uimenu(gui.menu.color_theme,...
    'Label','standard','Callback',@onMenuExtraColor);
% 4.2 basic color theme
gui.menu.color_theme_basic = uimenu(gui.menu.color_theme,...
    'Label','basic','Callback',@onMenuExtraColor);
% 4.3 dark color theme
gui.menu.color_theme_dark = uimenu(gui.menu.color_theme,...
    'Label','dark','Callback',@onMenuExtraColor);
% 4.4 black color theme
gui.menu.color_theme_black = uimenu(gui.menu.color_theme,...
    'Label','black','Callback',@onMenuExtraColor);
switch gui.myui.inidata.colortheme
    case 'standard'
        set(gui.menu.color_theme_standard,'Checked','on');
    case 'basic'
        set(gui.menu.color_theme_basic,'Checked','on');
    case 'dark'
        set(gui.menu.color_theme_dark,'Checked','on');
    case 'black'
        set(gui.menu.color_theme_black,'Checked','on');
end

%% 5. Help
gui.menu.help = uimenu(gui.figh,...
    'Label','Help','Enable','off');

% 5.1 About
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