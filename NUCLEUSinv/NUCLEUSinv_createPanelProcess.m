function [gui,myui] = NUCLEUSinv_createPanelProcess(data,gui,myui)
%NUCLEUSinv_createPanelProcess creates process panel
%
% Syntax:
%       [gui,myui] = NUCLEUSinv_createPanelProcess(data,gui,myui)
%
% Inputs:
%       data - figure data structure
%       gui - figure gui elements structure
%       myui - individual GUI settings structure
%
% Outputs:
%       gui
%       myui
%
% Example:
%       [gui,myui] = NUCLEUSinv_createPanelProcess(data,gui,myui)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% create all boxes
gui.panels.process.VBox = uix.VBox('Parent',gui.panels.process.main,...
    'Spacing',3,'Padding',3);

% choose first and last echo
gui.panels.process.HBox1 = uix.HBox('Parent',gui.panels.process.VBox,...
    'Spacing',3);
% re-sampling - time gates
gui.panels.process.HBox2 = uix.HBox('Parent',gui.panels.process.VBox,...
    'Spacing',3);
% normalizing & time scale
gui.panels.process.HBox3 = uix.HBox('Parent',gui.panels.process.VBox,...
    'Spacing',3);

%% choose first and last echo
gui.text_handles.process_start = uicontrol('Parent',gui.panels.process.HBox1,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','first echo | last echo');
tstr = ['<HTML>Choose the first echo of the NMR signal.<br>',...
    'Sometimes the first echo(s) are flawed.<br><br>',...
    '<u>Default values:</u><br>',...
    '<b>1</b> for T1 data.<br>',...
    '<b>1</b> for T2 data.<br>'];
gui.edit_handles.process_start = uicontrol('Parent',gui.panels.process.HBox1,...
    'Style','edit','String',num2str(data.process.start(1,1)),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.process.start(1,1) 1 1]),...
    'Tag','process_start','Enable','off','Callback',@onEditValue);
tstr = ['<HTML>Choose the last echo of the NMR signal.<br><br>',...
    '<u>Default value:</u><br>',...
    '<b>max</b><br><br>',...
    '<u>Tip:</u><br>',...
    'If you enter <b>0</b> it will automatically take the full signal.'];
gui.edit_handles.process_end = uicontrol('Parent',gui.panels.process.HBox1,...
    'Style','edit','String',num2str(data.process.end(1,1)),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.process.end(1,1) 1 1]),...
    'Tag','process_end','Enable','off','Callback',@onEditValue);
set(gui.panels.process.HBox1,'Widths',[200 -1 -1]);

%% resampling - time gates
gui.text_handles.process_gates = uicontrol('Parent',gui.panels.process.HBox2,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','signal gating | echoes / gate');
tstr = ['<HTML>Allows to re-sample (gate) the NMR raw signal.<br>',...
    'This speeds up the inversion.<br><br>',...
    '<u>Available options:</u><br>',...
    '<b>log</b> recommended for T2 data.<br>',...
    '<b>lin</b> <br>',...
    '<b>none</b> recommended for T1 data.<br>'];
gui.radio_handles.process_gates_log = uicontrol('Parent',gui.panels.process.HBox2,...
    'Style','radiobutton','String','log',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioGates);
gui.radio_handles.process_gates_lin = uicontrol('Parent',gui.panels.process.HBox2,...
    'Style','radiobutton','String','lin',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioGates);
gui.radio_handles.process_gates_none = uicontrol('Parent',gui.panels.process.HBox2,...
    'Style','radiobutton','String','none',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioGates);
tstr = ['<HTML>Maximum number of echoes per gate.<br><br>',...
    '<u>Default value:</u><br>',...
    '<b>50</b><br><br>',...
    '<u>Note:</u><br>',...
    'More echoes per gate speed up the inversion but <br>',...
    'you loose the "dynamics" of the RTD. The <br>',...
    'regularization parameter &lambda needs to be <br>',...
    'determined again.'];
gui.edit_handles.process_Nechoes = uicontrol('Parent',gui.panels.process.HBox2,...
    'Style','edit','String',num2str(data.process.Nechoes(1,1)),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.process.Nechoes(1,1) 1 1]),...
    'Tag','process_Nechoes','Enable','off','Callback',@onEditValue);
set(gui.panels.process.HBox2,'Widths',[200 -1 -1 -1.5 50]);

%% normalizing & time scale
gui.text_handles.process_normalize = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','normalize');
tstr = ['<HTML>Normalize the NMR raw signal.<br>',...
    'Sometimes this helps to stabilize the inversion.<br><br>',...
    '<u>Available options:</u><br>',...
    '<b>on</b> <br>',...
    '<b>off</b> <br><br>',...
    '<u>Default value:</u><br>',...
    '<b>off</b> <br>'];
gui.radio_handles.process_normalize_on = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','radiobutton','String','on',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioNormalize);
gui.radio_handles.process_normalize_off = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','radiobutton','String','off',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioNormalize);

gui.text_handles.process_timescale = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','time scale');
tstr = ['<HTML>Change the global time scale from [s] to [ms] or vice versa.<br>',...
    'Sometimes this helps to stabilize the inversion.<br><br>',...
    '<u>Available options:</u><br>',...
    '<b>s</b> <br>',...
    '<b>ms</b> <br><br>',...
    '<u>Default value:</u><br>',...
    '<b>s</b> <br>'];
gui.radio_handles.process_timescale_s = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','radiobutton','String','s',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioTimescale);
gui.radio_handles.process_timescale_ms = uicontrol('Parent',gui.panels.process.HBox3,...
    'Style','radiobutton','String','ms',...
    'UserData',struct('Tooltipstr',tstr),'FontSize',myui.fontsize,...
    'Enable','off','Callback',@onRadioTimescale);
set(gui.panels.process.HBox3,'Widths',[100 -1 -1 100 -1 -1]);

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
