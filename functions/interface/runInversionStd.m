function runInversionStd
%runInversionStd controls the standard inversion process to invert a
%relaxation time distribution (RTD) from NMR data
%
% Syntax:
%       runInversionStd
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       runInversionStd
%
% Other m-files required:
%       calibratePorosity
%       clearAllAxes
%       displayStatusText
%       fitDataFree
%       fitDataFree_fmin
%       fitDataLUdecomp
%       fitDataLSQ
%       getLambdaFromLCurve
%       NUCLEUSinv_updateInterface
%       onPushRun
%       onPushShowHide
%       onPushStop
%       removeInversionFields	
%       showFitStatistics
%       updateInfo
%       updatePlotsDistribution
%       updatePlotsLcurve	
%       updatePlotsSignal	
%       useSignalAsCalibration
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

% id of the chosen NMR signal
id = get(gui.listbox_handles.signal,'Value');

% check if joint inversion is activated
isjoint = strcmp(get(gui.menu.extra_joint,'Checked'),'on');

if ~isempty(id) && ~isempty(INVdata)
    % remove temporary data fields
    data = removeInversionFields(data);
    
    % if joint inversion is enabled clear joint PSD and CPS axes because a
    % new std inversion might change E0 and hence the saturation value of
    % the NMR signal
    if isjoint
        clearSingleAxis(gui.axes_handles.psdj);
        ph = findall(gui.axes_handles.cps,'Tag','SatPoints');
        if ~isempty(ph)
            set(ph,'HandleVisibility','on')
            delete(ph);
        end
        clearSingleAxis(gui.axes_handles.cps);
    end
    
    % switch depending on regularization method
    switch data.invstd.regtype
        case 'lcurve' % L-curve regularization
            % clear inversion axes
            clearAllAxes(gui.figh);
            
            % make the RUN button a STOP button
            % set "UserData" to 1 to catch a STOP button event
            set(gui.push_handles.invstd_run,'String','STOP',...
                'BackGroundColor','r','UserData',1,'Callback',@onPushStop);
            
            % no command line output during l-curve calculation
            param.info = 'off';
            
            % lambda range and initialization of output variables
            lambda_range = logspace(log10(data.invstd.lambdaR(1)),log10(data.invstd.lambdaR(2)),data.invstd.NlambdaR);
            RMS = zeros(size(lambda_range));
            XN = zeros(size(lambda_range));
            RN = zeros(size(lambda_range));
            
            % general inversion parameter
            param.T1T2 = data.results.nmrproc.T1T2;
            param.T1IRfac = data.results.nmrproc.T1IRfac;
            param.Tb = data.invstd.Tbulk;
            param.Td = data.invstd.Tdiff;
            param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
            param.regMethod = 'manual';
            param.Lorder = data.invstd.Lorder;
            param.noise = data.results.nmrproc.noise;
            param.TE = data.results.nmrraw.t(2)-data.results.nmrraw.t(1);
            if isfield(data.results.nmrproc,'W')
                param.W = data.results.nmrproc.W;
            end
            param.solver = data.info.solver;
            
            % status bar information
            infostring = 'L-curve calculation ... ';
            displayStatusText(gui,infostring);
            
            % wait-bar option
            wbopts.show = true;
            wbopts.tag = 'INV';
            if wbopts.show
                hwb = waitbar(0,'processing ...','Name','L-curve calculation','Visible','off');
                steps = length(lambda_range);
                fig = findobj('Tag',wbopts.tag);
                if ~isempty(fig)
                    posf = get(fig,'Position');
                    set(hwb,'Units','Pixel')
                    posw = get(hwb,'Position');
                    set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
                end
                set(hwb,'Visible','on');
            end
            
            % the L-curve calculation
            for i = 1:length(lambda_range)
                % check if the STOP button was pressed
                % if "UserData" is 1 STOP was not pressed -> continue
                if get(gui.push_handles.invstd_run,'UserData') == 1
                    param.lambda = lambda_range(i);
                    invdata = fitDataLSQ(data.results.nmrproc.t,data.results.nmrproc.s,param);                  
                    % output data
                    RMS(i) = invdata.rms;
                    RN(i) = invdata.rn;
                    XN(i) = invdata.xn;
                    % wait-bar update
                    if wbopts.show
                        waitbar(i / steps,hwb,['processing ...',num2str(i),' / ',num2str(steps),' lambda steps']);
                    end
                end
            end
            % delete the wait-bar
            if wbopts.show
                delete(hwb);
            end
            
            % check if the STOP button was pressed
            % if "UserData" is 1 STOP was not pressed -> save data
            if get(gui.push_handles.invstd_run,'UserData') == 1
                lc.lambda = lambda_range;
                lc.RMS = RMS;
                lc.RN = RN;
                lc.XN = XN;                
                % get optimal lambda
                lc.index = getLambdaFromLCurve(RN,XN,0);
                data.results.lcurve = lc;                
                % update GUI data
                setappdata(fig,'data',data);
                % update L-curve plots
                updatePlotsLcurve;
                % status bar information
                displayStatusText(gui,[infostring,' done']);
            else
                % status bar information
                displayStatusText(gui,[infostring,' was canceled']);
                % remove temporary data fields
                data = removeInversionFields(data);
            end
            
        otherwise % normal inversion
            % time the whole inversion
            tic;
            % Do we want inversion output on the command line
            switch data.info.InvInfo
                case 'on'
                    param.info = 'final';
                case 'off'
                    param.info = 'off';
            end
            
            % disable the RUN button to indicate a running inversion
            set(gui.push_handles.invstd_run,'String','RUNNING ...',...
                'Enable','inactive');            
            % switch depending on inversion method
            switch data.invstd.invtype
                case 'mono' % mono-exponential inversion
                    flag = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = data.invstd.Tfixed_bool;
                    param.Tfixed_val = data.invstd.Tfixed_val;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    % status bar information
                    switch data.info.has_optim
                        case 'on'
                            infostring = 'Inversion using ''Optimization Toolbox'' ... ';
                        case 'off'
                            infostring = 'Inversion using ''fminsearchbnd'' ... ';
                    end
                    displayStatusText(gui,infostring);
                    param.t_raw = data.results.nmrraw.t;
                    param.s_raw = data.results.nmrraw.s;
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,1);
                    data.invstd.Tfixed_val = [invstd.T zeros(1,4)];
                    
                case 'free' % N free single-exponential inversion
                    flag = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.noise = data.results.nmrproc.noise;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = data.invstd.Tfixed_bool;
                    param.Tfixed_val = data.invstd.Tfixed_val;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    % status bar information
                    switch data.info.has_optim
                        case 'on'
                            infostring = 'Inversion using ''Optimization Toolbox'' ... ';
                        case 'off'
                            infostring = 'Inversion using ''fminsearchbnd'' ... ';
                    end
                    displayStatusText(gui,infostring);
                    invstd = fitDataFree(data.results.nmrproc.t,...
                        data.results.nmrproc.s,flag,param,data.invstd.freeDT);
                    data.invstd.Tfixed_val = [invstd.T(1:data.invstd.freeDT)...
                        zeros(1,5-data.invstd.freeDT)];
                            
                case 'LU' % multi-exponential inversion
                    % general parameter
                    param.T1T2 = data.results.nmrproc.T1T2;
                    param.T1IRfac = data.results.nmrproc.T1IRfac;
                    param.Tb = data.invstd.Tbulk;
                    param.Td = data.invstd.Tdiff;
                    param.Tint = [log10(data.invstd.time) data.invstd.Ntime];
                    param.Lorder = data.invstd.Lorder;
                    param.lambda = data.invstd.lambda;
                    param.noise = data.results.nmrproc.noise;
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    % status bar information
                    infostring = 'Inversion using LU decomposition ... ';
                    displayStatusText(gui,infostring);
                    invstd = fitDataLUdecomp(data.results.nmrproc.t,...
                        data.results.nmrproc.s,param);
                    
                case 'NNLS' % multi-exponential inversion with manual regularization
                    % general parameter
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
                    if isfield(data.results.nmrproc,'W')
                        param.W = data.results.nmrproc.W;
                    end
                    
                    % status bar information
                    switch data.info.solver
                        case 'lsqlin'
                            infostring = 'Inversion using ''Optimization Toolbox'' ... ';
                        case 'lsqnonneg'
                            infostring = 'Inversion using ''lsqnonneg'' ... ';
                    end
                    displayStatusText(gui,infostring);
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
            % normalize to 1
            if data.process.norm == 1
                switch data.invstd.invtype
                    case {'LU','NNLS','MUMO'}
                        % normalization with sum() -> sum(f)=1
                        % this is the standard way of doing it
                        invstd.T1T2f = invstd.T1T2f./sum(invstd.T1T2f);
                        % alternatives depending on the objective:
                        % 1.) normalization with sum(f*dt) -> area~=1
                        % dt = log10(invstd.T1T2me(2))-log10(invstd.T1T2me(1));
                        % invstd.T1T2f = invstd.T1T2f/sum(invstd.T1T2f*dt);
                        % 2.) normalization with trapz() -> area=1 but sum(f)>1
                        % invstd.T1T2f = invstd.T1T2f./trapz(invstd.T1T2me,invstd.T1T2f);
                    otherwise
                        % nothing to do
                end
            end
            runtime = toc;
            displayStatusText(gui,[infostring,'done | inversion took ',...
                sprintf('%5.2f',runtime),' s']);
            % save inversion results
            data.results.invstd = invstd;
            setappdata(fig,'data',data);
    end    
    % as long as the "UserData" is 1 the STOP button was not pressed and
    % the inversion result gets saved in "INVdata"
    if get(gui.push_handles.invstd_run,'UserData') == 1 && ...
            ( isfield(data.results,'invstd') || ...
            isfield(data.results,'lcurve') )
        INVdata{id} = [];
        INVdata{id} = data;
        INVdata{id} = rmfield(INVdata{id},'import');
        INVdata{id} = rmfield(INVdata{id},'info');
        INVdata{id} = rmfield(INVdata{id},'calib');
        INVdata{id} = rmfield(INVdata{id},'pressure');
        
        % color the list entries that already have an inversion result
        strL = get(gui.listbox_handles.signal,'String');
        str1 = strL{id};
        str2 = ['<HTML><BODY bgcolor="rgb(',...
            sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',str1,'</BODY></HTML>'];
        strL{id} = str2;
        set(gui.listbox_handles.signal,'String',strL);
        
        % update GUI INVdata
        setappdata(fig,'INVdata',INVdata);
        
        % ---
        % special treatment for LIAG processing
        if isfield(data.import,'LIAG') && ~strcmp(data.invstd.regtype,'lcurve')
            if contains(str1,' - calibration')
                % save Tbulk from the calibration sample
                btn1 = 'Yes keep it';
                btn2 = 'No, reset to 1e6 [s]';
                if data.results.invstd.T2 < 0.2
                    answer = questdlg(['Tbulk seems very short with ',...
                        sprintf('%4.3f',data.results.invstd.T2),' [s] ',...
                        'Do you want to keep it?'], ...
                        'Keep relaxation time as Tbulk', ...
                        btn1,btn2,btn2);
                    % Handle response
                    switch answer
                        case btn1
                            data.import.LIAG.Tbulk = data.results.invstd.T2;
                        case btn2
                            data.import.LIAG.Tbulk = 1e6;
                    end
                else
                    data.import.LIAG.Tbulk = data.results.invstd.T2;
                end
                % update GUI data
                setappdata(fig,'data',data);
                % save calibration data
                useSignalAsCalibration(id);                
            else
                calibratePorosity;
            end
        end
        % ---
    else  % STOP was pressed (because "UserData" is 0)
        % reset "UserData"
        set(gui.push_handles.invstd_run,'UserData',1);
    end    
    % update plots and INFO fields
    updatePlotsSignal;
    updatePlotsDistribution;
    updateInfo(gui.plots.SignalPanel);
    % set focus on results
    set(gui.plots.SignalPanel,'Selection',1);
    set(gui.plots.DistPanel,'Selection',1);
    % open INFO field
    set(gui.push_handles.info,'String','<');
    onPushShowHide(gui.push_handles.info);
    if ~isempty(findobj('Tag','FITSTATS'))
        showFitStatistics;
    end
    if ~isempty(findobj('Tag','FIXEDTIMEVIEW'))
        FixedTimeView(gui.menu.extra_fixedtime);
    end
    NUCLEUSinv_updateInterface;
else
    helpdlg('Cannot start inversion because no data set is selected!',...
        'Select NMR data first.');
end

%% at the end, no matter what reset the RUN button
set(gui.push_handles.invstd_run,'String','<HTML><u>R</u>UN',...
    'BackgroundColor','g','Enable','on','Callback',@onPushRun);
setappdata(fig,'gui',gui);

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