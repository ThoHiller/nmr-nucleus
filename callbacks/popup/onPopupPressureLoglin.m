function onPopupPressureLoglin(src,~)
%onPopupPressureLoglin select if the pressure range values are spaced
%linearly or logarithmically
%
% Syntax:
%       onPopupPressureLoglin
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupPressureLoglin(src,~)
%
% Other m-files required:
%       clearSingleAxis.m
%       updateCPSTable.m
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
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

% get the value of the popup menu
value = get(src,'Value');

% change settings accordingly
switch value
    case 1 % log        
        data.pressure.loglin = 1;
        
    case 2 % lin        
        data.pressure.loglin = 0;        
end
% remove old fields
data = removeCalculationFields(data,'cps');
data = removeCalculationFields(data,'nmr');
% update GUI data
setappdata(fig,'data',data);
% update CPS table
updateCPSTable('clear');
% reset NMR plot
clearSingleAxis(gui.axes_handles.nmr);

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