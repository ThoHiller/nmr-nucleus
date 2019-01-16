function caluclatePressureSaturation
%caluclatePressureSaturation calculates the geometry dependent pressure
%saturation curves needed for the foward calculation by NUCLEUSmod
%
% Syntax:
%       caluclatePressureSaturation
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       caluclatePressureSaturation
%
% Other m-files required:
%       clearSingleAxis
%       getConstants
%       displayStatusText
%       getSaturationFromPressureBatch
%       updateCPSTable
%       updatePlotsCPS
%
% Subfunctions:
%       getInitialSatLevels
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

%% are the pressure values log or lin spaced
switch data.pressure.loglin
    case 0 % lin
        pressure = linspace(data.pressure.range(1),data.pressure.range(2),data.pressure.rangeN);
    case 1 % log
        pressure = logspace(log10(data.pressure.range(1)),log10(data.pressure.range(2)),data.pressure.rangeN);
end

%% get standard values for physical constants
constants  = getConstants;
% and update with the ones from the GUI
constants.sigma = data.pressure.sigma;
constants.theta = data.pressure.theta;

%% waitbar option
wbopts.show = true;
wbopts.tag = 'MOD';

%% disable the RUN button to indicate a running calculation
set(gui.push_handles.press_RUN,'String','RUNNING ...','Enable','inactive');

%% calculate saturation states and update global data structure
displayStatusText(gui,'Calculating saturation ... ');
data.results.SAT = getSaturationFromPressureBatch(data.results.GEOM,pressure,data.results.psddata,constants,wbopts);
data.results.constants = constants;

%% remove old saturation levels
if isfield(data.pressure,'DrainLevels')
    data.pressure = rmfield(data.pressure,'DrainLevels');
    data.pressure = rmfield(data.pressure,'ImbLevels');
end

%% create new default saturation levels
[indd,indi] = getInitialSatLevels(data.results.SAT,5);
data.pressure.DrainLevels = indd;
data.pressure.ImbLevels = indi;

%% update the GUI data
setappdata(fig,'data',data);
% update the table
updateCPSTable('update');
% update the CPS axis
updatePlotsCPS;

%% reset NMR plots
clearSingleAxis(gui.axes_handles.nmr);
displayStatusText(gui,'Calculating saturation ... done');
% enable the RUN button again
set(gui.push_handles.press_RUN,'String','RUN','Enable','on');

end

function [indd,indi] = getInitialSatLevels(SAT,N)
% initially there are 5 saturation levels on each branch
SatLevels = linspace(1/N,1,N);
indd = zeros(size(SatLevels));
indi = zeros(size(SatLevels));
for i = 1:5
    indd(i) = find(abs(SAT.Sdfull-SatLevels(i))==min(abs(SAT.Sdfull-SatLevels(i))),1,'last');
    indi(i) = find(abs(SAT.Sifull-SatLevels(i))==min(abs(SAT.Sifull-SatLevels(i))),1,'last');
end
indd = unique(indd);
indi = unique(indi);
% the full saturation one is always the first one
indd(1) = 1;
indi(1) = 1;
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