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
%       fitDataInvLaplace
%       fitDataNNLS
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
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
    
    % remove temporary data fields
    data = removeInversionFields(data);
    
    % Inversion output on command line
    switch data.info.InvInfo
        case 'on'
            param.info = 'iter';
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
    
    % proceed all signals
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
                    param.t1Est = 1;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.optim;
                    
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,1);
                    
                case 'free'
                    flag = data.results.nmrproc.T1T2;
                    param.t1Est = 1;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.optim;
                    
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,data.invstd.freeDT);
                    
                case 'NNLS'
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.regMethod = data.invstd.regtype;
                    param.Lorder = data.invstd.Lorder;
                    param.lambda = data.invstd.lambda;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.optim;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    invstd = fitDataNNLS(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
                    
                case 'ILA'
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.Lorder = data.invstd.Lorder;
                    param.lambda = data.invstd.lambda;
                    param.noise = data.results.nmrproc.noise;
                    
                    invstd = fitDataInvLaplace(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
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
            
            % update waitbar
            if wbopts.show
                % for a small number of signals always update the waitbar
                if size(INVdata,1) < 25
                    waitbar(id / steps,hwb,['processing ...',num2str(id),...
                        ' / ',num2str(steps),' NMR signals']);
                else
                    % otherwise only update every 25 signals
                    % NOTE: Matlab's waitbar SLOWS DOWN the calculation
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
    end
    % delete waitbar
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