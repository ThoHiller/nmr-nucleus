function calibratePorosity
%calibratePorosity determines a sample's porosity from a calibration
%measurement. If the porosity is bigger than "1" the corresponding edit
%field is later colored red to indicate this obvious error.
%
% Syntax:
%       calibratePorosity
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       calibratePorosity
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

%% update all inversion results with the global calibration data
% check if there are any inversion results at all
foundINV = checkIfInversionExists(INVdata);
if foundINV
    for id = 1:size(INVdata,1)
       if isstruct(INVdata{id})
           INVdata{id}.param.calibVol = data.calib.vol;
           INVdata{id}.param.calibAmp = data.calib.amp;
       end
    end
end
setappdata(fig,'INVdata',INVdata);

% get the id of the signal in the list
id = get(gui.listbox_handles.signal,'Value');

% only continue if there is inversion data for that file
if isstruct(INVdata{id})
    % get the signals amplitude
    sampAmp = sum(INVdata{id}.results.invstd.E0);    
    % sample porosity from calibration
    % phi = fac *(Amplitude/Volume)
    fac = data.calib.vol/data.calib.amp;
    porosity = fac * (sampAmp/data.param.sampVol);
    data.invstd.porosity = porosity;
    INVdata{id}.invstd.porosity = porosity;
    INVdata{id}.param.sampVol = data.param.sampVol;
    % update the GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'INVdata',INVdata);
    NUCLEUSinv_updateInterface;
    % plot the rescaled distributions
    updatePlotsDistribution;
else
    helpdlg({'function: calibratePorosity',...
        'Invert NMR data first'},'No inversion data');
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