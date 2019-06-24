function onListboxData(src,~)
%onListboxData handles the calls from the context menu of the data
%listbox
%
% Syntax:
%       onListboxData
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onListboxData(src,~)
%
% Other m-files required:
%       clearSingleAxis
%       NUCLEUSinv_updateInterface
%       onPushRun
%       processNMRDataControl
%       removeInversionFields
%       updateInfo
%       updatePlotsDistribution
%       updatePlotsLcurve
%       updatePlotsSignal
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

% check if there is any data at all
if isfield(data.import,'NMR')
    
    % id of the selected file
    id = get(src,'Value');
    
    if ~isempty(id) && numel(id) == 1
        
        % get possible parameter file information
        if isfield(data.import.NMR,'para')
            data.info.parameter = data.import.NMR.para{id};
        else
            data.info.parameter = 'No parameter data available.';
        end
        
        % check if inversion data already exists for this file
        if isstruct(INVdata{id})
            
            % if so update the data and the GUI
            data_upd = INVdata{id};
            data_upd.info = data.info;
            data_upd.import = data.import;
            data_upd.calib = data.calib;
            data_upd.pressure = data.pressure;
            data = data_upd;
            setappdata(fig,'data',data);
            
            % update interface and plot axes
            NUCLEUSinv_updateInterface;
            updatePlotsSignal;
            updateInfo(gui.plots.SignalPanel);
            gui = getappdata(fig,'gui');
            if isfield(data,'results')
                if isfield(data.results,'invstd')
                    updatePlotsDistribution;
                end
                if isfield(data.results,'invjoint')
                    updatePlotsJointInversion;
                end
                if isfield(data.results,'lcurve')
                    updatePlotsLcurve;
                end
                if isfield(data.results,'iterchi2')
                    updatePlotsIterChi;
                end
            end
        else
            % remove temporary data fields
            data = removeInversionFields(data);
            
            % set format and T1/T2 dependent GUI elements
            switch data.import.NMR.data{id}.flag
                case 'T1'
                    data.process.gatetype = 'raw';
                    data.process.start = 1;
                case 'T2'
                    switch data.import.fileformat
                        case {'dart','field','mouse','NMRMOD','excel'}
                            data.process.gatetype = 'raw';
                            data.process.start = 1;
                        otherwise
                            % standard T2
                            data.process.gatetype = 'log';
                            data.process.start = 1;
                    end
                otherwise
                    disp('onListboxData: Something is utterly wrong.')
            end
            
            % take all echoes
            data.process.end = length(data.import.NMR.data{id}.signal);
            
            % ---
            % special treatments
            % there is no volume or porosity
            data.param.sampVol = 1;
            if isfield(data.import,'BGR')
                data.invstd.porosity = data.import.BGR.porosity;
            else
                data.invstd.porosity = 1;
            end
            if isfield(data.import,'LIAG')
                data.param.sampVol = data.import.LIAG.sampleVol(id);
                if ~isempty(strfind(data.import.NMR.filesShort{id},' - calibration'))
                    data.param.calibVol = data.import.LIAG.sampleVol(id);
                    % update the GUI data
                    setappdata(fig,'data',data);
                    % set mono fit as default
                    set(gui.popup_handles.invstd_InvType,'Value',1);
                    onPopupInvstdType(gui.popup_handles.invstd_InvType);
                    data = getappdata(fig,'data');
                end
                if isempty(strfind(data.import.NMR.filesShort{id},' - calibration'))
                    data.invstd.Tbulk = data.import.LIAG.Tbulk;
                    % update the GUI data
                    setappdata(fig,'data',data);
                    % set mono fit as default
                    set(gui.popup_handles.invstd_InvType,'Value',3);
                    onPopupInvstdType(gui.popup_handles.invstd_InvType);
                    data = getappdata(fig,'data');
                end
            else
                data.param.sampVol = 1;
            end
            if isfield(data.import,'NMRMOD')
                data.param.rho = data.import.NMR.para{id}.rho*1e6;
                data.invstd.Tbulk = data.import.NMR.para{id}.Tbulk;                
                data.invstd.porosity = data.import.NMR.para{id}.porosity;
            end
            % ---

            % update the figure data
            setappdata(fig,'data',data);            
           
            % process the NMR data
            processNMRDataControl(fig,id);
             % update interface
            NUCLEUSinv_updateInterface;
            
            % update the data plot axes
            updatePlotsSignal;
            % update the info fields
            updateInfo(gui.plots.SignalPanel);
            gui = getappdata(fig,'gui');
            
            % clear inversion axes
            clearSingleAxis(gui.axes_handles.rtd);
            clearSingleAxis(gui.axes_handles.psd);
        end
        
        % set focus on data
%         set(gui.plots.SignalPanel,'Selection',1);
%         set(gui.plots.DistPanel,'Selection',1);
        
        % reset all RUN buttons
        set(gui.push_handles.invstd_run,'String','<HTML><u>R</u>UN',...
            'BackgroundColor','g','Enable','on','Callback',@onPushRun);
        set(gui.push_handles.invjoint_run,'String','<HTML><u>R</u>UN',...
            'BackgroundColor','g','Enable','on','Callback',@onPushRun);
        
        % if the Fit Statistics window is open update it
        if ~isempty(findobj('Tag','FITSTATS'))
            showFitStatistics;
        end
        % if the PhaseView window is open update it
        if ~isempty(findobj('Tag','PHASEVIEW'))
            PhaseView(gui.menu.extra_phaseview);
        end
    else
        helpdlg({'onListboxData:','Only choose one data set at a time.'},...
            'too many data');
    end
else
    helpdlg('Nothing to do because there is no data loaded!',...
        'onListboxData: Load NMR data first.');
end

% update the figure data
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