function onMenuSolver(src,~)
%onMenuSolver handles the call from the menu that allows to choose the LSQ
%solver
%
% Syntax:
%       onMenuSolver
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuSolver(src,~)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%       updateStatusInformation
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

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% solver
solver = get(src,'Label');

% switch solver
if contains(solver,'LSQLIN')
        data.info.solver = 'lsqlin';
        % menu entry
        set(gui.menu.extra_solver_lsqlin,'Checked','on');
        set(gui.menu.extra_solver_lsqnonneg,'Checked','off');

        set(gui.menu.extra_lsqlin_echoflag,'Enable','on');

elseif contains(solver,'LSQNONNEG')
        data.info.solver = 'lsqnonneg';
        % menu entry
        set(gui.menu.extra_solver_lsqlin,'Checked','off');
        set(gui.menu.extra_solver_lsqnonneg,'Checked','on');
        
        data.info.EchoFlag = 'off';
        set(gui.menu.extra_lsqlin_echoflag,'Checked','off');
        set(gui.menu.extra_lsqlin_echoflag,'Enable','off');
end

% update GUI data
setappdata(fig,'data',data);
setappdata(fig,'gui',gui);
% update interface
NUCLEUSinv_updateInterface;
% update status information
updateStatusInformation(fig);
updateToolTips;

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Thomas Hiller
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