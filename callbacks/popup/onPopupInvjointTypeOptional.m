function onPopupInvjointTypeOptional(src,~)
%onPopupInvjointTypeOptional select regularization option for the joint
%inversion only if the inversion method is "free"
%
% Syntax:
%       onPopupInvjointTypeOptional
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupInvjointTypeOptional(src,~)
%
% Other m-files required:
%       clearSingleAxis
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
gui = getappdata(fig,'gui');

% get value of the popup menu
value = get(src,'Value');
% get the inversion method
invtype = data.invjoint.invtype;

% change settings accordingly
switch invtype    
    case 'free'        
        switch value % different regularization options/methods            
            case 1 % manual                
                data.invjoint.regtype = 'manual';
                data.invjoint.lambda = 1;
                
            case 2 % l-curve                
                data.invjoint.regtype = 'lcurve';
                data.invjoint.lambdaR = data.invjoint.lambdaRinit;
                clearSingleAxis(gui.axes_handles.rtd);
                clearSingleAxis(gui.axes_handles.psd);                
        end
        
    otherwise
        data.invjoint.lambda = 1;        
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