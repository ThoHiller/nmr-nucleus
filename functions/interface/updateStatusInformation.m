function updateStatusInformation
%updateStatusInformation updates all fields inside the bottom status bar
%
% Syntax:
%       updateStatusInformation
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updateStatusInformation
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
fig = findobj('Tag','INV');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

switch data.info.ExpertMode
    case 'on'
        set(gui.textMode,'String','Expert Mode: ON');
    case 'off'
        set(gui.textMode,'String','Expert Mode: OFF');
end

switch data.info.optim
    case 'on'
        set(gui.textOptim,'String','Optim. Toolbox: ON');
    case 'off'
        set(gui.textOptim,'String','Optim. Toolbox: OFF');
end

switch data.info.stat
    case 'on'
        set(gui.textStats,'String','Stat. Toolbox: ON');
    case 'off'
        set(gui.textStats,'String','Stat. Toolbox: OFF');
end

switch data.info.JointInv
    case 'on'
        set(gui.textJoint,'String','Inv. Type: JOINT');
    case 'off'
        set(gui.textJoint,'String','Inv. Type: STD');
end

switch data.info.InvInfo
    case 'on'
        set(gui.textInvinfo,'String','Inv. Info: ON');
    case 'off'
        set(gui.textInvinfo,'String','Inv. Info: OFF');
end

switch data.info.ToolTips
    case 'on'
        set(gui.textTooltips,'String','Tooltips: ON');
    case 'off'
        set(gui.textTooltips,'String','Tooltips: OFF');
end

% Matlab takes some time
pause(0.001);

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