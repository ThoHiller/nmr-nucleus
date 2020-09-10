function onPopupGeometrySinglePSD(src,~)
%onPopupGeometrySinglePSD select if the geometry is a single pore or a pore
%size distribution
%
% Syntax:
%       onPopupGeometrySinglePSD
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupGeometrySinglePSD(src,~)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
data = getappdata(fig,'data');

% get the value of the popup menu
value = get(src,'Value');

% change settings accordingly
switch value    
    case 1 % single pore        
        data.geometry.ispsd = 0;
        data.geometry.modesN = 1;
        
    case 2 % PSD        
        data.geometry.ispsd = 1;
end

% remove data fields because the geometry has changed
data = removeCalculationFields(data,'cps');
data = removeCalculationFields(data,'nmr');
% update GUI data
setappdata(fig,'data',data);
% recalculate geometry
calculateGeometry;
% update status bar
updateStatusInformation(fig);

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