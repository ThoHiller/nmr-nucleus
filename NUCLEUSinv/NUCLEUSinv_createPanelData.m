function [gui,myui] = NUCLEUSinv_createPanelData(gui,myui)
%NUCLEUSinv_createPanelData creates data panel
%
% Syntax:
%       [gui,myui] = NUCLEUSinv_createPanelData(gui,myui)
%
% Inputs:
%       gui - figure gui elements structure
%       myui - individual GUI settings structure
%
% Outputs:
%       gui
%       myui
%
% Example:
%       [gui,myui] = NUCLEUSinv_createPanelData(gui,myui)
%
% Other m-files required:
%       findjobj.m
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

%% create the box
gui.panels.data.VBox = uix.VBox('Parent',gui.panels.data.main,...
    'Spacing',3,'Padding',3);

%% text field where the current data path is displayed
gui.text_handles.data_path = uicontrol('Parent',gui.panels.data.VBox,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','left',...
    'String',myui.inidata.importpath);

%% listbox that shows all NMR data files in the folder
tstr = '<HTML>Choose a NMR data set to process.<br><b>Right-click</b> for a context menu.';
gui.listbox_handles.signal = uicontrol('Parent',gui.panels.data.VBox,...
    'Style','listbox','String',{'file names'},'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),'Callback',@onListboxData);
set(gui.panels.data.VBox,'Heights',[25 -1]);

% listbox context menu
gui.cm_handles.data_list = uicontextmenu(gui.figh);

% main menu
gui.cm_handles.data_list_sort = uimenu(gui.cm_handles.data_list,...
    'Label','sort');
uimenu(gui.cm_handles.data_list,...
    'Label','flip list','Tag','sort','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list,...
    'Label',[char(hex2dec('2191')),'up'],'Tag','sort',...
    'Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list,...
    'Label',[char(hex2dec('2193')),'down'],'Tag','sort',...
    'Callback',@onContextSignalList);
gui.cm_handles.data_list_single = uimenu(gui.cm_handles.data_list,...
    'Label','single','Separator','on');
gui.cm_handles.data_list_all = uimenu(gui.cm_handles.data_list,...
    'Label','batch');
% 'sort' sub menu
uimenu(gui.cm_handles.data_list_sort,...
    'Label','by name','Tag','sort','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_sort,...
    'Label','by date','Tag','sort','Callback',@onContextSignalList);
% 'single' sub menu
uimenu(gui.cm_handles.data_list_single,...
    'Label','run','Tag','single','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_single,...
    'Label','clear','Tag','single','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_single,...
    'Label','save','Tag','single','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_single,...
    'Label','remove','Tag','single','Separator','on',...
    'Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_single,...
    'Label','use as calib.','Tag','single','Separator','on',...
    'Callback',@onContextSignalList);
% 'batch' sub menu
uimenu(gui.cm_handles.data_list_all,...
    'Label','run','Tag','all','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_all,...
    'Label','clear','Tag','all','Callback',@onContextSignalList);
uimenu(gui.cm_handles.data_list_all,...
    'Label','save','Tag','all','Callback',@onContextSignalList);

set(gui.listbox_handles.signal,...
    'UIContextMenu',gui.cm_handles.data_list);

%% Java Hack to adjust vertical alignment of text fields
jh = findjobj(gui.text_handles.data_path);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

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