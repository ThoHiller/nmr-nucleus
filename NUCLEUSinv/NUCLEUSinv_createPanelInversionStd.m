function [gui,myui] = NUCLEUSinv_createPanelInversionStd(data,gui,myui)
%NUCLEUSinv_createPanelInversionStd creates standard inversion panel
%
% Syntax:
%       [gui,myui] = NUCLEUSinv_createPanelInversionStd(data,gui,myui)
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
%       [gui,myui] = NUCLEUSinv_createPanelInversionStd(data,gui,myui)
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
gui.panels.invstd.VBox = uix.VBox('Parent',gui.panels.invstd.main,...
    'Spacing',3,'Padding',3);

% inversion method
gui.panels.invstd.HBox1 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);
% min and max values of relaxation time distribution
gui.panels.invstd.HBox2 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);
% optional inversion settings depending on inversion type
gui.panels.invstd.HBox3 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);
% smoothness constraint / order of regularized solution
gui.panels.invstd.HBox4 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);
% min and max values of the L-curve
gui.panels.invstd.HBox5 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);
% RUN button
gui.panels.invstd.HBox6 = uix.HBox('Parent',gui.panels.invstd.VBox,...
    'Spacing',3);

%% inversion method
gui.text_handles.invstd_InvType = uicontrol('Parent',gui.panels.invstd.HBox1,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','inversion method');
switch data.info.ExpertMode
    case 'on'
        tstr = ' ';
        istring = {'Mono exp.','N free exp. (2-5)','Multi exp. (LSQ)','Multi exp. (LU decomp.)','Multi modal'};
    case 'off'
        tstr = ' ';
        istring = {'Mono exp.','N free exp. (2-5)','Multi exp. (LSQ)'};
end
gui.popup_handles.invstd_InvType = uicontrol('Parent',gui.panels.invstd.HBox1,...
    'Style','popup','String',istring,'FontSize',myui.fontsize,'Enable','off','Value',3,...
    'UserData',struct('Tooltipstr',tstr),'Callback',@onPopupInvstdType);
set(gui.panels.invstd.HBox1,'Widths',[200 -1]);

%% min and max values of relaxation time distribution
gui.text_handles.invstd_RTDtimes = uicontrol('Parent',gui.panels.invstd.HBox2,...
    'Style','text','FontSize',myui.fontsize,'String','RTD - min [s] | max [s] | # / dec');
tstr = 'Lower bound of relaxation time spectra.';
gui.edit_handles.invstd_time_min = uicontrol('Parent',gui.panels.invstd.HBox2,...
    'Style','edit','String',num2str(data.invstd.time(1,1)),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.time(1,1) 1 1]),...
    'Tag','invstd_time','Enable','off','Callback',@onEditValue);
tstr = 'Upper bound of relaxation time spectra.';
gui.edit_handles.invstd_time_max = uicontrol('Parent',gui.panels.invstd.HBox2,...
    'Style','edit','String',num2str(data.invstd.time(1,2)),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.time(1,2) 1 2]),...
    'Tag','invstd_time','Enable','off','Callback',@onEditValue);
tstr = 'Number of steps per decade.';
gui.edit_handles.invstd_Ntime = uicontrol('Parent',gui.panels.invstd.HBox2,...
    'Style','edit','String',num2str(data.invstd.Ntime),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.Ntime 1 1]),...
    'Tag','invstd_Ntime','Enable','off','Callback',@onEditValue);
set(gui.panels.invstd.HBox2,'Widths',[200 -1 -1 -1]);

%% optional inversion settings depending on inversion type
gui.text_handles.invstd_InvTypeOpt = uicontrol('Parent',gui.panels.invstd.HBox3,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','regularization options');
switch data.info.ExpertMode
    case 'on'
        tstr = ' ';
        rstring = {'Manual','Tikhonov (SVD)','TSVD (SVD)',...
            'DSVD (SVD)','Discrep. (SVD)','L-curve'};
    case 'off'
        tstr = ' ';
        rstring = {'Manual','L-curve'};
end
gui.popup_handles.invstd_InvTypeOpt = uicontrol('Parent',gui.panels.invstd.HBox3,...
    'Style','popup','String',rstring,'FontSize',myui.fontsize,'Enable','off','Value',1,...
    'UserData',struct('Tooltipstr',tstr),'Callback',@onPopupInvstdTypeOptional);
set(gui.panels.invstd.HBox3,'Widths',[200 -1]);

%% smoothness constraint / order of regularized solution
gui.text_handles.invstd_Lorder = uicontrol('Parent',gui.panels.invstd.HBox4,...
    'Style','text','FontSize',myui.fontsize,...
    'HorizontalAlignment','center','String','smoothness constraint (L-order)');
tstr = ['<HTML>Choose the smoothness constraint for the multi-exponential fitting routines.<br><br>',...
    '<u>Available options:</u><br>',...
    '<font color="red">Mono exp. | Several free exp. (2-5):<br>',...
    '<font color="black"><b>none</b><br>',...
    '<font color="red">Multi exp. (LSQ) | Multi exp. (LU decomp.):<br>',...
    '<font color="black">',...
    '<b>0</b> Zeroth-order smoothness constraint.<br>',...
    '<b>1</b> First-order smoothness constraint.<br>',...
    '<b>2</b> Second-order smoothness constraint.<br><br>',...
    '<u>Default value:</u><br>',...
    '<b>1</b><br>'];
gui.radio_handles.invstd_Lorder0 = uicontrol('Parent',gui.panels.invstd.HBox4,...
    'Style','radiobutton','String','0','Tag','invstd','FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),'Enable','off','Callback',@onRadioLorder);
gui.radio_handles.invstd_Lorder1 = uicontrol('Parent',gui.panels.invstd.HBox4,...
    'Style','radiobutton','String','1','Tag','invstd','FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),'Enable','off','Callback',@onRadioLorder);
gui.radio_handles.invstd_Lorder2 = uicontrol('Parent',gui.panels.invstd.HBox4,...
    'Style','radiobutton','String','2','Tag','invstd','FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr),'Enable','off','Callback',@onRadioLorder);
set(gui.panels.invstd.HBox4,'Widths',[200 -1 -1 -1]);

%% min and max values of the L-curve
gui.text_handles.invstd_lambda = uicontrol('Parent',gui.panels.invstd.HBox5,...
    'Style','text','FontSize',myui.fontsize,...
    'String','lambda  -  min | max | #');
tstr = 'Lambda value / Smallest Lambda in range.';
gui.edit_handles.invstd_lambda_min = uicontrol('Parent',gui.panels.invstd.HBox5,...
    'Style','edit','String',num2str(data.invstd.lambda),'FontSize',myui.fontsize,...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.lambdaR(1,1) 1 1]),...
    'Tag','invstd_lambdaR','Enable','off','Callback',@onEditValue);
tstr = 'Largest Lambda in range.';
gui.edit_handles.invstd_lambda_max = uicontrol('Parent',gui.panels.invstd.HBox5,...
    'Style','edit','String',num2str(data.invstd.lambdaR(1,2)),...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.lambdaR(1,2) 1 2]),...
    'Tag','invstd_lambdaR','FontSize',myui.fontsize,...
    'Enable','off','Callback',@onEditValue);
tstr = 'Number of Lambdas in L-curve.';
gui.edit_handles.invstd_NlambdaR = uicontrol('Parent',gui.panels.invstd.HBox5,...
    'Style','edit','String',num2str(data.invstd.NlambdaR),...
    'UserData',struct('Tooltipstr',tstr,'defaults',[data.invstd.NlambdaR 1 1]),...
    'Tag','invstd_NlambdaR','FontSize',myui.fontsize,...
    'Enable','off','Callback',@onEditValue);
set(gui.panels.invstd.HBox5,'Widths',[200 -1 -1 -1]);

%% RUN button
gui.text_handles.invstd_run = uicontrol('Parent',gui.panels.invstd.HBox6,...
    'Style','text','FontSize',myui.fontsize,'HorizontalAlignment','center',...
    'String','run Inversion');
gui.push_handles.invstd_run = uicontrol('Parent',gui.panels.invstd.HBox6,'Enable','off',...
    'String','<HTML><u>R</u>UN','FontSize',myui.fontsize,'BackGroundColor','g',...
    'Tag','std','UserData',1,'Callback',@onPushRun);
set(gui.panels.invstd.HBox6,'Widths',[200 -1]);

%% Java Hack to adjust vertical alignment of text fields
jh = findjobj(gui.text_handles.invstd_InvType);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
jh = findjobj(gui.text_handles.invstd_RTDtimes);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
jh = findjobj(gui.text_handles.invstd_InvTypeOpt);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
jh = findjobj(gui.text_handles.invstd_Lorder);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
jh = findjobj(gui.text_handles.invstd_lambda);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
jh = findjobj(gui.text_handles.invstd_run);
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