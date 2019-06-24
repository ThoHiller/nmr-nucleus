function useSignalAsCalibration(id)
%useSignalAsCalibration uses E0 as porosity calibration factor.
%
% Syntax:
%       useSignalAsCalibration
%
% Inputs:
%       id - index of selected NMR data file
%
% Outputs:
%       none
%
% Example:
%       useSignalAsCalibration(id)
%
% Other m-files required:
%       none
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

% only continue if there is data (INVdata is an easy indicator if data
% was actually imported) and if there is already an inversion for this signal
if ~isempty(INVdata) && isstruct(INVdata{id})    
    % get the initial amplitude
    E0 = sum(INVdata{id}.results.invstd.E0);
    data.param.calibAmp = E0;
    data.calib.amp = E0;
    set(gui.edit_handles.param_calibAmp,'String',num2str(data.param.calibAmp));
    
    data.param.calibVol = str2double(get(gui.edit_handles.param_calibVol,'String'));
    % for the calibration sample the volumes are identical
    data.param.sampVol = data.param.calibVol;
    set(gui.edit_handles.param_sampVol,'String',num2str(data.param.sampVol));
    
    % save the relevant calibration data to the GUI
    data.calib.vol = data.param.calibVol;
    data.calib.fac = data.calib.vol/E0;
    data.calib.name = data.import.NMR.filesShort{id};
    INVdata{id}.calib = data.calib;
    INVdata{id}.param.calibVol = data.param.calibVol;
    INVdata{id}.param.calibAmp = data.param.calibAmp;
    INVdata{id}.param.sampVol = data.param.sampVol;
    
    % update the GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'INVdata',INVdata);
    
    % ask for file to save calibration data
    FileName = -1;
    PathName = -1;
    if isfield(data.import,'LIAG')
        % find id of sample
%         id = 1;
        spath = data.import.LIAG.workpaths{id};
%         sfilename = ['INV_',data.import.NMR.filesShort{id}];
        sfile = 'NUCLEUS_calibData.mat';
%         [FileName,PathName,~] = uiputfile({'*.mat','Matlab file'},...
%             'NUCLEUSinv: Save Calibration Data',fullfile(spath,sfile));
        PathName = spath;
        FileName = sfile;
    else
%         [FileName,PathName,~] = uiputfile({'*.mat','Matlab file'},...
%             'NUCLEUSinv: Save Calibration Data',fullfile(data.import.path,...
%             'calibData.mat'));
        PathName = data.import.path;
        FileName = 'NUCLEUS_calibData.mat';
    end
    
%     if ~isequal(FileName,0) || ~isequal(PathName,0)
        
        calib = INVdata{id};
        save(fullfile(PathName,FileName),'calib');
        % show info message
        displayStatusText(gui,'Calibration data successfully exported');
%     else
%         displayStatusText(gui,'Calibration data only stored internally');
%     end
    calibratePorosity;    
else
    % if there is no data at all throw a help dialog
    helpdlg({'function: useSignalAsCalibration','Load NMR data first'},...
        'No NMR data');
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