function updateStatusInformation(fig)
%updateStatusInformation updates all fields inside the bottom status bar
%
% Syntax:
%       updateStatusInformation(fig)
%
% Inputs:
%       fig - GUI handle
%
% Outputs:
%       none
%
% Example:
%       updateStatusInformation(fig)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

switch fig_tag
    case 'INV'
        switch data.info.ExpertMode
            case 'on'
                set(gui.textMode,'String','Expert Mode: ON');
            case 'off'
                set(gui.textMode,'String','Expert Mode: OFF');
        end
        
        switch data.info.has_optim
            case 'on'
                set(gui.textOptim,'String','Optim. Toolbox: ON');
            case 'off'
                set(gui.textOptim,'String','Optim. Toolbox: OFF');
        end
        
        switch data.info.solver
            case 'lsqnonneg'
                set(gui.textSolver,'String','LSQNONNEG');
            case 'lsqlin'
                set(gui.textSolver,'String','LSQLIN');
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
        
        set(gui.textVersion,'String',['Version: ',gui.myui.version]);
        
    case 'MOD'
        
        switch data.geometry.type
            case 'cyl'
                set(gui.textGeom,'String','GEOM: cylindrical');
            case 'ang'
                set(gui.textGeom,'String','GEOM: right-angular');
            case 'poly'
                set(gui.textGeom,'String','GEOM: polygon');
        end
        
        switch data.geometry.ispsd
            case 0
                set(gui.textPSD,'String','PSD: OFF');
            case 1
                set(gui.textPSD,'String','PSD: ON');
        end
        
        switch data.info.ToolTips
            case 'on'
                set(gui.textTooltips,'String','Tooltips: ON');
            case 'off'
                set(gui.textTooltips,'String','Tooltips: OFF');
        end
        
        set(gui.textVersion,'String',['Version: ',gui.myui.version]);
        
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