function onMenuJointInversion(src,~)
%onMenuJointInversion handles the call from the menu that activates / deactivates
%the joint inversion panels
%
% Syntax:
%       onMenuJointInversion
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuJointInversion(src,~)
%
% Other m-files required:
%       clearSingleAxis
%       fixAxes
%       NUCLEUSinv_updateInterface
%       onFigureSizeChange
%       updateInfo
%       updatePlotsSignal
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
% panel heights
heights = gui.myui.heights;

% check the status of the settings panels
isminProc = get(gui.panels.process.main,'Minimized');
if isminProc
    hProc = heights(1,2);
else
    hProc = heights(2,2);
end
isminPetro = get(gui.panels.petro.main,'Minimized');
if isminPetro
    hPetro = heights(1,3);
else
    hPetro = heights(2,3);
end
isminStdInv = get(gui.panels.invstd.main,'Minimized');
if isminStdInv
    hStdInv = heights(1,4);
else
    hStdInv = heights(2,4);
end

% deactivate or activate joint inversion
switch onoff    
    case 'on' % it it's on, switch it off
        data.info.JointInv = 'off';
        
        % remove data
        nINV = size(INVdata,1);
        for i = 1:nINV
            if isstruct(INVdata{i})
                if isfield(INVdata{i}.results,'invjoint')
                    INVdata{i}.results = rmfield(INVdata{i}.results,'invjoint');
                end
            end
        end
        
        if isfield(data,'results')
            if isfield(data.results,'invjoint')
                data.results = rmfield(data.results,'invjoint');
            end
        end
        
        % clear axes
        clearSingleAxis(gui.axes_handles.all);
        clearSingleAxis(gui.axes_handles.psdj);
        clearSingleAxis(gui.axes_handles.cps);
        
        % menu entries
        set(gui.menu.extra_joint,'Checked','off');
        set(gui.menu.extra_joint_rhobounds,'Enable','off');
        set(gui.menu.file_export_data_invjoint_mat,'Enable','off');        
        
        % settings panel
        set(gui.popup_handles.invjoint_InvType,'Enable','off');
        set(gui.popup_handles.invjoint_geometry_type,'Enable','off');
        set(gui.push_handles.invjoint_run,'Enable','off');
        
        % cps panel
        set(gui.popup_handles.invjoint_pressure_units,'Enable','off');
        set(gui.push_handles.invjoint_Add,'Enable','off');
        set(gui.push_handles.invjoint_Delete,'Enable','off');
        set(gui.push_handles.invjoint_Load,'Enable','off');
        set(gui.table_handles.invjoint_table,'Enable','off');
        
        % minimize panels
        set(gui.panels.main,'Heights',[-1 hProc hPetro hStdInv 22]);
        set(gui.panels.invjoint.main,'Minimized',true);
        set(gui.center,'Heights',[-1 -1 22]);
        set(gui.plots.CPSPanel,'Minimized',true);
        
        % deactivate tabs
        gui.plots.SignalPanel.TabEnables = {'on','on','off'};
        gui.plots.DistPanel.TabEnables = {'on','on','off'};
        
        % set focus on std panels
        set(gui.plots.SignalPanel,'Selection',1);
        set(gui.plots.DistPanel,'Selection',1);
        
        % minimize CPS info field
        set(gui.panels.info.main,'Heights',[-1 -1 0]);                    
        
    case 'off' % it it's off, switch it on
        data.info.JointInv = 'on';
        
        % menu entries
        set(gui.menu.extra_joint,'Checked','on');
        set(gui.menu.extra_joint_rhobounds,'Enable','on');
        set(gui.menu.file_export_data_invjoint_mat,'Enable','on');
        
        % settings panel
        set(gui.popup_handles.invjoint_InvType,'Enable','on');
        set(gui.popup_handles.invjoint_geometry_type,'Enable','on');
        set(gui.push_handles.invjoint_run,'Enable','on');
        % choose default inversion method
        switch data.info.has_optim
            case 'on'
                data.invjoint.invtype = 'free';
            case 'off'
                data.invjoint.invtype = 'fixed';
        end
        
        % cps panel
        set(gui.popup_handles.invjoint_pressure_units,'Enable','on');
        set(gui.push_handles.invjoint_Add,'Enable','on');
        set(gui.push_handles.invjoint_Delete,'Enable','on');
        set(gui.push_handles.invjoint_Load,'Enable','on');
        set(gui.table_handles.invjoint_table,'Enable','on');
        
        % maximize panels
        set(gui.panels.main,'Heights',[-1 hProc hPetro hStdInv heights(2,5)]);
        set(gui.panels.invjoint.main,'Minimized',false);
        set(gui.center,'Heights',[-1 -1 -1]);
        set(gui.plots.CPSPanel,'Minimized',false);
        
        % activate tabs
        gui.plots.SignalPanel.TabEnables = {'on','on','on'};
        gui.plots.DistPanel.TabEnables = {'on','on','on'};
        
        % set focus on joint panels
        set(gui.plots.SignalPanel,'Selection',3);
        set(gui.plots.DistPanel,'Selection',3);
        % only update the plots if there is anything
        if isfield(data,'results')
            setappdata(fig,'data',data);
            updatePlotsSignal;
        end
        
        % maximize CPS info field
        set(gui.panels.info.main,'Heights',[-1 -1 -1]);
        setappdata(fig,'data',data);
        updateInfo(gui.plots.SignalPanel);
        fixAxes(gui.plots.CPSPanel);
end

setappdata(fig,'data',data);
setappdata(fig,'gui',gui);
NUCLEUSinv_updateInterface;
updateStatusInformation(fig);
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