function onMenuExportGraphics(src,~)
%onMenuExportGraphics handles the graphics export menu and calls the export
%function with the corresponding file type flag. Because the gui elements
%are identical in NUCLEUSinv & NUCLEUSmod the routine can be used by both
%GUIs
%
% Syntax:
%       onMenuExportGraphics
%
% Inputs:
%       src - Handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExportGraphics(src,~)
%
% Other m-files required:
%       exportGraphics
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
% get its unique tag
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');

% the label of the context menu
label = get(src,'Label');

% depending on the label call the export function with the correct file
% type
switch label    
    case 'vert'
        set(gui.menu.file_export_graphics_layout_vert,'Checked','on');
        set(gui.menu.file_export_graphics_layout_horz,'Checked','off');
    case 'horz'
        set(gui.menu.file_export_graphics_layout_vert,'Checked','off');
        set(gui.menu.file_export_graphics_layout_horz,'Checked','on');
    case 'FIG'
        exportGraphics(fig_tag,'fig');
    case 'PNG'
        exportGraphics(fig_tag,'png');
    case 'TIFF'
        exportGraphics(fig_tag,'tiff');
    case 'EPS'
        exportGraphics(fig_tag,'eps');
end
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