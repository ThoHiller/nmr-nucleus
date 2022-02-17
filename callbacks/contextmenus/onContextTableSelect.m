function onContextTableSelect(src,~)
%onContextTableSelect selects or deselects whole drainage and imbibition
%data in NUCLEUSmod
%
% Syntax:
%       onContextTableSelect
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onContextTableSelect(src,~)
%
% Other m-files required:
%       updatePlotsCPS
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
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get the tag of the context menu
tag = get(src,'Tag');
% get the label of the context menu
label = get(src,'Label');

% get current table data
table = get(gui.table_handles.pressure_table,'Data');
% get the checkbox status
drain = cell2mat(table(:,3));
imb = cell2mat(table(:,5));

switch tag
    case 'select'
        switch label
            case 'drainage'
                drain = true(size(drain));
            case 'imbibition'
                imb = true(size(imb));
        end
        
    case 'deselect'
        switch label
            case 'drainage'
                drain = false(size(drain));
            case 'imbibition'
                imb = false(size(imb));
        end
end

% update checkboxes in table
table(:,3) = num2cell(drain);
table(:,5) = num2cell(imb);
set(gui.table_handles.pressure_table,'Data',table);
% update internal data
DrainLevels = 1:1:data.pressure.rangeN;
ImbLevels = 1:1:data.pressure.rangeN;
data.pressure.DrainLevels = DrainLevels(drain);
data.pressure.ImbLevels = ImbLevels(imb);
% update the GUI data
setappdata(fig,'data',data);
% update the CPS axis
updatePlotsCPS;
% update the NMR axis
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