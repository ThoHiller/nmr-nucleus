function importCalibrationData
%importCalibrationdata imports previously saved calibration data for
%porosity determination
%
% Syntax:
%       importCalibrationdata
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       importCalibrationdata
%
% Other m-files required:
%       displayStatusText
%       NUCLEUSinv_updateInterface
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

% get file name
CALIBpath = -1;
CALIBfile = -1;
if isfield(data.import,'path')
    [CALIBfile,CALIBpath] = uigetfile(fullfile(data.import.path,'*.mat'),...
    'Choose Calibration file');
else
    [CALIBfile,CALIBpath] = uigetfile(fullfile(pwd,'*.mat'),...
        'Choose Calibration file');
end

% only continue if user didn't cancel
if sum([CALIBpath CALIBfile]) > 0
    
    indata = load(fullfile(CALIBpath,CALIBfile),'calib');
    if isfield(indata,'calib')
        % update the GUI data fields
        data.calib = indata.calib;
        data.param.calibV = data.calib.vol;
        data.param.useporosity = 1;
        
        % update the GUI data
        setappdata(fig,'data',data);
        NUCLEUSinv_updateInterface;
        
        % show info message
        displayStatusText(gui,'Calibration data successfully imported');
    else
        helpdlg({'function: importCalibrationdata',...
            'No calibration data in this file.'},'No calibration data');
    end    
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