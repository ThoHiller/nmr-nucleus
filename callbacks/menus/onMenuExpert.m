function onMenuExpert(src,~)
%onMenuExpert handles the call from the menu that activates / deactivates
%the expert mode functionality of the NUCLEUSinv GUI
%In "expert mode" joint inversion cannot be activated, the choice of
%inversion methods is limited and several other parameter cannot be
%set/used
%
% Syntax:
%       onMenuExpert
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExpert(src,~)
%
% Other m-files required:
%       makeINIfile
%       NUCLEUSinv_updateInterface
%       onFigureSizeChange
%       onMenuJointInversion
%       updateStatusInformation
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

% on / off switch
onoff = get(src,'Checked');

% deactivate or activate expert mode
switch onoff
    case 'on' % it it's on, switch it off
        data.info.ExpertMode = 'off';
        % menu entry
        set(gui.menu.extra_expert,'Checked','off');
        % update GUI data
        setappdata(fig,'data',data);
        setappdata(fig,'gui',gui);
        
        % deactivate solver menu and set to default
        onMenuSolver(gui.menu.extra_solver_lsqnonneg);
        % get changed GUI data
        data = getappdata(fig,'data');
        set(gui.menu.extra_solver,'Enable','off');        

        % update GUI data
        setappdata(fig,'data',data);
        setappdata(fig,'gui',gui);
        
        % deactivate joint inversion panels
        set(gui.menu.extra_joint,'Checked','on');
        onMenuJointInversion(gui.menu.extra_joint);
        % get changed GUI data
        data = getappdata(fig,'data');
        INVdata = getappdata(fig,'INVdata');
        % default std inversion settings
        data.invstd.invtype = 'NNLS';
        data.invstd.regtype = 'manual';
        data.invstd.lambda = 1;        
        % deactivate joint inversion menu
        set(gui.menu.extra_joint,'Enable','off');
        
        set(gui.menu.extra_graphics_amp,'Enable','off');
        set(gui.menu.extra_graphics_amp2,'Enable','off');
        set(gui.menu.extra_graphics_rtd,'Enable','off');
        
    case 'off' % it it's off, switch it on
        data.info.ExpertMode = 'on';
        % menu entry
        set(gui.menu.extra_expert,'Checked','on');
        
        % activate solver menu if optimization toolbox is available
        switch data.info.has_optim
            case 'on'
                set(gui.menu.extra_solver,'Enable','on');
            case 'off'
                set(gui.menu.extra_solver,'Enable','off');
        end
        
        % activate joint inversion menu
        set(gui.menu.extra_joint,'Enable','on');
        
        set(gui.menu.extra_graphics_amp,'Enable','on');
        set(gui.menu.extra_graphics_amp2,'Enable','on');
        set(gui.menu.extra_graphics_rtd,'Enable','on');
end

% update GUI data
setappdata(fig,'data',data);
setappdata(fig,'gui',gui);
% update ini-file
gui.myui.inidata.expertmode = data.info.ExpertMode;
gui = makeINIfile(gui,'update');
% update interface
NUCLEUSinv_updateInterface;
% update status information
updateStatusInformation(fig);
updateToolTips;
onFigureSizeChange(fig);

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