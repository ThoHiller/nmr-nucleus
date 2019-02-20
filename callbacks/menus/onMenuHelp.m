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
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');
myui = gui.myui;
load('NUCLEUS_logo.mat','logo');

switch fig_tag
    
    case 'INV'

        info{1,1}  = 'NUCLEUSinv:';
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['author: ',myui.author];
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['version: ',myui.version];
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['date: ',myui.date];
        info{end+1,1}  = ' ';
        
        switch data.info.optim
            case 'on'
                info{end+1,1}  = 'Optimization Toolbox: IS available.';
                info{end+1,1}  = 'All inversion features can be used.';
            case 'off'
                info{end+1,1}  = 'Optimization Toolbox: IS NOT available.';
                info{end+1,1}  = 'All multi-exponential fitting is done with ''lsqnonneg'' instead of ''lsqlin''.';
                info{end+1,1}  = 'For the Joint Inversion only the ''fixed'' and ''shape'' inversion options are available (using ''fminsearchbnd'').';
        end
        info{end+1,1} = ' ';
        switch data.info.stat
            case 'on'
                info{end+1,1}  = 'Statistics Toolbox: IS available.';
                info{end+1,1}  = 'All statistics features can be used.';
            case 'off'
                info{end+1,1}  = 'Statistics Toolbox: IS NOT available.';
                info{end+1,1}  = 'Confidence interval is calculated with basic ''getStudentInvCDF'' routine.';
        end
        info{end+1,1} = ' ';
        info{end+1,1} = ['NUCLEUSinv is a Graphical User Interface for processing NMR Lab Data. It',...
            ' allows standard NMR data inversion for relaxation time distributions (RTD).',...
            ' Additionally, it is possible to perform a joint inversion (together with CPS data) to directly infer a pore size distribution (PSD).'...
            ' Inversion results can be exported into different file formats and images for further processing or documentation purposes.'];
        info{end+1,1} = ' ';
        info{end+1,1} = 'Have Fun!';
        
        hh = msgbox(info,'About NUCLEUSinv:','custom',logo);
        
    case 'MOD'
        
        info{1,1}  = 'NUCLEUSmod:';
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['author: ',myui.author];
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['version: ',myui.version];
        info{end+1,1}  = ' ';
        info{end+1,1}  = ['date: ',myui.date];
        info{end+1,1}  = ' ';
        
        info{end+1,1} = ['NUCLEUSmod is a Graphical User Interface for modeling NMR Lab Data. The',...
            ' user can create pore size distributions (PSD) based on a capillary bundle model where the capillaries',...
            ' exhibit different cross-sectional shapes. Based on a chosen capillary pressure range, the pore model gets partially saturated'...
            ' and a capillary pressure saturation curve (CPS) is calculated. Finally, NMR signals are calculated for every CPS curve point.'];
        info{end+1,1} = ' ';
        info{end+1,1} = 'Have Fun!';
        
        hh = msgbox(info,'About NUCLEUSmod:','custom',logo);

end

% resize the info box
ui = findobj(hh,'Type','UIControl');
tt = findobj(hh,'Type','Text');
extent0 = get(tt,'Extent'); % text extent in old font
set([ui, tt],'FontSize',10);
extent1 = get(tt,'Extent'); % text extent in new font
delta = extent1 - extent0; % change in extent
pos = get(hh,'Position'); % current position
pos = pos + delta; % change size of box
set(hh,'Position',pos); % set new position

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