function PhaseView(src,~)
%PhaseView is an extra subGUI to visualize the phase of a T2 signal
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
%       none
%
% Subfunctions:
%       pv_onPushDefault
%       pv_onPushSave
%       pv_showSignal
%       pv_updateSlider
%       pv_updatePhase
%       shift_phase
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
colors = nucleus.gui.myui.colors;

hasData = false;
if isfield(nucleus.data,'results')
    if isfield(nucleus.data.results,'nmrraw') &&...
            isfield(nucleus.data.results,'nmrproc')
        hasData = true;
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
            'NumberTitle','off','ToolBar','none','Tag','PHASEVIEW');
        pos0 = get(fig,'Position');
        pos1 = get(fig_phase,'Position');
        cent(1) = (pos0(1)+pos0(3)/2);
        cent(2) = (pos0(2)+pos0(4)/2);
        set(fig_phase,'Position',[cent(1)-pos0(3)/3 pos0(2) pos0(3)/1.5 pos0(4)]);

        % create the layout
        gui.main = uix.VBox('Parent',fig_phase,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5);
        gui.row1 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % axes real
        gui.row2 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % axes imag
        gui.row3 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % axes SSE
        gui.row4 = uix.HBox('Parent',gui.main,'BackGroundColor',colors.panelBG,'Spacing',5); % control elements
        set(gui.main,'Heights',[-1 -1 -1 90]);

        % all axes
        gui.axes_handles.real = axes('Parent',gui.row1,...
            'Color',colors.axisBG,'XColor',colors.axisFG,...
            'YColor',colors.axisFG);
        gui.axes_handles.imag = axes('Parent',gui.row2,...
            'Color',colors.axisBG,'XColor',colors.axisFG,...
            'YColor',colors.axisFG);
        gui.axes_handles.sse = axes('Parent',gui.row3,...
            'Color',colors.axisBG,'XColor',colors.axisFG,...
            'YColor',colors.axisFG);

        % 3 horizontal boxes
        uix.Empty('Parent',gui.row4);
        gui.vbox1 = uix.VBox('Parent',gui.row4,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5); % control elements
        uix.Empty('Parent',gui.row4);
        set(gui.row4,'Widths',[-1 -2 -1]);

        % edit field
        gui.hbox11 = uix.HBox('Parent',gui.vbox1,'BackGroundColor',colors.panelBG,'Spacing',5);
        uix.Empty('Parent',gui.hbox11);
        gui.edit_phase = uicontrol('Parent',gui.hbox11,...
            'Style','edit','FontSize',nucleus.gui.myui.fontsize,'Tag','phase',...
            'String',num2str(0),'BackGroundColor',colors.editBG,...
            'ForeGroundColor',colors.panelFG,...
            'Callback',@pv_updatePhase);
        uix.Empty('Parent',gui.hbox11);
        set(gui.hbox11,'Widths',[-1 -1 -1]);

        % slider
        gui.hbox12 = uix.HBox('Parent',gui.vbox1,'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.hbox121 = uix.HBox('Parent',gui.hbox12,'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.text_down = uicontrol('Parent',gui.hbox121,'Style','text',...
            'String','down','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'HorizontalAlignment','right');
        gui.slider = uicontrol('Parent',gui.hbox12,'Style','slider',...
            'Min',-180,'Max',180,'Value',0,'SliderStep',[0.1/360 5/360],...
            'Callback',@pv_updateSlider);
        gui.hbox122 = uix.HBox('Parent',gui.hbox12,'BackGroundColor',colors.panelBG,'Spacing',5);
        gui.text_up = uicontrol('Parent',gui.hbox122,'Style','text',...
            'String','up','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'HorizontalAlignment','left');
        set(gui.hbox12,'Widths',[-1 -9 -1]);

        % buttons
        gui.hbox13 = uix.HBox('Parent',gui.vbox1,'BackGroundColor',colors.panelBG,'Spacing',5);
        uix.Empty('Parent',gui.hbox13);
        gui.push_default = uicontrol('Parent',gui.hbox13,...
            'Style','pushbutton','FontSize',nucleus.gui.myui.fontsize,'Tag','default',...
            'String','DEFAULT','Callback',@pv_onPushDefault);
        uix.Empty('Parent',gui.hbox13);
        gui.push_save = uicontrol('Parent',gui.hbox13,...
            'Style','pushbutton','FontSize',nucleus.gui.myui.fontsize,'Tag','save',...
            'String','KEEP','Callback',@pv_onPushSave);
        uix.Empty('Parent',gui.hbox13);
        set(gui.hbox13,'Widths',[-1 -2 -1 -2 -1]);

        set(gui.vbox1,'Heights',[-1 20 -1]);

        % Java Hack to adjust vertical alignment of text fields
        jh = findjobj(gui.text_down);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        jh = findjobj(gui.text_up);
        jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

        % store some main GUI settings
        gui.myui = nucleus.gui.myui;

        % save to GUI
        setappdata(fig_phase,'gui',gui);
    end
    % if the figure is already open load the GUI data
    gui = getappdata(fig_phase,'gui');

    % clear all axes
    clearAllAxes(fig_phase);

    if strcmp(nucleus.data.results.nmrproc.T1T2,'T2')

        %% get signal to show
        nmrraw = nucleus.data.results.nmrraw;
        loglinx = get(nucleus.gui.cm_handles.axes_raw_xaxis,'Label');

        % axes setting
        data.loglinx = loglinx;
        % phase from import-fit
        data.phase_default = rad2deg(nucleus.data.results.nmrraw.phase);
        % phase used in PhaseView
        data.phase = data.phase_default;
        set(gui.edit_phase,'String',num2str(data.phase));
        set(gui.slider,'Value',data.phase);
        % time
        data.time = nmrraw.t;

        % original unrotated signal
        data.signal_raw = nmrraw.s * exp(1i*deg2rad(shift_phase(-data.phase)));
        % rotated signal
        data.signal_rot = nmrraw.s;
        data.s_max = max(real(data.signal_rot));

        % SSE data
        beta_range = 0:1:360;
        SSE = data.signal_raw*exp(1i*deg2rad(beta_range));
        t0 = zeros(size(SSE));
        residual_i = t0-imag(SSE);
        residual_r = t0-real(SSE);
        sse_i = sum(residual_i.^2,1);
        sse_r = sum(residual_r.^2,1)*-1;
        data.beta_range = beta_range;
        data.sse_i = sse_i;
        data.sse_r = sse_r;

        setappdata(fig_phase,'data',data);
        setappdata(fig_phase,'gui',gui);
        pv_showSignal(fig_phase);
    else
        helpdlg({'function: PhaseView',...
            'Cannot continue because there is no T2 data!'},...
            'No T2 data.');
        delete(fig_phase);
    end
end

end

function pv_onPushDefault(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

data.phase = data.phase_default;
set(gui.slider,'Value',data.phase);
set(gui.edit_phase,'String',num2str(data.phase));

data.signal_rot = data.signal_raw * exp(1i*deg2rad(shift_phase(data.phase)));

setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
pv_showSignal(fig_phase);

end

function pv_onPushSave(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

fig = findobj('Tag','INV');
nucleus.data = getappdata(fig,'data');
nucleus.gui = getappdata(fig,'gui');

% get the selected signal ID
id = get(nucleus.gui.listbox_handles.signal,'Value');
% update phase
nucleus.data.import.NMR.data{id}.phase = deg2rad(data.phase);
nucleus.data.results.nmrraw.phase = deg2rad(data.phase);
% update signal
nucleus.data.import.NMR.data{id}.signal = data.signal_rot;
nucleus.data.results.nmrraw.s = data.signal_rot;

% update GUI data
setappdata(fig,'data',nucleus.data);

end

function pv_showSignal(fig_phase)
data = getappdata(fig_phase,'data');
gui = getappdata(fig_phase,'gui');

% axes handles
ax1 = gui.axes_handles.real;
ax2 = gui.axes_handles.imag;
ax3 = gui.axes_handles.sse;
% clear all axes
clearAllAxes(fig_phase);
hold(ax1,'on');
hold(ax2,'on');
hold(ax3,'on');

plot(data.time,real(data.signal_rot),'Color',gui.myui.colors.RE,'Parent',ax1);
plot(data.time,imag(data.signal_rot),'Color',gui.myui.colors.IM,'Parent',ax2);

switch data.loglinx
    case 'x-axis -> lin' % log axes
        xticks = floor(log10(data.time(1)))-1:1:log10(max(data.time))+1;
        set(ax1,'XScale','log','XLim',[data.time(1) max(data.time)],'XTick',10.^xticks);
        set(ax2,'XScale','log','XLim',[data.time(1) max(data.time)],'XTick',10.^xticks);
    case 'x-axis -> log' % lin axes
        set(ax1,'XScale','lin','XLim',[0 max(data.time)],'XTickMode','auto');
        set(ax2,'XScale','lin','XLim',[0 max(data.time)],'XTickMode','auto');
end
grid(ax1,'on');
grid(ax2,'on');

line(get(ax2,'XLim'),[0 0],'LineStyle','--','Color',gui.myui.colors.axisL,'LineWidth',1,'Parent',ax2);
hold(ax2,'off');

%residual of current phase angle
res_r = zeros(size(data.time))-real(data.signal_rot);
res_i = zeros(size(data.time))-imag(data.signal_rot);
sse_r = sum(res_r.^2);
sse_i = sum(res_i.^2);

set(get(ax1,'XLabel'),'String','time');
set(get(ax1,'YLabel'),'String','\Reeal');
text(0.975,0.8,['\Sigma \epsilon^2 = ',sprintf('%6.5e',sse_r)],...
    'HorizontalAlignment','right','BackgroundColor',gui.myui.colors.axisBG,...
    'Color',gui.myui.colors.panelFG,'Units','normalized',...
    'FontSize',12,'Parent',ax1);
set(get(ax2,'XLabel'),'String','time');
set(get(ax2,'YLabel'),'String','\Immag');
text(0.975,0.8,['\Sigma \epsilon^2 = ',sprintf('%6.5e',sse_i)],...
    'HorizontalAlignment','right','BackgroundColor',gui.myui.colors.axisBG,...
    'Color',gui.myui.colors.panelFG,'Units','normalized',...
    'FontSize',12,'Parent',ax2);

ymin = min([-1.*data.sse_r data.sse_i]);
ymax = max([-1.*data.sse_r data.sse_i]);
plot(data.beta_range-180,-1.*data.sse_r,'Color',gui.myui.colors.RE,'Parent',ax3);
plot(data.beta_range-180,data.sse_i,'Color',gui.myui.colors.IM,'Parent',ax3);
line([data.phase data.phase],[ymin ymax],'Color',gui.myui.colors.axisL,'LineStyle','--','Parent',ax3)
lgh = legend(ax3,'\Reeal','\Immag','\phi');
set(lgh,'FontSize',12,'TextColor',gui.myui.colors.panelFG);

set(ax3,'XLim',[-180 180],'XTick',-180:30:180);
set(ax3,'YLim',[ymin ymax]);
set(get(ax3,'XLabel'),'String','phase \phi [deg]');
set(get(ax3,'YLabel'),'String','\Sigma \epsilon^2');
hold(ax3,'off');

set(ax1,'FontSize',gui.myui.fontsize);
set(ax2,'FontSize',gui.myui.fontsize);
set(ax3,'FontSize',gui.myui.fontsize);

set(get(ax1,'YLabel'),'FontSize',16);
set(get(ax2,'YLabel'),'FontSize',16);

end

function pv_updateSlider(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

data.phase = get(gui.slider,'Value');
set(gui.edit_phase,'String',num2str(data.phase));

data.signal_rot = data.signal_raw * exp(1i*deg2rad(shift_phase(data.phase)));

setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
pv_showSignal(fig_phase);

end

function pv_updatePhase(src,~)
fig_phase = ancestor(src,'figure','toplevel');
gui = getappdata(fig_phase,'gui');
data = getappdata(fig_phase,'data');

data.phase = str2double(get(gui.edit_phase,'String'));
set(gui.slider,'Value',data.phase);

data.signal_rot = data.signal_raw * exp(1i*deg2rad(shift_phase(data.phase)));

setappdata(fig_phase,'data',data);
setappdata(fig_phase,'gui',gui);
pv_showSignal(fig_phase);

end

function phase = shift_phase(phase)
% shifts the phase values from [-180,180] to [0,360]
phase = phase + 180;
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