function onMenuView(src,~)
%onMenuView handles the view menu entries
%
% Syntax:
%       onMenuView
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuView(src,~)
%
% Other m-files required:
%       onPushShowHide
%       updateStatusInformation
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
% get its unique tag
fig_tag = get(fig,'Tag');

gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% parent = get(src,'Parent');
label = get(src,'Label');
onoff = lower(get(src,'Checked'));

switch fig_tag

    case 'INV'
        switch label
            case 'Tooltips'
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_tooltips,'Checked','off');
                        switchToolTips(gui,'off');
                        data.info.ToolTips = 'off';
                    case 'off'
                        set(gui.menu.view_tooltips,'Checked','on');
                        switchToolTips(gui,'on');
                        data.info.ToolTips = 'on';
                end
                % update ini-file
                gui.myui.inidata.tooltips = data.info.ToolTips;
                gui = makeINIfile(gui,'update');

            case 'Figure Toolbar' % switch on/off the default Figure Toolbar
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_toolbar,'Checked','off');
                        viewmenufcn('FigureToolbar');
                    case 'off'
                        set(gui.menu.view_toolbar,'Checked','on');
                        viewmenufcn('FigureToolbar');
                end

            case 'INFO fields'
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.push_handles.info,'String','>');
                    case 'off'
                        set(gui.push_handles.info,'String','<');
                end
                onPushShowHide(gui.push_handles.info);

            case 'CLI Inv. Info'
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_invinfo,'Checked','off');
                        data.info.InvInfo = 'off';
                    case 'off'
                        set(gui.menu.view_invinfo,'Checked','on');
                        data.info.InvInfo = 'on';
                end
                % update ini-file
                gui.myui.inidata.invinfo = data.info.InvInfo;
                gui = makeINIfile(gui,'update');
        end

    case {'2DINV','PHASEVIEW','UNCERTVIEW','CONDUCT'}
        switch label
            case 'Figure Toolbar' % switch on/off the default Figure Toolbar
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_toolbar,'Checked','off');
                        viewmenufcn('FigureToolbar');
                    case 'off'
                        set(gui.menu.view_toolbar,'Checked','on');
                        viewmenufcn('FigureToolbar');
                end
        end

    case 'MOD'
        switch label
            case 'Tooltips'
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_tooltips,'Checked','off');
                        switchToolTips(gui,'off');
                        data.info.ToolTips = 'off';
                    case 'off'
                        set(gui.menu.view_tooltips,'Checked','on');
                        switchToolTips(gui,'on');
                        data.info.ToolTips = 'on';
                end
            case 'Figure Toolbar'
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_toolbar,'Checked','off');
                        viewmenufcn('FigureToolbar');
                    case 'off'
                        set(gui.menu.view_toolbar,'Checked','on');
                        viewmenufcn('FigureToolbar');
                end
        end
    case '2DMOD'
        switch label
            case 'Figure Toolbar' % switch on/off the default Figure Toolbar
                switch onoff
                    case 'on' % it it's on, switch it off
                        set(gui.menu.view_toolbar,'Checked','off');
                        viewmenufcn('FigureToolbar');
                    case 'off'
                        set(gui.menu.view_toolbar,'Checked','on');
                        viewmenufcn('FigureToolbar');
                end
        end
end

% update GUI data
setappdata(fig,'gui',gui);
setappdata(fig,'data',data);
% update status bar
updateStatusInformation(fig);


end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2020 Thomas Hiller
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