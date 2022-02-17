function onPopupGeometryModesN(src,~)
%onPopupGeometryModesN handles the call from the popup menu to select the
%number of modes per PSD
%
% Syntax:
%       onPopupGeometryModesN
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupGeometryModesN(src,~)
%
% Other m-files required:
%       calculateGeometry
%       removeCalculationFields
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

% get the number of modes (1-3)
data.geometry.modesN = get(src,'Value');

% remove data fields because the PSD changed
data = removeCalculationFields(data,'cps');
data = removeCalculationFields(data,'nmr');
% update GUI data
setappdata(fig,'data',data);
% recalculate geometry
calculateGeometry;

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