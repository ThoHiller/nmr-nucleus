function runInversionBatch
%runInversionBatch batch processes the inversion using for all NMR signals
%the same inversion parameters as for the current one
%
% Syntax:
%       runInversionBatch
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       runInversionBatch
%
% Other m-files required:
%       displayStatusText
%       fitDataFree
%       fitDataFree_fmin
%       fitDataLUdecomp
%       fitDataLSQ
%       onPushRun
%       onPushStop
%       processNMRDataControl
%       removeInversionFields
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
INVdata = getappdata(fig,'INVdata');

% only proceed if there is data
if ~isempty(INVdata)
    % make the RUN button a STOP  button
    set(gui.push_handles.invstd_run,'String','STOP','BackGroundColor','r',...
        'UserData',1,'Callback',@onPushStop);

    % check if this run has uncertainty data
    hasUncert = false;
    if isfield(data.results.invstd,'uncert')
        uncertTMP = data.results.invstd.uncert;
        hasUncert = true;
    end
    
    % remove temporary data fields
    data = removeInversionFields(data);
    
    % Inversion output on command line
    switch data.info.InvInfo
        case 'on'
            param.info = 'final';
        case 'off'
            param.info = 'off';
    end
    
    infostring = 'Batch inversion ... ';
    displayStatusText(gui,infostring);
    
    % waitbar option
    wbopts.show = true;
    wbopts.tag = 'INV';
    if wbopts.show
        hwb = waitbar(0,'processing ...','Name','Batch calculation','Visible','off');
        steps = size(INVdata,1);
        fig = findobj('Tag',wbopts.tag);
        if ~isempty(fig)
            posf = get(fig,'Position');
            set(hwb,'Units','Pixel')
            posw = get(hwb,'Position');
            set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 ...
                posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
        end
        set(hwb,'Visible','on');
    end
    
    % proccess all signals
    for id = 1:size(INVdata,1)
        % only if the User didn't cancel
        if get(gui.push_handles.invstd_run,'UserData') == 1 % STOP was not pressed
            tic;
            % get GUI data
            data = getappdata(fig,'data');
            % processing settings
            if strcmp(data.import.NMR.data{id}.flag,'T1')
                data.process.gatetype = 'raw';
                data.process.start = 1;
            end
            data.process.end = length(data.import.NMR.data{id}.signal);
            % update GUI data
            setappdata(fig,'data',data);
            % process the current NMR signal
            processNMRDataControl(fig,id);
            % update GUI data
            data = getappdata(fig,'data');
            
            % switch depending on inversion method
            switch data.invstd.invtype                
                case 'mono'
                    flag = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = data.invstd.Tfixed_bool;
                    param.Tfixed_val = data.invstd.Tfixed_val;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,1);
                    data.invstd.Tfixed_val = [invstd.T zeros(1,4)];
                    
                case 'free'
                    flag = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = data.invstd.Tfixed_bool;
                    param.Tfixed_val = data.invstd.Tfixed_val;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,data.invstd.freeDT);
                    data.invstd.Tfixed_val = [invstd.T(1:data.invstd.freeDT)...
                        zeros(1,5-data.invstd.freeDT)];
                    
                case 'LU'
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Td = data.invstd.Tdiff;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.Lorder = data.invstd.Lorder;
                    param.lambda = data.invstd.lambda;
                    param.noise = data.results.nmrproc.noise;
                    
                    invstd = fitDataLUdecomp(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
                    
                case 'NNLS'
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Td = data.invstd.Tdiff;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.regMethod = data.invstd.regtype;
                    param.Lorder = data.invstd.Lorder;
                    param.lambda = data.invstd.lambda;
                    param.noise = data.results.nmrproc.noise;
                    param.solver = data.info.solver;
                    param.EchoFlag = data.info.EchoFlag;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    invstd = fitDataLSQ(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
                    
                case 'MUMO' % N free distribution inversion
                    param.nModes = data.invstd.freeDT;
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Td = data.invstd.Tdiff;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.noise = data.results.nmrproc.noise;
                    param.solver = data.info.solver;
                    param.optim = data.info.has_optim;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    % status bar information
                    switch data.info.solver
                        case 'lsqlin'
                            infostring = 'Inversion using ''Optimization Toolbox'' ... ';
                        case 'lsqnonneg'
                            infostring = 'Inversion using ''fminsearchbnd'' ... ';
                    end
                    displayStatusText(gui,infostring);
                    invstd = fitDataMultiModal(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
            end

            % estimate uncertainty
            if hasUncert
                % original fit parameter
                iparam = param;
                % uncertainty parameter
                uparam.id = id;
                uparam.time = data.results.nmrproc.t;
                uparam.signal = data.results.nmrproc.s;
                uparam.uncert = uncertTMP.params.uncert;
                invstd = estimateUncertainty(data.invstd.invtype,invstd,iparam,uparam);
            end
            
            % save inversion results
            data.results.invstd = invstd;
            if id == 1
                % get possible parameter file information
                if isfield(data.import.NMR,'para')
                    data.info.parameter = data.import.NMR.para{id};
                else
                    data.info.parameter = 'No parameter data available.';
                end
                INVdata{id} = [];
                INVdata{id} = data;
                INVdata{id} = rmfield(INVdata{id},'import');
                INVdata{id} = rmfield(INVdata{id},'info');
                INVdata{id} = rmfield(INVdata{id},'calib');
                INVdata{id} = rmfield(INVdata{id},'pressure');
                % copy data to all INVdata fields to allocate memory
                % this speeds up the overall runtime
                INVdata = repmat(INVdata(id),[length(data.import.NMR.filesShort),1]);
            else
                % save individual results
                INVdata{id}.process = data.process;
                INVdata{id}.results = data.results;
                if isfield(data.import.NMR,'para')
                    INVdata{id}.info.parameter = data.import.NMR.para{id};
                else
                    INVdata{id}.info.parameter = 'No parameter data available.';
                end
            end
            
            % color the list entries that already have an inversion result
            strL = get(gui.listbox_handles.signal,'String');
            str1 = strL{id};
            str2 = ['<HTML><BODY bgcolor="rgb(',...
            sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',str1,'</BODY></HTML>'];
            strL{id} = str2;
            set(gui.listbox_handles.signal,'String',strL);
            
            % update wait-bar
            if wbopts.show
                % for a small number of signals always update the wait-bar
                if size(INVdata,1) <= 50
                    waitbar(id / steps,hwb,['processing ...',num2str(id),...
                        ' / ',num2str(steps),' NMR signals']);
                else
                    % otherwise only update every 25 signals
                    % NOTE: Matlab's wait-bar SLOWS DOWN the calculation
                    % MASSIVELY
                    if id == 1 || mod(id,25) == 0
                        waitbar(id / steps,hwb,['processing ...',num2str(id),...
                            ' / ',num2str(steps),' NMR signals']);
                    end
                end
            end            
        else
            displayStatusText(gui,[infostring,' was canceled']);
            % remove temporary data fields
            data = removeInversionFields(data);
            % remove data from fields not processed
            INVdata{id} = [];
        end
    end % id = 1:size(INVdata,1)

    % delete wait-bar
    if wbopts.show
        delete(hwb);
    end
    if get(gui.push_handles.invstd_run,'UserData') == 1 % STOP was not pressed
        displayStatusText(gui,[infostring,'done']);
    end
    
    % update INVdata to GUI
    setappdata(fig,'INVdata',INVdata);
    % make the STOP button a RUN again
    set(gui.push_handles.invstd_run,'String','<HTML><u>R</u>UN',...
        'BackgroundColor','g','Callback',@onPushRun);
    % update GUI data
    setappdata(fig,'gui',gui);
    % set focus on the first entry in the list
    set(gui.listbox_handles.signal,'Value',1);
    onListboxData(gui.listbox_handles.signal);    
else
    helpdlg('Nothing to do because there is no data loaded!',...
        'runInversioBatch: Load NMR data first.');
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