function onPopupInvjointGeometryType(src,~)
%onPopupInvjointGeometryType selects the joint inversion geometry (dependend
%on inversion type)
%
% Syntax:
%       onPopupInvjointGeometryType
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupInvjointGeometryType(src,~)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
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
data = getappdata(fig,'data');

% get the geometry
value = get(src,'Value');

% get the inversion method
invtype = data.invjoint.invtype;

% change settings accordingly
switch invtype    
    case {'free','fixed'}        
        switch value            
            case 1 % cylindrical                
                data.invjoint.geometry_type = 'cyl';
                data.invjoint.polyN = 3;
                
            case 2 % rectangular                
                data.invjoint.geometry_type = 'ang';
                data.invjoint.polyN = 3;
                
            case 3 % polygon                
                data.invjoint.geometry_type = 'poly'; 
        end
        
    case 'shape'        
        switch value            
            case {1,3} % cylindrical or polygon                
                data.invjoint.geometry_type = 'ang';
                data.invjoint.polyN = 3;
                helpdlg({'onPopupInvjointGeometryType:',...
                    'For shape inversion only rectangular geometry is possible'},...
                    'invalid option');
                
            case 2 % rectangular                
                data.invjoint.geometry_type = 'ang';
                data.invjoint.polyN = 3;
        end
end

% update GUI data
setappdata(fig,'data',data);
% update interface
NUCLEUSinv_updateInterface;

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