function onMenuHelp(src,~)
%onMenuHelp shows the Help Information for both GUIs
%
% Syntax:
%       onMenuHelp
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuHelp(src)
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');
load('NUCLEUS_logo.mat','logo');

% header info
switch fig_tag
    case 'INV'
        header{1,1}  = 'NUCLEUSinv:';
    case 'MOD'
        header{1,1}  = 'NUCLEUSmod:';
end
header{end+1,1}  = ' ';
header{end+1,1}  = ['authors: ',gui.myui.author{1},', ',gui.myui.author{2}];
header{end+1,1}  = ' ';
header{end+1,1}  = ['version: ',gui.myui.version];
header{end+1,1}  = ' ';
header{end+1,1}  = ['date: ',gui.myui.date];
header{end+1,1}  = ' ';

switch fig_tag
    case 'INV'
        % info text
        info{1,1} = ['NUCLEUSinv is a Graphical User Interface for processing NMR Lab Data.',...
            ' It allows standard NMR data inversion for relaxation time distributions (RTD).',...
            ' Additionally, it is possible to perform a joint inversion (together with CPS data) to directly infer a pore size distribution (PSD).'...
            ' Inversion results can be exported into different file formats and images for further processing or documentation purposes.'];
        
    case 'MOD'
        % info text
        info{1,1} = ['NUCLEUSmod is a Graphical User Interface for modeling NMR Lab Data. The',...
            ' user can create pore size distributions (PSD) based on a capillary bundle model where the capillaries',...
            ' exhibit different cross-sectional shapes. Based on a chosen capillary pressure range, the pore model gets partially saturated'...
            ' and a capillary pressure saturation curve (CPS) is calculated. Finally, NMR signals are calculated for every CPS curve point.'];
        
end
info{end+1,1} = ' ';
info{end+1,1} = 'Have Fun!';


% get GUI position
posf = get(fig,'Position');
% default widht and height of About Figure
ww = 560; hh = 420;
xp = posf(1) + (posf(3)-ww)/2;
yp = posf(2) + (posf(4)-hh)/2;
% create Figure
hf = figure('Name',['About ',header{1,1}],...
    'NumberTitle','off','Tag','Help','ToolBar','none','MenuBar','none',...
    'Resize','off','Position',[xp yp ww hh],'Visible','off');
v1 = uix.VBox('Parent',hf,'Padding',10,'Spacing',10);

% text area
h1 = uix.VBox('Parent',v1);
% button area
h2 = uix.HBox('Parent',v1);
set(v1,'Heights',[-1 30]);

% text area
h3 = uix.HBox('Parent',h1);
% logo area
h4 = uix.HBox('Parent',h1);
set(h1,'Heights',[-1 -1]);

% close button at the bottom
uix.Empty('Parent',h2);
p1 = uicontrol('Style','pushbutton','Parent',h2,'String','OK',...
    'FontSize',10,'Callback','closereq()');
uix.Empty('Parent',h2);
set(h2,'Widths',[-1 50 -1])

% header
uix.Empty('Parent',h3);
t1 = uicontrol('Style','Text','Parent',h3,'String',header,...
    'FontSize',10,'HorizontalAlignment','left');
% logo
c1 = uicontainer('Parent',h3);
ax1 = axes('Parent',c1);
imshow(logo,'Parent',ax1);
set(h3,'Widths',[50 -1 -1]);

% info text
uix.Empty('Parent',h4);
t2 = uicontrol('Style','Text','Parent',h4,'String',info,...
    'FontSize',10,'HorizontalAlignment','left');
uix.Empty('Parent',h4);
set(h4,'Widths',[20 -1 20])

% text hack
jh = findjobj(t1);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER)

set(hf,'Visible','on');

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