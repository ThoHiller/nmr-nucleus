function NUCLEUSmod
%NUCLEUSmod is a graphical user interface (GUI) to forward model NMR
%relaxometry data based on an arbitrary pore size distribution (PSD).
%Depending on an applied capillary pressure the pore model can be partially
%saturated. It comes bundled with NUCLEUSinv which is the corresponding
%(joint) inversion GUI.
%
% Syntax:
%       NUCLEUSmod
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSmod
%
% Other m-files required:
%       NUCLEUSmod_createGUI.m
%       NUCLEUSmod_loadDefaults.m
%       calculateGeometry.m
%       calculateGuiOnMonitorPosition.m
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

%% Only one instance of NUCLEUSmod is allowed
h0  = findobj('Tag','MOD');
if ~isempty(h0); close(h0); end

%% GUI 'header' info and defaults
myui.version = '0.1.11';
myui.date = '12.03.2021';
myui.author = {'Thomas Hiller','Stephan Costabel'};
myui.email = 'thomas.hiller[at]leibniz-liag.de';
myui.fontsize = 10;

%% Default data settings
defaults = NUCLEUSmod_loadDefaults;

%% GUI initialization
gui.figh = figure('Name','NUCLEUSmod - Modeling Tool',...
    'NumberTitle','off','Tag','MOD','ToolBar','none','MenuBar','none',...
    'SizeChangedFcn',@onFigureSizeChange);

pos = calculateGuiOnMonitorPosition(16/10);
set(gui.figh,'Position',pos);

%% Color settings
myui.colors = getColorTheme('MOD','standard');

%% Data structure for handling all GUI data
data.geometry = defaults.geometry;
data.pressure = defaults.pressure;
data.nmr = defaults.nmr;
gui.myui = myui;

% save the data struct within the GUI
setappdata(gui.figh,'data',data);
setappdata(gui.figh,'gui',gui);

%% Create GUI elements
NUCLEUSmod_createGUI(gui.figh,1);

%% Calculate Initial Geometry
calculateGeometry;
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