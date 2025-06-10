function minimizePanel(src,~)
%minimizePanel handles the minimization/maximization of all box-panels for
%both GUIs
%
% Syntax:
%       minimizePanel
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       minimizePanel(src,~)
%
% Other m-files required:
%       findParentOfType
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
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');

% get the corresponding box-panel to be minimized / maximized
panel = findParentOfType(src,'uix.BoxPanel');
% panel title
paneltitle = get(panel,'Title');
% check if panel is minimized (true)
isminimized = get(panel,'Minimized');

% minimized height (default value for all box-panels)
pheightmin = 22;
% default heights
def_heights = gui.myui.heights;

% switch depending on figure tag
switch fig_tag
    case 'INV'
        panel_1 = 'Simple Processing';
        panel_2 = 'Petro Parameter';
        panel_3 = 'Standard Inversion';
        panel_4 = 'Joint Inversion';
        panel_5 = 'CPS (joint)';

        switch paneltitle
            case panel_1
                id = 2;
            case {panel_2,panel_5}
                id = 3;
            case panel_3
                id = 4;
            case panel_4
                id = 5;
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

        switch paneltitle
            case {panel_1,panel_2,panel_3,panel_4}
                % all heights of the left panels
                heights = get(gui.panels.main,'Heights');
                % default height of this panel
                pheight = def_heights(2,id);
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',true)
                end
                onFigureSizeChange(fig);
            case panel_5
                % all heights of the graphic panels
                heights = get(gui.center,'Heights');
                % default height of all graphic panels
                pheight = -1;
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.center,'Heights',heights);
                    set(panel,'Minimized',false);
                    set(gui.panels.info.main,'Heights',[-1 -1 -1]);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.center,'Heights',heights);
                    set(panel,'Minimized',true);
                    set(gui.panels.info.main,'Heights',[-1 -1 0]);
                end
                onFigureSizeChange(fig);
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

    case 'MOD'
        panel_1 = 'Geometry';
        panel_2 = 'Pressure / Saturation';
        panel_3 = 'NMR';
        panel_4 = 'Pore Size Distribution';
        panel_5 = 'Capillary Pressure Saturation Curve';
        panel_6 = 'NMR Signals';

        switch paneltitle
            case {panel_1,panel_4}
                id = 1;
            case {panel_2,panel_5}
                id = 2;
            case {panel_3,panel_6}
                id = 3;
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

        switch paneltitle
            case {panel_1,panel_2,panel_3}
                % all heights of the left panels
                heights = get(gui.panels.main,'Heights');
                % default height of this panel
                pheight = def_heights(2,id);
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',true)
                end
                onFigureSizeChange(fig);
            case {panel_4,panel_5,panel_6}
                % all heights of the graphic panels
                heights = get(gui.right,'Heights');
                % default height of all graphic panels
                pheight = -1;
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.right,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.right,'Heights',heights);
                    set(panel,'Minimized',true)
                end
                onFigureSizeChange(fig);
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

    case 'UNCERTVIEW'
        panel_1 = 'Recalculate RTD Uncertainty';
        panel_2 = 'Process Uncertainty Runs';
        panel_3 = 'RTD Calculation Bounds';
        panel_4 = 'Uncertainty Statistics';

        switch paneltitle
            case panel_1
                id = 1;
            case panel_2
                id = 2;
            case panel_3
                id = 3;
            case panel_4
                id = 4;
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

        switch paneltitle
            case {panel_1,panel_2,panel_3,panel_4}
                % all heights of the left panels
                heights = get(gui.left,'Heights');
                % default height of this panel
                pheight = def_heights(2,id);
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.left,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.left,'Heights',heights);
                    set(panel,'Minimized',true)
                end
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end
        
    case '2DINV'
        panel_1 = 'Properties';
        panel_2 = '2D inversion settings';
        panel_3 = 'Regularisation - "L-curve"';
        panel_4 = 'Information';

        switch paneltitle
            case panel_1
                id = 1;
            case panel_2
                id = 2;
            case panel_3
                id = 3;
            case panel_4
                id = 4;
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

        switch paneltitle
            case {panel_1,panel_2,panel_3,panel_4}
                % all heights of the left panels
                heights = get(gui.panels.main,'Heights');
                % default height of this panel
                pheight = def_heights(2,id);
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',true)
                end
                onFigureSizeChange(fig);
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

    case '2DMOD'
        panel_1 = '2D modelling settings';
        panel_2 = 'Properties';
        panel_3 = 'NMR signals';

        switch paneltitle
            case panel_1
                id = 1;
            case panel_2
                id = 2;
            case panel_3
                id = 3;
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end

        switch paneltitle
            case {panel_1,panel_2,panel_3}
                % all heights of the left panels
                heights = get(gui.panels.main,'Heights');
                % default height of this panel
                pheight = def_heights(2,id);
                if isminimized % maximize panel
                    heights(id) = pheight;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',false);
                else % minimize panel
                    heights(id) = pheightmin;
                    set(gui.panels.main,'Heights',heights);
                    set(panel,'Minimized',true)
                end
                onFigureSizeChange(fig);
            otherwise
                helpdlg({'function: minimizePanel',...
                    'Something is utterly wrong.'},'Info');
        end
end
% update GUI data
setappdata(fig,'gui',gui);

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