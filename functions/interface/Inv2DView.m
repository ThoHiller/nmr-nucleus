function Inv2DView(src,~)
%Inv2DView is an extra subGUI to calculate 2D inversion of T1-T2 data
%
% Syntax:
%       Inv2DView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       Inv2DView(src,~)
%
% Other m-files required:
%       beautifyAxes
%       clearAllAxes
%       displayStatusText
%       fitData2D
%       imagescnan
%       onListboxData
%       onRadioGates
%       updatePlotsSignal;
%       updatePlotsDistribution;
%       updateInfo;
%
% Subfunctions:
%       findApproxTlgmAmplitude
%       tv_closeme
%       tv_estimateIRtype
%       tv_getTLGM
%       tv_onCheckDCM
%       tv_onEditValue
%       tv_onPopupIRType
%       tv_onPopupT1Type
%       tv_onPushRun
%       tv_onPushSave
%       tv_onPushView
%       tv_onPushUpdate
%       tv_onRadioLogLin
%       tv_plotResults
%       tv_plotRawData
%       tv_prepareRawData
%       tv_setAxesScaling
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
figh_nucleus = ancestor(src,'figure','toplevel');
nucleus.data = getappdata(figh_nucleus,'data');
nucleus.gui = getappdata(figh_nucleus,'gui');
myui = nucleus.gui.myui;
colors = myui.colors;

%% get GUI data from NUCLEUS
data = nucleus.data.inv2D;

% check if the figure is already open
fig_T1T2map = findobj('Tag','2DINV');
% if not, create it
if isempty(fig_T1T2map)
    % draw the figure on top of NUCLEUSinv
    fig_T1T2map = figure('Name','NUCLEUSinv - 2D Inversion',...
        'NumberTitle','off','Resize','on','ToolBar','none',...
        'Tag','2DINV','CloseRequestFcn',@tv_closeme,...
        'MenuBar','none');
    pos0 = get(figh_nucleus,'Position');
    cent(1) = (pos0(1)+pos0(3)/2);
    cent(2) = (pos0(2)+pos0(4)/2);
    posf = [cent(1)-pos0(3)/2.5 pos0(2)+22 pos0(3)/1.25 pos0(4)-22];
    % posf = pos0;
    set(fig_T1T2map,'Position',posf);

    gui.menu.view = uimenu(fig_T1T2map,'Label','View');
    gui.menu.view_toolbar = uimenu(gui.menu.view,'Label','Figure Toolbar',...
        'Callback',@onMenuView);

    cpanel_w = 175;

    % create the main layout
    gui.main = uix.HBox('Parent',fig_T1T2map,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',5,'Visible','off');
    gui.left = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',0); % controls
    gui.right = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',0); % plots

    set(gui.main,'Widths',[350 -1 ]);

    % waitbar indicating the loading of the GUI
    steps = 4;
    hwb = waitbar(0,'loading ...','Name','T1T2 2DInv GUI initialization','Visible','off');
    set(hwb,'Units','Pixel')
    posw = get(hwb,'Position');
    set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    set(hwb,'Visible','on');

    % --- properties panel ---
    waitbar(1/steps,hwb,'loading GUI elements - properties');
    gui.panels.prop.main = uix.BoxPanel('Parent',gui.left,...
        'Title','Properties','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
    gui.panels.prop.VBox = uix.VBox('Parent',gui.panels.prop.main,...
        'Spacing',3,'Padding',3);

    % D coeff.
    gui.panels.prop.HBox1 = uix.HBox('Parent',gui.panels.prop.VBox,...
        'Spacing',3);
    gui.text_handles.diff = uicontrol('Parent',gui.panels.prop.HBox1,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String',['Diffusion coeff. [10',char(hex2dec('207B')),...
        char(hex2dec('2079')),' m',char(hex2dec('00B2')),'/s]']);
    uix.Empty('Parent',gui.panels.prop.HBox1);
    tstr = 'Set diffusion coefficient.';
    gui.edit_handles.diff = uicontrol('Parent',gui.panels.prop.HBox1,...
        'Style','edit','String',sprintf('%4.3f',data.prop.D*1e9),...
        'FontSize',myui.fontsize,'Tag','diff',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.prop.HBox1,'Widths',[cpanel_w -1 -1]);

    % Gradient
    gui.panels.prop.HBox2 = uix.HBox('Parent',gui.panels.prop.VBox,...
        'Spacing',3);
    gui.text_handles.gradient = uicontrol('Parent',gui.panels.prop.HBox2,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String',"Gradient [T/m]");
    uix.Empty('Parent',gui.panels.prop.HBox2);
    tstr = 'Set device gradient.';
    gui.edit_handles.gradient = uicontrol('Parent',gui.panels.prop.HBox2,...
        'Style','edit','String',sprintf('%d',data.prop.G0),...
        'FontSize',myui.fontsize,'Tag','gradient',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.prop.HBox2,'Widths',[cpanel_w -1 -1]);

    % echo time
    gui.panels.prop.HBox3 = uix.HBox('Parent',gui.panels.prop.VBox,...
        'Spacing',3);
    gui.text_handles.echo_time = uicontrol('Parent',gui.panels.prop.HBox3,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String',"Echo time tE [µs]");
    uix.Empty('Parent',gui.panels.prop.HBox3);
    tstr = 'Set echo time tE.';
    gui.edit_handles.echo_time = uicontrol('Parent',gui.panels.prop.HBox3,...
        'Style','edit','String',sprintf('%d',data.prop.te*1e6),...
        'FontSize',myui.fontsize,'Tag','echo_time',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off',...
        'Callback',@tv_onEditValue);
    set(gui.panels.prop.HBox3,'Widths',[cpanel_w -1 -1]);

    % first and last echo
    gui.panels.prop.HBox4 = uix.HBox('Parent',gui.panels.prop.VBox,...
        'Spacing',3);
    gui.text_handles.first = uicontrol('Parent',gui.panels.prop.HBox4,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String',"T2 echoes - first | last");
    tstr = 'Set first / last echo of all T2 signals.';
    gui.edit_handles.first = uicontrol('Parent',gui.panels.prop.HBox4,...
        'Style','edit','String',sprintf('%d',data.prop.first),...
        'FontSize',myui.fontsize,'Tag','first',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    gui.edit_handles.last = uicontrol('Parent',gui.panels.prop.HBox4,...
        'Style','edit','String',sprintf('%d',data.prop.last),...
        'FontSize',myui.fontsize,'Tag','last',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.prop.HBox4,'Widths',[cpanel_w -1 -1]);

    % --- inversion panel ---
    waitbar(2/steps,hwb,'loading GUI elements - 2D inversion');
    gui.panels.inv.main = uix.BoxPanel('Parent',gui.left,...
        'Title','2D inversion settings','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
    gui.panels.inv.VBox = uix.VBox('Parent',gui.panels.inv.main,...
        'Spacing',3,'Padding',3);

    % T1type
    gui.panels.inv.HBox0 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.T1type = uicontrol('Parent',gui.panels.inv.HBox0,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T1 type (SR / IR)');
    tstr = 'Choose between Saturation and Inversion Recovery.';
    gui.popup_handles.T1type = uicontrol('Parent',gui.panels.inv.HBox0,...
        'Style','popup','String',{'Saturation Recovery','Inversion Recovery'},...
        'Value',data.inv.T1IRfac,'FontSize',myui.fontsize,...
        'UserData',struct('Tooltipstr',tstr),'Callback',@tv_onPopupT1Type);
    set(gui.panels.inv.HBox0,'Widths',[cpanel_w -1]);

    % IR kernel type
    gui.panels.inv.HBox01 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.IRtype = uicontrol('Parent',gui.panels.inv.HBox01,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','IR kernel type');
    tstr = 'Choose IR kernel type.';
    gui.popup_handles.IRtype = uicontrol('Parent',gui.panels.inv.HBox01,...
        'Style','popup','String',{'1-2exp(-t/T1)','-exp(-t/T1)'},...
        'Value',1,'FontSize',myui.fontsize,...
        'UserData',struct('Tooltipstr',tstr),'Callback',@tv_onPopupIRType);
    set(gui.panels.inv.HBox01,'Widths',[cpanel_w -1]);

    % RTD T1
    gui.panels.inv.HBox1 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.rtdT1 = uicontrol('Parent',gui.panels.inv.HBox1,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','RTD T1 -  min [s] | max [s] | #');
    tstr = "";
    gui.edit_handles.rtdT1min = uicontrol('Parent',gui.panels.inv.HBox1,...
        'Style','edit','String',sprintf('%5.4f',data.inv.T1min),...
        'FontSize',myui.fontsize,'Tag','rtdT1min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT1max = uicontrol('Parent',gui.panels.inv.HBox1,...
        'Style','edit','String',sprintf('%d',data.inv.T1max),...
        'FontSize',myui.fontsize,'Tag','rtdT1max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT1N = uicontrol('Parent',gui.panels.inv.HBox1,...
        'Style','edit','String',sprintf('%d',data.inv.T1N),...
        'FontSize',myui.fontsize,'Tag','rtdT1N',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.inv.HBox1,'Widths',[cpanel_w -1 -1 -1]);

    % RTD T2
    gui.panels.inv.HBox2 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.rtdT2 = uicontrol('Parent',gui.panels.inv.HBox2,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','RTD T2 - min [s] | max [s] | #');
    tstr = "";
    gui.edit_handles.rtdT2min = uicontrol('Parent',gui.panels.inv.HBox2,...
        'Style','edit','String',sprintf('%5.4f',data.inv.T2min),...
        'FontSize',myui.fontsize,'Tag','rtdT2min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT2max = uicontrol('Parent',gui.panels.inv.HBox2,...
        'Style','edit','String',sprintf('%d',data.inv.T2max),...
        'FontSize',myui.fontsize,'Tag','rtdT2max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT2N = uicontrol('Parent',gui.panels.inv.HBox2,...
        'Style','edit','String',sprintf('%d',data.inv.T2N),...
        'FontSize',myui.fontsize,'Tag','rtdT2N',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.inv.HBox2,'Widths',[cpanel_w -1 -1 -1]);

    % T1 lambda / order
    gui.panels.inv.HBox3 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.lambdaT1 = uicontrol('Parent',gui.panels.inv.HBox3,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T1 - lambda | L-order');
    tstr = "";
    gui.edit_handles.lambdaT1 = uicontrol('Parent',gui.panels.inv.HBox3,...
        'Style','edit','String',sprintf('%d',data.inv.T1lambda),...
        'FontSize',myui.fontsize,'Tag','lambdaT1',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.orderT1 = uicontrol('Parent',gui.panels.inv.HBox3,...
        'Style','edit','String',sprintf('%d',data.inv.T1order),...
        'FontSize',myui.fontsize,'Tag','orderT1',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.inv.HBox3,'Widths',[cpanel_w -1 -1]);

    % T2 lambda / order
    gui.panels.inv.HBox4 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    gui.text_handles.lambdaT2 = uicontrol('Parent',gui.panels.inv.HBox4,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T2 - lambda | L-order');
    tstr = "";
    gui.edit_handles.lambdaT2 = uicontrol('Parent',gui.panels.inv.HBox4,...
        'Style','edit','String',sprintf('%d',data.inv.T2lambda),...
        'FontSize',myui.fontsize,'Tag','lambdaT2',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.orderT2 = uicontrol('Parent',gui.panels.inv.HBox4,...
        'Style','edit','String',sprintf('%d',data.inv.T2order),...
        'FontSize',myui.fontsize,'Tag','orderT2',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off','Callback',@tv_onEditValue);
    set(gui.panels.inv.HBox4,'Widths',[cpanel_w -1 -1]);

    % RUN button
    gui.panels.inv.HBox5 = uix.HBox('Parent',gui.panels.inv.VBox,...
        'Spacing',3);
    uix.Empty('Parent',gui.panels.inv.HBox5);
    tstr = 'RUN 2D inversion.';
    gui.push_handles.run_inv = uicontrol('Parent',gui.panels.inv.HBox5,...
        'String','RUN 2D INV','FontSize',myui.fontsize,'Tag','rtd',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'BackGroundColor','g','Callback',@tv_onPushRun);
    set(gui.panels.inv.HBox5,'Widths',[cpanel_w -1]);

    % --- information panel ---
    waitbar(3/steps,hwb,'loading GUI elements - information panel');
    gui.panels.info.main = uix.BoxPanel('Parent',gui.left,...
        'Title','Information','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
    gui.panels.info.VBox = uix.VBox('Parent',gui.panels.info.main,...
        'Spacing',3,'Padding',3);

    % T1 range
    gui.panels.info.HBox1 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.rangeT1 = uicontrol('Parent',gui.panels.info.HBox1,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T1 range - min [s] | max [s]');
    tstr = "";
    gui.edit_handles.T1min = uicontrol('Parent',gui.panels.info.HBox1,...
        'Style','edit','String',sprintf('%5.4f',data.info.T1min),...
        'FontSize',myui.fontsize,'Tag','T1min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.T1max = uicontrol('Parent',gui.panels.info.HBox1,...
        'Style','edit','String',sprintf('%d',data.info.T1max),...
        'FontSize',myui.fontsize,'Tag','T1max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.info.HBox1,'Widths',[cpanel_w -1 -1]);

    % T2 range
    gui.panels.info.HBox2 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.rangeT2 = uicontrol('Parent',gui.panels.info.HBox2,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T2 range - min [s] | max [s]');
    tstr = "";
    gui.edit_handles.T2min = uicontrol('Parent',gui.panels.info.HBox2,...
        'Style','edit','String',sprintf('%5.4f',data.info.T2min),...
        'FontSize',myui.fontsize,'Tag','T2min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    tstr = "";
    gui.edit_handles.T2max = uicontrol('Parent',gui.panels.info.HBox2,...
        'Style','edit','String',sprintf('%d',data.info.T2max),...
        'FontSize',myui.fontsize,'Tag','T2max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onEditValue);
    set(gui.panels.info.HBox2,'Widths',[cpanel_w -1 -1]);

    % E0
    gui.panels.info.HBox0 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.E0 = uicontrol('Parent',gui.panels.info.HBox0,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','E0 [-]');
    uix.Empty('Parent',gui.panels.info.HBox0);
    tstr = "";
    gui.edit_handles.E0 = uicontrol('Parent',gui.panels.info.HBox0,...
        'Style','edit','String',sprintf('%4.3f',data.info.E0),...
        'FontSize',myui.fontsize,'Tag','E0',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    set(gui.panels.info.HBox0,'Widths',[cpanel_w -1 -1]);

    % TLGM
    gui.panels.info.HBox3 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.Tlgm = uicontrol('Parent',gui.panels.info.HBox3,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','TLGM [s] (T1,T2)');
    tstr = "";
    gui.edit_handles.T1tlgm = uicontrol('Parent',gui.panels.info.HBox3,...
        'Style','edit','String',sprintf('%4.3f',data.info.T1tlgm),...
        'FontSize',myui.fontsize,'Tag','T1tlgm',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    tstr = "";
    gui.edit_handles.T2tlgm = uicontrol('Parent',gui.panels.info.HBox3,...
        'Style','edit','String',sprintf('%4.3f',data.info.T2tlgm),...
        'FontSize',myui.fontsize,'Tag','T2tlgm',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    set(gui.panels.info.HBox3,'Widths',[cpanel_w -1 -1]);

    % TLGM ratio
    gui.panels.info.HBox4 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.Tlgm_ratio = uicontrol('Parent',gui.panels.info.HBox4,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','TLGM ratio T1/T2');
    uix.Empty('Parent',gui.panels.info.HBox4);
    tstr = "";
    gui.edit_handles.Tlgm_ratio = uicontrol('Parent',gui.panels.info.HBox4,...
        'Style','edit','String',sprintf('%4.3f',data.info.T1tlgm/data.info.T2tlgm),...
        'FontSize',myui.fontsize,'Tag','Tlgm_ratio',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    set(gui.panels.info.HBox4,'Widths',[cpanel_w -1 -1]);

    % Tmax
    gui.panels.info.HBox5 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.Tmax = uicontrol('Parent',gui.panels.info.HBox5,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','TMAX [s] (T1,T2)');
    tstr = "";
    gui.edit_handles.T1tmax = uicontrol('Parent',gui.panels.info.HBox5,...
        'Style','edit','String',sprintf('%4.3f',data.info.T1tmax),...
        'FontSize',myui.fontsize,'Tag','T1tmax',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    tstr = "";
    gui.edit_handles.T2tmax = uicontrol('Parent',gui.panels.info.HBox5,...
        'Style','edit','String',sprintf('%4.3f',data.info.T2tmax),...
        'FontSize',myui.fontsize,'Tag','T2tmax',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    set(gui.panels.info.HBox5,'Widths',[cpanel_w -1 -1]);

    % Tmax ratio
    gui.panels.info.HBox6 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.Tmax_ratio = uicontrol('Parent',gui.panels.info.HBox6,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','TMAX ratio T1/T2');
    uix.Empty('Parent',gui.panels.info.HBox6);
    tstr = "";
    gui.edit_handles.Tmax_ratio = uicontrol('Parent',gui.panels.info.HBox6,...
        'Style','edit','String',sprintf('%4.3f',data.info.T1tmax/data.info.T2tmax),...
        'FontSize',myui.fontsize,'Tag','Tmax_ratio',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off');
    set(gui.panels.info.HBox6,'Widths',[cpanel_w -1 -1]);

    % log/lin axes
    gui.panels.info.HBox7 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.loglin_axes = uicontrol('Parent',gui.panels.info.HBox7,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','Echo time axes');
    tstr = "";
    gui.radio_handles.log = uicontrol('Parent',gui.panels.info.HBox7,...
        'Style','radiobutton','String','log','FontSize',myui.fontsize,'Tag','log',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','on','Value',1,'Callback',@tv_onRadioLogLin);
    gui.radio_handles.lin = uicontrol('Parent',gui.panels.info.HBox7,...
        'Style','radiobutton','String','lin','FontSize',myui.fontsize,'Tag','lin',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','on','Value',0,'Callback',@tv_onRadioLogLin);
    set(gui.panels.info.HBox7,'Widths',[cpanel_w -1 -1]);

    % DCM for 2D plot
    gui.panels.info.HBox8 = uix.HBox('Parent',gui.panels.info.VBox,...
        'Spacing',3);
    gui.text_handles.dcm = uicontrol('Parent',gui.panels.info.HBox8,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','2D model data inspection');
    tstr = "";
    gui.check_handles.dcm = uicontrol('Parent',gui.panels.info.HBox8,...
        'Style','checkbox','String','activate','FontSize',myui.fontsize,'Tag','dcm',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off','Callback',@tv_onCheckDCM);
    set(gui.panels.info.HBox8,'Widths',[cpanel_w -1]);

    % --- update MAIN GUI button ---
    gui.panels.save.HBox1 = uix.VBox('Parent',gui.left,...
        'Spacing',3);   
    tstr = 'UPDATE 2D inversion data in main NUCLEUSinv GUI.';
    gui.push_handles.update = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','UPDATE MAIN GUI','FontSize',myui.fontsize,'Tag','update',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onPushUpdate);
    tstr = 'SAVE 2D inversion data to external file.';
    gui.push_handles.save = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','SAVE RESULT','FontSize',myui.fontsize,'Tag','save',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onPushSave);
    tstr = 'Export current graphics view to Figure.';
    gui.push_handles.view = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','VIEW2FIG','FontSize',myui.fontsize,'Tag','view',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@tv_onPushView);
    % set(gui.panels.save.HBox1,'Widths',[-1 -1]);

    % fix text vertical alignment
    jh = findjobj(gui.text_handles.rtdT1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.rangeT1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.rtdT2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.rangeT2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.diff);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.gradient);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.echo_time);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.first);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.T1type);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.IRtype);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.lambdaT1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.lambdaT2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.E0);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.Tlgm);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.Tlgm_ratio);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.Tmax);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.Tmax_ratio);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.loglin_axes);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.dcm);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

    % empty space at bottom of left side
    uix.Empty('Parent',gui.left);
    % adjust the heights of all left-column-panels
    heights = [22 22 22 28 -1; 22+4*24+6*3 22+7*24+9*4 22+9*24+11*3 28*3 -1];
    % panel header is always 22 high
    set(gui.left,'Heights',heights(2,:),...
        'MinimumHeights',[22 22 22 28 0]);

    % --- plot boxes ---
    waitbar(4/steps,hwb,'loading GUI elements - graphics');
    gui.rightPanel = uix.TabPanel('Parent',gui.right,...
        'BackGroundColor',colors.panelBG);
    % -- tab1
    gui.tab1 = uix.GridFlex('Parent',gui.rightPanel,...
        'BackGroundColor',colors.panelBG,'Spacing',5);

    gui.pbox11 = uicontainer('Parent',gui.tab1,...
        'BackGroundColor',colors.panelBG);
    gui.pbox13 = uicontainer('Parent',gui.tab1,...
        'BackGroundColor',colors.panelBG);

    gui.pbox12 = uicontainer('Parent',gui.tab1,...
        'BackGroundColor',colors.panelBG);
    gui.pbox14 = uicontainer('Parent',gui.tab1,...
        'BackGroundColor',colors.panelBG);

    set(gui.tab1,'Widths',[-1 -1],'Heights',[-1 -1]);

    % -- tab2
    gui.tab2 = uix.GridFlex('Parent',gui.rightPanel,...
        'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5);

    gui.pbox21 = uicontainer('Parent',gui.tab2,...
        'BackGroundColor',colors.panelBG);
    gui.pbox22 = uicontainer('Parent',gui.tab2,...
        'BackGroundColor',colors.panelBG);

    gui.pbox23 = uicontainer('Parent',gui.tab2,...
        'BackGroundColor',colors.panelBG);
    gui.pbox24 = uicontainer('Parent',gui.tab2,...
        'BackGroundColor',colors.panelBG);

    set(gui.tab2,'Widths',[-6 -1],'Heights',[-1 -6]);

    % -- tab3
    gui.tab3 = uix.VBoxFlex('Parent',gui.rightPanel,...
        'BackGroundColor',colors.panelBG,'Spacing',5);
    gui.pbox31 = uicontainer('Parent',gui.tab3,...
        'BackGroundColor',colors.panelBG);
    gui.pbox32 = uicontainer('Parent',gui.tab3,...
        'BackGroundColor',colors.panelBG);
    set(gui.tab3,'Heights',[-1 -2]);

    gui.rightPanel.TabTitles = {'DATA','2D INV','FITS'};
    gui.rightPanel.TabWidth = 75;
    gui.rightPanel.TabEnables = {'on','on','on'};

    % -- plot axes --
    gui.axes11 = axes('Parent',gui.pbox11,'Box','on');
    gui.axes12 = axes('Parent',gui.pbox12,'Box','on');
    gui.axes13 = axes('Parent',gui.pbox13,'Box','on');
    gui.axes14 = axes('Parent',gui.pbox14,'Box','on');
    gui.axes2 = axes('Parent',gui.pbox22,'Box','on','Tag','2D');
    gui.axes21 = axes('Parent',gui.pbox21,'Box','on');
    gui.axes24 = axes('Parent',gui.pbox24,'Box','on');
    gui.axes31 = axes('Parent',gui.pbox31,'Box','on');
    gui.axes32 = axes('Parent',gui.pbox32,'Box','on');

    % create data curor mode for 2D inv plot inspection
    gui.dcm = datacursormode(fig_T1T2map);
    gui.dcm.UpdateFcn = @(hObj,event,ax)localDcmFcn(hObj,event,gui.axes2);
    gui.dcm.Enable = 'off';

    % --- store main GUI settings ---
    gui.myui = nucleus.gui.myui;
    gui.myui.heights = heights;
    gui.figh_nucleus = figh_nucleus;

    % --- save gui data to GUI ---
    setappdata(fig_T1T2map,'gui',gui);
    setappdata(fig_T1T2map,'data',data);

    % minimize upper panel at startup
    tmp_h = gui.myui.heights(2,:);
    tmp_h(1) = gui.myui.heights(1,1);
    set(gui.left,'Heights',tmp_h);
    set(gui.panels.prop.main,'Minimized',true);

    % make GUI visible
    delete(hwb);
    set(gui.main,'Visible','on');
else
    % if the figure is already open load the GUI data
    data = getappdata(fig_T1T2map,'data');
    gui = getappdata(fig_T1T2map,'gui');
end

% import the current data from the main NUCLEUS GUI
data.results.T1T2map = nucleus.data.import.T1T2map;
data.results.T1T2map.import = nucleus.data.import.NMR.data;

% check if there is already 2D inversion data in the main NUCLEUS GUI
if isfield(nucleus.data,'results') && isfield(nucleus.data.results,'inv2D')
    % if it is there, then load the INVdata
    nucleus.INVdata = getappdata(figh_nucleus,'INVdata');    
    % the 2D data is stored within the data struct of the merged T1 curve
    data.results.inv2D = nucleus.INVdata{end}.results.inv2D;
    % update new 2Dinv GUI data
    setappdata(fig_T1T2map,'data',data);
    % clear axes
    clearAllAxes(fig_T1T2map);
    % prepare raw data
    tv_prepareRawData(fig_T1T2map);
    % plot the imported raw data
    tv_plotRawData(fig_T1T2map);
    tv_plotResults(fig_T1T2map);
else
    % set the last echo entry
    data.prop.last = data.results.T1T2map.t2N;
    set(gui.edit_handles.last,'String',num2str(data.prop.last));
    % update new 2Dinv GUI data
    setappdata(fig_T1T2map,'data',data);
    % clear axes
    clearAllAxes(fig_T1T2map);
    % prepare raw data
    tv_prepareRawData(fig_T1T2map);
    % plot the imported raw data
    tv_plotRawData(fig_T1T2map);
end

tv_estimateIRtype(fig_T1T2map);
beautifyAxes(fig_T1T2map);
end

%% subfunction to update the edit fields
function tv_onEditValue(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');

% get the edit field value
val = str2double(get(src,'String'));

switch get(src,'Tag')
    case {'diff','gradient','echo_time'}
        data.prop.D = str2double(get(gui.edit_handles.diff,'String'))/1e9;
        data.prop.G0 = str2double(get(gui.edit_handles.gradient,'String'));
        data.prop.te = str2double(get(gui.edit_handles.echo_time,'String'))/1e6;
    case {'first','last'}
        data.prop.first = str2double(get(gui.edit_handles.first,'String'));
        data.prop.last = str2double(get(gui.edit_handles.last,'String'));
        % update GUI data
        setappdata(figh,'data',data);
        clearAllAxes(figh);
        tv_prepareRawData(figh);
        data = getappdata(figh,'data');
        tv_plotRawData(figh);
        beautifyAxes(figh);
    case {'rtdT1min','rtdT1max','rtdT1N'}
        data.inv.T1min = str2double(get(gui.edit_handles.rtdT1min,'String'));
        data.inv.T1max = str2double(get(gui.edit_handles.rtdT1max,'String'));
        data.inv.T1N = str2double(get(gui.edit_handles.rtdT1N,'String'));
    case {'rtdT2min','rtdT2max','rtdT2N'}
        data.inv.T2min = str2double(get(gui.edit_handles.rtdT2min,'String'));
        data.inv.T2max = str2double(get(gui.edit_handles.rtdT2max,'String'));
        data.inv.T2N = str2double(get(gui.edit_handles.rtdT2N,'String'));
    case 'lambdaT1'
        data.inv.T1lambda = str2double(get(src,'String'));
    case 'orderT1'
        set(gui.edit_handles.orderT2,'String',num2str(val));
        data.inv.T1order = str2double(get(src,'String'));
        data.inv.T2order = str2double(get(gui.edit_handles.orderT2,'String'));
    case 'lambdaT2'
        data.inv.T2lambda = str2double(get(src,'String'));
    case 'orderT2'
        data.inv.T2order = str2double(get(src,'String'));
    case {'T1min','T1max','T2min','T2max'}
        data.info.T1min = str2double(get(gui.edit_handles.T1min,'String'));
        data.info.T1max = str2double(get(gui.edit_handles.T1max,'String'));
        data.info.T2min = str2double(get(gui.edit_handles.T2min,'String'));
        data.info.T2max = str2double(get(gui.edit_handles.T2max,'String'));
        % update GUI data
        setappdata(figh,'data',data);
        tv_getTLGM(figh);
        data = getappdata(figh,'data');
        tv_plotResults(figh);
        beautifyAxes(figh);
end

% update GUI data
setappdata(figh,'data',data);
% in case an error occurred, reset the RUN button
set(gui.push_handles.run_inv,'String','RUN 2D INV',...
    'BackgroundColor','g','Enable','on','Callback',@tv_onPushRun);
setappdata(figh,'gui',gui);
end

%% subfunction to set the T1 type
function tv_onPopupT1Type(src,~)
figh = ancestor(src,'figure','toplevel');
data = getappdata(figh,'data');
gui = getappdata(figh,'gui');

switch get(src,'Value')
    case 1 % Saturation Recovery
        data.inv.T1IRfac = 1;
        set(gui.popup_handles.IRtype,'Enable','off');
    case 2 % Inversion Recovery
        data.inv.T1IRfac = 2;
        set(gui.popup_handles.IRtype,'Enable','on');
end

% update GUI data
setappdata(figh,'data',data);
setappdata(figh,'gui',gui);
end

%% subfunction to set the IR type
function tv_onPopupIRType(src,~)
figh = ancestor(src,'figure','toplevel');
data = getappdata(figh,'data');

switch get(src,'Value')
    case 1 % IR standard 1-2exp()
        data.inv.IRtype = 1;
    case 2 % IR Hürlimann -exp()
        data.inv.IRtype = 2;
end

% update GUI data
setappdata(figh,'data',data);
end

%% subfunction to start a new uncertainty calculation
function tv_onPushRun(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
% NUCLEUSinv data
guiN = getappdata(gui.figh_nucleus,'gui');
dataN = getappdata(gui.figh_nucleus,'data');
% local T1T2 data
T1T2map = data.results.T1T2map;

% prepare inversion parameter struct
param.T1T2 = 'T1T2'; % T1-T2 2D inv

% get system properties
param.D = data.prop.D;
param.G0 = data.prop.G0;
param.te = data.prop.te;

% IR/SR factor
param.T1IRfac = data.inv.T1IRfac;
param.IRtype = data.inv.IRtype;

% get T1/T2 RTDs values
param.T1min = data.inv.T1min;
param.T1max = data.inv.T1max;
param.T1N = data.inv.T1N;
param.T2min = data.inv.T2min;
param.T2max = data.inv.T2max;
param.T2N = data.inv.T2N;

% inversion/regularization settings
param.lamT1 = data.inv.T1lambda;
param.lamT2 = data.inv.T2lambda;
param.orderT1 = data.inv.T1order;
param.orderT2 = data.inv.T2order;

% prepare data
dat = struct;
for n = 1:numel(T1T2map.t_recov)
    dat(n).t = T1T2map.t2;
    dat(n).s = T1T2map.E_raw_surf(n,:)';
    dat(n).noise = std(T1T2map.N_raw_surf(n,:));
    dat(n).T1 = T1T2map.t_recov(n);
end
% global noise
param.noise = std(T1T2map.N_raw_surf(:));

% take solver from main NUCLEUS GUI
param.solver = dataN.info.solver;
switch dataN.info.InvInfo
    case 'on'
        param.info = 'final';
    case 'off'
        param.info = 'off';
end

% status bar information
switch dataN.info.solver
    case 'lsqlin'
        infostring = '2D Inversion using ''Optimization Toolbox'' ... ';
    case 'lsqnonneg'
        infostring = '2D Inversion using ''lsqnonneg'' ... ';
end
displayStatusText(guiN,infostring);

% disable the RUN button to indicate a running inversion
set(gui.push_handles.run_inv,'String','RUNNING ...',...
    'BackgroundColor',get(gui.push_handles.update,'BackgroundColor'),...
    'Enable','off'); pause(0.01);

tic;
% call 2D inversion
inv2D = fitData2D(dat,param);
runtime = toc;
displayStatusText(guiN,[infostring,'done | inversion took ',...
    sprintf('%5.2f',runtime),' s']);

% enable the RN button
set(gui.push_handles.run_inv,'String','RUN 2D INV',...
    'BackgroundColor','g','Enable','on','Callback',@tv_onPushRun);
setappdata(figh,'gui',gui);

% save results
data.results.inv2D = inv2D;

% update data
setappdata(figh,'data',data);

% plot all 2D inversion data
tv_getTLGM(figh);
tv_plotResults(figh);
beautifyAxes(figh);
set(gui.check_handles.dcm,'Enable','on');
end

%% subfunction to export the 2D inversion data
function tv_onPushSave(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
uvgui = getappdata(figh,'gui');
uvdata = getappdata(figh,'data');
% NUCLEUSinv data
data = getappdata(uvgui.figh_nucleus,'data');

% get data path to save inversion results
[sfile,spath] = uiputfile('*.mat','Select File for Save',...
    fullfile(data.import.path,'2Dinvdata.mat'));
% if user did not cancel, procceed
if sfile > 0
    invdata = uvdata;
    save(fullfile(spath,sfile),'invdata');
    disp('2D Inverions data saved to: ');
    disp(fullfile(spath,sfile));
else
    disp('Save cancelled.');
end

end

%% subfunction to export the current view to a figure
function tv_onPushView(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
gui = getappdata(figh,'gui');

% opening the export figure
expfig = figure('Color',gui.myui.colors.panelBG);

% create axes layout depending on view
switch get(gui.rightPanel,'Selection')
    case 1
        % create layout
        ax1 = subplot(2,2,1,'Parent',expfig);
        ax2 = subplot(2,2,2,'Parent',expfig);
        ax3 = subplot(2,2,3,'Parent',expfig);
        ax4 = subplot(2,2,4,'Parent',expfig);
        % get positions
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        pos3 = get(ax3,'Position');
        pos4 = get(ax4,'Position');
        % delete axes
        delete(ax1);delete(ax2);delete(ax3);delete(ax4);
        % copy GUI axes
        ax1 = copyobj(gui.axes11,expfig);
        ax2 = copyobj(gui.axes12,expfig);
        ax3 = copyobj(gui.axes13,expfig);
        ax4 = copyobj(gui.axes14,expfig);
        % adjust positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
        set(ax3,'Position',pos3);
        set(ax4,'Position',pos4);
        % set colorbars
        colorbar(ax1,'Location','EastOutside');
        colorbar(ax2,'Location','EastOutside');
        colorbar(ax3,'Location','EastOutside');
        colorbar(ax4,'Location','EastOutside');
    case 2
        % create layout
        ax1 = subplot(5,5,[1 2 3 4],'Parent',expfig);
        ax2 = subplot(5,5,[6:9 11:14 16:19 21:24],'Parent',expfig);
        ax3 = subplot(5,5,[10 15 20 25],'Parent',expfig);
        % get positions
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        pos3 = get(ax3,'Position');
        % delete axes
        delete(ax1);delete(ax2);delete(ax3);
        % copy GUI axes
        ax1 = copyobj(gui.axes21,expfig);
        ax2 = copyobj(gui.axes2,expfig);
        ax3 = copyobj(gui.axes24,expfig);
        % adjust positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
        set(ax3,'Position',pos3);
    case 3
        % create layout
        ax1 = subplot(7,1,[1 2],'Parent',expfig);
        ax2 = subplot(7,1,[4 5 6 7],'Parent',expfig);
        % get positions
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        % delete axes
        delete(ax1);delete(ax2);
        % copy GUI axes
        ax1 = copyobj(gui.axes31,expfig);
        ax2 = copyobj(gui.axes32,expfig);
        % adjust positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
end

end

%% subfunction to update the main NUCLEUSinv GUI
function tv_onPushUpdate(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
uvgui = getappdata(figh,'gui');
uvdata = getappdata(figh,'data');
% NUCLEUSinv data
gui = getappdata(uvgui.figh_nucleus,'gui');
INVdata = getappdata(uvgui.figh_nucleus,'INVdata');
data = getappdata(uvgui.figh_nucleus,'data');

% loop over all signals
E_inv = zeros(size(uvdata.results.T1T2map.t_recov));
for id = 1:numel(INVdata)
    % the standard INVdata struct
    INVdata{id} = [];
    
    % old, slow but consistent way
    % trigger the listbox entry
    % set(gui.listbox_handles.signal,'Value',id);
    % onListboxData(gui.listbox_handles.signal);
    % no gating
    % which radiobutton ('log', 'lin' or 'none')
    % onRadioGates(gui.radio_handles.process_gates_none);
    % get the fresh data
    % data = getappdata(uvgui.figh_nucleus,'data');
    
    % new, fast and hopefully consistent :-) way
    if id == numel(INVdata)
        data.process.start = 1;
        data.process.end = numel(uvdata.results.T1T2map.import{id}.time);
    else
        data.process.start = uvdata.prop.first;
        data.process.end = uvdata.prop.last; %numel(uvdata.results.T1T2map.import{id}.time);
    end
    data.process.gatetype = 'raw';
    data.process.isgated = false;
    % update 2Dinv GUI settings
    data.inv2D.prop = uvdata.prop;
    data.inv2D.inv = uvdata.inv;
    data.inv2D.info = uvdata.info;
    % create raw data struct
    data.results.nmrraw.t = uvdata.results.T1T2map.import{id}.time;
    data.results.nmrraw.s = uvdata.results.T1T2map.import{id}.signal;
    if id == numel(INVdata)
        data.results.nmrraw.noise = uvdata.results.T1T2map.import{id}.noise;
        data.results.nmrproc.T1T2 = 'T1';
        data.results.nmrproc.T1IRfac = 2;
    else
        data.results.nmrraw.phase = uvdata.results.T1T2map.import{id}.phase;
        data.results.nmrproc.T1T2 = 'T2';
        data.results.nmrproc.T1IRfac = 1;
    end
    % create proc data struct
    if id == numel(INVdata)
        data.results.nmrproc.start = 1;
        data.results.nmrproc.end = numel(uvdata.results.T1T2map.import{id}.time);
    else
        data.results.nmrproc.start = uvdata.prop.first;
        data.results.nmrproc.end = uvdata.prop.last; %numel(uvdata.results.T1T2map.import{id}.time);
    end    
    data.results.nmrproc.gatetype = 'raw';
    data.results.nmrproc.isgated = false;
    data.results.nmrproc.t = uvdata.results.T1T2map.import{id}.time(data.results.nmrproc.start:data.results.nmrproc.end);
    data.results.nmrproc.s = real(uvdata.results.T1T2map.import{id}.signal(data.results.nmrproc.start:data.results.nmrproc.end));
    data.results.nmrproc.N = ones(size(data.results.nmrproc.s));
    if isfield(uvdata.results.T1T2map.import{id},'noise')
        data.results.nmrproc.noise = uvdata.results.T1T2map.import{id}.noise;
    else
        range = floor(numel(data.results.nmrproc.s)/2):numel(data.results.nmrproc.s);
        data.results.nmrproc.noise = std(imag(uvdata.results.T1T2map.import{id}.signal(range)));
    end
    data.results.nmrproc.e = data.results.nmrproc.noise*ones(size(data.results.nmrproc.s));
    if isfield(data.results.nmrproc,'W')
        data.results.nmrproc = rmfield(data.results.nmrproc,'W');
    end

    % and use it for the INVdata
    INVdata{id} = data;
    INVdata{id} = rmfield(INVdata{id},'import');
    INVdata{id} = rmfield(INVdata{id},'info');
    INVdata{id} = rmfield(INVdata{id},'calib');
    INVdata{id} = rmfield(INVdata{id},'pressure');

    % now add a dummy "invstd" field
    if id == numel(INVdata)
        % for the final merged T1
        INVdata{id}.results.invstd.fit_t = uvdata.results.T1T2map.t_recov;
        INVdata{id}.results.invstd.fit_s = E_inv;
        INVdata{id}.results.invstd.E0 = uvdata.results.inv2D.E0;
        INVdata{id}.results.invstd.ciE0 = NaN;
        out = getFitErrors(uvdata.results.T1T2map.E_raw(:,1),E_inv,data.results.nmrproc.noise);
        INVdata{id}.results.invstd.resnorm = out.resnorm;
        INVdata{id}.results.invstd.residual = out.residual;
        INVdata{id}.results.invstd.chi2 = out.chi2;
        INVdata{id}.results.invstd.rms = out.rms;
    else
        % for the individual signals
        INVdata{id}.results.invstd.fit_t = uvdata.results.inv2D.data(id).t;
        INVdata{id}.results.invstd.fit_s = uvdata.results.inv2D.data(id).s_fit;
        E_inv(id,1) = uvdata.results.inv2D.data(id).s_fit(1);
        INVdata{id}.results.invstd.E0 = uvdata.results.inv2D.data(id).s_fit(1);
        INVdata{id}.results.invstd.ciE0 = NaN;
        INVdata{id}.results.invstd.resnorm = uvdata.results.inv2D.data(id).resnorm;
        INVdata{id}.results.invstd.residual = uvdata.results.inv2D.data(id).residual;
        INVdata{id}.results.invstd.chi2 = uvdata.results.inv2D.data(id).chi2;
        INVdata{id}.results.invstd.rms = uvdata.results.inv2D.data(id).rms;
    end
    INVdata{id}.results.invstd.lambda_out = 1;
    INVdata{id}.results.invstd.xn = 0;
    INVdata{id}.results.invstd.rn = 0;
    INVdata{id}.results.invstd.invtype = data.invstd.invtype;
    INVdata{id}.results.invstd.invparams = NaN;
    if id == numel(INVdata)
        INVdata{id}.results.inv2D = uvdata.results.inv2D;
    else
        INVdata{id}.results.inv2D = true;
    end

    % color the corresponding list entries in the main GUI
    strL = get(gui.listbox_handles.signal,'String');
    str1 = strL{id};
    str2 = ['<HTML><BODY bgcolor="rgb(',...
        sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',str1,'</BODY></HTML>'];
    strL{id} = str2;
    set(gui.listbox_handles.signal,'String',strL);
end

% update GUI INVdata
setappdata(uvgui.figh_nucleus,'INVdata',INVdata);

% set focus on first signal
set(gui.listbox_handles.signal,'Value',1);
onListboxData(gui.listbox_handles.signal);
end

%% subfunction zo switch x-axis scaling
function tv_onRadioLogLin(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
% get tag of the radio menu
tag = get(src,'Tag');
val = get(src,'Value');

switch tag
    case 'log'
        switch val
            case 1 % log should be used
                set(gui.radio_handles.lin,'Value',0);
            case 0 % lin should be used
                set(gui.radio_handles.lin,'Value',1);
        end
    case 'lin'
        switch val
            case 1 % lin should be used
                set(gui.radio_handles.log,'Value',0);
            case 0 % log should be used
                set(gui.radio_handles.log,'Value',1);
        end
end
% update GUI data
setappdata(figh,'gui',gui);

% call function to adapt the axes scaling
tv_setAxesScaling(figh);
end

%% subfunction to activate data tips on 2D plot
function tv_onCheckDCM(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
% get tag of the radio menu
val = get(src,'Value');

switch val
    case 1 % DCM on
        gui.dcm.Enable = 'on';
    case 0 % DCM off
        gui.dcm.Enable = 'off';
end

% update GUI data
setappdata(figh,'gui',gui);
end

%% subfunction to switch x-axis scaling log<->lin
function tv_setAxesScaling(figh)
gui = getappdata(figh,'gui');

uselog = get(gui.radio_handles.log,'Value');
switch uselog
    case 1
        set(gui.axes11,'XScale','log');
        set(gui.axes12,'XScale','log');
        set(gui.axes13,'XScale','log');
        set(gui.axes14,'XScale','log');
        log_t_ticks = logspace(-5,2,8);
        set(gui.axes32,'XScale','log','XTick',log_t_ticks);
    case 0
        set(gui.axes11,'XScale','lin');
        set(gui.axes12,'XScale','lin');
        set(gui.axes13,'XScale','lin');
        set(gui.axes14,'XScale','lin');
        set(gui.axes32,'XScale','lin','XTickMode','auto');
end

end

%% subfunction to update all plots
function tv_plotResults(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
T1T2map = data.results.T1T2map;
inv2D = data.results.inv2D;
col = gui.myui.colors;

% clear axes
clearSingleAxis(gui.axes13);
clearSingleAxis(gui.axes14);
clearSingleAxis(gui.axes2);
clearSingleAxis(gui.axes21);
clearSingleAxis(gui.axes24);
clearSingleAxis(gui.axes31);
clearSingleAxis(gui.axes32);
hold(gui.axes13,'on');
hold(gui.axes14,'on');
hold(gui.axes2,'on');
hold(gui.axes21,'on');
hold(gui.axes24,'on');
hold(gui.axes31,'on');
hold(gui.axes32,'on');

% get T1/T2 range from GUI
T1range(1) = str2double(get(gui.edit_handles.T1min,'String'));
T1range(2) = str2double(get(gui.edit_handles.T1max,'String'));
T2range(1) = str2double(get(gui.edit_handles.T2min,'String'));
T2range(2) = str2double(get(gui.edit_handles.T2max,'String'));

% define some axes settings
log_t_ticks = logspace(-5,2,8);
t_recov_lims = [min(T1T2map.t_recov)/2 max(T1T2map.t_recov)*2];
p_alpha = 0.8;

z_max = max(inv2D.f_2Dmap(:));
% tab 2 - 2D inversion model
[X,Y] = meshgrid(inv2D.T2vec,inv2D.T1vec);
% imagescnan(X,Y,inv2D.f_2Dmap,'Parent',gui.axes2);
sh = surf(X,Y,inv2D.f_2Dmap,'Parent',gui.axes2);
sh.FaceColor = 'flat';
sh.EdgeColor = 'none';
plot3(inv2D.T2tlgm,inv2D.T1tlgm,z_max,'o','Color',col.FIT,'Parent',gui.axes2);
plot3(inv2D.T2tmax,inv2D.T1tmax,z_max,'+','Color',col.FIT,'Parent',gui.axes2);
plot3([1e-5 100],[1e-5 100],[z_max z_max],...
    '--','Color','w','LineWidth',1,'Parent',gui.axes2);
view(gui.axes2,[0 90]);
set(gui.axes2,'XScale','log','XTick',log_t_ticks,...
    'XLim',[min(inv2D.T2vec) max(inv2D.T2vec)]);
set(gui.axes2,'YScale','log','XTick',log_t_ticks,...
    'YLim',[min(inv2D.T1vec) max(inv2D.T1vec)],'YDir','normal');
set(get(gui.axes2,'XLabel'),'String','relaxation time T2 [s]');
set(get(gui.axes2,'YLabel'),'String','relaxation time T1 [s]');
set(gui.axes2,'Layer','top','XGrid','off','YGrid','off');
colorbar(gui.axes2,'Location','EastOutside');

% sum along each dimension to get both RTDs
T1rtd = sum(inv2D.f_2Dmap,2);
T2rtd = sum(inv2D.f_2Dmap,1);
% find common maximum for y-axis setting
ymax = max([max(T1rtd) max(T2rtd)])*1.1;
% T1 RTD
plot(T1rtd,inv2D.T1vec,'Color',col.FIT,'Parent',gui.axes24);
amp = findApproxTlgmAmplitude(inv2D.T1vec,T1rtd,inv2D.T1tlgm);
plot([0 amp],[inv2D.T1tlgm inv2D.T1tlgm],'Color',col.FIT,'LineStyle','--',...
    'LineWidth',1,'DisplayName','Tlgm','Tag','TLGM','Parent',gui.axes24);
amp = findApproxTlgmAmplitude(inv2D.T1vec,T1rtd,inv2D.T1tmax);
plot([0 amp],[inv2D.T1tmax inv2D.T1tmax],'Color',col.FIT,'LineStyle','-.',...
    'LineWidth',1,'DisplayName','Tmax','Tag','TMAX','Parent',gui.axes24);
set(gui.axes24,'XScale','lin','XLim',[0 ymax]);
set(gui.axes24,'YScale','log','YTickLabel','');
if T1range(1)>inv2D.T1vec(1)
    xlims = get(gui.axes24,'XLim');
    % draw a transparent patch
    v = [xlims(1) inv2D.T1vec(1); xlims(2) inv2D.T1vec(1);
        xlims(2) T1range(1); xlims(1) T1range(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes24);
end
if T1range(2)<inv2D.T1vec(end)
    xlims = get(gui.axes24,'XLim');
    % draw a transparent patch
    v = [xlims(1) inv2D.T1vec(end); xlims(2) inv2D.T1vec(end);
        xlims(2) T1range(2); xlims(1) T1range(2)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes24);
end

% T2 RTD
plot(inv2D.T2vec,T2rtd,'Color',col.FIT,'DisplayName','RTD','Parent',gui.axes21);
amp = findApproxTlgmAmplitude(inv2D.T2vec,T2rtd,inv2D.T2tlgm);
plot([inv2D.T2tlgm inv2D.T2tlgm],[0 amp],'Color',col.FIT,'LineStyle','--',...
    'LineWidth',1,'DisplayName','Tlgm','Tag','TLGM','Parent',gui.axes21);
amp = findApproxTlgmAmplitude(inv2D.T2vec,T2rtd,inv2D.T2tmax);
plot([inv2D.T2tmax inv2D.T2tmax],[0 amp],'Color',col.FIT,'LineStyle','-.',...
    'LineWidth',1,'DisplayName','Tmax','Tag','TMAX','Parent',gui.axes21);
set(gui.axes21,'YScale','lin','YLim',[0 ymax]);
set(gui.axes21,'XScale','log','XTickLabel','');
legend(gui.axes21,'Location','East','FontSize',8);
if T2range(1)>inv2D.T2vec(1)
    ylims = get(gui.axes21,'YLim');
    % draw a transparent patch
    v = [inv2D.T2vec(1) ylims(1);inv2D.T2vec(1) ylims(2);
        T2range(1) ylims(2);T2range(1) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes21);
end
if T2range(2)<inv2D.T2vec(end)
    ylims = get(gui.axes21,'YLim');
    % draw a transparent patch
    v = [inv2D.T2vec(end) ylims(1);inv2D.T2vec(end) ylims(2);
        T2range(2) ylims(2);T2range(2) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes21);
end

% tab 1 - model response
data_inv = inv2D.data;
E_fit_surf = zeros(numel(data_inv),numel(inv2D.data(1).t));
Residual_surf = E_fit_surf;
for nn = 1:numel(data_inv)
    E_fit_surf(nn,:) = data_inv(nn).s_fit;
    Residual_surf(nn,:) = data_inv(nn).residual;
end
[tx,ty] = meshgrid(T1T2map.t2,T1T2map.t_recov);
% data
imagescnan(tx,ty,E_fit_surf,'Parent',gui.axes13);
view(gui.axes13,[0 90]);
set(gui.axes13,'XScale','log');
set(gui.axes13,'YScale','log','YDir','normal');
set(get(gui.axes13,'XLabel'),'String','time [s]');
set(get(gui.axes13,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes13,'Title'),'String','d pred');
set(gui.axes13,'CLim',get(gui.axes11,'CLim'));
set(gui.axes13,'Layer','top','XGrid','off','YGrid','off');
cb = colorbar(gui.axes13);
set(cb,'Location','EastOutside');
% residual
imagescnan(tx,ty,Residual_surf,'Parent',gui.axes14);
view(gui.axes14,[0 90]);
set(gui.axes14,'XScale','log');
set(gui.axes14,'YScale','log','YDir','normal');
set(get(gui.axes14,'XLabel'),'String','time [s]');
set(get(gui.axes14,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes14,'Title'),'String',...
    ['residual (RMS=',sprintf('%3.2f',inv2D.error_global.rms),...
    ';X^2=',sprintf('%3.2f',inv2D.error_global.chi2),')']);
set(gui.axes14,'CLim',get(gui.axes12,'CLim'));
set(gui.axes14,'Layer','top','XGrid','off','YGrid','off');
cb = colorbar(gui.axes14);
set(cb,'Location','EastOutside');

% prepare the data for the combined T1 curve
E_inv = zeros(size(T1T2map.t_recov));
for nn = 1:numel(data_inv)
    E_inv(nn) = data_inv(nn).s_fit(1);
    % E_inv(nn,2) = std(T1T2map.data(nn).s);
    % plot individual T2 signals and fits
    plot3(inv2D.data(nn).t,inv2D.data(nn).T1*ones(size(inv2D.data(nn).s)),...
        inv2D.data(nn).s,'Color',col.RE,'DisplayName','T2 signals',...
        'LineWidth',1,'Parent',gui.axes32);
    plot3(data_inv(nn).t,data_inv(nn).T1*ones(size(data_inv(nn).s_fit)),data_inv(nn).s_fit,...
        'Color',col.FIT,'DisplayName','fits','Parent',gui.axes32);
end
view(gui.axes32,[30 20]);
set(gui.axes32,'XScale','log','XTick',log_t_ticks);
set(gui.axes32,'YScale','log','YDir','normal','YTick',log_t_ticks,'YLim',t_recov_lims);
set(get(gui.axes32,'XLabel'),'String','time [s]');
set(get(gui.axes32,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes32,'ZLabel'),'String','amplitude [a.u.]');

% tab 3 - combined T1 curve and fit
plot(T1T2map.t_recov,T1T2map.E_raw(:,1),'o-','Color',col.RE,...
    'LineWidth',1,'DisplayName','T1 curve','Parent',gui.axes31);
plot(T1T2map.t_recov,E_inv,'Color',col.FIT,'DisplayName','fit','Parent',gui.axes31);
set(gui.axes31,'XScale','log','XLim',t_recov_lims);
set(gui.axes31,'YScale','lin');
set(get(gui.axes31,'XLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes31,'YLabel'),'String','mean(E(1:3)) [a.u.]');
legend(gui.axes31,'Location','SouthEast');

% hold off all axes
hold(gui.axes13,'off');
hold(gui.axes14,'off');
hold(gui.axes2,'off');
hold(gui.axes21,'off');
hold(gui.axes24,'off');
hold(gui.axes31,'off');
hold(gui.axes32,'off');

% call function to adapt the axes scaling
tv_setAxesScaling(figh);
end

%%  subfunction to plot the raw data
function tv_plotRawData(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
T1T2map = data.results.T1T2map;
col = gui.myui.colors;
hold(gui.axes32,'on');

% ticks and limits
log_t_ticks = logspace(-5,2,8);
t_recov_lims = [min(T1T2map.t_recov)/2 max(T1T2map.t_recov)*2];

% plot the raw signals in the 3D axis
for i = 1:numel(T1T2map.t_recov)
    % plot the individual T2 signals into the 3D data cube
    plot3(T1T2map.t2,T1T2map.t_recov(i)*ones(size(T1T2map.t2)),T1T2map.E_raw_surf(i,:),...
        'Color',col.RE,'DisplayName','T2 signals','LineWidth',1,'Parent',gui.axes32);
end

% tab 1 - surface plots
[tx,ty] = meshgrid(T1T2map.t2,T1T2map.t_recov);
% signal
imagescnan(tx,ty,T1T2map.E_raw_surf,'Parent',gui.axes11);
view(gui.axes11,[0 90]);
set(gui.axes11,'XScale','log');
set(gui.axes11,'YScale','log','YDir','normal');
set(get(gui.axes11,'XLabel'),'String','time [s]');
set(get(gui.axes11,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes11,'Title'),'String','d obs');
set(gui.axes11,'Layer','top','XGrid','off','YGrid','off');
cb = colorbar(gui.axes11);
set(cb,'Location','EastOutside');

% noise
imagescnan(tx,ty,T1T2map.N_raw_surf,'Parent',gui.axes12);
view(gui.axes12,[0 90]);
% limits & ticks
set(gui.axes12,'XScale','log');
set(gui.axes12,'YScale','log','YDir','normal');
set(get(gui.axes12,'XLabel'),'String','time [s]');
set(get(gui.axes12,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes12,'Title'),'String',['e obs (STD=',sprintf('%3.2f',...
    std(T1T2map.N_raw_surf(:))),')']);
set(gui.axes12,'Layer','top','XGrid','off','YGrid','off');
cb = colorbar(gui.axes12);
set(cb,'Location','EastOutside');

% tab 3 - combined T1 curve
plot(T1T2map.t_recov,T1T2map.E_raw(:,1),'o-','Color',col.RE,...
    'LineWidth',1,'DisplayName','T1 curve','Parent',gui.axes31);
set(gui.axes31,'XScale','log','XLim',t_recov_lims);
set(gui.axes31,'YScale','lin');
set(get(gui.axes31,'XLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes31,'YLabel'),'String','mean(E(1:3)) [a.u.]');
legend(gui.axes31,'Location','SouthEast');

% tab 3  - 2D data cube
view(gui.axes32,[30 20]);
set(gui.axes32,'XScale','log','XTick',log_t_ticks);
set(gui.axes32,'YScale','log','YDir','normal','YTick',log_t_ticks,'YLim',t_recov_lims);
set(get(gui.axes32,'XLabel'),'String','time [s]');
set(get(gui.axes32,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes32,'ZLabel'),'String','amplitude [a.u.]');
hold(gui.axes32,'off');

% call function to adapt the axes scaling
tv_setAxesScaling(figh);
end

%% subfunction to update all plots
function tv_getTLGM(figh)
% local GUI data
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
% get 2D inversion data
inv2D = data.results.inv2D;

% get T1/T2 range from GUI
T1range(1) = data.info.T1min;
T1range(2) = data.info.T1max;
T2range(1) = data.info.T2min;
T2range(2) = data.info.T2max;

% get TLGM and TMAX accounting for T1 and T2 ranges
[TLGM,TMAX] = getTLogMean2D(inv2D.T1vec,inv2D.T2vec,inv2D.f_2Dmap,T1range,T2range);

% update results in data struct
inv2D.T1tlgm = TLGM(1);
inv2D.T2tlgm = TLGM(2);
inv2D.T1tmax = TMAX(1);
inv2D.T2tmax = TMAX(2);

% update GUI data struct
data.info.E0 = inv2D.E0;
data.info.T1tlgm = inv2D.T1tlgm;
data.info.T2tlgm = inv2D.T2tlgm;
data.info.T1tmax = inv2D.T1tmax;
data.info.T2tmax = inv2D.T2tmax;

% update GUI elements
set(gui.edit_handles.E0,'String',sprintf('%4.3f',inv2D.E0));
set(gui.edit_handles.T1tlgm,'String',sprintf('%4.3f',inv2D.T1tlgm));
set(gui.edit_handles.T2tlgm,'String',sprintf('%4.3f',inv2D.T2tlgm));
set(gui.edit_handles.Tlgm_ratio,'String',sprintf('%4.3f',inv2D.T1tlgm/inv2D.T2tlgm));
set(gui.edit_handles.T1tmax,'String',sprintf('%4.3f',inv2D.T1tmax));
set(gui.edit_handles.T2tmax,'String',sprintf('%4.3f',inv2D.T2tmax));
set(gui.edit_handles.Tmax_ratio,'String',sprintf('%4.3f',inv2D.T1tmax/inv2D.T2tmax));

% update data
data.results.inv2D = inv2D;
setappdata(figh,'data',data);
end

%% subfunction to find RTD amplitude
function amp = findApproxTlgmAmplitude(t,f,TLGM)

if isnan(TLGM)
    amp = NaN;
else
    index = find(abs(t-TLGM)==min(abs(t-TLGM)));
    if index == 1 || index == numel(t)
        amp = f(index);
    else
        amp = interp1(t(index-1:index+1),f(index-1:index+1),TLGM);
    end
end

end

%%  subfunction to plot the raw data
function tv_prepareRawData(figh)
data = getappdata(figh,'data');
T1T2map = data.results.T1T2map;

% select first T2 echo
firstN = data.prop.first;
lastN = data.prop.last;
T1T2map.t2 = T1T2map.import{1}.time(firstN:lastN);

% prepare the surface plots for the raw data
T1T2map.E_raw_surf = zeros(numel(T1T2map.t_recov),lastN-firstN+1);
T1T2map.N_raw_surf = zeros(numel(T1T2map.t_recov),lastN-firstN+1);
for i = 1:numel(T1T2map.t_recov)
    T1T2map.E_raw_surf(i,:) = real(T1T2map.import{i}.signal(firstN:lastN));
    T1T2map.N_raw_surf(i,:) = imag(T1T2map.import{i}.signal(firstN:lastN));
end
% get merged T1 curve
T1T2map.E_raw = T1T2map.import{end}.signal;

% update the data
data.results.T1T2map = T1T2map;
% update GUI data
setappdata(figh,'data',data);
end

%% estimate IR type
function tv_estimateIRtype(figh)
data = getappdata(figh,'data');
gui = getappdata(figh,'gui');
T1T2map = data.results.T1T2map;

% the T1 curve
E = T1T2map.E_raw;

if E(1) > 0
    % possibly SR
    data.inv.IRtype = 1;
    data.inv.T1IRfac = 1;
    set(gui.popup_handles.T1type,'Value',1);
    set(gui.popup_handles.IRtype,'Enable','off');
else
    if E(end) < abs(E(1))*0.5
        % possibly IR with kernel type 2 => -exp(t/T1)
        data.inv.IRtype = 2;
        set(gui.popup_handles.T1type,'Value',2);
        set(gui.popup_handles.IRtype,'Value',2);
    else
        % possibly IR with kernel type 1 => 1-2exp(t/T1)
        data.inv.IRtype = 1;
        data.inv.T1IRfac = 2;
        set(gui.popup_handles.T1type,'Value',2);
        set(gui.popup_handles.IRtype,'Value',1);
    end
end

% update GUI data
setappdata(figh,'data',data);
setappdata(figh,'gui',gui);
end

%% adjust the data tip on the 2D axes
function txt = localDcmFcn(~,event,ax)

if strcmp(get(ax,'Tag'),'2D')
    % find indices to closest x and y data values. This requires the
    % number of values in XData and YData to agree with CData size.
    [~, xidx] = min(abs(event.Target.XData - event.Position(1)),[],2);
    [~, yidx] = min(abs(event.Target.YData - event.Position(2)),[],1);
    colorbarValue = event.Target.CData(yidx(1), xidx(1));
    % colormapIdx = round((colorbarValue - ax.CLim(1))/(ax.CLim(2)-ax.CLim(1)) * (size(ax.Colormap,1)-1) +1);
    txt = sprintf('[T2,T1]: [%.2g, %.2g]\nValue: %.2g', ...
        event.Position(1:2), colorbarValue);
end

end

%% close function
function tv_closeme(src,~)
figh = ancestor(src,'figure','toplevel');
% try to close the sub GUI in a clean manner
try
    % NOTE: maybe needed at some later point
    %     gui = getappdata(figh,'gui');
    %     data = getappdata(gui.figh_nucleus,'data');
    %     % update NUCLEUSinv
    %     setappdata(gui.figh_nucleus,'data',data);
    delete(figh);
catch
    % if this is not working: just close it
    delete(figh);
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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