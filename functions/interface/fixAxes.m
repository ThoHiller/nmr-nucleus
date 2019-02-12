function fixAxes(src,~)
%fixAxes fixes an ugly Matlab bug when resizing a box-panel which holds an
%axis and a legend. This problem occurs even though the axis is inside a
%uicontainer to group all axes elements. And it only occurs for box-panels.
%If the uicontainer, which holds axis and legend, is inside a tab-panel this
%problem does not occur. They had one job ... m(
%
% Syntax:
%       fixAxes(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       fixAxes(src,~)
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
gui = getappdata(fig,'gui');

% get the tag of the calling uicontainer
tag = get(src,'Tag');

if ~isempty(gui)
    % get the position of an unaffected axis
    switch tag
        case 'CPS_INV'
            pos = get(gui.axes_handles.all,'Position');
        case 'CPS_MOD'
            pos = get(gui.axes_handles.geo,'Position');
    end

% update the position of the problematic axis with the position of
% the unaffected one; this can be done because the position inside the
% uicontainer is normalized
set(gui.axes_handles.cps,'Units','normalized','Position',pos);
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