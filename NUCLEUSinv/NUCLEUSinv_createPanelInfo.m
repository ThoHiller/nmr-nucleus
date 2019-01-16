function [gui] = NUCLEUSinv_createPanelInfo(gui)
%NUCLEUSinv_createPanelInfo creates status bar
%
% Syntax:
%       [gui] = NUCLEUSinv_createPanelInfo(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       [gui] = NUCLEUSinv_createPanelInfo(gui)
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

%% create a hbox for button and info panels
gui.push_handles.info = uicontrol('Parent',gui.right,...
    'Style','pushbutton','String','<','FontName','Courier',...
    'BackgroundColor',[0.75 0.75 0.75],'Callback',@onPushShowHide);
gui.panels.info.main = uix.VBox('Parent',gui.right,'Padding',3);
set(gui.right,'Widths',[10 -1]);

%% create the individual panels
gui.panels.info.signal = uix.Panel('Parent',gui.panels.info.main,'Title','INFO:');
gui.panels.info.dist = uix.Panel('Parent',gui.panels.info.main,'Title','INFO:');
gui.panels.info.cps = uix.Panel('Parent',gui.panels.info.main,'Title','INFO:');

%% and the corresponding list boxes
tstr = '<HTML>Displays information on NMR data set';
gui.listbox_handles.info_signal = uicontrol('Parent',gui.panels.info.signal,...
    'Style','listbox','UserData',struct('Tooltipstr',tstr),'Tag','signalInfo',...
    'FontSize',10,'FontName','Courier','String','Signal:',...
    'HorizontalAlignment','left','Enable','on');
tstr = '<HTML>Displays information on RTD and PSD inversion results';
gui.listbox_handles.info_dist = uicontrol('Parent',gui.panels.info.dist,...
    'Style','listbox','UserData',struct('Tooltipstr',tstr),'Tag','distInfo',...
    'FontSize',10,'FontName','Courier','String','Dist:',...
    'HorizontalAlignment','left','Enable','on');
tstr = '<HTML>Displays information on CPS data';
gui.listbox_handles.info_cps = uicontrol('Parent',gui.panels.info.cps,...
    'Style','listbox','UserData',struct('Tooltipstr',tstr),'Tag','cpsInfo',...
    'FontSize',10,'FontName','Courier','String','CPS:',...
    'HorizontalAlignment','left','Enable','on');

% adjust their heights
set(gui.panels.info.main,'Heights',[-1 -1 0]);
set(gui.top,'Widths',[400 -1 10]);
set(gui.right,'Widths',[10 0]);

return

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