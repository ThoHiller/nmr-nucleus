function importINV2INV(src)
%importINV2INV imports a previously saved NUCLEUSinv session
%back into the GUI
%
% Syntax:
%       importINV2INV(src)
%
% Inputs:
%       src - handle to the calling uimenu
%
% Outputs:
%       none
%
% Example:
%       importINV2INV(src)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%       updatePlotsSignal
%       updatePlotsDistribution
%       updatePlotsLcurve
%
% Subfunctions:
%       none
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
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get the file name
Sessionpath = -1;
Sessionfile = -1;
% if there is already a data folder present start from there
if isfield(data.import,'path')
    [Sessionfile,Sessionpath] = uigetfile(data.import.path,...
        'Choose NUCLEUSinv session file');
else
    % otherwise start at the current working directory
    % 'pathstr' hold s the name of the chosen data path
    here = mfilename('fullpath');
    [pathstr,~,~] = fileparts(here);
    [Sessionfile,Sessionpath] = uigetfile(pathstr,...
        'Choose NUCLEUSinv session file');
end

% only continue if user didn't cancel
if sum(Sessionpath) > 0
    % display info text
    displayStatusText(gui,'Importing GUI session from mat-file ...');
    
    % check if it is a valid session file
    tmp = load(fullfile(Sessionpath,Sessionfile),'savedata');
    if isfield(tmp,'savedata') && isfield(tmp.savedata,'data') && ...
            isfield(tmp.savedata,'id') && isfield(tmp.savedata,'INVdata')
        savedata = tmp.savedata;
        
        % check import uimenu
        set(src,'Checked','on');
        
        % backward compatibility with older versions
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... backward compatibility.');
        % current GUI version
        version = getVersionNoFromString(gui.myui.version);
        % import GUI version
        version_in = getVersionNoFromString(savedata.myui.version);
        if version_in < version
            if version_in < 19 % changes introduced with v.0.1.9
                % rename 'ILA' to 'LU' in savedata
                if strcmp(savedata.data.invstd.invtype,'ILA')
                    savedata.data.invstd.invtype = 'LU';                    
                end
                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i}) && ...
                            strcmp(savedata.INVdata{i}.invstd.invtype,'ILA')
                        savedata.INVdata{i}.invstd.invtype = 'LU';
                    end
                end
            end
            if version_in < 112 % changes introduced with v.0.1.12
                % add 'Tdiff' field to savedata
                savedata.data.invstd.Tdiff = data.invstd.Tdiff;
                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i})
                        savedata.INVdata{i}.invstd.Tdiff = data.invstd.Tdiff;
                    end
                end
            end
        end
        
        % update GUI data from session mat-file
        data = savedata.data;
        INVdata = savedata.INVdata;
        
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... update GUI data.');
        % check if the import path exists on this machine
        isdir_import = dir(data.import.path);
        % if not replace it with the path the session-file was loaded from
        if isempty(isdir_import)
            data.import.path = Sessionpath;
        end
        % update the path info field with "path" ("file")
        if data.import.file > 0
            tmpstr = fullfile(data.import.path,data.import.file);
        else
            tmpstr = data.import.path;
        end
        % update GUI data
        setappdata(fig,'data',data);
        setappdata(fig,'gui',gui);
        setappdata(fig,'INVdata',INVdata);        
        
        % update the ini-file
        gui.myui.inidata.importpath = data.import.path;
        gui = makeINIfile(gui,'update');
        setappdata(fig,'gui',gui);
        
        if length(tmpstr)>50
            set(gui.text_handles.data_path,'String',['...',tmpstr(end-50:end)],...
                'HorizontalAlignment','left');
        else
            set(gui.text_handles.data_path,'String',tmpstr,...
                'HorizontalAlignment','left');
        end
        set(gui.text_handles.data_path,'TooltipString',tmpstr);
        
        % update the list of file names
        set(gui.listbox_handles.signal,'String',data.import.NMR.filesShort);
        set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
        
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... update GUI interface.');
        % update GUI interface
        NUCLEUSinv_updateInterface;
        
        % color the file names where there is an inversion set
        for id = 1:size(INVdata,1)
            if isstruct(INVdata{id})
                strL = get(gui.listbox_handles.signal,'String');
                str1 = strL{id};
                str2 = ['<HTML><BODY bgcolor="rgb(',...
                    sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',...
                    str1,'</BODY></HTML>'];
                strL{id} = str2;
                set(gui.listbox_handles.signal,'String',strL);
            end
        end
        
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... update GUI menus.');
        % adjust menu entry for expert mode
        switch savedata.data.info.ExpertMode
            case 'on'
                set(gui.menu.extra_expert,'Checked','off');
            case 'off'
                set(gui.menu.extra_expert,'Checked','on');
        end
        onMenuExpert(gui.menu.extra_expert);
        
        % adjust menu entry for joint inversion
        switch savedata.data.info.JointInv
            case 'on'
                set(gui.menu.extra_joint,'Checked','off');
            case 'off'
                set(gui.menu.extra_joint,'Checked','on');
        end
        onMenuJointInversion(gui.menu.extra_joint);
        enableGUIelements('NMR');
        
        % adjust menu entry for comand line inversion info
        switch savedata.data.info.InvInfo
            case 'on'
                set(gui.menu.view_invinfo,'Checked','off');
            case 'off'
                set(gui.menu.view_invinfo,'Checked','on');
        end
        onMenuView(gui.menu.view_invinfo);
        
        % adjust menu entry for tool tips
        switch savedata.data.info.ToolTips
            case 'on'
                set(gui.menu.view_tooltips,'Checked','off');
            case 'off'
                set(gui.menu.view_tooltips,'Checked','on');
        end
        onMenuView(gui.menu.view_tooltips);
        
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... show last file.');
        % set focus on last file used in previous session
        set(gui.listbox_handles.signal,'Value',savedata.id);
        % and simulate click to update all relevant GUI elements
        onListboxData(gui.listbox_handles.signal);
        
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... done.');        
    else
        % display info text
        displayStatusText(gui,'Importing GUI session from mat-file ... cancelled.');
        
        helpdlg({'importINV2INV:';...
            'This seems to be not a valid NUCLEUSinv session file'},...
            'No session data found');
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