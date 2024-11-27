function Mod2DView(src,~)
%Mod2DView is an extra subGUI to calculate 2D forward T1-T2 data
%
% Syntax:
%       Mod2DView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       Mod2DView(src,~)
%
% Other m-files required:
%       beautifyAxes
%       clearAllAxes
%       displayStatusText
%       fitData2D_T1T2
%       imagescnan
%
% Subfunctions:
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
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
data = nucleus.data.mod2D;

% check if the figure is already open
fig_2Dmod = findobj('Tag','2DMOD');
% if not, create it
if isempty(fig_2Dmod)
    % draw the figure on top of NUCLEUSinv
    fig_2Dmod = figure('Name','NUCLEUSmod - 2D Modeling',...
        'NumberTitle','off','Resize','on','ToolBar','none',...
        'Tag','2DMOD','CloseRequestFcn',@fv_closeme,...
        'MenuBar','none');
    pos0 = get(figh_nucleus,'Position');
    cent(1) = (pos0(1)+pos0(3)/2);
    cent(2) = (pos0(2)+pos0(4)/2);
    posf = [cent(1)-pos0(3)/2.5 pos0(2)+22 pos0(3)/1.25 pos0(4)-22];
    % posf = pos0;
    set(fig_2Dmod,'Position',posf);

    gui.menu.view = uimenu(fig_2Dmod,'Label','View');
    gui.menu.view_toolbar = uimenu(gui.menu.view,'Label','Figure Toolbar',...
        'Callback',@onMenuView);

    cpanel_w = 190;

    % create the main layout
    gui.main = uix.HBox('Parent',fig_2Dmod,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',5,'Visible','off');
    gui.left = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',0); % controls
    gui.right = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
        'Spacing',5,'Padding',0); % plots

    set(gui.main,'Widths',[400 -1 ]);

    % waitbar indicating the loading of the GUI
    steps = 4;
    hwb = waitbar(0,'loading ...','Name','2DMod GUI initialization','Visible','off');
    set(hwb,'Units','Pixel')
    posw = get(hwb,'Position');
    set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
    set(hwb,'Visible','on');

    % --- modelling panel ---
    waitbar(1/steps,hwb,'loading GUI elements - 2D modelling');
    gui.panels.mod.main = uix.BoxPanel('Parent',gui.left,...
        'Title','2D modelling settings','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.GEO,'ForegroundColor',colors.BoxTitle);
    gui.panels.mod.VBox = uix.VBox('Parent',gui.panels.mod.main,...
        'Spacing',3,'Padding',3);

    % RTD T1
    gui.panels.mod.HBox1 = uix.HBox('Parent',gui.panels.mod.VBox,...
        'Spacing',3);
    gui.text_handles.rtdT1 = uicontrol('Parent',gui.panels.mod.HBox1,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','RTD T1 -  min [s] | max [s] | #');
    tstr = "";
    gui.edit_handles.rtdT1min = uicontrol('Parent',gui.panels.mod.HBox1,...
        'Style','edit','String',sprintf('%5.4f',data.mod.T1min),...
        'FontSize',myui.fontsize,'Tag','rtdT1min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT1max = uicontrol('Parent',gui.panels.mod.HBox1,...
        'Style','edit','String',sprintf('%d',data.mod.T1max),...
        'FontSize',myui.fontsize,'Tag','rtdT1max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT1N = uicontrol('Parent',gui.panels.mod.HBox1,...
        'Style','edit','String',sprintf('%d',data.mod.T1N),...
        'FontSize',myui.fontsize,'Tag','rtdT1N',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    set(gui.panels.mod.HBox1,'Widths',[cpanel_w -1 -1 -1]);

    % RTD T2
    gui.panels.mod.HBox2 = uix.HBox('Parent',gui.panels.mod.VBox,...
        'Spacing',3);
    gui.text_handles.rtdT2 = uicontrol('Parent',gui.panels.mod.HBox2,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','RTD T2 - min [s] | max [s] | #');
    tstr = "";
    gui.edit_handles.rtdT2min = uicontrol('Parent',gui.panels.mod.HBox2,...
        'Style','edit','String',sprintf('%5.4f',data.mod.T2min),...
        'FontSize',myui.fontsize,'Tag','rtdT2min',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT2max = uicontrol('Parent',gui.panels.mod.HBox2,...
        'Style','edit','String',sprintf('%d',data.mod.T2max),...
        'FontSize',myui.fontsize,'Tag','rtdT2max',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.rtdT2N = uicontrol('Parent',gui.panels.mod.HBox2,...
        'Style','edit','String',sprintf('%d',data.mod.T2N),...
        'FontSize',myui.fontsize,'Tag','rtdT2N',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    set(gui.panels.mod.HBox2,'Widths',[cpanel_w -1 -1 -1]);

    uix.Empty('Parent',gui.panels.mod.VBox);
    % table
    gui.panels.mod.HBox3 = uix.HBox('Parent',gui.panels.mod.VBox,...
        'Spacing',3);
    m = data.mod.mu;
    s = data.mod.sigma;
    a = data.mod.amp;
    table = cell(1,1);
    for i = 1:data.mod.Ndist
        table{i,1} = false;
        table{i,2} = m(i,1);
        table{i,3} = m(i,2);
        table{i,4} = s{i}(1,1);
        table{i,5} = s{i}(2,2);
        table{i,6} = s{i}(1,2);
        table{i,7} = s{i}(2,1);
        table{i,8} = a(i);
    end
    table{1,1} = true;
    data.results.mod2D.table = table;
    gui.table_handles.mod = uitable('Parent',gui.panels.mod.HBox3,...
    'Data',table,...
    'ColumnFormat',({'logical' 'short' 'short' 'bank' 'bank' 'bank' 'bank' 'bank'}),...
    'ColumnEditable',[true true true true true true true true],...
    'ColumnWidth',{35 77 77 33 33 33 33 33},...
    'RowName','numbered',...
    'ColumnName',{'use' 'mX','mY','xx','yy','xy','yx','A'},...
    'UserData',struct('Tooltipstr',tstr),...
    'CellEditCallback',@fv_onEditTable,...
    'FontSize',myui.fontsize);
    
    % UPDATE button
    % gui.panels.mod.HBox5 = uix.HBox('Parent',gui.panels.mod.VBox,...
    %     'Spacing',3);
    % uix.Empty('Parent',gui.panels.mod.HBox5);
    % tstr = 'Update model';
    % gui.push_handles.model = uicontrol('Parent',gui.panels.mod.HBox5,...
    %     'String','UPDATE MODEL','FontSize',myui.fontsize,'Tag','rtd',...
    %     'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
    %     'BackGroundColor','g','Callback',@fv_getModel);
    % set(gui.panels.mod.HBox5,'Widths',[cpanel_w -1]);

    % adjust heights
    set(gui.panels.mod.VBox,'Heights',[25 25 25 -1]);

    %% --- properties panel ---
    waitbar(2/steps,hwb,'loading GUI elements - properties');
    gui.panels.prop.main = uix.BoxPanel('Parent',gui.left,...
        'Title','Properties','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.GEO,'ForegroundColor',colors.BoxTitle);
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
        'Callback',@fv_onEditValue);
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
        'Callback',@fv_onEditValue);
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
        'Style','edit','String',sprintf('%d',data.nmr.T2te*1e6),...
        'FontSize',myui.fontsize,'Tag','echo_time',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','off',...
        'Callback',@fv_onEditValue);
    set(gui.panels.prop.HBox3,'Widths',[cpanel_w -1 -1]);

    % Tbulk
    gui.panels.prop.HBox4 = uix.HBox('Parent',gui.panels.prop.VBox,...
        'Spacing',3);
    gui.text_handles.Tbulk = uicontrol('Parent',gui.panels.prop.HBox4,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String',"Bulk relaxation [s]");
    uix.Empty('Parent',gui.panels.prop.HBox4);
    tstr = 'Set Tbulk value.';
    gui.edit_handles.Tbulk = uicontrol('Parent',gui.panels.prop.HBox4,...
        'Style','edit','String',sprintf('%d',data.prop.Tbulk),...
        'FontSize',myui.fontsize,'Tag','Tbulk',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    set(gui.panels.prop.HBox4,'Widths',[cpanel_w -1 -1]);

    %% --- NMR signal panel ---
    waitbar(3/steps,hwb,'loading GUI elements - Signal panel');
    gui.panels.nmr.main = uix.BoxPanel('Parent',gui.left,...
        'Title','NMR signals','MinimizeFcn',@minimizePanel,...
        'TitleColor',colors.NMR,'ForegroundColor',colors.BoxTitle);
    gui.panels.nmr.VBox = uix.VBox('Parent',gui.panels.nmr.main,...
        'Spacing',3,'Padding',3);

    % T1type
    gui.panels.nmr.HBox0 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    gui.text_handles.T1type = uicontrol('Parent',gui.panels.nmr.HBox0,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T1 type (SR / IR)');
    tstr = 'Choose between Saturation and Inversion Recovery.';
    gui.popup_handles.T1type = uicontrol('Parent',gui.panels.nmr.HBox0,...
        'Style','popup','String',{'Saturation Recovery','Inversion Recovery'},...
        'Value',data.nmr.T1IRfac,'FontSize',myui.fontsize,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onPopupT1Type);
    set(gui.panels.nmr.HBox0,'Widths',[cpanel_w -1]);

    % T1 timings
    gui.panels.nmr.HBox1 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    gui.text_handles.timeT1 = uicontrol('Parent',gui.panels.nmr.HBox1,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T1 recov -  min [s] | max [s] | #');
    tstr = "";
    gui.edit_handles.T1trmin = uicontrol('Parent',gui.panels.nmr.HBox1,...
        'Style','edit','String',sprintf('%5.4f',data.nmr.T1trmin),...
        'FontSize',myui.fontsize,'Tag','T1trmin',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.T1trmax = uicontrol('Parent',gui.panels.nmr.HBox1,...
        'Style','edit','String',sprintf('%d',data.nmr.T1trmax),...
        'FontSize',myui.fontsize,'Tag','T1trmax',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.T1trN = uicontrol('Parent',gui.panels.nmr.HBox1,...
        'Style','edit','String',sprintf('%d',data.nmr.T1trN),...
        'FontSize',myui.fontsize,'Tag','T1trN',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    set(gui.panels.nmr.HBox1,'Widths',[cpanel_w -1 -1 -1]);

    % T2 timings
    gui.panels.nmr.HBox2 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    gui.text_handles.timeT2 = uicontrol('Parent',gui.panels.nmr.HBox2,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','T2 echo time [µs] | # echos');
    tstr = "";
    gui.edit_handles.T2te = uicontrol('Parent',gui.panels.nmr.HBox2,...
        'Style','edit','String',sprintf('%5.2f',data.nmr.T2te*1e6),...
        'FontSize',myui.fontsize,'Tag','T2te',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    tstr = "";
    gui.edit_handles.T2teN = uicontrol('Parent',gui.panels.nmr.HBox2,...
        'Style','edit','String',sprintf('%d',data.nmr.T2teN),...
        'FontSize',myui.fontsize,'Tag','T2teN',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onEditValue);
    set(gui.panels.nmr.HBox2,'Widths',[cpanel_w -1 -1]);
    
    % noise
    gui.panels.nmr.HBox3 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    gui.text_handles.noise = uicontrol('Parent',gui.panels.nmr.HBox3,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','Noise settings');
    tstr = ['<HTML>NMR data noise method.<br><br>',...
        'A noise level will be used globally for all NMR signals.<br>',...
        'A signal-to-ratio will be used individually on every single NMR signal.<br><br>',...
        '<u>Available options:</u><br>',...
        '<b>noise level</b> or <b>SNR</b> <br><br>',...
        '<u>Default value:</u><br>',...
        '<b>noise level</b> <br>'];
    gui.popup_handles.noisetype = uicontrol('Parent',gui.panels.nmr.HBox3,...
        'Style','popup','String',{'noise level','SNR'},...
        'Value',1,'FontSize',myui.fontsize,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onPopupNoiseType);
    tstr = ['<HTML>NMR data noise.<br><br>',...
        '<u>Hint:</u><br>',...
        'You do not need to press RUN to add noise to the NMR signals.<br>',...
        'The raw NMR signals are stored internally and the noise is<br>',...
        'applied instantaneously.<br><br>',...
        '<u>Default value:</u><br>',...
        '<b>0</b><br>'];
    gui.edit_handles.noise = uicontrol('Parent',gui.panels.nmr.HBox3,...
        'Style','edit','String',num2str(data.nmr.noise),'FontSize',myui.fontsize,...
        'UserData',struct('Tooltipstr',tstr,'defaults',[data.nmr.noise 1 1]),...
        'Tag','nmr_noise','Enable','on','Callback',@fv_onEditValue);
    set(gui.panels.nmr.HBox3,'Widths',[cpanel_w -1 -1]);

    % Calc button
    gui.panels.nmr.HBox4 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    uix.Empty('Parent',gui.panels.nmr.HBox4);
    tstr = 'Get NMR signals';
    gui.push_handles.nmr = uicontrol('Parent',gui.panels.nmr.HBox4,...
        'String','GET NMR SIGNALS','FontSize',myui.fontsize,'Tag','2dmod',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'BackGroundColor','g','Callback',@fv_getNMR);
    set(gui.panels.nmr.HBox4,'Widths',[cpanel_w -1]);

    % log/lin axes
    gui.panels.nmr.HBox5 = uix.HBox('Parent',gui.panels.nmr.VBox,...
        'Spacing',3);
    gui.text_handles.loglin_axes = uicontrol('Parent',gui.panels.nmr.HBox5,...
        'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        'String','Echo time axes');
    tstr = "";
    gui.radio_handles.log = uicontrol('Parent',gui.panels.nmr.HBox5,...
        'Style','radiobutton','String','log','FontSize',myui.fontsize,'Tag','log',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','on','Value',1,'Callback',@fv_onRadioLogLin);
    gui.radio_handles.lin = uicontrol('Parent',gui.panels.nmr.HBox5,...
        'Style','radiobutton','String','lin','FontSize',myui.fontsize,'Tag','lin',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Enable','on','Value',0,'Callback',@fv_onRadioLogLin);
    set(gui.panels.nmr.HBox5,'Widths',[cpanel_w -1 -1]);

    %% --- update MAIN GUI button ---
    gui.panels.save.HBox1 = uix.VBox('Parent',gui.left,...
        'Spacing',3);   
    tstr = 'UPDATE 2D inversion data in main NUCLEUSinv GUI.';
    gui.push_handles.update = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','UPDATE MAIN GUI','FontSize',myui.fontsize,'Tag','update',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onPushUpdate,'Enable','off');
    tstr = 'SAVE 2D inversion data to external file.';
    gui.push_handles.save = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','SAVE RESULT','FontSize',myui.fontsize,'Tag','save',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onPushSave);
    tstr = 'Export current graphics view to Figure.';
    gui.push_handles.view = uicontrol('Parent',gui.panels.save.HBox1,...
        'String','VIEW2FIG','FontSize',myui.fontsize,'Tag','view',...
        'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
        'Callback',@fv_onPushView);
    % set(gui.panels.save.HBox1,'Widths',[-1 -1]);

    % fix text vertical alignment
    jh = findjobj(gui.text_handles.diff);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.gradient);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.echo_time);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.Tbulk);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

    jh = findjobj(gui.text_handles.rtdT1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.rtdT2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    
    jh = findjobj(gui.text_handles.T1type);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.timeT1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.timeT2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.noise);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
    jh = findjobj(gui.text_handles.loglin_axes);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

    % empty space at bottom of left side
    uix.Empty('Parent',gui.left);
    % adjust the heights of all left-column-panels
    heights = [22 22 22 28 -1; 22+2*24+3*4+115 22+4*24+6*3 22+6*24+8*3 28*3 -1];
    % panel header is always 22 high
    set(gui.left,'Heights',heights(2,:),...
        'MinimumHeights',[22 22 22 28 0]);

    %% --- plot boxes ---
    waitbar(4/steps,hwb,'loading GUI elements - graphics');
    gui.rightPanel = uix.TabPanel('Parent',gui.right,...
        'BackGroundColor',colors.panelBG);

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

    gui.rightPanel.TabTitles = {'MODEL','SIGNALS'};
    gui.rightPanel.TabWidth = 75;
    gui.rightPanel.TabEnables = {'on','on'};

    % -- plot axes --
    gui.axes2 = axes('Parent',gui.pbox22,'Box','on');
    gui.axes21 = axes('Parent',gui.pbox21,'Box','on');
    gui.axes24 = axes('Parent',gui.pbox24,'Box','on');
    gui.axes31 = axes('Parent',gui.pbox31,'Box','on');
    gui.axes32 = axes('Parent',gui.pbox32,'Box','on');

    % --- store main GUI settings ---
    gui.myui = nucleus.gui.myui;
    gui.myui.heights = heights;
    gui.figh_nucleus = figh_nucleus;

    % --- save gui data to GUI ---
    setappdata(fig_2Dmod,'gui',gui);
    setappdata(fig_2Dmod,'data',data);

    % make GUI visible
    delete(hwb);
    set(gui.main,'Visible','on');
else
    % if the figure is already open bring t to the front
    figure(fig_2Dmod);
end

% trigger the model update pushbutton for the initial view
fv_getModel(fig_2Dmod);
beautifyAxes(fig_2Dmod);
end

%% subfunction to update the table entries
function fv_onEditTable(src,~)
figh = ancestor(src,'figure','toplevel');
fv_getModel(figh)

end

%% subfunction to update the edit fields
function fv_onEditValue(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');

switch get(src,'Tag')
    case {'diff','gradient','Tbulk'}
        data.prop.D = str2double(get(gui.edit_handles.diff,'String'))/1e9;
        data.prop.G0 = str2double(get(gui.edit_handles.gradient,'String'));        
        data.prop.Tbulk = str2double(get(gui.edit_handles.Tbulk,'String'));
    case {'rtdT1min','rtdT1max','rtdT1N'}
        data.mod.T1min = str2double(get(gui.edit_handles.rtdT1min,'String'));
        data.mod.T1max = str2double(get(gui.edit_handles.rtdT1max,'String'));
        data.mod.T1N = str2double(get(gui.edit_handles.rtdT1N,'String'));
        setappdata(figh,'data',data);
        fv_getModel(gui.push_handles.model);
        data = getappdata(figh,'data');
    case {'rtdT2min','rtdT2max','rtdT2N'}
        data.mod.T2min = str2double(get(gui.edit_handles.rtdT2min,'String'));
        data.mod.T2max = str2double(get(gui.edit_handles.rtdT2max,'String'));
        data.mod.T2N = str2double(get(gui.edit_handles.rtdT2N,'String'));
        setappdata(figh,'data',data);
        fv_getModel(gui.push_handles.model);
        data = getappdata(figh,'data');
     case {'T1trmin','T1trmax','T1trN'}
        data.nmr.T1trmin = str2double(get(gui.edit_handles.T1trmin,'String'));
        data.nmr.T1trmax = str2double(get(gui.edit_handles.T1trmax,'String'));
        data.nmr.T1trN = str2double(get(gui.edit_handles.T1trN,'String'));
    case {'T2te','T2teN'}
        data.nmr.T2te = str2double(get(gui.edit_handles.T2te,'String'))/1e6;
        data.nmr.T2teN = str2double(get(gui.edit_handles.T2teN,'String'));

        data.prop.te = data.nmr.T2te;
        set(gui.edit_handles.echo_time,'String',data.prop.te*1e6);
    case {'nmr_noise'}
        data.nmr.noise = str2double(get(gui.edit_handles.noise,'String'));
        switch data.nmr.noisetype
            case 'level'
            case 'SNR'
                if data.nmr.noise == 0
                    data.nmr.noise = Inf;
                    set(src,'String',num2str(data.nmr.noise));
                end
        end
        setappdata(figh,'data',data);
        if isfield(data.results.mod2D,'data')
            fv_addNoise(figh)
            data = getappdata(figh,'data');
        end        
end

% update GUI data
setappdata(figh,'data',data);
end

%% subfunction to set the T1 type
function fv_onPopupT1Type(src,~)
figh = ancestor(src,'figure','toplevel');
data = getappdata(figh,'data');

switch get(src,'Value')
    case 1 % Saturation Recovery
        data.nmr.T1IRfac = 1;
    case 2 % Inversion Recovery
        data.nmr.T1IRfac = 2;
end

% update GUI data
setappdata(figh,'data',data);
end

%% subfunction to set the NMR data noise type
function fv_onPopupNoiseType(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');

% change settings accordingly
switch get(src,'Value')
    case 1 % noise level
        data.nmr.noisetype = 'level';
        if data.nmr.noise > 0
            data.nmr.noise = 1/data.nmr.noise;
        end        
    case 2 % signal-to-noise ratio (SNR)
        data.nmr.noisetype = 'SNR';
        if data.nmr.noise == 0
            data.nmr.noise = inf;
        else
            data.nmr.noise = 1/data.nmr.noise;
        end        
end
% update the corresponding edit field
set(gui.edit_handles.noise,'String',num2str(data.nmr.noise));

% update GUI data
setappdata(figh,'data',data);
% update NMR data (if available)
if isfield(data.results.mod2D,'data')
    fv_addNoise(figh);
end

end

%% subfunction to set the T1 t<pe
function fv_addNoise(figh)
data = getappdata(figh,'data');
mod2D = data.results.mod2D;

% first check what is the noise type
switch data.nmr.noisetype
    case 'level'
        noise = data.nmr.noise;
    case 'SNR'
        SNR = data.nmr.noise;
        noise = 1./SNR;
end

if noise > 0
    for n = 1:numel(mod2D.data)
        mod2D.data(n).noise = noise;
        [re,im] = addNoiseToSignal(mod2D.data(n).s_raw,0,noise);
        mod2D.data(n).s = complex(re,im);
    end
else
    % reset the NMR signals with the raw data (without noise)
    for n = 1:numel(mod2D.data)
        mod2D.data(n).noise = 0;
        mod2D.data(n).s = complex(mod2D.data(n).s_raw,zeros(size(mod2D.data(n).s_raw)));
    end
end

% update the GUI data
data.results.mod2D = mod2D;
setappdata(figh,'data',data);
% plot all signals
fv_plotSignals(figh);
beautifyAxes(figh);
end

%% subfunction to get the 2D model
function fv_getModel(figh)
% figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');

% create model space from relaxation time T vectors
T1min = data.mod.T1min;
T1max = data.mod.T1max;
T1N = data.mod.T1N;
T2min = data.mod.T2min;
T2max = data.mod.T2max;
T2N = data.mod.T2N;

T1vec = logspace(log10(T1min),log10(T1max),T1N);
T2vec = logspace(log10(T2min),log10(T2max),T2N);
MOD = zeros(numel(T1vec),numel(T2vec));

[X1,X2] = meshgrid(T2vec,T1vec);
X = [X1(:) X2(:)];

% get table with model parameters
table = get(gui.table_handles.mod,'Data');
data.results.mod2D.table = table;
% create distributions
for nn = 1:size(table,1)
    if table{nn,1}
        % muX muY
        mu = [table{nn,2} table{nn,3}];
        % sigma = [xx xy; yx yy]
        Sigma = [table{nn,4} table{nn,6}; table{nn,7} table{nn,5}];
        % get multivariate distribution of linearized data
        p = getMultivariateGaussian(log10(X), log10(mu), Sigma);
        p = reshape(p,T1N,T2N);
        Amp = table{nn,8};
        MOD = MOD + Amp*p./max(p(:));
    end
end

if any(isnan(MOD))
    MOD = ones(size(MOD));
end

% normalize to 1
MOD = MOD./sum(MOD(:));

data.results.mod2D.T1vec = T1vec;
data.results.mod2D.T2vec = T2vec;
data.results.mod2D.MOD = MOD;
% update GUI data
setappdata(figh,'data',data);
% update plot
fv_plotModel(figh);
beautifyAxes(figh);
end

%% subfunction to calculate the NMR signals
function fv_getNMR(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
mod2D = data.results.mod2D;

% prepare parameters
% IR / SR factor
T1IRfac = data.nmr.T1IRfac;
IRtype = data.nmr.IRtype;

% get system properties
D = data.prop.D;
G0 = data.prop.G0;
te = data.prop.te;
Tbulk = data.prop.Tbulk;

T1vec = mod2D.T1vec;
T2vec = mod2D.T2vec;

% disable the RUN button to indicate a running inversion
set(gui.push_handles.nmr,'String','RUNNING ...',...
    'BackgroundColor',get(gui.push_handles.update,'BackgroundColor'),...
    'Enable','off'); pause(0.01);

% prepare data
% T2 time vector
t2 = getNMRTimeVector(data.nmr.T2te,'s','N',data.nmr.T2teN);
T1 = logspace(log10(data.nmr.T1trmin),log10(data.nmr.T1trmax),data.nmr.T1trN);
dat = struct;
for n = 1:numel(T1)
    dat(n).t = t2;
    dat(n).s = zeros(size(t2));
    dat(n).T1 = T1(n);
end

% create the Kernel matrix for inversion
p.G0 = G0;
p.D = D;
p.te = te;
p.Tbulk = Tbulk;
p.T1IRfac = T1IRfac;
p.IRtype = IRtype;
[K,indices] = createKernelMatrix2D(dat,T1vec,T2vec,p);

MODvec = reshape(mod2D.MOD',size(mod2D.MOD,1)*size(mod2D.MOD,2),1);
RESvec = K*MODvec;

for n = 1:numel(T1)
    dat(n).s = RESvec(indices.lin_1(n):indices.lin_end(n));
    dat(n).s_raw = RESvec(indices.lin_1(n):indices.lin_end(n));
end

% enable the RN button
set(gui.push_handles.nmr,'String','GET NMR SIGNALS',...
    'BackgroundColor','g','Enable','on','Callback',@fv_getNMR);
setappdata(figh,'gui',gui);

% save results
data.results.mod2D.t2 = t2;
data.results.mod2D.t_recov = T1;
data.results.mod2D.data = dat;

% update data
setappdata(figh,'data',data);
fv_addNoise(figh)

% plot all signals
fv_plotSignals(figh);
beautifyAxes(figh);
gui.rightPanel.Selection = 2;
end

%% subfunction to export the 2D inversion data
function fv_onPushSave(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
data = getappdata(figh,'data');

% get data path to save inversion results
[sfile,spath] = uiputfile('*.mat','Select File for Save',...
    fullfile(pwd,'2Dmoddata.mat'));
% if user did not cancel, procceed
if sfile > 0
    moddata = data;
    save(fullfile(spath,sfile),'moddata');
    disp('2D Modeling data saved to: ');
    disp(fullfile(spath,sfile));
else
    disp('Save cancelled.');
end

end

%% subfunction to export the current view to a figure
function fv_onPushView(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
gui = getappdata(figh,'gui');

% opening the export figure
expfig = figure('Color',gui.myui.colors.panelBG);

% create axes layout depending on view
switch get(gui.rightPanel,'Selection')
    case 1
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
    case 2
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
function fv_onPushUpdate(src,~)
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
    data.process.start = 1;
    data.process.end = numel(uvdata.results.T1T2map.import{id}.time);
    data.process.gatetype = 'raw';
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
    end
    % create proc data struct
    data.results.nmrproc.start = 1;
    data.results.nmrproc.end = numel(uvdata.results.T1T2map.import{id}.time);
    data.results.nmrproc.gatetype = 'raw';
    data.results.nmrproc.t = uvdata.results.T1T2map.import{id}.time;
    data.results.nmrproc.s = real(uvdata.results.T1T2map.import{id}.signal);
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

%% subfunction to update all plots
function fv_plotSignals(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
mod2D = data.results.mod2D;
data_mod = mod2D.data;
col = gui.myui.colors;

% clear axes
clearSingleAxis(gui.axes31);
clearSingleAxis(gui.axes32);
hold(gui.axes31,'on');
hold(gui.axes32,'on');

% define some axes settings
log_t_ticks = logspace(-5,2,8);
t_recov_lims = [min(mod2D.t_recov)/2 max(mod2D.t_recov)*2];

% prepare the data for the combined T1 curve
E_mod = zeros(size(mod2D.t_recov));
for nn = 1:numel(data_mod)
    E_mod(nn,1) = data_mod(nn).s(1);
    % plot individual T2 signals and fits
    plot3(data_mod(nn).t,data_mod(nn).T1*ones(size(data_mod(nn).s)),...
        data_mod(nn).s,'Color',col.axisL,'DisplayName','T2 signals',...
        'LineWidth',1,'Parent',gui.axes32);
end
view(gui.axes32,[30 20]);
set(gui.axes32,'XScale','log','XTick',log_t_ticks);
set(gui.axes32,'YScale','log','YDir','normal','YTick',log_t_ticks,'YLim',t_recov_lims);
set(get(gui.axes32,'XLabel'),'String','time [s]');
set(get(gui.axes32,'YLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes32,'ZLabel'),'String','amplitude [a.u.]');
% fv_fixLabel3DAxes(gui.axes32)

% tab 3 - combined T1 curve and fit
plot(mod2D.t_recov,E_mod(:,1),'o-','Color',col.axisL,...
    'LineWidth',1,'DisplayName','T1 curve','Parent',gui.axes31);
set(gui.axes31,'XScale','log','XLim',t_recov_lims);
set(gui.axes31,'YScale','lin');
set(get(gui.axes31,'XLabel'),'String','recovery time t_{rec} [s]');
set(get(gui.axes31,'YLabel'),'String','mean(E(1:3)) [a.u.]');
legend(gui.axes31,'Location','SouthEast');

% hold off all axes
hold(gui.axes31,'off');
hold(gui.axes32,'off');

% call function to adapt the axes scaling
fv_setAxesScaling(figh);
end

%%  subfunction to plot the raw data
function fv_plotModel(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
col = gui.myui.colors;
mod2D = data.results.mod2D;

clearSingleAxis(gui.axes2);
clearSingleAxis(gui.axes21);
clearSingleAxis(gui.axes24);
hold(gui.axes2,'on');
hold(gui.axes21,'on');
hold(gui.axes24,'on');

log_t_ticks = logspace(-5,2,8);

% tab 2 - 2D inversion model
[X,Y] = meshgrid(mod2D.T2vec,mod2D.T1vec);
imagescnan(X,Y,mod2D.MOD,'Parent',gui.axes2);
plot([1e-5 100],[1e-5 100],...
    '--','Color','w','LineWidth',1,'Parent',gui.axes2);
view(gui.axes2,[0 90]);
set(gui.axes2,'XScale','log','XTick',log_t_ticks,...
    'XLim',[min(mod2D.T2vec) max(mod2D.T2vec)]);
set(gui.axes2,'YScale','log','XTick',log_t_ticks,...
    'YLim',[min(mod2D.T1vec) max(mod2D.T1vec)],'YDir','normal');
set(get(gui.axes2,'XLabel'),'String','relaxation time T2 [s]');
set(get(gui.axes2,'YLabel'),'String','relaxation time T1 [s]');
set(gui.axes2,'Layer','top','XGrid','off','YGrid','off');

% sum along each dimension to get both RTDs
T1rtd = sum(mod2D.MOD,2);
T2rtd = sum(mod2D.MOD,1);
% find common maximum for y-axis setting
ymax = max([max(T1rtd) max(T2rtd)])*1.1;
% T1 RTD
plot(T1rtd,mod2D.T1vec,'Color',col.axisL,'Parent',gui.axes24);
set(gui.axes24,'XScale','lin','XLim',[0 ymax]);
set(gui.axes24,'YScale','log','YTickLabel','');

% T2 RTD
plot(mod2D.T2vec,T2rtd,'Color',col.axisL,'DisplayName','RTD','Parent',gui.axes21);
set(gui.axes21,'YScale','lin','YLim',[0 ymax]);
set(gui.axes21,'XScale','log','XTickLabel','');

hold(gui.axes2,'off');
hold(gui.axes21,'off');
hold(gui.axes24,'off');
end

%% subfunction zo switch x-axis scaling
function fv_onRadioLogLin(src,~)
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
fv_setAxesScaling(figh);
end

%% subfunction to switch x-axis scaling log<->lin
function fv_setAxesScaling(figh)
gui = getappdata(figh,'gui');

uselog = get(gui.radio_handles.log,'Value');
switch uselog
    case 1
        log_t_ticks = logspace(-5,2,8);
        set(gui.axes32,'XScale','log','XTick',log_t_ticks);
    case 0
        set(gui.axes32,'XScale','lin','XTickMode','auto');
end

end

%% close function
function fv_closeme(src,~)
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