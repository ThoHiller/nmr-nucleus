function ConductView(src,~)
%ConductView is an extra subGUI to visualize hydraulic conductivity
%estimates
%
% Syntax:
%       ConductView(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       ConductView
%
% Other m-files required:
%       none
%
% Subfunctions:
%       cv_onEditProp
%       cv_onPopupUnit
%       cv_onRadioMethod
%       cv_updateAxes
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod, NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
nucleus.data = getappdata(fig,'data');
nucleus.gui = getappdata(fig,'gui');
colors = nucleus.gui.myui.colors;

showplot = false;

% gather data depending on figure tag
switch fig_tag
    case 'INV'
        INVdata = getappdata(fig,'INVdata');
        [foundINV,~] = checkIfInversionExists(INVdata);
        
        if foundINV
            tolKrel = 0.999;
            geom_type = INVdata{1}.invjoint.geometry_type;
            constants = getConstants;
            if isfield(nucleus.data.results,'invjoint')
                colors.CPS = colors.BoxCPS;
                constants.porosity = INVdata{1}.invstd.porosity;
                constants.tortuosity = 1;
                pSAT = nucleus.data.results.invjoint.pSAT;
                showplot = true;
            end
        end
        
    case 'MOD'
        tolKrel = 0.9999;
        geom_type = nucleus.data.geometry.type;
        constants = nucleus.data.results.constants;
        constants.porosity = nucleus.data.nmr.porosity;
        constants.tortuosity = 1;
        pSAT = nucleus.data.results.SAT;
        showplot = true;
end

% now plot the CONDUCT gui
if showplot
    % prepare neccesary gui data
    data.constants = constants;
    data.geom_type = geom_type;
    data.myui = nucleus.gui.myui;
    data.tolKrel = tolKrel;
    data.cond_unit = 1;
    data.perm_unit = 1;
    data.SAT = pSAT;
    
    % check if the figure is already open
    fig_conduct = findobj('Tag','CONDUCT');
    % if not, create it
    if isempty(fig_conduct)
        % draw the figure on top of NUCLEUS
        fig_conduct = figure('Name','NUCLEUS - ConductView',...
            'NumberTitle','off','ToolBar','none','Menubar','none','Tag','CONDUCT');
        pos0 = get(fig,'Position');
        cent(1) = (pos0(1)+pos0(3)/2);
        cent(2) = (pos0(2)+pos0(4)/2);
        set(fig_conduct,'Position',[cent(1)-pos0(3)/3 pos0(2)+22 pos0(3)/1.5 pos0(4)-22]);

        gui.menu.view = uimenu(fig_conduct,'Label','View');
        gui.menu.view_toolbar = uimenu(gui.menu.view,'Label','Figure Toolbar',...
        'Callback',@onMenuView);
        
        % create the layout
        gui.main = uix.HBox('Parent',fig_conduct,...
            'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5);
        % control panel
        gui.col1 = uix.VBox('Parent',gui.main,...
            'BackGroundColor',colors.panelBG,'Spacing',5);
        % axes panel
        gui.col2 = uix.CardPanel('Parent',gui.main,...
            'BackGroundColor',colors.panelBG,'Visible','off');
        set(gui.main,'Width',[200 -1]);
        
        % axes inside uicontainers
        for i = 1:6
            gui.card(i) = uicontainer('Parent',gui.col2,...
                'BackGroundColor',colors.panelBG);
            gui.ax(i) = axes('Parent',gui.card(i),'Color',colors.axisBG,...
                'XColor',colors.axisFG,'YColor',colors.axisFG,...
                'FontSize',12);
        end
        
        % control boxes
        uix.Empty('Parent',gui.col1);
        gui.panels.method = uix.BoxPanel('Parent',gui.col1,'Title','Upscaling Method',...
            'TitleColor',colors.CPS,'ForegroundColor',colors.BoxTitle);
        gui.panels.type = uix.BoxPanel('Parent',gui.col1,'Title','Plot Type',...
            'TitleColor',colors.CPS,'ForegroundColor',colors.BoxTitle);
        gui.panels.prop = uix.BoxPanel('Parent',gui.col1,'Title','Properties',...
            'TitleColor',colors.CPS,'ForegroundColor',colors.BoxTitle);
        uix.Empty('Parent',gui.col1);
        set(gui.col1,'Heights',[-1 100 175 210 -1]);
        
        % vboxes inside panels
        gui.vbox1 = uix.VBox('Parent',gui.panels.method,...
            'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        gui.vbox2 = uix.VBox('Parent',gui.panels.type,...
            'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        gui.vbox3 = uix.VBox('Parent',gui.panels.prop,...
            'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        
        % radio buttons inside 1. box
        gui.radio_handles.coord = [1 1];
        % parallel connection
        gui.radio_handles.pc = uicontrol('Parent',gui.vbox1,...
            'Style','radiobutton','String','parallel connection',...
            'Tag','method','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Value',1,'Callback',@cv_onRadioMethod);
        % effective capillary
        gui.radio_handles.eff = uicontrol('Parent',gui.vbox1,...
            'Style','radiobutton','String','effective capillary',...
            'Tag','method','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Callback',@cv_onRadioMethod);
        
        % radio buttons inside 2. box
        % hydraulic conductivity
        gui.radio_handles.cond = uicontrol('Parent',gui.vbox2,...
            'Style','radiobutton','String','hydraulic conductivity',...
            'Tag','type','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Value',1,'Callback',@cv_onRadioMethod);
        gui.hbox10 = uix.HBox('Parent',gui.vbox2,'BackGroundColor',colors.panelBG,'Spacing',4,'Padding',2);
        uix.Empty('Parent',gui.hbox10);
        gui.popup_handles.cond = uicontrol('Parent',gui.hbox10,...
            'Style','popupmenu','String',{'m/s','cm/d'},...
            'Tag','cond','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Value',1,'Callback',@cv_onPopupUnit);
        gui.text_handles.cond_unit = uicontrol('Parent',gui.hbox10,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','left',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','unit');
        uix.Empty('Parent',gui.hbox10);
        set(gui.hbox10,'Widths',[25 -3 -3 -1]);
        % permeability
        gui.radio_handles.perm = uicontrol('Parent',gui.vbox2,...
            'Style','radiobutton','String','permeability',...
            'Tag','type','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Callback',@cv_onRadioMethod);
        gui.hbox11 = uix.HBox('Parent',gui.vbox2,'BackGroundColor',colors.panelBG,'Spacing',4,'Padding',2);
        uix.Empty('Parent',gui.hbox11);
        gui.popup_handles.perm = uicontrol('Parent',gui.hbox11,...
            'Style','popupmenu','String',{'m²','D','mD'},...
            'Tag','perm','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Value',1,'Callback',@cv_onPopupUnit);
        gui.text_handles.perm_unit = uicontrol('Parent',gui.hbox11,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','left',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','unit');
        uix.Empty('Parent',gui.hbox11);
        set(gui.hbox11,'Widths',[25 -3 -3 -1]);
        % relative cond / perm
        gui.radio_handles.rel = uicontrol('Parent',gui.vbox2,...
            'Style','radiobutton','String','relative cond / perm [-]',...
            'Tag','type','FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.panelBG,....
            'ForeGroundColor',colors.panelFG,...
            'Enable','on','Callback',@cv_onRadioMethod);
        
        % horizontal boxes inside 3. box
        gui.hbox1 = uix.HBox('Parent',gui.vbox3,'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        gui.hbox2 = uix.HBox('Parent',gui.vbox3,'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        gui.hbox3 = uix.HBox('Parent',gui.vbox3,'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        uix.Empty('Parent',gui.vbox3);
        gui.hbox4 = uix.HBox('Parent',gui.vbox3,'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        gui.hbox5 = uix.HBox('Parent',gui.vbox3,'BackGroundColor',colors.panelBG,'Spacing',2,'Padding',2);
        set(gui.vbox3,'Heights',[-4 -4 -4 -1 -4 -4]);
        
        % gravitational acceleration [m/s²]
        gui.edit_handles.gravity = uicontrol('Parent',gui.hbox1,...
            'Style','edit','String',num2str(constants.gravity),'FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
            'Tag','gravity','Enable','on','Callback',@cv_onEditProp);
        gui.text_handles.gravity = uicontrol('Parent',gui.hbox1,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','center',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','grav. acc. [m/s²]');
        % density [kg/m³]
        gui.edit_handles.dens = uicontrol('Parent',gui.hbox2,...
            'Style','edit','String',num2str(constants.density),'FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
            'Tag','dens','Enable','on','Callback',@cv_onEditProp);
        gui.text_handles.dens = uicontrol('Parent',gui.hbox2,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','center',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','density [kg/m³]');
        % dynamic viscosity [Pa s]
        gui.edit_handles.dyn = uicontrol('Parent',gui.hbox3,...
            'Style','edit','String',num2str(constants.dynvisc),'FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
            'Tag','dyn','Enable','on','Callback',@cv_onEditProp);
        gui.text_handles.dyn = uicontrol('Parent',gui.hbox3,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','center',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','dyn. visc. [Pa s]');
        % edit and text fields for different properties
        % porosity [-]
        gui.edit_handles.poro = uicontrol('Parent',gui.hbox4,...
            'Style','edit','String',num2str(constants.porosity),'FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
            'Tag','poro','Enable','on','Callback',@cv_onEditProp);
        gui.text_handles.poro = uicontrol('Parent',gui.hbox4,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','center',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','porosity [-]');
        % edit and text fields for different properties
        % porosity [-]
        gui.edit_handles.tort = uicontrol('Parent',gui.hbox5,...
            'Style','edit','String',num2str(constants.tortuosity),'FontSize',nucleus.gui.myui.fontsize,...
            'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
            'Tag','tort','Enable','on','Callback',@cv_onEditProp);
        gui.text_handles.tort = uicontrol('Parent',gui.hbox5,...
            'Style','text','FontSize',nucleus.gui.myui.fontsize,'HorizontalAlignment','center',...
            'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
            'String','tortuosity [-]');
        % adjust the boxes
        set(gui.hbox1,'Width',[-1 -1.5]);
        set(gui.hbox2,'Width',[-1 -1.5]);
        set(gui.hbox3,'Width',[-1 -1.5]);
        set(gui.hbox4,'Width',[-1 -1.5]);
        set(gui.hbox5,'Width',[-1 -1.5]);
        
        % store some main GUI settings
        gui.myui = nucleus.gui.myui;
        % save to GUI
        setappdata(fig_conduct,'gui',gui);
        fixVerticalTextAlignment(fig_conduct);
    else
        % if the figure is already open load the GUI data
        gui = getappdata(fig_conduct,'gui');
        % clear all axes
        clearAllAxes(fig_conduct);
        % set default radio buttons
        gui.radio_handles.coord = [1 1];
        set(gui.radio_handles.pc,'Value',1);
        set(gui.radio_handles.cond,'Value',1);
        cv_onRadioMethod(gui.radio_handles.pc);
        cv_onRadioMethod(gui.radio_handles.cond);
        % set unit popup menus
        set(gui.popup_handles.cond,'Value',1);
        set(gui.popup_handles.perm,'Value',1);        
        % set properties (may have changed)
        set(gui.edit_handles.poro,'String',num2str(constants.porosity));
        set(gui.edit_handles.gravity,'String',num2str(constants.gravity));
        set(gui.edit_handles.dens,'String',num2str(constants.density));
        set(gui.edit_handles.dyn,'String',num2str(constants.dynvisc));
        set(gui.edit_handles.tort,'String',num2str(constants.tortuosity));
    end
    % save to GUI
    setappdata(fig_conduct,'data',data);
    % plot the data
    cv_updateAxes(fig_conduct);
    % make the axes visible
    set(gui.col2,'Selection',1,'Visible','on');
else
    helpdlg({'function: showConduct',...
        'Cannot continue because there is no data.'},...
        'Not enough data to show');
end

end

%%
function cv_onEditProp(src,~)
fig_conduct = ancestor(src,'figure','toplevel');
% gui = getappdata(fig_conduct,'gui');
data = getappdata(fig_conduct,'data');

val = str2double(get(src,'String'));

switch get(src,'Tag')
    case 'poro'
        % check that porosity stays within limits
        if val <= 0 || val > 1
            val = 1;
            set(src,'String',num2str(val));
        end
        data.constants.porosity = val;
    case 'gravity'
        data.constants.gravity = val;
    case 'dens'
        data.constants.density = val;
    case 'dyn'
        data.constants.dynvisc = val;
    case 'tort'
        data.constants.tortuosity = val;
end
setappdata(fig_conduct,'data',data);
cv_updateAxes(fig_conduct);

end

%%
function cv_onPopupUnit(src,~)
fig_conduct = ancestor(src,'figure','toplevel');
data = getappdata(fig_conduct,'data');
gui = getappdata(fig_conduct,'gui');

% check which popup menu was selected
% and set the corresponding unit
switch get(src,'Tag')
    case 'cond'
        data.cond_unit = get(src,'Value'); 
    case 'perm'
        data.perm_unit = get(src,'Value');
end
% update gui data
setappdata(fig_conduct,'data',data);
setappdata(fig_conduct,'gui',gui);

% get the id of the current visible plot
id = get(gui.col2,'Selection');
% update all plots
cv_updateAxes(fig_conduct)
% show the current visible plot again
set(gui.col2,'Selection',id);

end

%%
function cv_onRadioMethod(src,~)
fig_conduct = ancestor(src,'figure','toplevel');
gui = getappdata(fig_conduct,'gui');

% check which radiobutton was selected
switch get(src,'Tag')
    case 'method'
        switch get(src,'String')
            case 'parallel connection'
                gui.radio_handles.coord(2) = 1;
                set(src,'Value',1);
                set(gui.radio_handles.eff,'Value',0);
            case 'effective capillary'
                gui.radio_handles.coord(2) = 2;
                set(src,'Value',1);
                set(gui.radio_handles.pc,'Value',0);
        end        
    case 'type'
        switch get(src,'String')
            case 'hydraulic conductivity'
                gui.radio_handles.coord(1) = 1;
                set(src,'Value',1);
                set(gui.radio_handles.perm,'Value',0);
                set(gui.radio_handles.rel,'Value',0);
            case 'permeability'
                gui.radio_handles.coord(1) = 2;
                set(src,'Value',1);
                set(gui.radio_handles.cond,'Value',0);
                set(gui.radio_handles.rel,'Value',0);
            case 'relative cond / perm [-]'
                gui.radio_handles.coord(1) = 3;
                set(src,'Value',1);
                set(gui.radio_handles.cond,'Value',0);
                set(gui.radio_handles.perm,'Value',0);
        end
end
% update gui data
setappdata(fig_conduct,'gui',gui);

% activate selected card panel
id = 3*(gui.radio_handles.coord(2)-1)+gui.radio_handles.coord(1);
set(gui.col2,'Selection',id);

end

%%
function cv_updateAxes(fig_conduct)
gui = getappdata(fig_conduct,'gui');
data = getappdata(fig_conduct,'data');
colors = gui.myui.colors;

% get unit for hydraulic conductivity
if data.cond_unit == 1
    unitfak_1 = 1; % [m/s]
    unitstr_1 = '[m/s]';
else
    unitfak_1 = 8.64e6; % [cm/d]
    unitstr_1 = '[cm/d]';
end
ylstr_1 = ['hydraulic conductivity ',unitstr_1];

% get unit for permeability
if data.perm_unit == 1
    unitfak_2 = 1; % [m^2]
    unitstr_2 = '[m²]';
elseif data.perm_unit == 2
    unitfak_2 = (1/9.86923e-13); % [D] Darcy
    unitstr_2 = '[D]';
else
    unitfak_2 = (1/9.86923e-16); % [mD] miili Darcy
    unitstr_2 = '[mD]';
end
ylstr_2 = ['permeability ',unitstr_2];

% gather parameters
tolKrel = data.tolKrel;
constants = data.constants;
permfak = constants.dynvisc / constants.density / constants.gravity;
porofak = constants.porosity / constants.tortuosity;
SAT = data.SAT;
% "color brewer" colors
coldrain = [0.2157 0.4941 0.7216]; % blue
colimb = [0.8941 0.1020 0.1098]; % red

% clear and hold all axes
for i = 1:6
    cla(gui.ax(i))
    hold(gui.ax(i),'on');
end

% plot data
% pc - cond
KSpc = max(unitfak_1*porofak*SAT.Kdfull(SAT.Sdfull==1));
if isempty(KSpc)
    KSpc = max(unitfak_1*porofak*SAT.Kdfull(SAT.Sdfull==max(SAT.Sdfull)));
end
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kdfull,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(1));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Kifull,'Color',colimb,...
            'LineStyle','--','DisplayName','imb','Parent',gui.ax(1));
    otherwise
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kdfull,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(1));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Kifull,'Color',colimb,...
            'DisplayName','imb','Parent',gui.ax(1));
end
ymin = min([unitfak_1*porofak*SAT.Kdfull;unitfak_1*porofak*SAT.Kifull]);
ymax = max([unitfak_1*porofak*SAT.Kdfull;unitfak_1*porofak*SAT.Kifull]);
ymin = 10^floor(log10(ymin));
ymax = 10^ceil(log10(ymax));
set(gui.ax(1),'YLim',[ymin ymax]);
lgh = legend(gui.ax(1),'Location','SouthEast');
set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);

% pc - perm
kSpc = max(unitfak_2*permfak*porofak*SAT.Kdfull(SAT.Sdfull==1));
if isempty(kSpc)
    kSpc = max(unitfak_2*permfak*porofak*SAT.Kdfull(SAT.Sdfull==max(SAT.Sdfull)));
end
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kdfull.*permfak,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(2));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Kifull.*permfak,'Color',colimb,...
            'LineStyle','--','DisplayName','imb','Parent',gui.ax(2));
    otherwise
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kdfull.*permfak,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(2));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Kifull.*permfak,'Color',colimb,...
            'DisplayName','imb','Parent',gui.ax(2));
end
ymin = min([unitfak_2*porofak*SAT.Kdfull.*permfak;unitfak_2*porofak*SAT.Kifull.*permfak]);
ymax = max([unitfak_2*porofak*SAT.Kdfull.*permfak;unitfak_2*porofak*SAT.Kifull.*permfak]);
ymin = 10^floor(log10(ymin));
ymax = 10^ceil(log10(ymax));
set(gui.ax(2),'YLim',[ymin ymax]);
lgh = legend(gui.ax(2),'Location','SouthEast');
set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);

% pc - rel
rel1 = SAT.Kdfull/SAT.Kdfull(find(SAT.Sdfull<tolKrel,1));
rel2 = SAT.Kifull/SAT.Kifull(find(SAT.Sifull<tolKrel,1));
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,rel1,'Color',coldrain,'DisplayName','drain','Parent',gui.ax(3));
        plot(SAT.Sifull,rel2,'Color',colimb,'DisplayName','imb','LineStyle','--','Parent',gui.ax(3));
    otherwise
        plot(SAT.Sdfull,rel1,'Color',coldrain,'DisplayName','drain','Parent',gui.ax(3));
        plot(SAT.Sifull,rel2,'Color',colimb,'DisplayName','imb','Parent',gui.ax(3));
end
ymin = min([rel1; rel2]);
ymin = 10^floor(log10(ymin));
set(gui.ax(3),'YLim',[ymin 1]);
lgh = legend(gui.ax(3),'Location','SouthEast');
set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);

% eff - cond
KSeff = max(unitfak_1*porofak*SAT.Kd_eff(SAT.Sdfull==1));
if isempty(KSeff)
    KSeff = max(unitfak_1*porofak*SAT.Kd_eff(SAT.Sdfull==max(SAT.Sdfull)));
end
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kd_eff,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(4));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Ki_eff,'Color',colimb,...
            'DisplayName','imb','LineStyle','--','Parent',gui.ax(4));
        lgh = legend(gui.ax(4),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
    otherwise
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kd_ducts,'Color',coldrain,'LineStyle','--',...
            'DisplayName','ducts','Parent',gui.ax(4));
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kd_corners,'Color',coldrain,'LineStyle',':',...
            'DisplayName','corners','Parent',gui.ax(4));
        plot(SAT.Sdfull,unitfak_1*porofak*SAT.Kd_eff,'Color',coldrain,...
            'DisplayName','sum','Parent',gui.ax(4));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Ki_ducts,'Color',colimb,'LineStyle','--',...
            'DisplayName','ducts','Parent',gui.ax(4));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Ki_corners,'Color',colimb,'LineStyle',':',...
            'DisplayName','corners','Parent',gui.ax(4));
        plot(SAT.Sifull,unitfak_1*porofak*SAT.Ki_eff,'Color',colimb,...
            'DisplayName','sum','Parent',gui.ax(4));
        lgh = legend(gui.ax(4),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
        lgh.NumColumns = 2;
        lgh.Title.String = 'drain             imb';
end
ymin = min([unitfak_1*porofak*SAT.Kd_eff';unitfak_1*porofak*SAT.Ki_eff']);
ymax = max([unitfak_1*porofak*SAT.Kd_eff';unitfak_1*porofak*SAT.Ki_eff']);
ymin = 10^floor(log10(ymin));
ymax = 10^ceil(log10(ymax));
set(gui.ax(4),'YLim',[ymin ymax]);


% eff - perm
kSeff = max(unitfak_2*permfak*porofak*SAT.Kd_eff(SAT.Sdfull==1));
if isempty(kSeff)
    kSeff = max(unitfak_2*permfak*porofak*SAT.Kd_eff(SAT.Sdfull==max(SAT.Sdfull)));
end
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kd_eff.*permfak,'Color',coldrain,...
            'DisplayName','drain','Parent',gui.ax(5));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Ki_eff.*permfak,'Color',colimb,...
            'DisplayName','imb','LineStyle','--','Parent',gui.ax(5));
        lgh = legend(gui.ax(5),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
    otherwise
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kd_ducts.*permfak,'Color',coldrain,'LineStyle','--',...
            'DisplayName','ducts','Parent',gui.ax(5));
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kd_corners.*permfak,'Color',coldrain,'LineStyle',':',...
            'DisplayName','corners','Parent',gui.ax(5));
        plot(SAT.Sdfull,unitfak_2*porofak*SAT.Kd_eff.*permfak,'Color',coldrain,...
            'DisplayName','sum','Parent',gui.ax(5));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Ki_ducts.*permfak,'Color',colimb,'LineStyle','--',...
            'DisplayName','ducts','Parent',gui.ax(5));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Ki_corners.*permfak,'Color',colimb,'LineStyle',':',...
            'DisplayName','corners','Parent',gui.ax(5));
        plot(SAT.Sifull,unitfak_2*porofak*SAT.Ki_eff.*permfak,'Color',colimb,...
            'DisplayName','sum','Parent',gui.ax(5));
        lgh = legend(gui.ax(5),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
        lgh.NumColumns = 2;
        lgh.Title.String = 'drain             imb';
end
ymin = min([unitfak_2*porofak*SAT.Kd_eff'.*permfak;unitfak_2*porofak*SAT.Ki_eff'.*permfak]);
ymax = max([unitfak_2*porofak*SAT.Kd_eff'.*permfak;unitfak_2*porofak*SAT.Ki_eff'.*permfak]);
ymin = 10^floor(log10(ymin));
ymax = 10^ceil(log10(ymax));
set(gui.ax(5),'YLim',[ymin ymax]);

% eff - rel
rel1 = SAT.Kd_eff/SAT.Kd_eff(find(SAT.Sdfull<tolKrel,1));
rel2 = SAT.Ki_eff/SAT.Ki_eff(find(SAT.Sifull<tolKrel,1));
switch data.geom_type
    case 'cyl'
        plot(SAT.Sdfull,rel1,'Color',coldrain,'DisplayName','drain',...
            'Parent',gui.ax(6));
        plot(SAT.Sifull,rel2,'Color',colimb,'DisplayName','imb',...
            'LineStyle','--','Parent',gui.ax(6));
        lgh = legend(gui.ax(6),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
    otherwise
        plot(SAT.Sdfull,SAT.Kd_ducts/SAT.Kd_eff(find(SAT.Sdfull<tolKrel,1)),...
            'Color',coldrain,'LineStyle','--','DisplayName','ducts','Parent',gui.ax(6));
        plot(SAT.Sdfull,SAT.Kd_corners/SAT.Kd_eff(find(SAT.Sdfull<tolKrel,1)),...
            'Color',coldrain,'LineStyle',':','DisplayName','corners','Parent',gui.ax(6));
        plot(SAT.Sdfull,rel1,'Color',coldrain,'DisplayName','sum','Parent',gui.ax(6));
        plot(SAT.Sifull,SAT.Ki_ducts/SAT.Ki_eff(find(SAT.Sifull<tolKrel,1)),...
            'Color',colimb,'LineStyle','--','DisplayName','ducts','Parent',gui.ax(6));
        plot(SAT.Sifull,SAT.Ki_corners/SAT.Ki_eff(find(SAT.Sifull<tolKrel,1)),...
            'Color',colimb,'LineStyle',':','DisplayName','corners','Parent',gui.ax(6));
        plot(SAT.Sifull,rel2,'Color',colimb,'DisplayName','sum','Parent',gui.ax(6));
        lgh = legend(gui.ax(6),'Location','SouthEast');
        set(lgh,'TextColor',colors.panelFG,'Color',colors.axisBG);
        lgh.NumColumns = 2;
        lgh.Title.String = 'drain             imb';
end
ymin = min([rel1(rel1>0)'; rel2(rel2>0)']);
ymin = 10^floor(log10(ymin));
set(gui.ax(6),'YLim',[ymin 1]);

% general axes settingd
set(gui.ax,'YScale','log','XLim',[0 1]);
for i = 1:6
    grid(gui.ax(i),'on');
    hold(gui.ax(i),'off');
    set(get(gui.ax(i),'XLabel'),'String','saturation [-]');
end

% set the individual axes titles with the full saturated values for "K" / "k"
col = get(gui.ax(1),'XColor');
set(get(gui.ax(1),'Title'),'String',['K(S=1) = ',sprintf('%1.2e',KSpc),' ',unitstr_1],...
    'Color',col);
set(get(gui.ax(2),'Title'),'String',['k(S=1) = ',sprintf('%1.2e',kSpc),' ',unitstr_2],...
    'Color',col);
set(get(gui.ax(4),'Title'),'String',['K(S=1) = ',sprintf('%1.2e',KSeff),' ',unitstr_1],...
    'Color',col);
set(get(gui.ax(5),'Title'),'String',['k(S=1) = ',sprintf('%1.2e',kSeff),' ',unitstr_2],...
    'Color',col);

% some special axes settings
for i = 1:3
    % adjust the y-limits for similar axes
    ylim1 = get(gui.ax(i),'YLim');
    ylim2 = get(gui.ax(i+3),'YLim');
    
    if ylim1(1) == 0
        ylim1(1) = ylim2(1);
    end
    if ylim2(1) == 0
        ylim2(1) = ylim1(1);
    end
    
    if i<3
        set(gui.ax(i),'YLim',[min([ylim1(1) ylim2(1)]) max([ylim1(2) ylim2(2)])]);
        set(gui.ax(i+3),'YLim',[min([ylim1(1) ylim2(1)]) max([ylim1(2) ylim2(2)])]);
    else
        set(gui.ax(i),'YLim',[min([ylim1(1) ylim2(1)]) 1]);
        set(gui.ax(i+3),'YLim',[min([ylim1(1) ylim2(1)]) 1]);
    end
    
    % axes labels
    if i == 1
        set(get(gui.ax(i),'YLabel'),'String',ylstr_1);
        set(get(gui.ax(i+3),'YLabel'),'String',ylstr_1);
    elseif i == 2
        set(get(gui.ax(i),'YLabel'),'String',ylstr_2);
        set(get(gui.ax(i+3),'YLabel'),'String',ylstr_2);
    else
        set(get(gui.ax(i),'YLabel'),'String','relative cond. / perm. [-]');
        set(get(gui.ax(i+3),'YLabel'),'String','relative cond. / perm. [-]');
    end
end

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