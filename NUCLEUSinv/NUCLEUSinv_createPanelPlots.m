function [gui,myui] = NUCLEUSinv_createPanelPlots(gui,myui)
%NUCLEUSinv_createPanelPlots creates graphics panel
%
% Syntax:
%       [gui,myui] = NUCLEUSinv_createPanelPlots(data,gui,myui)
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
%       [gui,myui] = NUCLEUSinv_createPanelPlots(data,gui,myui)
%
% Other m-files required:
%       findjobj.m
%       beautifyAxes.m
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

%% first create the individual TabPanels and BoxPanels
gui.plots.SignalPanel = uix.TabPanel('Parent',gui.center,...
    'BackgroundColor',myui.colors.TabSIG,'SelectionChangedFcn',@updateInfo);
gui.plots.DistPanel = uix.TabPanel('Parent',gui.center,...
    'BackgroundColor',myui.colors.TabDIST,'SelectionChangedFcn',@updateInfo);
gui.plots.CPSPanel = uix.BoxPanel('Parent',gui.center,...
    'TitleColor',myui.colors.BoxCPS,'ForegroundColor',myui.colors.BoxTitle,...
    'MinimizeFcn',@minimizePanel,'SizeChangedFcn',@fixAxes,'Tag','CPS_INV');

%% 1. panel - Processing - PROC and RAW data
gui.plots.Signal.ProcTab = uix.VBox('Parent',gui.plots.SignalPanel,...
    'Spacing',5,'Padding',0);
gui.plots.Signal.RawTab = uix.VBox('Parent',gui.plots.SignalPanel,...
    'Spacing',5,'Padding',0);
gui.plots.Signal.AllTab = uix.VBox('Parent',gui.plots.SignalPanel,...
    'Spacing',5,'Padding',0);
gui.plots.SignalPanel.TabTitles = {'PROC','RAW','ALL (joint)'};
gui.plots.SignalPanel.TabWidth = 75;
gui.plots.SignalPanel.TabEnables = {'on','on','off'};

%% 1.1 the PROC panel
gui.plots.Signal.Proc.box1 = uicontainer('Parent',gui.plots.Signal.ProcTab);
gui.plots.Signal.Proc.box2 = uicontainer('Parent',gui.plots.Signal.ProcTab);
set(gui.plots.Signal.ProcTab,'Heights',[-4 -1]);

% now the actual axes 1
gui.axes_handles.proc = axes('Parent',gui.plots.Signal.Proc.box1,'Box','on');
set(get(gui.axes_handles.proc,'XLabel'),'String','time [s]');
set(get(gui.axes_handles.proc,'YLabel'),'String','amplitude [a.u.]');
% the axes has a context menu
gui.cm_handles.axes_proc = uicontextmenu(gui.figh);
gui.cm_handles.axes_proc_xaxis = uimenu(gui.cm_handles.axes_proc,...
    'Label','x-axis -> lin','Tag','Proc','Enable','off',...
    'Callback',@onContextAxisLogLin);
gui.cm_handles.axes_proc_yaxis = uimenu(gui.cm_handles.axes_proc,...
    'Label','y-axis -> log','Tag','Proc','Enable','off',...
    'Callback',@onContextAxisLogLin);
set(gui.axes_handles.proc,'UIContextMenu',gui.cm_handles.axes_proc);

% now the actual axes 2
gui.axes_handles.err = axes('Parent',gui.plots.Signal.Proc.box2,'Box','on');
set(get(gui.axes_handles.err,'XLabel'),'String','');
set(get(gui.axes_handles.err,'YLabel'),'String','');
set(gui.axes_handles.err,'XTickLabel','');
set(gui.axes_handles.err,'YTickLabel','');

%% 1.2 the RAW panel
gui.plots.Signal.Raw.box1 = uicontainer('Parent',gui.plots.Signal.RawTab);
gui.plots.Signal.Raw.box2 = uicontainer('Parent',gui.plots.Signal.RawTab);
set(gui.plots.Signal.RawTab,'Heights',[-4 -1]);

% now the actual axes 1
gui.axes_handles.raw = axes('Parent',gui.plots.Signal.Raw.box1,'Box','on');
set(get(gui.axes_handles.raw,'XLabel'),'String','time [s]');
set(get(gui.axes_handles.raw,'YLabel'),'String','\Reeal');
% the axes has a context menu
gui.cm_handles.axes_raw = uicontextmenu(gui.figh);
gui.cm_handles.axes_raw_xaxis = uimenu(gui.cm_handles.axes_raw,...
    'Label','x-axis -> lin','Tag','Proc','Enable','off',...
    'Callback',@onContextAxisLogLin);
gui.cm_handles.axes_raw_yaxis = uimenu(gui.cm_handles.axes_raw,...
    'Label','y-axis -> log','Tag','Proc','Enable','off',...
    'Callback',@onContextAxisLogLin);
set(gui.axes_handles.raw,'UIContextMenu',gui.cm_handles.axes_raw);

% now the actual axes 2
gui.axes_handles.imag = axes('Parent',gui.plots.Signal.Raw.box2,'Box','on');
set(get(gui.axes_handles.imag,'XLabel'),'String','');
set(get(gui.axes_handles.imag,'YLabel'),'String','\Immag');
set(gui.axes_handles.imag,'XTickLabel','');
set(gui.axes_handles.imag,'YTickLabel','');

%% 1.3 the ALL panel
gui.plots.Signal.All.box1 = uicontainer('Parent',gui.plots.Signal.AllTab);
gui.plots.Signal.All.box2 = uicontainer('Parent',gui.plots.Signal.AllTab);
set(gui.plots.Signal.AllTab,'Heights',[-4 -1]);

% now the actual axes 1
gui.axes_handles.all = axes('Parent',gui.plots.Signal.All.box1,'Box','on');
set(get(gui.axes_handles.all,'XLabel'),'String','time [s]');
set(get(gui.axes_handles.all,'YLabel'),'String','amplitude [a.u.]');
% the axes has a context menu
gui.cm_handles.axes_all = uicontextmenu(gui.figh);
gui.cm_handles.axes_all_xaxis = uimenu(gui.cm_handles.axes_all,...
    'Label','x-axis -> lin','Tag','All','Enable','off','Callback',@onContextAxisLogLin);
gui.cm_handles.axes_all_yaxis = uimenu(gui.cm_handles.axes_all,...
    'Label','y-axis -> log','Tag','All','Enable','off','Callback',@onContextAxisLogLin);
set(gui.axes_handles.all,'UIContextMenu',gui.cm_handles.axes_all);

% now the actual axes 2
gui.axes_handles.err_joint = axes('Parent',gui.plots.Signal.All.box2,'Box','on');
set(get(gui.axes_handles.err_joint,'XLabel'),'String','');
set(get(gui.axes_handles.err_joint,'YLabel'),'String','');
set(gui.axes_handles.err_joint,'XTickLabel','');
set(gui.axes_handles.err_joint,'YTickLabel','');

%% 2. panel - Distributions - RTD, PSD and PSDJ data
gui.plots.Dist.RTDTab = uix.HBox('Parent',gui.plots.DistPanel,...
    'Spacing',0,'Padding',0);
gui.plots.Dist.PSDTab = uix.HBox('Parent',gui.plots.DistPanel,...
    'Spacing',0,'Padding',0);
gui.plots.Dist.PSDJTab = uix.HBox('Parent',gui.plots.DistPanel,...
    'Spacing',0,'Padding',0);
gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
gui.plots.DistPanel.TabWidth = 75;
gui.plots.DistPanel.TabEnables = {'on','on','off'};

%% 2.1 the RTD panel
gui.plots.Dist.RTD.box = uicontainer('Parent',gui.plots.Dist.RTDTab);

% now the actual axes
gui.axes_handles.rtd = axes('Parent',gui.plots.Dist.RTD.box,'Box','on');
set(get(gui.axes_handles.rtd ,'XLabel'),'String','relaxation time [s]');
set(get(gui.axes_handles.rtd ,'YLabel'),'String','water content [vol. %]');
% the axes has a context menu
gui.cm_handles.axes_rtd = uicontextmenu(gui.figh);
gui.cm_handles.axes_rtd_view = uimenu(gui.cm_handles.axes_rtd,...
    'Label','view','Enable','off');
gui.cm_handles.axes_rtd_view_freq = uimenu(gui.cm_handles.axes_rtd_view,...
    'Label','freq','Tag','view','Checked','on','Callback',@onContextPlotsRTD);
gui.cm_handles.axes_rtd_view_cum = uimenu(gui.cm_handles.axes_rtd_view,...
    'Label','cum','Tag','view','Callback',@onContextPlotsRTD);
set(gui.axes_handles.rtd,'UIContextMenu',gui.cm_handles.axes_rtd);
gui.cm_handles.axes_rtd_uncert = uimenu(gui.cm_handles.axes_rtd,...
    'Label','uncert','Enable','off');
gui.cm_handles.axes_rtd_uncert_lines = uimenu(gui.cm_handles.axes_rtd_uncert,...
    'Label','lines','Tag','uncert','Checked','on','Callback',@onContextPlotsRTD);
gui.cm_handles.axes_rtd_uncert_patch = uimenu(gui.cm_handles.axes_rtd_uncert,...
    'Label','patch','Tag','uncert','Callback',@onContextPlotsRTD);
set(gui.axes_handles.rtd,'UIContextMenu',gui.cm_handles.axes_rtd);

%% 2.2 the PSD panel
gui.plots.Dist.PSD.box = uicontainer('Parent',gui.plots.Dist.PSDTab);

% now the actual axes
gui.axes_handles.psd = axes('Parent',gui.plots.Dist.PSD.box,'Box','on');
set(get(gui.axes_handles.psd,'XLabel'),'String','equiv. pore size [m]');
set(get(gui.axes_handles.psd,'YLabel'),'String','water content [vol. %]');
% the axes has a context menu
gui.cm_handles.axes_psd = uicontextmenu(gui.figh);
gui.cm_handles.axes_psd_view = uimenu(gui.cm_handles.axes_psd,...
    'Label','view','Enable','off');
gui.cm_handles.axes_psd_view_freq = uimenu(gui.cm_handles.axes_psd_view,...
    'Label','freq','Tag','view','Checked','on','Callback',@onContextPlotsPSD);
gui.cm_handles.axes_psd_view_cum = uimenu(gui.cm_handles.axes_psd_view,...
    'Label','cum','Tag','view','Callback',@onContextPlotsPSD);
set(gui.axes_handles.psd,'UIContextMenu',gui.cm_handles.axes_psd);

%% 2.3 the PSD(joint) panel
gui.plots.Dist.PSDJ.box = uicontainer('Parent',gui.plots.Dist.PSDJTab);

% now the actual axes
gui.axes_handles.psdj = axes('Parent',gui.plots.Dist.PSDJ.box,'Box','on');
set(get(gui.axes_handles.psdj,'XLabel'),'String','equiv. pore size [m]');
set(get(gui.axes_handles.psdj,'YLabel'),'String','water content [vol. %]');
% the axes has a context menu
gui.cm_handles.axes_psdj = uicontextmenu(gui.figh);
gui.cm_handles.axes_psdj_view = uimenu(gui.cm_handles.axes_psdj,...
    'Label','view','Enable','off');
gui.cm_handles.axes_psdj_view_freq = uimenu(gui.cm_handles.axes_psdj_view,...
    'Label','freq','Tag','view','Checked','on','Callback',@onContextPlotsPSDJ);
gui.cm_handles.axes_psdj_view_cum = uimenu(gui.cm_handles.axes_psdj_view,...
    'Label','cum','Tag','view','Callback',@onContextPlotsPSDJ);
set(gui.axes_handles.psdj,'UIContextMenu',gui.cm_handles.axes_psdj);

%% 3. panel - CPS data
gui.plots.CPSTab = uix.HBox('Parent',gui.plots.CPSPanel,...
    'Spacing',0,'Padding',0);
gui.plots.CPSPanel.Title = 'CPS (joint)';

%% 3.1 the CPS axes
% inside a uicontainer for proper resizing
gui.plots.CPS.box = uicontainer('Parent',gui.plots.CPSTab,...
    'Tag','CPS_INV','SizeChangedFcn',@fixAxes);

% now the actual axes
gui.axes_handles.cps = axes('Parent',gui.plots.CPS.box,'Box','on');
set(get(gui.axes_handles.cps,'XLabel'),'String','pressure [Pa]');
set(get(gui.axes_handles.cps,'YLabel'),'String','saturation [-]');

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