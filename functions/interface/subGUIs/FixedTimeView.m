function FixedTimeView(src,~)
%FixedTimeView is an extra subGUI to fix certain relaxation times during
%the free inversion with #1-5 free relaxation times; thus only the
%amplitude gets fitted
%
% Syntax:
%       FixedTimeView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       FixedTimeView(src,~)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       ft_closeme
%       ft_updateChecked
%       ft_updateEdit
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
colors = nucleus.gui.myui.colors;

%% proceed if the correct inversion type is chosen
if strcmp(nucleus.data.invstd.invtype,'mono') || strcmp(nucleus.data.invstd.invtype,'free')

    % check if the figure is already open
    fig_fixedtime = findobj('Tag','FIXEDTIMEVIEW');
    % if not, create it
    if isempty(fig_fixedtime)
        % draw the figure on top of NUCLEUSinv
        fig_fixedtime = figure('Name','NUCLEUSinv - Fix Relaxation Time',...
            'NumberTitle','off','Resize','on','ToolBar','none',...
            'CloseRequestFcn',@ft_closeme,...
            'MenuBar','none','Tag','FIXEDTIMEVIEW');
        pos0 = get(figh_nucleus,'Position');
        cent(1) = (pos0(1)+pos0(3)/2);
        cent(2) = (pos0(2)+pos0(4)/2);
        posf = [cent(1)-pos0(3)/6 pos0(2)+pos0(4)-pos0(4)/5 pos0(3)/3 pos0(4)/5];
%         posf = [cent(1)-pos0(3)/6 pos0(2)+pos0(4)-140 350 145];
        set(fig_fixedtime,'Position',posf);

        % create the main layout
        gui.main = uix.VBox('Parent',fig_fixedtime,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5);
        gui.row1 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % check boxes
        gui.row2 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % edit fields
        gui.row3 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % text fields
        set(gui.main,'Heights',[-1 -1 -1]);

        % horizontal boxes
        gui.hbox1 = uix.HBox('Parent',gui.row1,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5); % control elements
        gui.hbox2 = uix.HBox('Parent',gui.row2,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5); % control elements
        gui.hbox3 = uix.HBox('Parent',gui.row3,'BackGroundColor',colors.panelBG,'Spacing',5,'Padding',5); % text

        % create the ui elements inside the horizontal boxes
        for i = 1:5
            % check boxes
            gui.check(i).fixed = uicontrol('Parent',gui.hbox1,...
                'Style','checkbox','FontSize',nucleus.gui.myui.fontsize,'Tag',num2str(i),...
                'Value',nucleus.data.invstd.Tfixed_bool(i),'String','fix it',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
                'Callback',@ft_updateChecked);
            jh = findjobj(gui.check(i).fixed);
            jh.setHorizontalAlignment(javax.swing.JLabel.CENTER);

            % edit fields
            gui.edit(i).fixed = uicontrol('Parent',gui.hbox2,...
                'Style','edit','FontSize',nucleus.gui.myui.fontsize,'Tag',num2str(i),...
                'String',sprintf('%6.4f',nucleus.data.invstd.Tfixed_val(i)),...
                'BackGroundColor',colors.editBG,'ForeGroundColor',colors.panelFG,...
                'Callback',@ft_updateEdit);

            % text fields
            gui.text(i).fixed = uicontrol('Parent',gui.hbox3,...
                'Style','text','FontSize',nucleus.gui.myui.fontsize,'Tag',['text',num2str(i)],...
                'HorizontalAlignment','center',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG,...
                'String',['#',num2str(i)]);
        end

        % store main GUI settings
        gui.myui = nucleus.gui.myui;
        gui.figh_nucleus = figh_nucleus;

        % save to GUI
        setappdata(fig_fixedtime,'gui',gui);
    end

    % if the figure is already open load the GUI data
    gui = getappdata(fig_fixedtime,'gui');
    
    % update all edit fields and check boxes
    for i = 1:5
        set(gui.edit(i).fixed,'String',sprintf('%6.4f',nucleus.data.invstd.Tfixed_val(i)));
        set(gui.check(i).fixed,'Value',nucleus.data.invstd.Tfixed_bool(i))

        % enable only the needed ones
        if i <=nucleus.data.invstd.freeDT
            set(gui.check(i).fixed,'Enable','on');
            set(gui.edit(i).fixed,'Enable','on');
        else
            set(gui.check(i).fixed,'Enable','off');
            set(gui.edit(i).fixed,'Enable','off');
        end
    end
else
    % check if the figure is already open
    fig_fixedtime = findobj('Tag','FIXEDTIMEVIEW');
    if ~isempty(fig_fixedtime)
        ft_closeme(fig_fixedtime)
    else
        helpdlg({'function: FixedTimeView',...
            'Cannot continue because wrong inversion method!'},...
            'Wrong inversion method.');
    end
end

end

% subfunction to update the check boxes
function ft_updateChecked(src,~)
fig_fixedtime = ancestor(src,'figure','toplevel');
gui = getappdata(fig_fixedtime,'gui');
data = getappdata(gui.figh_nucleus,'data');

id = str2double(get(src,'Tag'));
value = get(src,'Value');

data.invstd.Tfixed_bool(id) = value;

% update local GUI
setappdata(fig_fixedtime,'gui',gui);

% update NUCLEUSinv
setappdata(gui.figh_nucleus,'data',data);
end

% subfunction to update the edit fields
function ft_updateEdit(src,~)
fig_fixedtime = ancestor(src,'figure','toplevel');
gui = getappdata(fig_fixedtime,'gui');
data = getappdata(gui.figh_nucleus,'data');

id = str2double(get(src,'Tag'));
value = str2double(get(src,'String'));

data.invstd.Tfixed_val(id) = value;

% update local GUI
setappdata(fig_fixedtime,'gui',gui);

% update NUCLEUSinv
setappdata(gui.figh_nucleus,'data',data);
end

% subfunction to update the edit fields
function ft_closeme(src,~)
fig_fixedtime = ancestor(src,'figure','toplevel');
% try to close the sub GUI in a clean manner
try
    gui = getappdata(fig_fixedtime,'gui');
    data = getappdata(gui.figh_nucleus,'data');
    % reset ui controls
    data.invstd.Tfixed_bool = zeros(1,5);
    data.invstd.Tfixed_val = zeros(1,5);

    % update NUCLEUSinv
    setappdata(gui.figh_nucleus,'data',data);
    delete(fig_fixedtime);
catch
    % if this is not working: just close it
    delete(fig_fixedtime);
end


end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2023 Thomas Hiller
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