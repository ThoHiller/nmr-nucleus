function UncertView(src,~)
%UncertView is an extra subGUI to show results of the uncertainty
%calculation
%
% Syntax:
%       UncertView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       UncertView(src,~)
%
% Other m-files required:
%       beautifyAxes
%       clearAllAxes
%       estimateUncertainty
%       createKernelMatrix
%       updatePlotsSignal
%       updatePlotsDistribution
%       updateInfo
%
% Subfunctions:
%       uv_closeme
%       uv_onEditValue
%       uv_updateMASK
%       uv_onPushRun
%       uv_onPushUpdate
%       uv_onPushReset
%       uv_updateInformation
%       uv_updatePlots
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

hasUncert = false;
if isfield(nucleus.data.results,'invstd')
    if isfield(nucleus.data.results.invstd,'uncert')
        hasUncert = true;
    end
end

%% proceed only if there is already uncertainty data
if hasUncert
    nucleus_data = nucleus.data;

    % check if the figure is already open
    fig_uncert = findobj('Tag','UNCERTVIEW');
    % if not, create it
    if isempty(fig_uncert)
        % draw the figure on top of NUCLEUSinv
        fig_uncert = figure('Name','NUCLEUSinv - RTD Uncertainty',...
            'NumberTitle','off','Resize','on','ToolBar','none',...
            'CloseRequestFcn',@uv_closeme,...
            'MenuBar','none','Tag','UNCERTVIEW');
        pos0 = get(figh_nucleus,'Position');
        cent(1) = (pos0(1)+pos0(3)/2);
        cent(2) = (pos0(2)+pos0(4)/2);
        % posf = [cent(1)-pos0(3)/3 pos0(2)+22 pos0(3)/1.5 pos0(4)-22];
        posf = [cent(1)-pos0(3)/2.5 pos0(2)+22 pos0(3)/1.25 pos0(4)-22];
        set(fig_uncert,'Position',posf);

        gui.menu.view = uimenu(fig_uncert,'Label','View');
        gui.menu.view_toolbar = uimenu(gui.menu.view,'Label','Figure Toolbar',...
            'Callback',@onMenuView);

        cpanel_w = 175;

        % create the main layout
        gui.main = uix.HBox('Parent',fig_uncert,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',5,'Visible','off');
        gui.left = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',0); % controls
        gui.right = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',0); % plots

        set(gui.main,'Widths',[350 -1 ]);

        % waitbar indicating the loading of the GUI
        steps = 5;
        hwb = waitbar(0,'loading ...','Name','UncertView initialization','Visible','off');
        set(hwb,'Units','Pixel')
        posw = get(hwb,'Position');
        set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
        set(hwb,'Visible','on');

        % --- control panel ---
        waitbar(1/steps,hwb,'loading GUI elements - control');
        gui.panels.control.main = uix.BoxPanel('Parent',gui.left,...
            'Title','Recalculate RTD Uncertainty','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
        gui.panels.control.VBox = uix.VBox('Parent',gui.panels.control.main,...
            'Spacing',3,'Padding',3);
        % uncertainty method
        gui.panels.control.HBox1 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        gui.text_handles.uncertMethod = uicontrol('Parent',gui.panels.control.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','Method');
        tstr = ['<HTML>Choose the uncertainty calculation method.<br><br>',...
            '<u>Available options:</u><br>',...
            '<font color="red">Multi exp. (LSQ) | Multi exp. (LU decomp.):<br>',...
            '<font color="black">',...
            '<b>RMS - unbounded</b> Keep all uncert models.<br>',...
            '<b>RMS - bounded</b> Only keep models within Lm and chi2 bounds.<br>',...
            '<font color="red">Multi modal:<br>',...
            '<font color="black">',...
            '<b>RMS - unbounded</b> Keep all uncert models.<br>',...
            '<b>RMS - bounded</b> Only keep models within Lm and chi2 bounds.<br>',...
            '<b>Threshold</b> Vary fit parameter by threshold.<br>',...
            '<b>Conf. Interval</b> Vary fit parameter randomly within confidence interval.<br><br>',...
            '<u>Default value:</u><br>',...
            '<b>RMS - bounded</b><br>'];
        gui.popup_handles.uncertMethod = uicontrol('Parent',gui.panels.control.HBox1,...
            'Style','popup','String',{'RMS - unbounded','RMS - bounded'},...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,'Tag','control','Callback',@uv_onPopupMethod);
        set(gui.panels.control.HBox1,'Widths',[cpanel_w -1]);
        % number of uncertainty models
        gui.panels.control.HBox2 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        gui.text_handles.uncertN = uicontrol('Parent',gui.panels.control.HBox2,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','#models');
        uix.Empty('Parent',gui.panels.control.HBox2);
        tstr = 'Number of uncertainty models to calculate.';
        gui.edit_handles.uncertN = uicontrol('Parent',gui.panels.control.HBox2,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','uncertN',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        set(gui.panels.control.HBox2,'Widths',[cpanel_w -1 -1]);
        % bound1: chi2 range
        gui.panels.control.HBox3 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        gui.text_handles.uncertchi2 = uicontrol('Parent',gui.panels.control.HBox3,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',[char(hex2dec('03A7')),char(hex2dec('00B2')),...
            ' range          min | max']);
        tstr = 'Lower bound of chi2 range.';
        gui.edit_handles.uncertchi2_min = uicontrol('Parent',gui.panels.control.HBox3,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','control',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        tstr = 'Upper bound of chi2 range.';
        gui.edit_handles.uncertchi2_max = uicontrol('Parent',gui.panels.control.HBox3,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','control',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        set(gui.panels.control.HBox3,'Widths',[cpanel_w -1 -1]);
        % bound2: model norm range
        gui.panels.control.HBox4 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        gui.text_handles.uncertmnorm = uicontrol('Parent',gui.panels.control.HBox4,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',['|Lm|',char(hex2dec('2082')),' range      min | max']);
        tstr = 'Lower bound of model norm range.';
        gui.edit_handles.uncertmnorm_min = uicontrol('Parent',gui.panels.control.HBox4,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','control',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        tstr = 'Upper bound of model norm range.';
        gui.edit_handles.uncertmnorm_max = uicontrol('Parent',gui.panels.control.HBox4,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','control',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        set(gui.panels.control.HBox4,'Widths',[cpanel_w -1 -1]);
        % bound3: threshold
        gui.panels.control.HBox5 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        gui.text_handles.uncertThresh = uicontrol('Parent',gui.panels.control.HBox5,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','Threshold   |   Max. #tries');
        % uix.Empty('Parent',gui.panels.control.HBox5);
        tstr = 'Threshold value (0.05 = 5%).';
        gui.edit_handles.uncertThresh = uicontrol('Parent',gui.panels.control.HBox5,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','uncertThresh',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        % set(gui.panels.control.HBox5,'Widths',[cpanel_w -1 -1]);
        % max tries
        % gui.panels.control.HBox6 = uix.HBox('Parent',gui.panels.control.VBox,...
        %     'Spacing',3);
        % gui.text_handles.uncertMax = uicontrol('Parent',gui.panels.control.HBox6,...
        %     'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
        %     'String','Max. #tries');
        % uix.Empty('Parent',gui.panels.control.HBox6);
        tstr = 'Maximum number of unsuccesful tries.';
        gui.edit_handles.uncertMax = uicontrol('Parent',gui.panels.control.HBox5,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','uncertMax',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Enable','off','Callback',@uv_onEditValue);
        set(gui.panels.control.HBox5,'Widths',[cpanel_w -1 -1]);
        % RUN button
        gui.panels.control.HBox7 = uix.HBox('Parent',gui.panels.control.VBox,...
            'Spacing',3);
        uix.Empty('Parent',gui.panels.control.HBox7);        
        tstr = ['<HTML>RUN uncertainty calculation.<br>',...
            'Regularization is the same as in main NUCLEUSinv GUI.'];
        gui.push_handles.run = uicontrol('Parent',gui.panels.control.HBox7,...
            'String','RUN UNCERT','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackGroundColor','g','Callback',@uv_onPushRun);
        set(gui.panels.control.HBox7,'Widths',[cpanel_w -1]);

        % --- process panel ---
        waitbar(2/steps,hwb,'loading GUI elements - process');
        gui.panels.process.main = uix.BoxPanel('Parent',gui.left,...
            'Title','Process Uncertainty Runs','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
        gui.panels.process.VBox = uix.VBox('Parent',gui.panels.process.main,...
            'Spacing',3,'Padding',3);
        % chi2 range
        gui.panels.process.HBox1 = uix.HBox('Parent',gui.panels.process.VBox,...
            'Spacing',3);
        gui.text_handles.chi2 = uicontrol('Parent',gui.panels.process.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',[char(hex2dec('03A7')),char(hex2dec('00B2')),...
            ' range          min | max']);
        tstr = 'Lower bound of chi2 range.';
        gui.edit_handles.chi2_min = uicontrol('Parent',gui.panels.process.HBox1,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        tstr = 'Upper bound of chi2 range.';
        gui.edit_handles.chi2_max = uicontrol('Parent',gui.panels.process.HBox1,...
            'Style','edit','String','2','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        set(gui.panels.process.HBox1,'Widths',[cpanel_w -1 -1]);
        % model norm range
        gui.panels.process.HBox2 = uix.HBox('Parent',gui.panels.process.VBox,...
            'Spacing',3);
        gui.text_handles.mnorm = uicontrol('Parent',gui.panels.process.HBox2,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',['|Lm|',char(hex2dec('2082')),' range      min | max']);
        tstr = 'Lower bound of model norm range.';
        gui.edit_handles.mnorm_min = uicontrol('Parent',gui.panels.process.HBox2,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        tstr = 'Upper bound of model norm range.';
        gui.edit_handles.mnorm_max = uicontrol('Parent',gui.panels.process.HBox2,...
            'Style','edit','String','2','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        set(gui.panels.process.HBox2,'Widths',[cpanel_w -1 -1]);
        % RESET button
        gui.panels.process.HBox3 = uix.HBox('Parent',gui.panels.process.VBox,...
            'Spacing',3);
        uix.Empty('Parent',gui.panels.process.HBox3);
        tstr = 'SEND bounds to recaluclation panel above.';
        gui.push_handles.send = uicontrol('Parent',gui.panels.process.HBox3,...
            'String','USE','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushSend);
        tstr = 'RESET processing bounds and plots.';
        gui.push_handles.reset = uicontrol('Parent',gui.panels.process.HBox3,...
            'String','RESET','FontSize',myui.fontsize,'Tag','process',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushReset);
        set(gui.panels.process.HBox3,'Widths',[cpanel_w -1 -1]);

        % --- RTD panel ---
        waitbar(3/steps,hwb,'loading GUI elements - RTD bounds');
        gui.panels.rtd.main = uix.BoxPanel('Parent',gui.left,...
            'Title','RTD Calculation Bounds','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
        gui.panels.rtd.VBox = uix.VBox('Parent',gui.panels.rtd.main,...
            'Spacing',3,'Padding',3);
        % RTD range
        gui.panels.rtd.HBox1 = uix.HBox('Parent',gui.panels.rtd.VBox,...
            'Spacing',3);
        gui.text_handles.rtd = uicontrol('Parent',gui.panels.rtd.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','RTD range       min | max');
        tstr = ['<HTML>Minimum relaxation time in RTDs used<br>',...
            'for calculating statistics on E0 & TLGM.'];
        gui.edit_handles.rtd_min = uicontrol('Parent',gui.panels.rtd.HBox1,...
            'Style','edit','String','0','FontSize',myui.fontsize,'Tag','rtd',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        tstr = ['<HTML>Maximum relaxation time in RTDs used<br>',...
            'for calculating statistics on E0 & TLGM.'];
        gui.edit_handles.rtd_max = uicontrol('Parent',gui.panels.rtd.HBox1,...
            'Style','edit','String','2','FontSize',myui.fontsize,'Tag','rtd',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onEditValue);
        set(gui.panels.rtd.HBox1,'Widths',[cpanel_w -1 -1]);
        % RESET button
        gui.panels.rtd.HBox3 = uix.HBox('Parent',gui.panels.rtd.VBox,...
            'Spacing',3);
        uix.Empty('Parent',gui.panels.rtd.HBox3);
        uix.Empty('Parent',gui.panels.rtd.HBox3);
        tstr = 'RESET RTDs calculation bounds.';
        gui.push_handles.reset_rtd = uicontrol('Parent',gui.panels.rtd.HBox3,...
            'String','RESET','FontSize',myui.fontsize,'Tag','rtd',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushReset);
        set(gui.panels.rtd.HBox3,'Widths',[cpanel_w -1 -1]);

        % --- Statistics panel ---
        waitbar(4/steps,hwb,'loading GUI elements - statistics');
        gui.panels.info.main = uix.BoxPanel('Parent',gui.left,...
            'Title','Uncertainty Statistics','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxINV,'ForegroundColor',colors.BoxTitle);
        gui.panels.info.VBox = uix.VBox('Parent',gui.panels.info.main,...
            'Spacing',3,'Padding',3);
        % mean TLGM
        gui.panels.info.HBox1 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.TLGM = uicontrol('Parent',gui.panels.info.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','TLGM          mean | 2*std');
        tstr = 'MEAN of all TLGM values.';
        gui.edit_handles.TLGM_mean = uicontrol('Parent',gui.panels.info.HBox1,...
            'Style','edit','String','0','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxPRC);
        tstr = 'STD of all TLGM values.';
        gui.edit_handles.TLGM_std = uicontrol('Parent',gui.panels.info.HBox1,...
            'Style','edit','String','2','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxPRC);
        set(gui.panels.info.HBox1,'Widths',[cpanel_w -1 -1]);
        % aad TLGM
        gui.panels.info.HBox2 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.TLGM_aad = uicontrol('Parent',gui.panels.info.HBox2,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','TLGM          2*aad(mean)');
        uix.Empty('Parent',gui.panels.info.HBox2);
        tstr = 'AAD (average absolute deviation from mean) of all TLGM values.';
        gui.edit_handles.TLGM_aad = uicontrol('Parent',gui.panels.info.HBox2,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Style','edit','String','2','FontSize',myui.fontsize);
        set(gui.panels.info.HBox2,'Widths',[cpanel_w -1 -1]);
        % median TLGM
        gui.panels.info.HBox3 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.TLGM_med = uicontrol('Parent',gui.panels.info.HBox3,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','TLGM median | 2*aad(med)');
        tstr = 'MEDIAN of all TLGM values.';
        gui.edit_handles.TLGM_med = uicontrol('Parent',gui.panels.info.HBox3,...
            'Style','edit','String','0','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxCPS);
        tstr = 'AAD (average absolute deviation from median) of all TLGM values.';
        gui.edit_handles.TLGM_aadmed = uicontrol('Parent',gui.panels.info.HBox3,...
            'Style','edit','String','2','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxCPS);
        set(gui.panels.info.HBox3,'Widths',[cpanel_w -1 -1]);
        % mean E0
        gui.panels.info.HBox4 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.E0 = uicontrol('Parent',gui.panels.info.HBox4,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','E0              mean | 2*std');
        tstr = 'MEAN of all E0 values.';
        gui.edit_handles.E0_mean = uicontrol('Parent',gui.panels.info.HBox4,...
            'Style','edit','String','0','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxPRC);
        tstr = 'STD of all E0 values.';
        gui.edit_handles.E0_std = uicontrol('Parent',gui.panels.info.HBox4,...
            'Style','edit','String','2','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxPRC);
        set(gui.panels.info.HBox4,'Widths',[cpanel_w -1 -1]);
        % aad E0
        gui.panels.info.HBox5 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.E0_aad = uicontrol('Parent',gui.panels.info.HBox5,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','E0              2*aad(mean)');
        uix.Empty('Parent',gui.panels.info.HBox5);
        tstr = 'AAD (average absolute deviation from mean) of all E0 values.';
        gui.edit_handles.E0_aad = uicontrol('Parent',gui.panels.info.HBox5,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Style','edit','String','2','FontSize',myui.fontsize);
        set(gui.panels.info.HBox5,'Widths',[cpanel_w -1 -1]);
        % median E0
        gui.panels.info.HBox6 = uix.HBox('Parent',gui.panels.info.VBox,...
            'Spacing',3);
        gui.text_handles.E0_med = uicontrol('Parent',gui.panels.info.HBox6,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String','E0   median | 2*aad(med)');
        tstr = 'MEDIAN of all E0 values.';
        gui.edit_handles.E0_med = uicontrol('Parent',gui.panels.info.HBox6,...
            'Style','edit','String','0','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxCPS);
        tstr = 'AAD (average absolute deviation from median) of all E0 values.';
        gui.edit_handles.E0_aadmed = uicontrol('Parent',gui.panels.info.HBox6,...
            'Style','edit','String','2','FontSize',myui.fontsize,...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackgroundColor',colors.BoxCPS);
        set(gui.panels.info.HBox6,'Widths',[cpanel_w -1 -1]);

        % --- update MAIN GUI button ---
        gui.panels.save.VBox1 = uix.VBox('Parent',gui.left,...
            'Spacing',3);
        tstr = 'UPDATE uncertainty data in main NUCLEUSinv GUI.';
        gui.push_handles.update = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','UPDATE MAIN GUI','FontSize',myui.fontsize,'Tag','update',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushUpdate);
        tstr = 'APPLY RTD bounds to all signals with uncertainty data in main NUCLEUSinv GUI.';
        gui.push_handles.apply2all = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','APPLY RTD bounds 2 all','FontSize',myui.fontsize,'Tag','apply2all',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushUpdate);
        tstr = 'Export current graphics view to Figure.';
        gui.push_handles.view = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','VIEW2FIG','FontSize',myui.fontsize,'Tag','view',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@uv_onPushView);

        % empty space at bottom of left side
        uix.Empty('Parent',gui.left);
        % adjust the heights of all left-column-panels
        heights = [22 22 22 22 28 -1; 22+6*24+8*3 22+3*24+5*3 22+2*24+4*4 22+6*24+8*3 28*3 -1];
        % panel header is always 22 high
        set(gui.left,'Heights',heights(2,:),...
            'MinimumHeights',[22 22 22 22 28 0]);

        % --- plot boxes ---
        waitbar(5/steps,hwb,'loading GUI elements - graphics');
        gui.rightPanel = uix.TabPanel('Parent',gui.right,...
            'BackGroundColor',colors.panelBG);
        % -- tab1
        gui.righttop1 = uix.HBox('Parent',gui.rightPanel,...
            'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.pbox11 = uicontainer('Parent',gui.righttop1,...
            'BackGroundColor',colors.panelBG);
        gui.pbox12 = uicontainer('Parent',gui.righttop1,...
            'BackGroundColor',colors.panelBG);
        set(gui.righttop1,'Widths',[-1 -1 ]);
        gui.rightbot = uix.HBox('Parent',gui.right,...
            'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.pbox2 = uicontainer('Parent',gui.rightbot,...
            'BackGroundColor',colors.panelBG);

        % -- tab2
        gui.righttop2 = uix.HBox('Parent',gui.rightPanel,...
            'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.pbox21 = uicontainer('Parent',gui.righttop2,...
            'BackGroundColor',colors.panelBG);
        gui.pbox22 = uicontainer('Parent',gui.righttop2,...
            'BackGroundColor',colors.panelBG);
        set(gui.righttop2,'Widths',[-1 -1 ]);

        gui.rightPanel.TabTitles = {'STATISTICS','KDEs'};
        gui.rightPanel.TabWidth = 75;
        gui.rightPanel.TabEnables = {'on','on'};

        % -- plot axes --
        gui.axes11 = axes('Parent',gui.pbox12,'Box','on');
        gui.axes12 = axes('Parent',gui.pbox11,'Box','on');
        gui.axes2 = axes('Parent',gui.pbox2,'Box','on');
        gui.axes21 = axes('Parent',gui.pbox21,'Box','on');
        gui.axes22 = axes('Parent',gui.pbox22,'Box','on');

        % the chi2 vs. xn plot has a context menu
        gui.cm_handles.axes_chi2 = uicontextmenu(fig_uncert);
        gui.cm_handles.axes_color = uimenu(gui.cm_handles.axes_chi2,...
            'Label','color by');
        gui.cm_handles.axes_color_none = uimenu(gui.cm_handles.axes_color,...
            'Label','none','Tag','none','Checked','on',...
            'Callback',@uv_onContextPlotsColor);
        gui.cm_handles.axes_color_chi2 = uimenu(gui.cm_handles.axes_color,...
            'Label','X²','Tag','chi2','Callback',@uv_onContextPlotsColor);
        gui.cm_handles.axes_color_mnorm = uimenu(gui.cm_handles.axes_color,...
            'Label',['|Lm|',char(hex2dec('2082'))],'Tag','xn','Callback',@uv_onContextPlotsColor);
        set(gui.axes12,'UIContextMenu',gui.cm_handles.axes_chi2);

        % the RTD plot has a context menu
        gui.cm_handles.axes_rtd = uicontextmenu(fig_uncert);
        gui.cm_handles.axes_rtd_lines = uimenu(gui.cm_handles.axes_rtd,...
            'Label','lines','Tag','lines','Checked','on',...
            'Callback',@uv_onContextPlotsRTD);
        gui.cm_handles.axes_rtd_patch = uimenu(gui.cm_handles.axes_rtd,...
            'Label','patch');
        gui.cm_handles.axes_rtd_patch_mean = uimenu(gui.cm_handles.axes_rtd_patch,...
            'Label','mean / std','Tag','patchmean',...
            'Callback',@uv_onContextPlotsRTD);
        gui.cm_handles.axes_rtd_patch_median = uimenu(gui.cm_handles.axes_rtd_patch,...
            'Label','median / aad','Tag','patchmedian',...
            'Callback',@uv_onContextPlotsRTD);
        set(gui.axes2,'UIContextMenu',gui.cm_handles.axes_rtd);

        % --- store main GUI settings ---
        gui.myui = nucleus.gui.myui;
        gui.myui.heights = heights;
        gui.figh_nucleus = figh_nucleus;

        % --- save gui data to GUI ---
        setappdata(fig_uncert,'gui',gui);
        fixVerticalTextAlignment(fig_uncert);
        changeColorTheme('UNCERTVIEW',myui.colors.theme);

        % make GUI visible
        delete(hwb);
        set(gui.main,'Visible','on');

        % initialize color style
        uv.colorstyle = 'none';
        % initialize RTD plot style
        uv.rtd_plotstyle = 'lines';
        % save the initial id
        uv.id0 = nucleus_data.results.invstd.uncert.params.id;
    else
        data = getappdata(fig_uncert,'data');
        uv = data.uv;
    end
    
    % if the figure is already open load the GUI data
    gui = getappdata(fig_uncert,'gui');
    % update new NUCLEUSinv data
    setappdata(fig_uncert,'data',nucleus_data);
    data = getappdata(fig_uncert,'data');
    % clear axes
    clearAllAxes(fig_uncert);

    % round all chi2 and xn values to 6 digits
    chi2_all = data.results.invstd.uncert.chi2_all;
    chi2_all = round(1e6.*chi2_all)./1e6;
    data.results.invstd.uncert.chi2_all = chi2_all;
    mnorm_all = data.results.invstd.uncert.mnorm_all;
    mnorm_all = round(1e6.*mnorm_all)./1e6;
    data.results.invstd.uncert.mnorm_all = mnorm_all;

    % create logical mask
    uv.touse = ones(nucleus_data.uncert.N,1);
    % --- fill the edit fields ---
    invstd = data.results.invstd;
    uncert = invstd.uncert;
    % 1.) control
    uv.uncertMethod = uncert.params.uncert.Method;
    uv.uncertN = uncert.params.uncert.N;
    set(gui.edit_handles.uncertN,'String',num2str(uv.uncertN));
    uv.uncertThresh = uncert.params.uncert.Thresh;
    set(gui.edit_handles.uncertThresh,'String',num2str(uv.uncertThresh));
    uv.uncertMax = uncert.params.uncert.Max;
    set(gui.edit_handles.uncertMax,'String',num2str(uv.uncertMax));
    uv.chi2_range_calc  = [min(uncert.chi2_all) max(uncert.chi2_all)];
    uv.mnorm_range_calc = [min(uncert.mnorm_all) max(uncert.mnorm_all)];
    % set popup menu
    switch invstd.invtype
        case {'LU','NNLS'}
            set(gui.popup_handles.uncertMethod,...
                'String',{'RMS - unbounded','RMS - bounded'})
            switch uncert.params.uncert.Method
                case 'RMS_free'
                    set(gui.popup_handles.uncertMethod,'Value',1);
                case 'RMS_bound'
                    set(gui.popup_handles.uncertMethod,'Value',2);
            end
        case 'MUMO'
            set(gui.popup_handles.uncertMethod,...
                'String',{'RMS - unbounded','RMS - bounded','Threshold','Conf. Interval'})
            switch uncert.params.uncert.Method
                case 'RMS_free'
                    set(gui.popup_handles.uncertMethod,'Value',1);
                case 'RMS_bound'
                    set(gui.popup_handles.uncertMethod,'Value',2);
                case 'thresh'
                    set(gui.popup_handles.uncertMethod,'Value',3);
                case 'ci'
                    set(gui.popup_handles.uncertMethod,'Value',4);
            end
    end
    set(gui.edit_handles.uncertN,'String',num2str(uncert.params.uncert.N));
    % 2.) process
    chi2_range  = uv.chi2_range_calc;
    mnorm_range = uv.mnorm_range_calc;
    set(gui.edit_handles.chi2_min,'String',sprintf('%7.6f',chi2_range(1,1)));
    set(gui.edit_handles.chi2_max,'String',sprintf('%7.6f',chi2_range(1,2)));
    set(gui.edit_handles.mnorm_min,'String',sprintf('%7.6f',mnorm_range(1,1)));
    set(gui.edit_handles.mnorm_max,'String',sprintf('%7.6f',mnorm_range(1,2)));
    % 3.) RTD range
    rtd_range = uncert.statistics.RTD_bounds;
    set(gui.edit_handles.rtd_min,'String',num2str(rtd_range(1,1)));
    set(gui.edit_handles.rtd_max,'String',num2str(rtd_range(1,2)));
    uv.chi2_range = chi2_range;
    uv.mnorm_range = mnorm_range;
    uv.rtd_range = rtd_range;

    % update data
    data.uv = uv;
    setappdata(fig_uncert,'data',data);
    uv_onPopupMethod(gui.popup_handles.uncertMethod);

    % plot all uncertainty data
    uv_updateInformation(fig_uncert);
    beautifyAxes(fig_uncert);
end

end

%% subfunction to update the edit fields
function uv_onEditValue(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;

% get the edit field value
val = str2double(get(src,'String'));

switch get(src,'Tag')
    case 'uncertN'
        if val < 10
            uncertN = 10;
        else
            uncertN = round(val);
        end
        set(src,'String',num2str(uncertN));
        uv.uncertN = uncertN;
        data.uv = uv;
    case 'uncertThresh'
    case 'uncertMax'
    case 'control'
        % set the value with the desired layout
        set(src,'String',sprintf('%7.6f',val));
        chi2_range_calc(1,1) = str2double(get(gui.edit_handles.uncertchi2_min,'String'));
        chi2_range_calc(1,2) = str2double(get(gui.edit_handles.uncertchi2_max,'String'));
        mnorm_range_calc(1,1) = str2double(get(gui.edit_handles.uncertmnorm_min,'String'));
        mnorm_range_calc(1,2) = str2double(get(gui.edit_handles.uncertmnorm_max,'String'));
        % update data
        uv.chi2_range_calc = chi2_range_calc;
        uv.mnorm_range_calc = mnorm_range_calc;
        data.uv = uv;
    case 'process'
        % set the value with the desired layout
        set(src,'String',sprintf('%7.6f',val));
        % get all range values
        chi2_range(1,1) = str2double(get(gui.edit_handles.chi2_min,'String'));
        chi2_range(1,2) = str2double(get(gui.edit_handles.chi2_max,'String'));
        mnorm_range(1,1) = str2double(get(gui.edit_handles.mnorm_min,'String'));
        mnorm_range(1,2) = str2double(get(gui.edit_handles.mnorm_max,'String'));
        % fix wrong user input
        if chi2_range(2) <= chi2_range(1)
            warndlg({'function: UNCERTVIEW',...
                'Lower bound is larger than upper bound!'},...
                'Resetting.');
            chi2_range(1) = min(data.results.invstd.uncert.chi2_all);
            chi2_range(2) = max(data.results.invstd.uncert.chi2_all);
            set(gui.edit_handles.chi2_min,'String',sprintf('%7.6f',chi2_range(1)));
            set(gui.edit_handles.chi2_max,'String',sprintf('%7.6f',chi2_range(2)));
        end
        if mnorm_range(2) <= mnorm_range(1)
            warndlg({'function: UNCERTVIEW',...
                'Lower bound is larger than upper bound!'},...
                'Resetting.');
            mnorm_range(1) = min(data.results.invstd.uncert.mnorm_all);
            mnorm_range(2) = max(data.results.invstd.uncert.mnorm_all);
            set(gui.edit_handles.mnorm_min,'String',sprintf('%7.6f',mnorm_range(1)));
            set(gui.edit_handles.mnorm_max,'String',sprintf('%7.6f',mnorm_range(2)));
        end
        % update data
        uv.chi2_range = chi2_range;
        uv.mnorm_range = mnorm_range;
        data.uv = uv;
        % update logical mask for plotting
        data = uv_updateMASK(data);
    case 'rtd'
        % set the value with the desired layout
        set(src,'String',num2str(val));
        % get all range values
        rtd_range(1,1) = str2double(get(gui.edit_handles.rtd_min,'String'));
        rtd_range(1,2) = str2double(get(gui.edit_handles.rtd_max,'String'));
        % update data
        uv.rtd_range = rtd_range;
        data.uv = uv;
end

% in case of error reactivate the run button
set(gui.push_handles.run,'String','RUN UNCERT',...
    'BackgroundColor','g','Enable','on','Callback',@uv_onPushRun);
setappdata(figh,'gui',gui);
% update GUI data
setappdata(figh,'data',data);
% update information
uv_updateInformation(figh);
end

%% subfunction to copy the chi2 and xn range to the control panel
function uv_onPushSend(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;

% get all data
chi2_range(1,1) = str2double(get(gui.edit_handles.chi2_min,'String'));
chi2_range(1,2) = str2double(get(gui.edit_handles.chi2_max,'String'));
mnorm_range(1,1) = str2double(get(gui.edit_handles.mnorm_min,'String'));
mnorm_range(1,2) = str2double(get(gui.edit_handles.mnorm_max,'String'));

% copy data to calc
uv.chi2_range_calc = chi2_range;
uv.mnorm_range_calc = mnorm_range;
data.uv = uv;

% write values to edit field
set(gui.edit_handles.uncertchi2_min,...
    'String',sprintf('%7.6f',uv.chi2_range_calc(1)));
set(gui.edit_handles.uncertchi2_max,...
    'String',sprintf('%7.6f',uv.chi2_range_calc(2)));
set(gui.edit_handles.uncertmnorm_min,...
    'String',sprintf('%7.6f',uv.mnorm_range_calc(1)));
set(gui.edit_handles.uncertmnorm_max,...
    'String',sprintf('%7.6f',uv.mnorm_range_calc(2)));

% update GUI data
setappdata(figh,'data',data);
end

%% subfunction to control the line color
function uv_onContextPlotsColor(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;

% switch through different plot options
switch get(src,'Tag')
    case 'none'
        set(gui.cm_handles.axes_color_none,'Checked','on');
        set(gui.cm_handles.axes_color_chi2,'Checked','off');
        set(gui.cm_handles.axes_color_mnorm,'Checked','off');
    case 'chi2'
        set(gui.cm_handles.axes_color_none,'Checked','off');
        set(gui.cm_handles.axes_color_chi2,'Checked','on');
        set(gui.cm_handles.axes_color_mnorm,'Checked','off');
    case 'xn'
        set(gui.cm_handles.axes_color_none,'Checked','off');
        set(gui.cm_handles.axes_color_chi2,'Checked','off');
        set(gui.cm_handles.axes_color_mnorm,'Checked','on');
end
uv.colorstyle = get(src,'Tag');

% update GUI data
data.uv = uv;
setappdata(figh,'data',data);
% update information and plots
uv_updateInformation(figh);
end

%% subfunction to control RTD axes context menu
function uv_onContextPlotsRTD(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;

% switch through different plot options
switch get(src,'Tag')
    case 'lines'
        set(gui.cm_handles.axes_rtd_lines,'Checked','on');
        set(gui.cm_handles.axes_rtd_patch_mean,'Checked','off');
        set(gui.cm_handles.axes_rtd_patch_median,'Checked','off');
    case 'patchmean'
        set(gui.cm_handles.axes_rtd_lines,'Checked','off');
        set(gui.cm_handles.axes_rtd_patch_mean,'Checked','on');
        set(gui.cm_handles.axes_rtd_patch_median,'Checked','off');
    case 'patchmedian'
        set(gui.cm_handles.axes_rtd_lines,'Checked','off');
        set(gui.cm_handles.axes_rtd_patch_mean,'Checked','off');
        set(gui.cm_handles.axes_rtd_patch_median,'Checked','on');
end
uv.rtd_plotstyle = get(src,'Tag');

% update GUI data
data.uv = uv;
setappdata(figh,'data',data);
% update information and plots
uv_updateInformation(figh);
end

%% subfunction to update the logical mask
function data = uv_updateMASK(data)
uncert = data.results.invstd.uncert;
uv = data.uv;

mask1 = uncert.chi2_all >= uv.chi2_range(1) & uncert.chi2_all <= uv.chi2_range(2);
mask2 = uncert.mnorm_all >= uv.mnorm_range(1) & uncert.mnorm_all <= uv.mnorm_range(2);
uv.touse = mask1 & mask2;

data.uv = uv;
end

%% subfunction to update control panel based on uncertainty method
function uv_onPopupMethod(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;
invstd = data.results.invstd;

val = get(gui.popup_handles.uncertMethod,'Value');

switch invstd.invtype
    case {'LU','NNLS'}
        switch val
            case 1 % RMS_free
                uv.uncertMethod = 'RMS_free';
                set(gui.edit_handles.uncertchi2_min,'Enable','off');
                set(gui.edit_handles.uncertchi2_max,'Enable','off');
                set(gui.edit_handles.uncertmnorm_min,'Enable','off');
                set(gui.edit_handles.uncertmnorm_max,'Enable','off');
                set(gui.edit_handles.uncertThresh,'Enable','off');
                set(gui.edit_handles.uncertMax,'Enable','off');
            case 2 % RMS_bound
                uv.uncertMethod = 'RMS_bound';
                set(gui.edit_handles.uncertchi2_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(1)));
                set(gui.edit_handles.uncertchi2_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(2)));
                set(gui.edit_handles.uncertmnorm_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(1)));
                set(gui.edit_handles.uncertmnorm_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(2)));
                set(gui.edit_handles.uncertThresh,'Enable','off');
                set(gui.edit_handles.uncertMax,'Enable','on',...
                    'String',num2str(uv.uncertMax));
        end
    case 'MUMO'
        switch val
            case 1 % RMS_free
                uv.uncertMethod = 'RMS_free';
                set(gui.edit_handles.uncertchi2_min,'Enable','off');
                set(gui.edit_handles.uncertchi2_max,'Enable','off');
                set(gui.edit_handles.uncertmnorm_min,'Enable','off');
                set(gui.edit_handles.uncertmnorm_max,'Enable','off');
                set(gui.edit_handles.uncertThresh,'Enable','off');
                set(gui.edit_handles.uncertMax,'Enable','off');
            case 2 % RMS_bound
                uv.uncertMethod = 'RMS_bound';
                set(gui.edit_handles.uncertchi2_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(1)));
                set(gui.edit_handles.uncertchi2_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(2)));
                set(gui.edit_handles.uncertmnorm_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(1)));
                set(gui.edit_handles.uncertmnorm_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(2)));
                set(gui.edit_handles.uncertThresh,'Enable','off');
                set(gui.edit_handles.uncertMax,'Enable','on',...
                    'String',num2str(uv.uncertMax));
            case 3 % threshold
                uv.uncertMethod = 'thresh';
                uv.chi2_range_calc = [0 10];
                uv.mnorm_range_calc = [0 10];
                set(gui.edit_handles.uncertchi2_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(1)));
                set(gui.edit_handles.uncertchi2_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(2)));
                set(gui.edit_handles.uncertmnorm_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(1)));
                set(gui.edit_handles.uncertmnorm_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(2)));
                set(gui.edit_handles.uncertThresh,'Enable','on');
                set(gui.edit_handles.uncertMax,'Enable','on',...
                    'String',num2str(uv.uncertMax));
            case 4 % ci - confidence intrval
                uv.uncertMethod = 'ci';
                uv.chi2_range_calc = [0 10];
                uv.mnorm_range_calc = [0 10];
                set(gui.edit_handles.uncertchi2_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(1)));
                set(gui.edit_handles.uncertchi2_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.chi2_range_calc(2)));
                set(gui.edit_handles.uncertmnorm_min,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(1)));
                set(gui.edit_handles.uncertmnorm_max,'Enable','on',...
                    'String',sprintf('%7.6f',uv.mnorm_range_calc(2)));
                set(gui.edit_handles.uncertThresh,'Enable','off');
                set(gui.edit_handles.uncertMax,'Enable','on',...
                    'String',num2str(uv.uncertMax));
        end
end

% update GUI data
data.uv = uv;
setappdata(figh,'data',data);
end

%% subfunction to start a new uncertainty calculation
function uv_onPushRun(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;
invstd = data.results.invstd;
uncert = invstd.uncert;

% disable the CALC: button to indicate a running calculation
set(gui.push_handles.run,'String','RUNNING ...','Enable','off');
pause(0.01);

% original fit parameter
iparam = invstd.invparams;
% original uncertainty parameter
uparam = uncert.params;
% new uncertainty parameter from GUI
uparam.uncert.Method = uv.uncertMethod;
uparam.uncert.Thresh = uv.uncertThresh;
uparam.uncert.chi2_range = uv.chi2_range_calc;
uparam.uncert.mnorm_range = uv.mnorm_range_calc;
uparam.uncert.N = uv.uncertN;
uparam.uncert.Max = uv.uncertMax;
invstd = estimateUncertainty(invstd.invtype,invstd,iparam,uparam);

% enable the CALC. button
set(gui.push_handles.run,'String','RUN UNCERT',...
    'BackgroundColor','g','Enable','on','Callback',@uv_onPushRun);
setappdata(figh,'gui',gui);

% save updated inversion results
invstd.uncert.params = uparam;
data.results.invstd = invstd;

% update GUI data
% round all chi2 and xn values to 6 digits
chi2_all = data.results.invstd.uncert.chi2_all;
chi2_all = round(1e6.*chi2_all)./1e6;
data.results.invstd.uncert.chi2_all = chi2_all;
mnorm_all = data.results.invstd.uncert.mnorm_all;
mnorm_all = round(1e6.*mnorm_all)./1e6;
data.results.invstd.uncert.mnorm_all = mnorm_all;

% create logical mask
uv.touse = ones(uv.uncertN,1);

% 1.) control
uv.chi2_range_calc = [min(chi2_all) max(chi2_all)];
uv.mnorm_range_calc = [min(mnorm_all) max(mnorm_all)];

% 2.) process
uv.chi2_range = uv.chi2_range_calc;
uv.mnorm_range = uv.mnorm_range_calc;
set(gui.edit_handles.chi2_min,'String',sprintf('%7.6f',uv.chi2_range(1,1)));
set(gui.edit_handles.chi2_max,'String',sprintf('%7.6f',uv.chi2_range(1,2)));
set(gui.edit_handles.mnorm_min,'String',sprintf('%7.6f',uv.mnorm_range(1,1)));
set(gui.edit_handles.mnorm_max,'String',sprintf('%7.6f',uv.mnorm_range(1,2)));

% update data
data.uv = uv;
setappdata(figh,'data',data);

% plot all uncertainty data
uv_updateInformation(figh);
beautifyAxes(figh);
end

%% subfunction to export the current view to a figure
function uv_onPushView(src,~)
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
        ax3 = subplot(2,2,[3 4],'Parent',expfig);
        % get positions
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        pos3 = get(ax3,'Position');
        % delete axes
        delete(ax1);delete(ax2);delete(ax3);
        % copy GUI axes
        ax1 = copyobj(gui.axes12,expfig);
        ax2 = copyobj(gui.axes11,expfig);
        ax3 = copyobj(gui.axes2,expfig);
        % adjust positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
        set(ax3,'Position',pos3);
        % legend
        lgh1 = legend(ax2,'Location','best');
        set(lgh1,'EdgeColor',gui.myui.colors.axisFG,...
            'TextColor',gui.myui.colors.axisFG);
    case 2
        % create layout
        ax1 = subplot(2,2,1,'Parent',expfig);
        ax2 = subplot(2,2,2,'Parent',expfig);
        ax3 = subplot(2,2,[3 4],'Parent',expfig);
        % get positions
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        pos3 = get(ax3,'Position');
        % delete axes
        delete(ax1);delete(ax2);delete(ax3);
        % copy GUI axes
        ax1 = copyobj(gui.axes21,expfig);
        ax2 = copyobj(gui.axes22,expfig);
        ax3 = copyobj(gui.axes2,expfig);
        % adjust positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
        set(ax3,'Position',pos3);
        % legend
        lgh2 = legend(ax2,'Location','best');
        set(lgh2,'EdgeColor',gui.myui.colors.axisFG,...
            'TextColor',gui.myui.colors.axisFG);
end

end

%% subfunction to update the main NUCLEUSinv GUI
function uv_onPushUpdate(src,~)
figh = ancestor(src,'figure','toplevel');
% local GUI data
uvgui = getappdata(figh,'gui');
uvdata = getappdata(figh,'data');
% NUCLEUSinv data
gui = getappdata(uvgui.figh_nucleus,'gui');
data = getappdata(uvgui.figh_nucleus,'data');
INVdata = getappdata(uvgui.figh_nucleus,'INVdata');

switch get(src,'Tag')
    case 'update'
        % update single data

        % get signal id
        id = uvdata.uv.id0;
        % get data
        INVdata0 = INVdata{id};

        % --- update data ---
        % -- general settings --
        data.uncert.N = uvdata.uv.uncertN;
        data.uncert.Method = uvdata.uv.uncertMethod;
        data.uncert.Thresh = uvdata.uv.uncertThresh;
        data.uncert.Max = uvdata.uv.uncertMax;

        % -- check if data was excluded --
        if sum(uvdata.uv.touse == 0) > 0
            % if yes, proceed
            in = uvdata.uv.touse == 1;
            data.uncert.N = sum(in);
            uvdata.results.invstd.uncert.params.uncert.N = sum(in);
            uvdata.results.invstd.uncert.chi2_all = uvdata.results.invstd.uncert.chi2_all(in);
            uvdata.results.invstd.uncert.mnorm_all = uvdata.results.invstd.uncert.mnorm_all(in);
            uvdata.results.invstd.uncert.rnorm_all = uvdata.results.invstd.uncert.rnorm_all(in);
            uvdata.results.invstd.uncert.interp_f = uvdata.results.invstd.uncert.interp_f(in,:);
            uvdata.results.invstd.uncert.interp_s = uvdata.results.invstd.uncert.interp_s(:,in');
            uvdata.results.invstd.uncert.interp_E0 = uvdata.results.invstd.uncert.interp_E0(in);
            uvdata.results.invstd.uncert.E0 = [mean(uvdata.results.invstd.uncert.interp_E0) std(uvdata.results.invstd.uncert.interp_E0)];
            uvdata.results.invstd.uncert.interp_Tlgm = uvdata.results.invstd.uncert.interp_Tlgm(in);
            uvdata.results.invstd.uncert.Tlgm = [mean(uvdata.results.invstd.uncert.interp_Tlgm) std(uvdata.results.invstd.uncert.interp_Tlgm)];
        end

        % add statisitics
        uvdata.results.invstd.uncert.statistics = uvdata.uv.stats;

        % update data structs
        data.results.invstd.uncert = uvdata.results.invstd.uncert;
        INVdata0.uncert = data.uncert;
        INVdata0.results.invstd = uvdata.results.invstd;

        % update INVdata
        INVdata{id} = INVdata0;
        % update GUI data
        setappdata(uvgui.figh_nucleus,'data',data);
        % update GUI INVdata
        setappdata(uvgui.figh_nucleus,'INVdata',INVdata);

        % update relevant GUI elements
        set(gui.edit_handles.uncert_N,'String',num2str(data.results.invstd.uncert.params.uncert.N))

        % update plots and INFO fields in main NUCLEUS GUI
        updatePlotsSignal;
        updatePlotsDistribution;
        updateInfo(gui.plots.SignalPanel);

    case 'apply2all'

        % calculate statistics for all signals in main GUI using the
        % current RTD bounds
        infostring = 'Apply UncertView RTD bounds 2 all ... ';
        displayStatusText(gui,infostring);
        % loop over all signals
        for id = 1:numel(INVdata)
            % only if there is Inversion data
            if isstruct(INVdata{id})
                INVdataT = INVdata{id};
                invstdT = INVdataT.results.invstd;
                % only if there is already uncertainty data
                if isfield(invstdT,'uncert')
                    uncertT = invstdT.uncert;
                    uvT = uvdata.uv;

                    % RTD time vector
                    T = INVdataT.results.invstd.T1T2me;
                    % kernel matrices for pure (single) E0 estimation
                    iparam = invstdT.invparams;
                    switch iparam.T1T2
                        case 'T1'
                            K0 = createKernelMatrix(10*INVdataT.results.nmrproc.t(end),T',...
                                iparam.Tb,iparam.Td,'T1',iparam.T1IRfac);
                        case 'T2'
                            K0 = createKernelMatrix(0,T',iparam.Tb,...
                                iparam.Td,'T2',iparam.T1IRfac);
                    end
                    % get statistics
                    stats = getUncertaintyStatistics(T,uncertT.interp_f,uvT.rtd_range,K0);

                    % TLGM
                    uvT.Tlgm = [stats.Tlgm(1) stats.Tlgm(2)];
                    % aad - mean
                    uvT.Tlgm_aad = stats.Tlgm(3);
                    % aad - median
                    uvT.Tlgm_aadmed = [stats.Tlgm_med(1) stats.Tlgm_med(2)];
                    % E0
                    uvT.E0 = [stats.E0(1) stats.E0(2)];
                    % aad - mean
                    uvT.E0_aad = stats.E0(3);
                    % aad - median
                    uvT.E0_aadmed = [stats.E0_med(1) stats.E0_med(2)];

                    uvT.stats = stats;

                    % add statisitics
                    INVdataT.results.invstd.uncert.statistics = stats;
                    % update data structs
                    INVdata{id} = INVdataT;
                end
            end
        end
        % update GUI INVdata
        setappdata(uvgui.figh_nucleus,'INVdata',INVdata);
        infostring = 'Apply UncertView RTD bounds 2 all ... done';
        displayStatusText(gui,infostring);
end

end

%% subfunction to reset chi2 and model norm bounds
function uv_onPushReset(src,~)
figh = ancestor(src,'figure','toplevel');
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
uv = data.uv;
invstd = data.results.invstd;
uncert = invstd.uncert;

switch get(src,'Tag')
    case 'process'
        % reset to original values
        chi2_range  = [min(uncert.chi2_all) max(uncert.chi2_all)];
        mnorm_range = [min(uncert.mnorm_all) max(uncert.mnorm_all)];
        % update edit fields
        set(gui.edit_handles.chi2_min,'String',sprintf('%7.6f',chi2_range(1,1)));
        set(gui.edit_handles.chi2_max,'String',sprintf('%7.6f',chi2_range(1,2)));
        set(gui.edit_handles.mnorm_min,'String',sprintf('%7.6f',mnorm_range(1,1)));
        set(gui.edit_handles.mnorm_max,'String',sprintf('%7.6f',mnorm_range(1,2)));
        % update data
        uv.chi2_range = chi2_range;
        uv.mnorm_range = mnorm_range;
        data.uv = uv;
        % update logical mask for plotting
        data = uv_updateMASK(data);
    case 'rtd'
        % reset to original values
        rtd_range = data.invstd.time;
        % update edit fields
        set(gui.edit_handles.rtd_min,'String',num2str(rtd_range(1,1)));
        set(gui.edit_handles.rtd_max,'String',num2str(rtd_range(1,2)));
        % update data
        uv.rtd_range = rtd_range;
        data.uv = uv;
end

setappdata(figh,'data',data);
% update information
uv_updateInformation(figh);
end

%% subfunction to update the information output
function uv_updateInformation(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');
invstd = data.results.invstd;
uncert = invstd.uncert;
uv = data.uv;

% which models to use
in = data.uv.touse == 1;
% RTD time vector
T = data.results.invstd.T1T2me;
% kernel matrices for pure (single) E0 estimation
iparam = invstd.invparams;
switch iparam.T1T2
    case 'T1'
        K0 = createKernelMatrix(10*data.results.nmrproc.t(end),T',...
            iparam.Tb,iparam.Td,'T1',iparam.T1IRfac);
    case 'T2'
        K0 = createKernelMatrix(0,T',iparam.Tb,...
            iparam.Td,'T2',iparam.T1IRfac);
end
% get statistics
stats = getUncertaintyStatistics(T,uncert.interp_f(in,:),uv.rtd_range,K0);

% assign to GUI fields
% TLGM
uv.Tlgm = [stats.Tlgm(1) stats.Tlgm(2)];
set(gui.edit_handles.TLGM_mean,'String',sprintf('%5.4f',uv.Tlgm(1)));
set(gui.edit_handles.TLGM_std,'String',sprintf('%5.4f',2*uv.Tlgm(2)));
% aad - mean
uv.Tlgm_aad = stats.Tlgm(3);
set(gui.edit_handles.TLGM_aad,'String',sprintf('%5.4f',2*uv.Tlgm_aad));
% aad - median
uv.Tlgm_aadmed = [stats.Tlgm_med(1) stats.Tlgm_med(2)];
set(gui.edit_handles.TLGM_med,'String',sprintf('%5.4f',uv.Tlgm_aadmed(1)));
set(gui.edit_handles.TLGM_aadmed,'String',sprintf('%5.4f',2*uv.Tlgm_aadmed(2)));
% E0
uv.E0 = [stats.E0(1) stats.E0(2)];
set(gui.edit_handles.E0_mean,'String',sprintf('%5.4f',uv.E0(1)));
set(gui.edit_handles.E0_std,'String',sprintf('%5.4f',2*uv.E0(2)));
% aad - mean
uv.E0_aad = stats.E0(3);
set(gui.edit_handles.E0_aad,'String',sprintf('%5.4f',2*uv.E0_aad));
% aad - median
uv.E0_aadmed = [stats.E0_med(1) stats.E0_med(2)];
set(gui.edit_handles.E0_med,'String',sprintf('%5.4f',uv.E0_aadmed(1)));
set(gui.edit_handles.E0_aadmed,'String',sprintf('%5.4f',2*uv.E0_aadmed(2)));

% update GUI data
uv.stats = stats;
data.uv = uv;
setappdata(figh,'data',data);
% update plots
uv_updatePlots(figh);
end

%% subfunction to update all plots
function uv_updatePlots(figh)
gui = getappdata(figh,'gui');
data = getappdata(figh,'data');

% clear axes
clearAllAxes(figh);
hold(gui.axes11,'on');
hold(gui.axes12,'on');
hold(gui.axes2,'on');
hold(gui.axes21,'on');
hold(gui.axes22,'on');

% get relevant data
uv = data.uv;
invstd = data.results.invstd;
uncert = invstd.uncert;
col = gui.myui.colors;

% get indices for models to use and not to use
in = data.uv.touse == 1;
out = data.uv.touse == 0;

switch uv.colorstyle
    case 'none'
        % default gray
        lcolors = [0.5 0.5 0.5];
        tmpchi2 = uncert.chi2_all(in);
        tmpmnorm = uncert.mnorm_all(in);
        % tmpE0 = uncert.interp_E0(in);
        % tmpTlgm = uncert.interp_Tlgm(in);
        tmpE0 = uv.stats.E0_all;
        tmpTlgm = uv.stats.Tlgm_all;
        clims = [0 1];
    case 'chi2'
        tmp = uncert.chi2_all(in);
        [tmpchi2,idx] = sort(tmp);
        lcolors = tmpchi2;
        tmpmnorm = uncert.mnorm_all(in);
        tmpmnorm = tmpmnorm(idx);
        % tmpE0 = uncert.interp_E0(in);
        tmpE0 = uv.stats.E0_all;
        tmpE0 = tmpE0(idx);
        % tmpTlgm = uncert.interp_Tlgm(in);
        tmpTlgm = uv.stats.Tlgm_all;
        tmpTlgm = tmpTlgm(idx);
        % clims = [min(uncert.chi2_all) max(uncert.chi2_all)];
        clims = [min(uncert.chi2_all(in)) max(uncert.chi2_all(in))];
    case 'xn'
        tmp = uncert.mnorm_all(in);
        [tmpmnorm,idx] = sort(tmp);
        lcolors = tmpmnorm;
        tmpchi2 = uncert.chi2_all(in);
        tmpchi2 = tmpchi2(idx);
        % tmpE0 = uncert.interp_E0(in);
        tmpE0 = uv.stats.E0_all;
        tmpE0 = tmpE0(idx);
        % tmpTlgm = uncert.interp_Tlgm(in);
        tmpTlgm = uv.stats.Tlgm_all;
        tmpTlgm = tmpTlgm(idx);
        % clims = [min(uncert.mnorm_all) max(uncert.mnorm_all)];
        clims = [min(uncert.mnorm_all(in)) max(uncert.mnorm_all(in))];
end

% --- chi2 vs model norm ---
scatter(uncert.chi2_all(out),uncert.mnorm_all(out),[],'red',...
    'LineWidth',1,'Parent',gui.axes12);
scatter(gui.axes12,tmpchi2,tmpmnorm,[],lcolors,...
    'LineWidth',1);
plot(invstd.chi2,invstd.xn,'+','MarkerSize',10,'Color',col.FIT,'Parent',gui.axes12);
% axis limits
xlims = [min([uncert.chi2_all(in); invstd.chi2]) max([uncert.chi2_all(in); invstd.chi2])];
dx = xlims(2)-xlims(1);
xlims = [xlims(1)-dx/5 xlims(2)+dx/5];
ylims = [min([uncert.mnorm_all(in); invstd.xn]) max([uncert.mnorm_all(in); invstd.xn])];
dy = ylims(2)-ylims(1);
ylims = [ylims(1)-dy/5 ylims(2)+dy/5];
% -- lines indicating TLGM and E0 bounds --
line([min(uncert.chi2_all(in)) min(uncert.chi2_all(in))],[ylims(1) ylims(2)],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'Parent',gui.axes12,'Tag','infolines');
line([max(uncert.chi2_all(in)) max(uncert.chi2_all(in))],[ylims(1) ylims(2)],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'Parent',gui.axes12,'Tag','infolines');
line([xlims(1) xlims(2)],[min(uncert.mnorm_all(in)) min(uncert.mnorm_all(in))],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'Parent',gui.axes12,'Tag','infolines');
line([xlims(1) xlims(2)],[max(uncert.mnorm_all(in)) max(uncert.mnorm_all(in))],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'Parent',gui.axes12,'Tag','infolines');
% axis setings
set(gui.axes12,'XScale','lin','XLim',xlims);
set(gui.axes12,'YScale','log','YLim',ylims);
set(gui.axes12,'CLim',clims);
set(get(gui.axes12,'XLabel'),'String','X² (error weighted residuals)');
set(get(gui.axes12,'YLabel'),'String','model norm |Lm|_{2}');

% --- TLGM vs E0 ---
scatter(uncert.interp_Tlgm(out),uncert.interp_E0(out),[],'red',...
    'LineWidth',1,'DisplayName','runs (out)','Parent',gui.axes11);
scatter(tmpTlgm,tmpE0,[],lcolors,...
    'LineWidth',1,'DisplayName','runs (in)','Parent',gui.axes11);
plot(invstd.Tlgm,invstd.E0,'+','MarkerSize',10,'Color',col.FIT,...
    'DisplayName','init','Parent',gui.axes11);
errorbar(uv.Tlgm(1),uv.E0(1),2*uv.E0(2),2*uv.E0(2),2*uv.Tlgm(2),2*uv.Tlgm(2),...
    'Color',col.BoxPRC,'LineWidth',2,'DisplayName','mean (2*std)','Parent',gui.axes11);
errorbar(uv.Tlgm_aadmed(1),uv.E0_aadmed(1),2*uv.E0_aadmed(2),2*uv.E0_aadmed(2),2*uv.Tlgm_aadmed(2),2*uv.Tlgm_aadmed(2),...
    'Color',col.BoxCPS,'LineWidth',2,'DisplayName','median (2*aad)','Parent',gui.axes11);
% axis limits
% xlims = [min([uncert.interp_Tlgm; invstd.Tlgm; uv.Tlgm(1)])*0.95 ...
%     max([uncert.interp_Tlgm; invstd.Tlgm; uv.Tlgm(1)])*1.05];
% ylims = [min([uncert.interp_E0; invstd.E0; uv.E0(1)])*0.95 ...
%     max([uncert.interp_E0; invstd.E0; uv.E0(1)])*1.05];
% xlims = [min([uncert.interp_Tlgm(in); invstd.Tlgm; uv.Tlgm(1)])*0.975 ...
%     max([uncert.interp_Tlgm(in); invstd.Tlgm; uv.Tlgm(1)])*1.025];
% ylims = [min([uncert.interp_E0(in); invstd.E0; uv.E0(1)])*0.975 ...
%     max([uncert.interp_E0(in); invstd.E0; uv.E0(1)])*1.025];
xlims = [min([tmpTlgm; invstd.Tlgm; uv.Tlgm(1)])*0.975 ...
    max([tmpTlgm; invstd.Tlgm; uv.Tlgm(1)])*1.025];
ylims = [min([tmpE0; invstd.E0; uv.E0(1)])*0.975 ...
    max([tmpE0; invstd.E0; uv.E0(1)])*1.025];
% -- lines indicating TLGM and E0 bounds --
line([min(uncert.interp_Tlgm(in)) min(uncert.interp_Tlgm(in))],[ylims(1) ylims(2)],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'HandleVisibility','off','Parent',gui.axes11,'Tag','infolines');
line([max(uncert.interp_Tlgm(in)) max(uncert.interp_Tlgm(in))],[ylims(1) ylims(2)],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'HandleVisibility','off','Parent',gui.axes11,'Tag','infolines');
line([xlims(1) xlims(2)],[min(uncert.interp_E0(in)) min(uncert.interp_E0(in))],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'HandleVisibility','off','Parent',gui.axes11,'Tag','infolines');
line([xlims(1) xlims(2)],[max(uncert.interp_E0(in)) max(uncert.interp_E0(in))],'Color',[0.25 0.25 0.25],...
    'LineStyle',':','LineWidth',0.75,'HandleVisibility','off','Parent',gui.axes11,'Tag','infolines');
lgh = legend(gui.axes11,'Location','NorthEast');
set(lgh,'EdgeColor',gui.myui.colors.axisFG,'TextColor',gui.myui.colors.axisFG);
% axis settings
set(gui.axes11,'XScale','lin','XLim',xlims);
set(gui.axes11,'YScale','lin','YLim',ylims);
set(gui.axes11,'CLim',clims);
set(get(gui.axes11,'XLabel'),'String','TLGM');
set(get(gui.axes11,'YLabel'),'String','initial amplitude E0');

% --- RTDs ---
plotmethod = 1;
switch uv.rtd_plotstyle
    case 'patchmean'
        plotmethod = 2;
    case 'patchmedian'
        plotmethod = 3;
    otherwise
        % nothing to do because 'lines' is default
end

% the 'init' RTD
F0 = invstd.T1T2f;
% normalize all curves to the median of all E0 values
E0norm = uv.E0_aadmed(1);
if sum(F0)>0
    F = (data.invstd.porosity*100).*F0./E0norm;
    ylims = [0 max(F)*1.05];
else
    ylims = [-1 1];
end
% the uncertainty runs
% only the selected ones within the chi2 and xn bounds
FDIST = uncert.interp_f(in,:);
% scaling
FDIST = (data.invstd.porosity*100).*FDIST./E0norm;

% if selected plot lines
if plotmethod == 1
    % find maximum for axis limts
    f_max = max([ylims(2) max(FDIST(:))]);
    switch uv.colorstyle
        case {'chi2','xn'}
            % get colormap from chi2 vs xn axis
            cmap = get(gui.axes12,'Colormap');
            % make vector of values to sort
            idc = linspace(clims(1),clims(2),size(cmap,1));
            for i1 = 1:sum(in)
                % find closest value (need for coloring)
                idc1 = find(abs(idc-tmp(idx(i1)))==min(abs(idc-tmp(idx(i1)))));
                % idc1 = abs(idc-tmp(idx(i1)))==min(abs(idc-tmp(idx(i1))));
                % plot line with correct color
                plot(invstd.T1T2me,FDIST(idx(i1),:),'-','Color',cmap(idc1(1),:),...
                    'LineWidth',1,'Displayname',num2str(tmp(idx(i1))),'Parent',gui.axes2);
            end
            % adjust color limits
            set(gui.axes2,'CLim',clims);
        otherwise
            % need to plot transpose of FDIST because 'x' is a column vector
            % otherwise plot goes bananas if numel(x) = #models
            plot(invstd.T1T2me,FDIST','-','Color',[0.5 0.5 0.5],...
                'LineWidth',1,'Parent',gui.axes2);
    end
end

% if selected plot patch
if plotmethod > 1
    % what kind of patch is created
    if plotmethod == 2 % mean +- std
        mean_f = mean(FDIST);
        std_f = std(FDIST);
    else % median +- mad
        mean_f = median(FDIST);
        std_f = getAAD(FDIST,1);
    end

    % patch lower and upper bounds
    patch_f_std1 = [mean_f+std_f;mean_f-std_f];
    patch_f_std2 = [mean_f+2*std_f;mean_f-2*std_f];
    patch_f_std3 = [mean_f+3*std_f;mean_f-3*std_f];
    patch_f_std1(patch_f_std1<0) = 0;
    patch_f_std2(patch_f_std2<0) = 0;
    patch_f_std3(patch_f_std3<0) = 0;
    f_max = max([ylims(2) max(patch_f_std1) max(patch_f_std2) max(patch_f_std3)]);

    % draw all three patches on top of each other
    verts = [invstd.T1T2me patch_f_std3(2,:)'; flipud(invstd.T1T2me) flipud(patch_f_std3(1,:)')];
    faces = 1:1:size(verts,1);
    patch('Faces',faces,'Vertices',verts,'FaceColor',[0.6 0.6 0.6],...
        'FaceAlpha',0.75,'EdgeColor','none','Parent',gui.axes2);
    verts = [invstd.T1T2me patch_f_std2(2,:)'; flipud(invstd.T1T2me) flipud(patch_f_std2(1,:)')];
    faces = 1:1:size(verts,1);
    patch('Faces',faces,'Vertices',verts,'FaceColor',[0.4 0.4 0.4],...
        'FaceAlpha',0.75,'EdgeColor','none','Parent',gui.axes2);
    verts = [invstd.T1T2me patch_f_std1(2,:)'; flipud(invstd.T1T2me) flipud(patch_f_std1(1,:)')];
    faces = 1:1:size(verts,1);
    patch('Faces',faces,'Vertices',verts,'FaceColor',[0.2 0.2 0.2],...
        'FaceAlpha',0.75,'EdgeColor','none','Parent',gui.axes2);
end

% adjust y-limits
ylims(2) = max([ylims(2) max(f_max)*1.05]);

% plot original solution
plot(invstd.T1T2me,F,'-','Color',col.FIT,'Parent',gui.axes2);

% axes properties
ticks = 10.^(round(log10(min(invstd.T1T2me)) :1: log10(max(invstd.T1T2me))));
set(gui.axes2,'XScale','log','XLim',[ticks(1) ticks(end)],'XTick',ticks);
set(gui.axes2,'YScale','lin','YLim',ylims);
set(get(gui.axes2,'XLabel'),'String','relaxation time');
set(get(gui.axes2,'YLabel'),'String','amplitude');
grid(gui.axes2,'on');

% -- RTD bounds --
uv = data.uv;
% line([uv.rtd_range(1) uv.rtd_range(1)],[0 ylims(2)],'Color',[0.25 0.25 0.25],...
%     'LineStyle','-.','LineWidth',2,'Parent',gui.axes2,'Tag','infolines');
% line([uv.rtd_range(2) uv.rtd_range(2)],[0 ylims(2)],'Color',[0.25 0.25 0.25],...
%     'LineStyle','-.','LineWidth',2,'Parent',gui.axes2,'Tag','infolines');
p_alpha = 0.8;
if uv.rtd_range(1)>ticks(1)
    % draw a transparent patch
    v = [ticks(1) ylims(1); ticks(1) ylims(2);
        uv.rtd_range(1) ylims(2); uv.rtd_range(1) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes2);
end
if uv.rtd_range(2)<ticks(end)
    % draw a transparent patch
    v = [ticks(end) ylims(1); ticks(end) ylims(2);
        uv.rtd_range(2) ylims(2); uv.rtd_range(2) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', gui.axes2);
end

% --- Histograms ---
% [f1,xi1] = getKernelDensityEstimate(uncert.interp_E0(in));
% [f2,xi2] = getKernelDensityEstimate(uncert.interp_Tlgm(in));
[f1,xi1] = getKernelDensityEstimate(uv.stats.E0_all);
[f2,xi2] = getKernelDensityEstimate(uv.stats.Tlgm_all);

% plot the KDEs
plot(xi1,f1,'Color',[0.5 0.5 0.5],'DisplayName','KDE','Parent',gui.axes21);
plot(xi2,f2,'Color',[0.5 0.5 0.5],'DisplayName','KDE','Parent',gui.axes22);

% "init" E0
line([invstd.E0 invstd.E0],[0 max(f1)],'Color',col.FIT,...
    'LineStyle',':','LineWidth',2,'Parent',gui.axes21,'DisplayName','init',...
    'Tag','infolines');
% "init" TLGM
line([invstd.Tlgm invstd.Tlgm],[0 max(f2)],'Color',col.FIT,...
    'LineStyle',':','LineWidth',2,'Parent',gui.axes22,'DisplayName','init',...
    'Tag','infolines');

% mean E0
line([uv.E0(1) uv.E0(1)],[0 max(f1)],'Color',col.BoxPRC,...
    'LineStyle','-','LineWidth',2,'Parent',gui.axes21,'DisplayName','mean');
line([uv.E0(1)+2*uv.E0(2) uv.E0(1)+2*uv.E0(2)],[0 max(f1)],'Color',col.BoxPRC,...
    'LineStyle','--','LineWidth',1,'Parent',gui.axes21,'DisplayName','2*std');
line([uv.E0(1)-2*uv.E0(2) uv.E0(1)-2*uv.E0(2)],[0 max(f1)],'Color',col.BoxPRC,...
    'LineStyle','--','LineWidth',1,'Parent',gui.axes21,'DisplayName','2*std',...
    'HandleVisibility','off','Tag','infolines');

% mean TLGM
line([uv.Tlgm(1) uv.Tlgm(1)],[0 max(f2)],'Color',col.BoxPRC,...
    'LineStyle','-','LineWidth',2,'Parent',gui.axes22,'DisplayName','mean');
line([uv.Tlgm(1)+2*uv.Tlgm(2) uv.Tlgm(1)+2*uv.Tlgm(2)],[0 max(f2)],'Color',col.BoxPRC,...
    'LineStyle','--','LineWidth',1,'Parent',gui.axes22,'DisplayName','2*std');
line([uv.Tlgm(1)-2*uv.Tlgm(2) uv.Tlgm(1)-2*uv.Tlgm(2)],[0 max(f2)],'Color',col.BoxPRC,...
    'LineStyle','--','LineWidth',1,'Parent',gui.axes22,'DisplayName','2*std',...
    'HandleVisibility','off','Tag','infolines');

% median E0
line([uv.E0_aadmed(1) uv.E0_aadmed(1)],[0 max(f1)],'Color',col.BoxCPS,...
    'LineStyle','-','LineWidth',2,'Parent',gui.axes21,'DisplayName','median');
line([uv.E0_aadmed(1)+2*uv.E0_aadmed(2) uv.E0_aadmed(1)+2*uv.E0_aadmed(2)],...
    [0 max(f1)],'Color',col.BoxCPS,'LineStyle','--','LineWidth',1,...
    'Parent',gui.axes21,'DisplayName','2*aad');
line([uv.E0_aadmed(1)-2*uv.E0_aadmed(2) uv.E0_aadmed(1)-2*uv.E0_aadmed(2)],...
    [0 max(f1)],'Color',col.BoxCPS,'LineStyle','--','LineWidth',1,...
    'Parent',gui.axes21,'DisplayName','2*aad','HandleVisibility','off',...
    'Tag','infolines');

% median TLGM
line([uv.Tlgm_aadmed(1) uv.Tlgm_aadmed(1)],[0 max(f2)],'Color',col.BoxCPS,...
    'LineStyle','-','LineWidth',2,'Parent',gui.axes22,'DisplayName','median');
line([uv.Tlgm_aadmed(1)+2*uv.Tlgm_aadmed(2) uv.Tlgm_aadmed(1)+2*uv.Tlgm_aadmed(2)],...
    [0 max(f2)],'Color',col.BoxCPS,'LineStyle','--','LineWidth',1,...
    'Parent',gui.axes22,'DisplayName','2*aad');
line([uv.Tlgm_aadmed(1)-2*uv.Tlgm_aadmed(2) uv.Tlgm_aadmed(1)-2*uv.Tlgm_aadmed(2)],...
    [0 max(f2)],'Color',col.BoxCPS,'LineStyle','--','LineWidth',1,...
    'Parent',gui.axes22,'DisplayName','2*aad','HandleVisibility','off',...
    'Tag','infolines');
lgh = legend(gui.axes22,'Location','NorthWest');
set(lgh,'EdgeColor',gui.myui.colors.axisFG,'TextColor',gui.myui.colors.axisFG);

% axes properties
set(get(gui.axes21,'XLabel'),'String','E0');
set(get(gui.axes21,'YLabel'),'String','kernel denisty estimate');
set(get(gui.axes22,'XLabel'),'String','TLGM');
set(get(gui.axes22,'YLabel'),'String','kernel density estimate');

% hold off all axes
hold(gui.axes11,'off');
hold(gui.axes12,'off');
hold(gui.axes2,'off');
hold(gui.axes21,'off');
hold(gui.axes22,'off');
end

%% close function
function uv_closeme(src,~)
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