function onFigureSizeChange(fig,~)
%onFigureSizeChange fixes an ugly Matlab bug when resizing a box-panel
%which holds an axis and a legend. This problem occurs even though the
%axis is inside a uicontainer to group all axes elements. And it only
%occurs for box-panels. If the uicontainer, which holds axis and legend, 
%is inside a tab-panel this problem does not occur. They had one job ... m(
%
% Syntax:
%       onFigureSizeChange(fig,~)
%
% Inputs:
%       fig - handle of the calling figure
%
% Outputs:
%       none
%
% Example:
%       onFigureSizeChange(h)
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

%% get GUI data
gui = getappdata(fig,'gui');

% proceed if there is data
if ~isempty(gui)
    if isfield(gui,'panels')
        heights = get(gui.panels.main,'Heights');
        set(gui.left,'Heights',-1,'MinimumHeights',sum(heights(2:end))+250);
        % check if CPS settings panel is activated
        if heights(end) > 100
            % check if there is a vertical scrollbar
            hpos = get(gui.top,'InnerPosition');
            if get(gui.left,'MinimumHeights') > hpos(4)
                % if yes shift the table slightly to the right to avoid
                % horizontal resizing
                set(gui.panels.invjoint.TabCPS,'Widths',[180 -1]);
            else
                % if not use the default layout
                set(gui.panels.invjoint.TabCPS,'Widths',[200 -1]);
            end
        end
        % check if process panel is activated
        if heights(2) > 100
            % check if there is a vertical scrollbar
            hpos = get(gui.top,'InnerPosition');
            if get(gui.left,'MinimumHeights') > hpos(4)
                % if yes shift the hbox2 slightly to the right
                set(gui.panels.process.HBox2,'Widths',[180 -1 -1 -1.5 50]);
            else
                % if not use the default layout
                set(gui.panels.process.HBox2,'Widths',[200 -1 -1 -1.5 50]);
            end
        end
    end
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