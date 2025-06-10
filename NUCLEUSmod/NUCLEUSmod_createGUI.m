function NUCLEUSmod_createGUI(h,wbon)
%NUCLEUSmod_createGUI controls the creation of all GUI elements
%
% Syntax:
%       NUCLEUSmod_createGUI(h,wbon)
%
% Inputs:
%       h - figure handle
%       wbon - show wait-bar (yes=1, no=0)
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSmod_createGUI(gcf,1)
%
% Other m-files required:
%       fixAxes.m
%       NUCLEUSmod_createMenus.m
%       NUCLEUSmod_createPanelGeometry.m
%       NUCLEUSmod_createPanelCPS.m
%       NUCLEUSmod_createPanelNMR.m
%       NUCLEUSmod_createPanelPlots.m
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

%% get figure data
gui = getappdata(h,'gui');
data = getappdata(h,'data');
myui = gui.myui;

%% init wait-bar
if wbon
    hwb = waitbar(0,'loading ...','Name','NUCLEUSmod initialization','Visible','off');
    steps = 5;
    if ~isempty(h)
        posf = get(h,'Position');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    end
    set(hwb,'Visible','on');
end

data.info.ToolTips = 'off';

%% uimenus
if wbon
    waitbar(1/steps,hwb,'loading GUI elements - menus');
end
gui = NUCLEUSmod_createMenus(gui);

%% MAIN GUI "BOX"
% make everything invisible during creation
gui.main = uix.VBox('Parent',gui.figh,'Visible','off');
% gui.main = uix.HBox('Parent',gui.figh);

% top part for settings and plots
gui.top = uix.HBox('Parent',gui.main,'Spacing',0);
% bottom part for the statusbar
gui.bottom = uix.HBox('Parent',gui.main);
% minimum heights of main elements
set(gui.main,'Heights',[-1 20],'MinimumHeights',[250+2*22 20]);

% all control panels are on the left inside a vertically scrollable panel
gui.left = uix.ScrollingPanel('Parent',gui.top);
% all graphics are on the right inside a vertical box
gui.right = uix.VBox('Parent',gui.top,'Spacing',3);
% fix size of the settings side to 400 pixel
set(gui.top,'Widths',[400 -1]);
set(gui.top,'MinimumWidths',[400 200]);

%% A. settings column
gui.panels.main = uix.VBox('Parent',gui.left);
gui.panels.geometry.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Geometry',...
    'TitleColor',myui.colors.GEO,...
    'ForegroundColor',myui.colors.BoxTitle,...
    'MinimizeFcn',@minimizePanel);
gui.panels.cps.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','Pressure / Saturation',...
    'TitleColor',myui.colors.CPS,...
    'ForegroundColor',myui.colors.BoxTitle,...
    'MinimizeFcn',@minimizePanel);
gui.panels.nmr.main = uix.BoxPanel('Parent',gui.panels.main,...
    'Title','NMR',...
    'TitleColor',myui.colors.NMR,...
    'ForegroundColor',myui.colors.BoxTitle,...
    'MinimizeFcn',@minimizePanel);

% adjust the heights of all left-column-panels
myui.heights = [22 22 22; 249 -1 170];
% panel header is always 22 high
set(gui.panels.main,'Heights',myui.heights(2,:),...
    'MinimumHeights',[22 22 22]);
set(gui.left,'Heights',-1,'MinimumHeights',249+250+170+20);

% 1. geometry panel
if wbon
    waitbar(2/steps,hwb,'loading GUI elements - geometry');
end
[gui,myui] = NUCLEUSmod_createPanelGeometry(data,gui,myui);

% 2. CPS panel
if wbon
    waitbar(3/steps,hwb,'loading GUI elements - pressure');
end
[gui,myui] = NUCLEUSmod_createPanelCPS(data,gui,myui);

% 3. NMR panel
if wbon
    waitbar(4/steps,hwb,'loading GUI elements - NMR');
end
[gui,myui] = NUCLEUSmod_createPanelNMR(data,gui,myui);


%% B. graphics column
if wbon
    waitbar(5/steps,hwb,'loading GUI elements - graphics');
end
[gui,myui] = NUCLEUSmod_createPanelPlots(gui,myui);

% delete wait-bar
if wbon
    delete(hwb);
end

%% C. status bar
gui = NUCLEUSmod_createStatusbar(gui);

%% finalize
% make the main GUI visible again; "gui" needs to be saved because
% otherwise "fixAxes" throws an error
setappdata(h,'gui',gui);
fixVerticalTextAlignment(h);
set(gui.main,'Visible','on');

% update the GUI data
gui.myui = myui;
setappdata(h,'gui',gui);
setappdata(h,'data',data);
displayStatusText(gui,'NUCLEUSmod successfully started');
updateStatusInformation(h);
fixAxes(gui.plots.cps.box);

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