function PhaseView(src,~)
%PhaseView is an extra subGUI to manipulate the phase of a T2 signal
%
% Syntax:
%       PhaseView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       PhaseView(src,~)
%
% Other m-files required:
%       onListboxData
%       onMenuView
%
% Subfunctions:
%       getSSR
%       phasefit_fcn
%       pv_onEditValues
%       pv_onPushAngle
%       pv_onPushApply
%       pv_onPushKeep
%       pv_onPushRun
%       pv_onSlider
%       pv_plotSignal
%       pv_plotSSR
%       pv_updateFullDataSet
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
fig = ancestor(src,'figure','toplevel');
nucleus.data = getappdata(fig,'data');
nucleus.gui = getappdata(fig,'gui');
myui = nucleus.gui.myui;
colors = nucleus.gui.myui.colors;

hasData = false;
if isfield(nucleus.data,'results')
    if isfield(nucleus.data.results,'nmrraw') &&...
            isfield(nucleus.data.results,'nmrproc')
        hasData = true;
        ID = get(nucleus.gui.listbox_handles.signal,'value');
    end
end

%% proceed if there is data
if hasData
    % check if the figure is already open
    fig_phase = findobj('Tag','PHASEVIEW');
    % if not, create it
    if isempty(fig_phase)
        % draw the figure on top of NUCLEUSinv
        fig_phase = figure('Name','NUCLEUSinv - PhaseView',...
            'NumberTitle','off','Resize','on','ToolBar','none',...
            'Tag','PHASEVIEW','Menubar','none');
        pos0 = get(fig,'Position');
        cent(1) = (pos0(1)+pos0(3)/2);
        cent(2) = (pos0(2)+pos0(4)/2);
        set(fig_phase,'Position',[cent(1)-pos0(3)/3 pos0(2)+22 pos0(3)/1.5 pos0(4)-22]);

        gui.menu.view = uimenu(fig_phase,'Label','View');
        gui.menu.view_toolbar = uimenu(gui.menu.view,'Label','Figure Toolbar',...
        'Callback',@onMenuView);

        cpanel_w = 150;
        % phase angle fit range
        data.phase_range = [-180 180];
        % SSR data
        % phase angle range to show nice diagram
        data.beta_range = -180:1:180;
        % echo range to calculate SSR
        data.echo_range = [nucleus.data.process.start nucleus.data.process.end];

        % create the main layout
        gui.main = uix.HBox('Parent',fig_phase,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',5,'Visible','off');
        gui.left = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',0); % controls
        gui.right = uix.VBox('Parent',gui.main,'BackGroundColor',colors.panelBG,...
            'Spacing',5,'Padding',0); % plots

        set(gui.main,'Widths',[300 -1 ]);

        % empty space at top of left side
        uix.Empty('Parent',gui.left);

        % --- properties panel ---
        % waitbar(1/steps,hwb,'loading GUI elements - properties');
        gui.panels.prop.main = uix.BoxPanel('Parent',gui.left,...
            'Title','Fit phase angle','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxPRC,'ForegroundColor',colors.BoxTitle);
        gui.panels.prop.VBox = uix.VBox('Parent',gui.panels.prop.main,...
            'Spacing',3,'Padding',3);

        % first and last echo
        gui.panels.prop.HBox1 = uix.HBox('Parent',gui.panels.prop.VBox,...
            'Spacing',3);
        gui.text_handles.first = uicontrol('Parent',gui.panels.prop.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',"T2 echoes - first | last");
        tstr = 'Set first / last echo of all T2 signals.';
        gui.edit_handles.first = uicontrol('Parent',gui.panels.prop.HBox1,...
            'Style','edit','String',sprintf('%d',nucleus.data.process.start),...
            'FontSize',myui.fontsize,'Tag','first',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onEditValue);
        gui.edit_handles.last = uicontrol('Parent',gui.panels.prop.HBox1,...
            'Style','edit','String',sprintf('%d',nucleus.data.process.end),...
            'FontSize',myui.fontsize,'Tag','last',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onEditValue);
        set(gui.panels.prop.HBox1,'Widths',[cpanel_w -1 -1]);

        % phase angle range
        gui.panels.prop.HBox2 = uix.HBox('Parent',gui.panels.prop.VBox,...
            'Spacing',3);
        gui.text_handles.range = uicontrol('Parent',gui.panels.prop.HBox2,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',"Phase range [-180, 180]");
        tstr = 'Set phase angle range for fitting';
        gui.edit_handles.range_min = uicontrol('Parent',gui.panels.prop.HBox2,...
            'Style','edit','String',sprintf('%d',-180),...
            'FontSize',myui.fontsize,'Tag','range_min',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onEditValue);
        gui.edit_handles.range_max = uicontrol('Parent',gui.panels.prop.HBox2,...
            'Style','edit','String',sprintf('%d',180),...
            'FontSize',myui.fontsize,'Tag','range_max',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onEditValue);
        set(gui.panels.prop.HBox2,'Widths',[cpanel_w -1 -1]);

        % fit method
        gui.panels.prop.HBox3 = uix.HBox('Parent',gui.panels.prop.VBox,...
            'Spacing',3);
        gui.text_handles.fitmethod = uicontrol('Parent',gui.panels.prop.HBox3,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',"Phase fit method");
        tstr = ['<HTML>Choose the phase fitting method.<br><br>',...
            '<u>Available options:</u><br>',...
            '<b>maxRE minIM</b> maximize REal part, minimize IMag part.<br>',...
            '<b>maxRE</b> Only maximize REal part.<br>',...
            '<b>minIM</b> Only minimize IMag part.<br>',...
            '<b>minIMstd</b> Only minimize standard deviation of IMag part.<br><br>',...
            '<u>Default value:</u><br>',...
            '<b>maxRE minIM</b><br>'];
        gui.popup_handles.fitmethod = uicontrol('Parent',gui.panels.prop.HBox3,...
            'Style','popup','String',{'maxRE minIM','maxRE','minIM','minIMstd'},...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,'Tag','control');
        set(gui.panels.prop.HBox3,'Widths',[cpanel_w -1]);

        % run fit
        gui.panels.prop.HBox4 = uix.HBox('Parent',gui.panels.prop.VBox,...
            'Spacing',3);
        uix.Empty('Parent',gui.panels.prop.HBox4);
        tstr = 'RUN phase fitting.';
        gui.push_handles.runfit = uicontrol('Parent',gui.panels.prop.HBox4,...
            'Style','pushbutton','String','RUN phase fit',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'BackGroundColor','g','FontSize',myui.fontsize,...
            'Tag','control','Callback',@pv_onPushRun);
        set(gui.panels.prop.HBox4,'Widths',[cpanel_w -1]);


        % --- manual control panel ---
        % waitbar(1/steps,hwb,'loading GUI elements - properties');
        gui.panels.manual.main = uix.BoxPanel('Parent',gui.left,...
            'Title','Manually set phase angle','MinimizeFcn',@minimizePanel,...
            'TitleColor',colors.BoxPRC,'ForegroundColor',colors.BoxTitle);
        gui.panels.manual.VBox = uix.VBox('Parent',gui.panels.manual.main,...
            'Spacing',3,'Padding',3);

        % edit field
        gui.panels.manual.HBox1 = uix.HBox('Parent',gui.panels.manual.VBox,...
            'BackGroundColor',colors.panelBG,'Spacing',3);
        gui.text_handles.edit_manual = uicontrol('Parent',gui.panels.manual.HBox1,...
            'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
            'String',"Current phase [deg]");
        gui.edit_handles.phase = uicontrol('Parent',gui.panels.manual.HBox1,...
            'Style','edit','FontSize',nucleus.gui.myui.fontsize,'Tag','phase',...
            'String',num2str(0),'BackGroundColor',colors.editBG,...
            'ForeGroundColor',colors.panelFG,...
            'Callback',@pv_onEditValue);
        set(gui.panels.manual.HBox1,'Widths',[cpanel_w -1]);

        % slider
        gui.panels.manual.HBox2 = uix.HBox('Parent',gui.panels.manual.VBox,...
            'BackGroundColor',colors.panelBG,'Spacing',3);
        gui.text_handles.slider_down = uicontrol('Parent',gui.panels.manual.HBox2,'Style','text',...
            'String','down','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'HorizontalAlignment','center');
        gui.slider_handles.slider = uicontrol('Parent',gui.panels.manual.HBox2,'Style','slider',...
            'Min',-180,'Max',180,'Value',0,'SliderStep',[0.1/360 5/360],...
            'Callback',@pv_onSlider);
        gui.text_handles.slider_up = uicontrol('Parent',gui.panels.manual.HBox2,'Style','text',...
            'String','up','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'HorizontalAlignment','center');
        set(gui.panels.manual.HBox2,'Widths',[-1 -6 -1]);

        % buttons
        gui.panels.manual.HBox3 = uix.HBox('Parent',gui.panels.manual.VBox,...
            'BackGroundColor',colors.panelBG,'Spacing',3);
        tstr = 'Change phase angle by -90°.';
        gui.push_handles.button_m90 = uicontrol('Parent',gui.panels.manual.HBox3,...
            'Style','pushbutton','String','-90',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,...
            'Tag','button_m90','Callback',@pv_onPushAngle);
        tstr = 'Change phase angle by -45°.';
        gui.push_handles.button_m45 = uicontrol('Parent',gui.panels.manual.HBox3,...
            'Style','pushbutton','String','-45',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,...
            'Tag','button_m45','Callback',@pv_onPushAngle);
        tstr = 'Change phase angle by +-180°.';
        gui.push_handles.button_pm180 = uicontrol('Parent',gui.panels.manual.HBox3,...
            'Style','pushbutton','String','+-180',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,...
            'Tag','button_pm180','Callback',@pv_onPushAngle);
        tstr = 'Change phase angle by +45°.';
        gui.push_handles.button_p45 = uicontrol('Parent',gui.panels.manual.HBox3,...
            'Style','pushbutton','String','+45',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,...
            'Tag','button_p45','Callback',@pv_onPushAngle);
        tstr = 'Change phase angle by +90°.';
        gui.push_handles.button_p90 = uicontrol('Parent',gui.panels.manual.HBox3,...
            'Style','pushbutton','String','+90',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'FontSize',myui.fontsize,...
            'Tag','button_p90','Callback',@pv_onPushAngle);
        set(gui.panels.manual.HBox3,'Widths',[-1 -1 -1 -1 -1]);

        % --- update MAIN GUI buttons ---
        gui.panels.save.VBox1 = uix.VBox('Parent',gui.left,...
            'Spacing',3);
        tstr = 'KEEP default phase angle from NUCLEUSinv GUI import.';
        gui.push_handles.default = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','KEEP default phase angle','FontSize',myui.fontsize,'Tag','default',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onPushKeep);
        tstr = 'APPLY the current phase angle to the signal in the NUCLEUSinv GUI';
        gui.push_handles.apply_single = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','APPLY current phase angle','FontSize',myui.fontsize,'Tag','apply',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onPushApply);
        tstr = 'APPLY the current phase angle to all signals in the NUCLEUSinv GUI';
        gui.push_handles.apply_all = uicontrol('Parent',gui.panels.save.VBox1,...
            'String','APPLY current phase angle 2 all','FontSize',myui.fontsize,'Tag','apply2all',...
            'ToolTipString',tstr,'UserData',struct('Tooltipstr',tstr),...
            'Callback',@pv_onPushApply);

        % Java Hack to adjust vertical alignment of text fields
        jh = findjobj(gui.text_handles.first);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        jh = findjobj(gui.text_handles.fitmethod);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        jh = findjobj(gui.text_handles.edit_manual);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        jh = findjobj(gui.text_handles.slider_down);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        jh = findjobj(gui.text_handles.slider_up);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

        % empty space at bottom of left side
        uix.Empty('Parent',gui.left);
        % adjust the heights of all left-column-panels
        heights = [-1 22 22 28 -1; -1 22+4*24+6*3 22+3*24+5*3 28*3 -1];
        % panel header is always 22 high
        set(gui.left,'Heights',heights(2,:),...
            'MinimumHeights',[0 22 22 28 0]);

        % --- plot boxes ---
        % -- tab3
        gui.tab = uix.VBoxFlex('Parent',gui.right,...
            'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.pbox1 = uicontainer('Parent',gui.tab,...
            'BackGroundColor',colors.panelBG);
        gui.pbox2 = uicontainer('Parent',gui.tab,...
            'BackGroundColor',colors.panelBG);
        gui.pbox3 = uicontainer('Parent',gui.tab,...
            'BackGroundColor',colors.panelBG);
        set(gui.tab,'Heights',[-1 -1 -1]);

        % -- plot axes --
        gui.axes_handles.real = axes('Parent',gui.pbox1,'Color',colors.axisBG,...
            'XColor',colors.axisFG,'YColor',colors.axisFG,'Box','on');
        gui.axes_handles.imag = axes('Parent',gui.pbox2,'Color',colors.axisBG,...
            'XColor',colors.axisFG,'YColor',colors.axisFG,'Box','on');
        gui.axes_handles.sse = axes('Parent',gui.pbox3,'Color',colors.axisBG,...
            'XColor',colors.axisFG,'YColor',colors.axisFG,'Box','on');

        % store some main GUI settings
        gui.myui = nucleus.gui.myui;

        % save to GUI
        setappdata(fig_phase,'gui',gui);

        % make GUI visible
        % delete(hwb);
        set(gui.main,'Visible','on');
    else
        % if the figure is already open load the GUI data
        gui = getappdata(fig_phase,'gui');
        data = getappdata(fig_phase,'data');

        % echo range to calculate SSR
        if data.echo_range(2) > nucleus.data.process.end
            data.echo_range(2) = nucleus.data.process.end;
            set(gui.edit_handles.last,'String',sprintf('%d',data.echo_range(2)));
        end
        % data.echo_range = [nucleus.data.process.start nucleus.data.process.end];
    end
    

    % clear all axes
    clearAllAxes(fig_phase);

    if strcmp(nucleus.data.results.nmrproc.T1T2,'T2')
        % get signal to show
        nmrraw = nucleus.data.results.nmrraw;
        loglinx = get(nucleus.gui.cm_handles.axes_raw_xaxis,'Label');

        % axes setting
        data.loglinx = loglinx;
        % phase from import-fit
        data.phase_default = rad2deg(nucleus.data.results.nmrraw.phase);
        % phase used in PhaseView
        data.phase = data.phase_default;
        set(gui.edit_handles.phase,'String',num2str(data.phase));
        set(gui.slider_handles.slider,'Value',data.phase);
        % time
        data.time = nmrraw.t;

        % original unrotated signal
        data.signal_raw = nmrraw.s * exp(1i*deg2rad(-data.phase));
        % rotated signal
        data.signal_rot = nmrraw.s;
        data.s_max = max(real(data.signal_rot));        

        % keep original signal
        data.orig_data = nucleus.data.import.NMR.data{ID};
        data.orig_para = nucleus.data.import.NMR.para{ID};
        
        % update GUI data
        setappdata(fig_phase,'data',data);
        setappdata(fig_phase,'gui',gui);
        % calculate SSR
        pv_updateFullDataSet(fig_phase);
        % update plots
        pv_plotSignal(fig_phase);
        pv_plotSSR(fig_phase);

    else
        % close the GUI because the selected signal is not a T2 signal
        helpdlg({'function: PhaseView',...
            'Cannot continue because there is no T2 data!'},...
            'No T2 data.');
        delete(fig_phase);
    end
end

end

%% subfunction to update the edit fields
function pv_onEditValue(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

switch get(src,'Tag')
    case {'first','last'}
        data.echo_range(1) = str2double(get(gui.edit_handles.first,'String'));
        data.echo_range(2) = str2double(get(gui.edit_handles.last,'String'));
        % update GUI data
        setappdata(fig_phase,'data',data);
        pv_updateFullDataSet(fig_phase);
        data = getappdata(fig_phase,'data');
        setappdata(fig_phase,'data',data);
        pv_plotSignal(fig_phase);
        pv_plotSSR(fig_phase);
    case {'range_min','range_max'}
        data.phase_range(1) = str2double(get(gui.edit_handles.range_min,'String'));
        data.phase_range(2) = str2double(get(gui.edit_handles.range_max,'String'));
        % update GUI data
        setappdata(fig_phase,'data',data);
        pv_plotSSR(fig_phase);
    case 'phase'
        data.phase = str2double(get(gui.edit_handles.phase,'String'));
        % update slider
        set(gui.slider_handles.slider,'Value',data.phase);        
        % apply new phase
        data.signal_rot = data.signal_raw * exp(1i*deg2rad(data.phase));        
        % update GUI data
        setappdata(fig_phase,'data',data);
        setappdata(fig_phase,'gui',gui);
        pv_plotSignal(fig_phase);
        pv_plotSSR(fig_phase);
end

% update GUI data
setappdata(fig_phase,'data',data);
end

%% subfunction to control the phase angle push buttons
function pv_onPushAngle(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

% get the angle offset according to the chosen button
switch get(src,'Tag')
    case 'button_m90'
        offset = -90;
    case 'button_m45'
        offset = -45;
    case 'button_pm180'
        offset = 180;
    case 'button_p45'
        offset = 45;
    case 'button_p90'
        offset = 90;
    otherwise
        offset = 0;
end

% map phase into the correct range
data.phase = -180 + mod((data.phase + offset)+180,360);
% update edit field
set(gui.edit_handles.phase,'String',num2str(data.phase));
% update slider
set(gui.slider_handles.slider,'Value',data.phase);
% new rotated signal
data.signal_rot = data.signal_raw * exp(1i*deg2rad(data.phase));

% update GUI data
setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
% update plots
pv_plotSignal(fig_phase);
pv_plotSSR(fig_phase);
end

%% subfunction to control the push button to apply the phase angle
function pv_onPushApply(src,~)
fig_phase = ancestor(src,'figure','toplevel');
data = getappdata(fig_phase,'data');

% get handle and data of main GUI
fig = findobj('Tag','INV');
nucleus.data = getappdata(fig,'data');
nucleus.gui = getappdata(fig,'gui');

% get selected signal ID from main GUI
id = get(nucleus.gui.listbox_handles.signal,'Value');

switch get(src,'Tag')
    case 'apply'        
        % update phase
        nucleus.data.import.NMR.data{id}.phase = deg2rad(data.phase);
        nucleus.data.results.nmrraw.phase = deg2rad(data.phase);
        % update signal
        nucleus.data.import.NMR.data{id}.signal = data.signal_rot;
        nucleus.data.results.nmrraw.s = data.signal_rot;

    case 'apply2all'
        N = numel(nucleus.data.import.NMR.data);
        for i1 = 1:N
            % only proceed if the signal is complex (T2 data)
            if ~isreal(nucleus.data.import.NMR.data{i1}.signal)
                % original unrotated signal
                phase_org = rad2deg(nucleus.data.import.NMR.data{i1}.phase);
                s_raw = nucleus.data.import.NMR.data{i1}.raw.signal;
                s_raw =  s_raw * exp(1i*deg2rad(-phase_org));

                % new phase
                phase_new = data.phase;
                nucleus.data.import.NMR.data{i1}.phase = deg2rad(phase_new);
                % signal with new phase
                s_new  = s_raw * exp(1i*deg2rad(phase_new));
                % update signal
                nucleus.data.import.NMR.data{i1}.signal = s_new;
                nucleus.data.import.NMR.data{i1}.raw.signal= s_new;
            end
        end
        % check if it is a T1-T2 data set, because then we need to adjust
        % the merged T1 curve also
        if isfield(nucleus.data.import,'T1T2map')
            % the last signal is the merged T1 curve
            N = numel(nucleus.data.import.T1T2map.t_recov) + 1;
            
            s_old = nucleus.data.import.NMR.data{N}.signal;
            time = nucleus.data.import.T1T2map.t_recov;
            s_new = zeros(size(s_old));
            for i1 = 1:numel(time)
                s_new(i1) = mean(real(nucleus.data.import.NMR.data{i1}.signal(1:3)));
            end
            
            % estimate noise of the new merged T1 curve
            disp('NUCLUESinv PhaseView: Estimating noise from exponential fit ...');
            flag = 'T1';
            param.T1IRfac = nucleus.data.import.NMR.data{N}.T1IRfac;
            param.noise = 0;
            param.optim = 'off';
            param.Tfixed_bool = [0 0 0 0 0];
            param.Tfixed_val = [0 0 0 0 0];
            for i1 = 1:5
                invstd = fitDataFree(time,s_new,flag,param,i1);
                if i1 == 1
                    noise = invstd.rms;
                else
                    noise = min([noise invstd.rms]);
                end
            end
            % update data
            nucleus.data.import.NMR.data{N}.signal = s_new;
            nucleus.data.import.NMR.data{N}.noise = noise;
            nucleus.data.import.NMR.data{N}.raw.signal = s_new;
        end
end

% update main GUI data
setappdata(fig,'data',nucleus.data);
% set focus on chosen signal
set(nucleus.gui.listbox_handles.signal,'Value',id);
onListboxData(nucleus.gui.listbox_handles.signal);
end

%% subfunction to control the push button to restore the default phase angle
function pv_onPushKeep(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

% get original pahse
data.phase = data.phase_default;
% update edit field
set(gui.edit_handles.phase,'String',num2str(data.phase));
% update slider
set(gui.slider_handles.slider,'Value',data.phase);
% new rotated signal
data.signal_rot = data.signal_raw * exp(1i*deg2rad(data.phase));

% update GUI data
setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
% update plots
pv_plotSignal(fig_phase);
pv_plotSSR(fig_phase);
end

%% subfunction to control the push button to fit the phase angle
function pv_onPushRun(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

% get signal
s = data.signal_raw;

% get signal bounds
te_start = data.echo_range(1);
te_end = data.echo_range(2);

% get fit method
fitval = get(gui.popup_handles.fitmethod,'Value');
fitmethod = get(gui.popup_handles.fitmethod,'String');
fitmethod = fitmethod{fitval};

% get phase angle range
alpha_range = deg2rad(data.phase_range);

% optim settings
options = optimset('MaxFunEvals',100,'MaxIter',100,'TolFun',1e-6,'TolX',1e-6);
% call fit function
[alpha,~,~,~] = fminsearchbnd(@(alpha) phasefit_fcn(alpha,s(te_start:te_end),fitmethod),...
    mean(alpha_range),alpha_range(1),alpha_range(2),options);

% s_rot is rotated signal
data.signal_rot = s .* exp(1i*alpha);

% save new phase
data.phase = rad2deg(alpha);
% update edit field
set(gui.edit_handles.phase,'String',num2str(data.phase));
% update slider
set(gui.slider_handles.slider,'Value',data.phase);

% update GUI data
setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
% update plots
pv_plotSignal(fig_phase);
pv_plotSSR(fig_phase);
end

% minimization function
function sse = phasefit_fcn(alpha,s,method)
% Inputs:
%       alpha - rotation phase angle in [rad]
%       s - NMR signal vector (has to be complex!)
%       method - "maxRE minIM", "maxRE", "minIM" or "minIMstd"
%
% Outputs:
%       sse - sum of squared residuals (option 1 to 3) or
%             standard deviation of imag. part (option 4)

s = s(:);
switch method
    case 'maxRE minIM'
        % make a vector of zeros
        t0 = zeros(size(s,1),1);
        t0 = t0(:);
        % s_rot is the rotated signal
        s_rot = s .* exp(1i*alpha);
        % create residuals
        residuali = t0-imag(s_rot);
        residualr = t0-real(s_rot);
        % real part times -1 because we seek the maximum
        sse = sum(residuali.^2) + sum(residualr.^2)*-1;
    case 'maxRE'
        % make a vector of zeros
        t0 = zeros(size(s,1),1);
        t0 = t0(:);
        % s_rot is the rotated signal
        s_rot = s .* exp(1i*alpha);
        % create residuals
        residualr = t0-real(s_rot);
        % maximum of real part should be maximized
        sse = sum(residualr.^2)*-1;
    case 'minIM'
        % make a vector of zeros
        t0 = zeros(size(s,1),1);
        t0 = t0(:);
        % s_rot is the rotated signal
        s_rot = s .* exp(1i*alpha);
        % create residuals
        residuali = t0-imag(s_rot);
        % sse
        sse = sum(residuali.^2);
    case 'minIMstd'
        % s_rot is the rotated signal
        s_rot = s .* exp(1i*alpha);
        % standard deviation of the imaginary part should be minimized
        sse = std(imag(s_rot));
end

end

%% subfunction to control the slider
function pv_onSlider(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

% new phase angle from slider
data.phase = get(src,'Value');
% update edit field
set(gui.edit_handles.phase,'String',num2str(data.phase));
% new rotated signal
data.signal_rot = data.signal_raw * exp(1i*deg2rad(data.phase));

% update GUI data
setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
% update signals
pv_plotSignal(fig_phase);
pv_plotSSR(fig_phase);
end

%% subfunction to calculate the full SSE values for a range of phase angles
function pv_updateFullDataSet(fig_phase)
data = getappdata(fig_phase,'data');

% get echo range
te_start = data.echo_range(1);
te_end = data.echo_range(2);
% get all signals with the desired phase angles
SSE = data.signal_raw*exp(1i*deg2rad(data.beta_range));

% get individual SSRs
sse_r = getSSR(real(SSE(te_start:te_end,:)));
sse_i = getSSR(imag(SSE(te_start:te_end,:)));
% save data
data.sse_i = sse_i;
data.sse_r = sse_r;

% update GUI data
setappdata(fig_phase,'data',data);
end

%% subfunction to plot the REal and IMag signal parts
function pv_plotSignal(fig_phase)
data = getappdata(fig_phase,'data');
gui = getappdata(fig_phase,'gui');

% axes handles
ax1 = gui.axes_handles.real;
ax2 = gui.axes_handles.imag;
clearSingleAxis(ax1);
clearSingleAxis(ax2);

% plot Real and IMag part of signal
plot(data.time,real(data.signal_rot),'Color',gui.myui.colors.RE,'Parent',ax1);
plot(data.time,imag(data.signal_rot),'Color',gui.myui.colors.IM,'Parent',ax2);

hold(ax1,'on');
hold(ax2,'on');

switch data.loglinx
    case 'x-axis -> lin' % log axes
        xticks = floor(log10(data.time(1)))-1:1:log10(max(data.time))+1;
        set([ax1 ax2],'XScale','log','XLim',[data.time(1) max(data.time)],'XTick',10.^xticks);
    case 'x-axis -> log' % lin axes
        set([ax1 ax2],'XScale','lin','XLim',[0 max(data.time)],'XTickMode','auto');
end
grid([ax1 ax2],'on');

set([ax1 ax2],'XLim',[data.orig_data.raw.time(1) data.orig_data.raw.time(end)]);
set(get(ax1,'YLabel'),'String','Real Ampl.');
set(get(ax2,'XLabel'),'String','time [s]');
set(get(ax2,'YLabel'),'String','Imag Ampl.');

% get SSR of current signal
te_start = data.echo_range(1);
te_end = data.echo_range(2);
sse_r = getSSR(real(data.signal_rot(te_start:te_end)));
sse_i = getSSR(imag(data.signal_rot(te_start:te_end)));

set(get(ax1,'Title'),'String',['SSR: ',sprintf('%6.5e',sse_r)]);
set(get(ax2,'Title'),'String',['SSR: ',sprintf('%6.5e',sse_i)]);

% plot patches to indicate echo range
p_alpha = 0.8;
xlims = get(ax1,'XLim');
ylims_re = get(ax1,'YLim');
ylims_im = get(ax2,'YLim');
if data.time(te_start)>xlims(1)
    % draw a transparent patch
    v_re = [xlims(1) ylims_re(1); xlims(1) ylims_re(2);
        data.time(te_start) ylims_re(2); data.time(te_start) ylims_re(1)];
    v_im = [xlims(1) ylims_im(1); xlims(1) ylims_im(2);
        data.time(te_start) ylims_im(2); data.time(te_start) ylims_im(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v_re,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax1);
    patch('Vertices',v_im,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax2);
end
if data.time(te_end)<xlims(2)
    % draw a transparent patch
    v_re = [xlims(2) ylims_re(1); xlims(2) ylims_re(2);
        data.time(te_end) ylims_re(2); data.time(te_end) ylims_re(1)];
    v_im = [xlims(2) ylims_im(1); xlims(2) ylims_im(2);
        data.time(te_end) ylims_im(2); data.time(te_end) ylims_im(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v_re,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax1);
    patch('Vertices',v_im,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax2);
end
set(ax1,'YLim',ylims_re);
set(ax2,'YLim',ylims_im);
set([ax1 ax2],'FontSize',gui.myui.fontsize);
hold(ax1,'off');
hold(ax2,'off');
end

%% subfunction to plot the SSR
function pv_plotSSR(fig_phase)
data = getappdata(fig_phase,'data');
gui = getappdata(fig_phase,'gui');

% axes handles
ax = gui.axes_handles.sse;
clearSingleAxis(ax);
hold(ax,'on');

% plot REal and IMag SSRs
ymin = min([data.sse_r data.sse_i]);
ymax = max([data.sse_r data.sse_i]);
plot(data.beta_range,data.sse_r,'Color',gui.myui.colors.RE,'Parent',ax);
plot(data.beta_range,data.sse_i,'Color',gui.myui.colors.IM,'Parent',ax);
% indicate current phase angle
line([data.phase data.phase],[ymin ymax],'Color',gui.myui.colors.axisL,'LineStyle','--','Parent',ax)
lgh = legend(ax,'Real','Imag','Phase');
set(lgh,'TextColor',gui.myui.colors.panelFG);

% plot patches to indicate angle range
p_alpha = 0.8;
xlims = [-180 180];
ylims = [ymin ymax];
if data.phase_range(1)>xlims(1)
    % draw a transparent patch
    v = [xlims(1) ylims(1); xlims(1) ylims(2);
        data.phase_range(1) ylims(2); data.phase_range(1) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax);
end
if data.phase_range(2)<xlims(2)
    % draw a transparent patch
    v = [xlims(2) ylims(1); xlims(2) ylims(2);
        data.phase_range(2) ylims(2); data.phase_range(2) ylims(1)];
    f = [1 2 3 4 1];
    patch('Vertices',v,'Faces',f,'FaceColor','w','FaceAlpha',p_alpha,...
        'HandleVisibility','off','Tag','infolines','Parent', ax);
end

xticks = -180:45:180;
set(ax,'XLim',[-180 180],'XTick',xticks);
set(ax,'YLim',[ymin ymax]);
set(get(ax,'XLabel'),'String','phase angle [deg]');
set(get(ax,'YLabel'),'String','squared sum res. (SSR)');
hold(ax,'off');
set(ax,'FontSize',gui.myui.fontsize);
end

%% subfunction to get the SSR
function ssr = getSSR(signal)
% residual of signal
res = zeros(size(signal))-signal;
% sum of squared residuals SSR
ssr = sum(res.^2);
end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Thomas Hiller
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