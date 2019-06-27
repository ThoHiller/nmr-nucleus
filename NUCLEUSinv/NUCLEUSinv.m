function NUCLEUSinv
%NUCLEUSinv is a graphical user interface (GUI) to invert NMR relaxometry
%data. It comes bundled with NUCLEUSmod which is the corresponding forward
%modeling GUI.
%
% Syntax:
%       NUCLEUSinv
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSinv
%
% Other m-files required:
%       NUCLEUSinv_createGUI.m
%       NUCLEUSinv_loadDefaults.m
%       calculateGuiOnMonitorPosition.m
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% Only one instance of NUCLEUSinv is allowed
h0  = findobj('Tag','INV');
if ~isempty(h0); close(h0); end

%% GUI 'header' info and defaults
myui.version = '0.1.7';
myui.date = '27.06.2019';
myui.author = 'Thomas Hiller';
myui.email = 'thomas.hiller[at]leibniz-liag.de';
myui.fontsize = 10;
myui.inifile = 'NUCLEUSinv.ini';

%% Default data settings
defaults = NUCLEUSinv_loadDefaults;

%% GUI initialization
gui.figh = figure('Name',['NUCLEUSinv - Inversion Tool v',myui.version],...
    'NumberTitle','off','Tag','INV','ToolBar','none','MenuBar','none',...
    'SizeChangedFcn',@onFigureSizeChange);

pos = calculateGuiOnMonitorPosition(16/10);
set(gui.figh,'Position',pos);

%% Color settings
myui.colors = getColorTheme('INV','standard');

%% Data structure for handling all GUI data
data.import = defaults.import;
data.info = defaults.info;
data.process = defaults.process;
data.param = defaults.param;
data.invstd = defaults.invstd;
data.calib = defaults.calib;
data.invjoint = defaults.invjoint;
data.pressure = defaults.pressure;
gui.myui = myui;

%% Check toolbox availability
% check if the Optimization & Statistics Toolbox are available
% if not then alternative routines will be used
Mver = ver;
for i = 1:size(Mver,2)
    if strcmp(Mver(i).Name,'Optimization Toolbox')
        data.info.optim = 'on';
    end
    if strfind(Mver(i).Name,'Statistics')
        data.info.stat = 'on';
    end
end

% save the data struct within the GUI
setappdata(gui.figh,'data',data);
setappdata(gui.figh,'gui',gui);

%% Create GUI elements
NUCLEUSinv_createGUI(gui.figh,1);

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