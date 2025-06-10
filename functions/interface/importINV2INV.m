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
data0 = data;

% get the file name
% Sessionpath = -1;
% Sessionfile = -1;
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
            if version_in < 114 % changes introduced with v.0.1.14
                % add 'Tfixed_bool' & 'Tfixed_val' field to savedata
                savedata.data.invstd.Tfixed_bool = data.invstd.Tfixed_bool;
                savedata.data.invstd.Tfixed_val = data.invstd.Tfixed_val;
                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i})
                        if strcmp(savedata.INVdata{i}.invstd.invtype,'mono') || ....
                                strcmp(savedata.INVdata{i}.invstd.invtype,'free')
                            switch savedata.INVdata{i}.results.nmrproc.T1T2
                                case 'T1'
                                    savedata.INVdata{i}.results.invstd.T = ...
                                        savedata.INVdata{i}.results.invstd.T1;
                                case 'T2'
                                    savedata.INVdata{i}.results.invstd.T = ...
                                        savedata.INVdata{i}.results.invstd.T2;
                            end
                        end
                        savedata.INVdata{i}.invstd.Tfixed_bool = data.invstd.Tfixed_bool;
                        savedata.INVdata{i}.invstd.Tfixed_val = data.invstd.Tfixed_val;
                    end
                end
            end
            if version_in < 200 % changes introduced with v.0.2.0
                % new 'RTDuncert' info flag
                savedata.data.info.RTDuncert = data.info.RTDuncert;
                % new 'isgated' field
                savedata.data.process.isgated = data.process.isgated;
                % clean-up possible old 'uncert' fields that were not used
                % prior to version 0.2.0
                if isfield(savedata.data.invstd,'useUncert')
                    savedata.data.invstd = rmfield(savedata.data.invstd,'useUncert');
                    savedata.data.invstd = rmfield(savedata.data.invstd,'uncertMethod');
                    savedata.data.invstd = rmfield(savedata.data.invstd,'uncertThresh');
                    savedata.data.invstd = rmfield(savedata.data.invstd,'uncertChi2');
                    savedata.data.invstd = rmfield(savedata.data.invstd,'uncertN');
                    savedata.data.invstd = rmfield(savedata.data.invstd,'uncertMax');
                end
                % now create the new 'uncert' struct
                savedata.data.uncert = data.uncert;

                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i})
                        savedata.INVdata{i}.info.RTDuncert = data.info.RTDuncert;
                        if strcmp(savedata.INVdata{i}.process.gatetype,'raw')
                            savedata.INVdata{i}.process.isgated = false;
                            savedata.INVdata{i}.results.nmrproc.isgated = false;
                        else
                            savedata.INVdata{i}.process.isgated = true;
                            savedata.INVdata{i}.results.nmrproc.isgated = true;
                        end

                        % clean-up possible old 'uncert' fields that were
                        % not used prior to version 0.2.0
                        if isfield(savedata.INVdata{i}.invstd,'useUncert')
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'useUncert');
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'uncertMethod');
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'uncertThresh');
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'uncertChi2');
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'uncertN');
                            savedata.INVdata{i}.invstd = rmfield(savedata.INVdata{i}.invstd,'uncertMax');
                        end
                        % now create the new 'uncert' struct
                        savedata.INVdata{i}.uncert = data.uncert;
                        
                        % now invtype is also stored in the results data
                        savedata.INVdata{i}.results.invstd.invtype = savedata.INVdata{i}.invstd.invtype;

                        % new 'invparams' field
                        invparams.info = 'off';                        
                        switch savedata.INVdata{i}.invstd.invtype
                            case {'mono','free'}
                                invparams.T1IRfac = savedata.INVdata{i}.results.nmrproc.T1IRfac;
                                invparams.noise = savedata.INVdata{i}.results.nmrproc.noise;
                                invparams.optim = data.info.has_optim;
                                invparams.Tfixed_bool = savedata.INVdata{i}.invstd.Tfixed_bool;
                                invparams.Tfixed_val = savedata.INVdata{i}.invstd.Tfixed_val;
                                if isfield(savedata.INVdata{i}.results.nmrproc,'W')
                                    invparams.W = savedata.INVdata{i}.results.nmrproc.W;
                                end
                                invparams.t_raw = savedata.INVdata{i}.results.nmrraw.t;
                                invparams.s_raw = savedata.INVdata{i}.results.nmrraw.s;

                            otherwise
                                invparams.T1T2 = savedata.INVdata{i}.results.nmrproc.T1T2;
                                invparams.T1IRfac = savedata.INVdata{i}.results.nmrproc.T1IRfac;
                                invparams.Tb = savedata.INVdata{i}.invstd.Tbulk;
                                invparams.Td = savedata.INVdata{i}.invstd.Tdiff;
                                invparams.Tint = [log10(savedata.INVdata{i}.invstd.time) savedata.INVdata{i}.invstd.Ntime];
                                invparams.noise = savedata.INVdata{i}.results.nmrproc.noise;
                                if isfield(savedata.INVdata{i}.results.nmrproc,'W')
                                    invparams.W = savedata.INVdata{i}.results.nmrproc.W;
                                end
                                switch savedata.INVdata{i}.invstd.invtype
                                    case 'LU'
                                        invparams.Lorder = savedata.INVdata{i}.invstd.Lorder;
                                        invparams.lambda = savedata.INVdata{i}.invstd.lambda;
                                    case 'NNLS'
                                        invparams.regMethod = savedata.INVdata{i}.invstd.regtype;
                                        invparams.Lorder = savedata.INVdata{i}.invstd.Lorder;
                                        invparams.lambda = savedata.INVdata{i}.invstd.lambda;
                                        invparams.solver = savedata.data.info.solver;
                                    case 'MUMO'
                                        invparams.nModes = savedata.INVdata{i}.invstd.freeDT;
                                        invparams.optim = data.info.has_optim;
                                end
                        end
                        % add the new field to the inversion results
                        savedata.INVdata{i}.results.invstd.invparams = invparams;
                    end
                end
            end % version < 200
            if version_in < 210 % changes introduced with v.0.2.1
                % new 'EchoFlag' info flag
                savedata.data.info.EchoFlag = data.info.EchoFlag;
                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i})
                        switch savedata.INVdata{i}.invstd.invtype
                            case 'NNLS'
                                invparams = savedata.INVdata{i}.results.invstd.invparams;
                                switch invparams.solver
                                    case 'lsqlin'
                                        % after version 0.1.12 this "flag"
                                        % was unfortunately hard-coded
                                        if version_in < 112
                                            invparams.EchoFlag = 'off';
                                        else
                                            invparams.EchoFlag = 'on';
                                        end
                                    otherwise
                                        % nothing to do
                                end
                                savedata.INVdata{i}.results.invstd.invparams = invparams;
                            otherwise
                                % nothing to do
                        end
                    end
                end
            end % version < 210
            if version_in < 400 % changes introduced with v.0.4.0
                % new 'L-curve' method
                savedata.data.info.LcurveMethod = data.info.LcurveMethod;
                
                % set the new nmrproc.imag_chi2 field (if applicable)
                for i = 1:numel(savedata.INVdata)
                    if isstruct(savedata.INVdata{i})
                        % the current data set
                        nmrdata = savedata.data.import.NMR.data{i};

                        % the raw data
                        nmrraw.t = nmrdata.time;
                        nmrraw.s = nmrdata.signal;
                        if strcmp(nmrdata.flag,'T2')
                            nmrraw.phase = nmrdata.phase;
                        end                        
                        % check if noise was calculated / estimated during import
                        % this value is used here
                        if isfield(nmrdata,'noise')
                            nmrraw.noise = nmrdata.noise;
                        end
                        nmrproc_in = savedata.INVdata{i}.results.nmrproc;
                        [~,nmrproc_out] = processNMRData(nmrraw,nmrproc_in);

                        savedata.INVdata{i}.results.nmrproc.imag_chi2 = nmrproc_out.imag_chi2;
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

        % adjust menu entry for LSQ solver
        % first check if we have the optimization toolbox
        switch data0.info.has_optim
            case 'on'
                % if yes, set the solver accordingly
                switch savedata.data.info.solver
                    case 'lsqlin'
                        set(gui.menu.extra_solver_lsqlin,'Checked','on');
                        onMenuSolver(gui.menu.extra_solver_lsqlin);
                    case 'lsqnonneg'
                        set(gui.menu.extra_solver_lsqnonneg,'Checked','on');
                        onMenuSolver(gui.menu.extra_solver_lsqnonneg);
                end
                % check if the EchoFlag was set and set it agin if
                % neccessary
                switch savedata.data.info.EchoFlag
                    case 'on'
                        set(gui.menu.extra_lsqlin_echoflag,'Checked','on');
                    case 'off'
                        set(gui.menu.extra_lsqlin_echoflag,'Checked','off');
                end
            case 'off'
                % if not set solver to LSQNONNEG
                data.info.has_optim = 'off';
                set(gui.menu.extra_solver_lsqnonneg,'Checked','on');
                onMenuSolver(gui.menu.extra_solver_lsqnonneg);
                set(gui.menu.extra_solver,'Enable','off');
        end        
        
        % adjust menu entry for L-curve method
        switch savedata.data.info.LcurveMethod
            case 'iterative'
                onMenuLcurve(gui.menu.extra_lcurve_iter);
            case 'discrete'
                onMenuLcurve(gui.menu.extra_lcurve_discrete);
        end        

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