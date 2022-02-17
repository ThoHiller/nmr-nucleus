function [gui] = NUCLEUSmod_createStatusbar(gui)
%NUCLEUSmod_createStatusbar creates status bar
%
% Syntax:
%       [gui] = NUCLEUSmod_createStatusbar(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       [gui] = NUCLEUSmod_createStatusbar(gui)
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
% See also: NUCLEUSmod

% Author: see AUTHORS.md
% email: see AUTHORS.md

%------------- BEGIN CODE --------------

%% create the box
gui.statusbar = uix.HBox('Parent',gui.bottom);

%% create the individual panels
gui.panels.status.main = uix.Panel('Parent',gui.statusbar);
gui.panels.status.geom = uix.Panel('Parent',gui.statusbar);
gui.panels.status.psd = uix.Panel('Parent',gui.statusbar);
gui.panels.status.tooltips = uix.Panel('Parent',gui.statusbar);
gui.panels.status.version = uix.Panel('Parent',gui.statusbar);
% adjust their widths
set(gui.statusbar,'Widths',[400 -1 -1 -1 -1]);

%% add the individual text fields
gui.textStatus = uicontrol('Style','Text',...
    'Parent',gui.panels.status.main,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.textGeom = uicontrol('Style','Text',...
    'Parent',gui.panels.status.geom,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.textPSD = uicontrol('Style','Text',...
    'Parent',gui.panels.status.psd,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.textTooltips = uicontrol('Style','Text',...
    'Parent',gui.panels.status.tooltips,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);
gui.textVersion = uicontrol('Style','Text',...
    'Parent',gui.panels.status.version,...
    'String','',...
    'HorizontalAlignment','left',...
    'FontSize',8);

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