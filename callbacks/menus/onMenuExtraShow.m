function onMenuExtraShow(src,~)
%onMenuExtraShow handles the extra menu entries to show additional
%information on the prompt or inside the GUI
%
% Syntax:
%       onMenuExtraShow
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraShow(src,~)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
% get its unique tag
fig_tag = get(fig,'Tag');

gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

parent = get(src,'Parent');
label = get(parent,'Label');
onoff = get(src,'Label');

switch fig_tag
    case 'INV'
        switch label
            case 'Inversion Display'
                switch onoff
                    case 'On'
                        set(gui.menu.extra_settings_invinfo_on,'Checked','on');
                        set(gui.menu.extra_settings_invinfo_off,'Checked','off');
                        data.info.InvInfo = 'on';
                        
                    case 'Off'
                        set(gui.menu.extra_settings_invinfo_on,'Checked','off');
                        set(gui.menu.extra_settings_invinfo_off,'Checked','on');
                        data.info.InvInfo = 'off';
                end
                % update ini-file
                gui.myui.inidata.invinfo = data.info.InvInfo;
                gui = makeINIfile(gui,'update');
                
            case 'Tooltips'
                switchToolTips(gui,onoff);
                switch onoff
                    case 'On'
                        set(gui.menu.extra_settings_tooltips_on,'Checked','on');
                        set(gui.menu.extra_settings_tooltips_off,'Checked','off');
                        data.info.ToolTips = 'on';
                        
                    case 'Off'
                        set(gui.menu.extra_settings_tooltips_on,'Checked','off');
                        set(gui.menu.extra_settings_tooltips_off,'Checked','on');
                        data.info.ToolTips = 'off';
                end
                % update ini-file
                gui.myui.inidata.tooltips = data.info.ToolTips;
                gui = makeINIfile(gui,'update');
                
            case 'INFO fields'
                switch onoff
                    case 'On'
                        set(gui.menu.extra_settings_infofields_on,'Checked','on');
                        set(gui.menu.extra_settings_infofields_off,'Checked','off');
                        set(gui.push_handles.info,'String','<');
                        
                    case 'Off'
                        set(gui.menu.extra_settings_infofields_on,'Checked','off');
                        set(gui.menu.extra_settings_infofields_off,'Checked','on');
                        set(gui.push_handles.info,'String','>');
                end
                onPushShowHide(gui.push_handles.info);
            case 'Figures'
                switch onoff
                    case 'Parameter Info'
                        showParameterInfo;
                end
        end
        
    case 'MOD'
        switch label
            case 'Tooltips'
                h = {'popup_handles','edit_handles','push_handles',...
                    'table_handles'};
                
                switch onoff
                    case 'On'
                        for i = 1:numel(h)
                            eval(['fnames = fieldnames(gui.',h{i},');']);
                            for j = 1:numel(fnames)
                                eval(['ud = get(gui.',h{i},'.',fnames{j},...
                                    ',''UserData'');']);
                                if isfield(ud,'Tooltipstr')
                                    tstr = ud.Tooltipstr;
                                    eval(['set(gui.',h{i},'.',fnames{j},...
                                        ',''ToolTipString'',tstr);']);
                                end
                            end
                        end
                        set(gui.menu.extra_show_tooltips_on,'Checked','on');
                        set(gui.menu.extra_show_tooltips_off,'Checked','off');
                        
                    case 'Off'
                        for i = 1:numel(h)
                            eval(['fnames = fieldnames(gui.',h{i},');']);
                            for j = 1:numel(fnames)
                                eval(['ud = get(gui.',h{i},'.',fnames{j},...
                                    ',''UserData'');']);
                                if isfield(ud,'Tooltipstr')
                                    tstr = ud.Tooltipstr;
                                    eval(['set(gui.',h{i},'.',fnames{j},...
                                        ',''ToolTipString'','''');']);
                                end
                            end
                        end
                        set(gui.menu.extra_show_tooltips_on,'Checked','off');
                        set(gui.menu.extra_show_tooltips_off,'Checked','on')
                end
                
            otherwise
                % nothing to do
        end        
end

setappdata(fig,'gui',gui);
setappdata(fig,'data',data);
switch fig_tag
    case 'INV'
        updateStatusInformation;
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