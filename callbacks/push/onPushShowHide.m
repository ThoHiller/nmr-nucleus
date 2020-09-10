function onPushShowHide(src,~)
%onPushShowHide shows/hides the INFO column on the right side of NUCLEUSinv
%
% Syntax:
%       onPushShowHide
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushShowHide(src,~)
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

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
gui = getappdata(fig,'gui');

% the HBOX containing the INFO column
hbox = get(src,'Parent');
% the TOP row containing "hbox"
panel = get(hbox,'Parent');%
% label of the push button
label = get(src,'String');

% proceed depending on the label
switch label        
    case '<' % show the INFO box
        set(panel,'Widths',[400 -1 260]);
        set(hbox,'Widths',[10 -1]);
        set(src,'String','>');
        set(gui.menu.view_infofields,'Checked','on')
        
    case '>' % hide the INFO box
        set(panel,'Widths',[400 -1 10]);
        set(hbox,'Widths',[10 0]);
        set(src,'String','<');
        set(gui.menu.view_infofields,'Checked','off')
end

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