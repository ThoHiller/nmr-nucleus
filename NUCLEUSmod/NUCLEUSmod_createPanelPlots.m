function [gui,myui] = NUCLEUSmod_createPanelPlots(gui,myui)
%NUCLEUSmod_createPanelPlots creates graphics panel
%
% Syntax:
%       [gui,myui] = NUCLEUSmod_createPanelPlots(data,gui,myui)
%
% Inputs:
%       gui - figure gui elements structure
%       myui - individual GUI settings structure
%
% Outputs:
%       gui
%       myui
%
% Example:
%       [gui,myui] = NUCLEUSmod_createPanelPlots(gui,myui)
%
% Other m-files required:
%       findjobj.m
%       beautifyAxes.m
% Subfunctions:
%       none
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% create the individual BoxPanels
gui.plots.GeoPanel = uix.BoxPanel('Parent',gui.right,...
    'Title','Pore Size Distribution','TitleColor',myui.colors.GEO,...
    'ForegroundColor',myui.colors.BoxTitle,'Padding',0,...
    'MinimizeFcn',@minimizePanel);
gui.plots.CPSPanel = uix.BoxPanel('Parent',gui.right,...
    'Title','Capillary Pressure Saturation Curve','TitleColor',myui.colors.CPS,......
    'ForegroundColor',myui.colors.BoxTitle,'Padding',0,...
    'MinimizeFcn',@minimizePanel);
gui.plots.NMRPanel = uix.BoxPanel('Parent',gui.right,...
    'Title','NMR Signals','TitleColor',myui.colors.NMR,...
    'ForegroundColor',myui.colors.BoxTitle,'Padding',0,...
    'MinimizeFcn',@minimizePanel);

% adjust heights
set(gui.right,'Heights',[-1 -1 -1]);

%% 1. panel - PSD plot
gui.plots.geo.box = uicontainer('Parent',gui.plots.GeoPanel);
gui.axes_handles.geo = axes('Parent',gui.plots.geo.box,'Box','on');
set(get(gui.axes_handles.geo,'XLabel'),'String','equiv. pore size [m]');
set(get(gui.axes_handles.geo,'YLabel'),'String','frequency [-]');
% axes context menu
gui.cm_handles.geo_cm = uicontextmenu(gui.figh);
gui.cm_handles.geo_cm_view = uimenu(gui.cm_handles.geo_cm,...
    'Label','view','Enable','on');
gui.cm_handles.geo_cm_viewfreq = uimenu(gui.cm_handles.geo_cm_view,...
    'Label','freq','Tag','view','Checked','on','Callback',@onContextPlotsPSD);
gui.cm_handles.geo_cm_viewcum = uimenu(gui.cm_handles.geo_cm_view,...
    'Label','cum','Tag','view','Callback',@onContextPlotsPSD);
set(gui.axes_handles.geo,'UIContextMenu',gui.cm_handles.geo_cm);

% sub axes to show the chosen pore geometry
gui.axes_handles.type = axes('Parent',gui.plots.geo.box,...
    'Position',[.15 .7 .15 .15],'LineWidth',1,'Box','on');
axis(gui.axes_handles.type,'equal');
set(gui.axes_handles.type,'YLim',[0 1],'XLim',[0 1]);
set(gui.axes_handles.type,'XTickLabel','','YTickLabel','',...
    'Color','none','XColor','none','YColor','none');

%% 2. panel - CPS plot
gui.plots.cps.box = uicontainer('Parent',gui.plots.CPSPanel,...
    'Tag','CPS_MOD','SizeChangedFcn',@fixAxes);
gui.axes_handles.cps = axes('Parent',gui.plots.cps.box,'Box','on');
set(get(gui.axes_handles.cps,'XLabel'),'String','pressure [Pa]');
set(get(gui.axes_handles.cps,'YLabel'),'String','saturation [-]');

%% 3. panel - NMR plot
% because Matlab is buggy when resizing axes put a uicontainer inside the panel
gui.plots.nmr.box = uicontainer('Parent',gui.plots.NMRPanel);
gui.axes_handles.nmr = axes('Parent',gui.plots.nmr.box,'Box','on');
set(get(gui.axes_handles.nmr,'XLabel'),'String','time [s]');
set(get(gui.axes_handles.nmr,'YLabel'),'String','amplitude [a.u.]');
% axes context menus
gui.cm_handles.nmr_cm = uicontextmenu(gui.figh);
gui.cm_handles.nmr_cm_axis = uimenu(gui.cm_handles.nmr_cm,'Label','axes');
gui.cm_handles.nmr_cm_show = uimenu(gui.cm_handles.nmr_cm,'Label','show');
% axis cm menu
gui.cm_handles.nmr_cm_xaxis = uimenu(gui.cm_handles.nmr_cm_axis,...
    'Label','x-axis -> log','Tag','NMR','Enable','on',...
    'Callback',@onContextAxisLogLin);
gui.cm_handles.nmr_cm_yaxis = uimenu(gui.cm_handles.nmr_cm_axis,...
    'Label','y-axis -> log','Tag','NMR','Enable','on',...
    'Callback',@onContextAxisLogLin);
% show cm menu
gui.cm_handles.nmr_cm_showT1 = uimenu(gui.cm_handles.nmr_cm_show,...
    'Label','T1','Tag','NMR','Enable','on','Checked','off',...
    'Callback',@onContextAxisT1T2);
gui.cm_handles.nmr_cm_showT2 = uimenu(gui.cm_handles.nmr_cm_show,...
    'Label','T2','Tag','NMR','Enable','on','Checked','on',...
    'Callback',@onContextAxisT1T2);
set(gui.axes_handles.nmr,'UIContextMenu',gui.cm_handles.nmr_cm);

% set some axes layout defaults
beautifyAxes(gui.figh);

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