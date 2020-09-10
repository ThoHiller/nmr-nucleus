function onMenuExtraColor(src,~)
%onMenuExtraColor handles the color theme menu of both GUIs
%
% Syntax:
%       onMenuExtraColor(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraColor(src)
%
% Other m-files required:
%       changeColorTheme
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
data = getappdata(fig,'data');

% get the menu label
label = get(src,'Label');

% mark the selected menu entry
switch label
    case 'standard'
        set(gui.menu.color_theme_standard,'Checked','on');
        set(gui.menu.color_theme_basic,'Checked','off');
        set(gui.menu.color_theme_dark,'Checked','off');
        set(gui.menu.color_theme_black,'Checked','off');
    case 'basic'
        set(gui.menu.color_theme_standard,'Checked','off');
        set(gui.menu.color_theme_basic,'Checked','on');
        set(gui.menu.color_theme_dark,'Checked','off');
        set(gui.menu.color_theme_black,'Checked','off');
    case 'dark'
        set(gui.menu.color_theme_standard,'Checked','off');
        set(gui.menu.color_theme_basic,'Checked','off');
        set(gui.menu.color_theme_dark,'Checked','on');
        set(gui.menu.color_theme_black,'Checked','off');
    case 'black'
        set(gui.menu.color_theme_standard,'Checked','off');
        set(gui.menu.color_theme_basic,'Checked','off');
        set(gui.menu.color_theme_dark,'Checked','off');
        set(gui.menu.color_theme_black,'Checked','on');
end

% adjust the colors
changeColorTheme(fig_tag,label);

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