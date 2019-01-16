function updateCPSTableSize(inc)
%updateCPSTableSize adds/removes one row of the CPS table in NUCLEUSinv
%
% Syntax:
%       updateCPSTableSize(inc)
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updateCPSTableSize(1)
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
fig  = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get the table
table = get(gui.table_handles.invjoint_table,'Data');
% how many rows
rows = size(table,1);
% +1 or -1
newrows = rows + inc;

if newrows > 0    
    if inc > 0
        newtable = table;
        newtable(end+1,:) = table(end,:);
    elseif inc < 0
        newtable = table(1:end-1,:);
    end
    
    % update the table
    data.pressure.table = newtable;
    % set to GUI
    set(gui.table_handles.invjoint_table,'Data',newtable);
    % update GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'gui',gui);
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