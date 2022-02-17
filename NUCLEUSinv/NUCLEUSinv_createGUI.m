function NUCLEUSinv_createGUI(h,wbon)
%NUCLEUSinv_createGUI controls the creation of all GUI elements
%
% Syntax:
%       NUCLEUSinv_createGUI(h,wbon)
%
% Inputs:
%       h - figure handle
%       wbon - show wait-bar (yes=1, no=0)
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSinv_createGUI(gcf,1)
%
% Other m-files required:
%       changeColorTheme.m
%       NUCLEUSinv_createMenus.m
%       NUCLEUSinv_createPanelData.m
%       NUCLEUSinv_createPanelProcess.m
%       NUCLEUSinv_createPanelPetro
%       NUCLEUSinv_createPanelInversionStd.m
%       NUCLEUSinv_createPanelInversionJoint.m
%       NUCLEUSinv_createPanelPlots.m
%       NUCLEUSinv_createPanelInfo.m
%       NUCLEUSinv_createStatusbar.m
%       switchToolTips.m
%       updateStatusInformation.m
%       updateToolTips.m
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

%% get figure data
gui = getappdata(h,'gui');
data = getappdata(h,'data');

%% init wait-bar
if wbon
    hwb = waitbar(0,'loading ...','Name','NUCLEUSinv initialization','Visible','off');
    steps = 8;
    if ~isempty(h)
        posf = get(h,'Position');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    end
    set(hwb,'Visible','on');
end

%% import ini-file
gui = NUCLEUSinv_processINI(gui);
myui = gui.myui;
% apply color theme
myui.colors = getColorTheme('INV',gui.myui.inidata.colortheme);
% get import path
data.import.path = myui.inidata.importpath;
% info stuff
data.info.ExpertMode = myui.inidata.expertmode;
data.info.InvInfo = myui.inidata.invinfo;
data.info.ToolTips = myui.inidata.tooltips;

%% uimenus
if wbon
    waitbar(1/steps,hwb,'loading GUI elements - menus');
end
gui = NUCLEUSinv_createMenus(data,gui);

%% MAIN GUI "BOX"
% make everything invisible during creation
gui.main = uix.VBox('Parent',gui.figh,'Visible','off');
% gui.main = uix.VBox('Parent',gui.figh);

% top part for settings and plots
gui.top = uix.HBoxFlex('Parent',gui.main,'Spacing',0);
% bottom part for the statusbar
gui.bottom = uix.HBox('Parent',gui.main);
% minimum heights of main elements
set(gui.main,'Heights',[-1 20],'MinimumHeights',[250+4*22 20]);

% all control panels are on the left inside a vertically scrollable panel
gui.left = uix.ScrollingPanel('Parent',gui.top);
% all graphics are in the center inside a vertical box
gui.center = uix.VBox('Parent',gui.top,'Spacing',3);
% all info fields are on the right inside a vertical box
gui.right = uix.HBox('Parent',gui.top,'Spacing',3);
% fix size of the settings side to 400 pixel
% set(gui.top,'Widths',[400 -1 210]);
set(gui.top,'Widths',[400 -1 -1]);
set(gui.top,'MinimumWidths',[400 200 10]);

%% A. settings column
gui.panels.main = uix.VBox('Parent',gui.left);
gui.panels.data.main = uix.BoxPanel('Parent',gui.panels.main,'Title','NMR Data',...
    'TitleColor',myui.colors.BoxDAT,'ForegroundColor',myui.colors.BoxTitle);
gui.panels.process.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Simple Processing','MinimizeFcn',@minimizePanel,...
    'TitleColor',myui.colors.BoxPRC,'ForegroundColor',myui.colors.BoxTitle);
gui.panels.petro.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Petro Parameter','MinimizeFcn',@minimizePanel,...
    'TitleColor',myui.colors.BoxCBW,'ForegroundColor',myui.colors.BoxTitle);
gui.panels.invstd.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Standard Inversion','MinimizeFcn',@minimizePanel,...
    'TitleColor',myui.colors.BoxINV,'ForegroundColor',myui.colors.BoxTitle);
gui.panels.invjoint.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Joint Inversion','MinimizeFcn',@minimizePanel,...
    'TitleColor',myui.colors.BoxCPS,'ForegroundColor',myui.colors.BoxTitle);

% adjust the heights of all left-column-panels
myui.heights = [250 22 22 22 22; -1 109 165 190 299];
% panel header is always 22 high
set(gui.panels.main,'Heights',myui.heights(2,:),...
    'MinimumHeights',[250 22 22 22 22]);
set(gui.left,'Heights',-1,'MinimumHeights',250+109+22+190+22);

% 1. data panel
if wbon
    waitbar(2/steps,hwb,'loading GUI elements - data');
end
[gui,myui] = NUCLEUSinv_createPanelData(gui,myui);

% 2. processing data panel
if wbon
    waitbar(3/steps,hwb,'loading GUI elements - process');
end
[gui,myui] = NUCLEUSinv_createPanelProcess(data,gui,myui);

% 3. petro parameter panel
if wbon
    waitbar(4/steps,hwb,'loading GUI elements - petro');
end
[gui,myui] = NUCLEUSinv_createPanelPetro(data,gui,myui);

% 4. standard inversion panel
if wbon
    waitbar(5/steps,hwb,'loading GUI elements - standard inversion');
end
[gui,myui] = NUCLEUSinv_createPanelInversionStd(data,gui,myui);

% 5. joint inversion panel
if wbon
    waitbar(6/steps,hwb,'loading GUI elements - joint inversion');
end
% adjust the default joint inversion method depending on Optimization
% toolbox availability
switch data.info.has_optim
    case 'on'
        data.invjoint.invtype = 'free';
    case 'off'
        data.invjoint.invtype = 'fixed';
end
[gui,myui] = NUCLEUSinv_createPanelInversionJoint(data,gui,myui);

%% B. graphics column
if wbon
    waitbar(7/steps,hwb,'loading GUI elements - graphics');
end
[gui,myui] = NUCLEUSinv_createPanelPlots(gui,myui);

%% C. Info column
if wbon
    waitbar(8/steps,hwb,'loading GUI elements - info column');
end
gui = NUCLEUSinv_createPanelInfo(gui);

% delete wait-bar
if wbon
    delete(hwb);
end

%% D. status bar
gui = NUCLEUSinv_createStatusbar(gui);

%% finalize
% minimize all petro and joint inversion related panels at startup
tmp_h = myui.heights(2,:);
tmp_h(3) = myui.heights(1,3);
tmp_h(5) = myui.heights(1,5);
set(gui.panels.main,'Heights',tmp_h);
set(gui.panels.petro.main,'Minimized',true);
set(gui.panels.invjoint.main,'Minimized',true);
set(gui.center,'Heights',[-1 -1 22]);
set(gui.plots.CPSPanel,'Minimized',true);
% minimum size of bottom status bar
set(gui.bottom,'MinimumWidths',610);

% make the GUI visible again; "gui" needs to be saved because
% otherwise "fixAxes" throws an error (in NUCLEUSmod); strangely here it
% also works without it, but I put it for consistency reasons
setappdata(h,'gui',gui);
changeColorTheme('INV',myui.colors.theme);
set(gui.main,'Visible','on');

%% enable all menus
set(gui.menu.file,'Enable','on');
set(gui.menu.view,'Enable','on');
set(gui.menu.extra,'Enable','on');
set(gui.menu.color_theme,'Enable','on');
set(gui.menu.help,'Enable','on');

%% process tooltip preferences
switchToolTips(gui,myui.inidata.tooltips);

%% update the GUI data
gui.myui = myui;
setappdata(h,'gui',gui);
setappdata(h,'data',data);
displayStatusText(gui,'NUCLEUSinv successfully started');
updateStatusInformation(h);
updateToolTips;

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