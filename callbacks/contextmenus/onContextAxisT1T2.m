function onContextAxisT1T2(src,~)
%onContextAxisT1T2 checks the axis context menu for plotting either T1 or
%T2 data and updates the corresponding axes
%
% Syntax:
%       onContextAxisT1T2
%
% Inputs:
%       src - Handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onContextAxisT1T2(src,~)
%
% Other m-files required:
%       updatePlotsNMR
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

% get the label of the context menu
label = get(src,'Label');
data.nmr.toplot = label;

% depending on the current label, set a check mark and uncheck the other one
switch label    
    case 'T1'        
        set(src,'Checked','on');
        set(gui.cm_handles.nmr_cm_showT2,'Checked','off');        
    case 'T2'        
        set(src,'Checked','on');        
        set(gui.cm_handles.nmr_cm_showT1,'Checked','off');
end

% update the GUI data
setappdata(fig,'data',data);
setappdata(fig,'gui',gui);
% update the plot axes
updatePlotsNMR;

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