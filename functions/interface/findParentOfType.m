function ph = findParentOfType(h,type)
%findParentOfType is a "hack" because Matlab changed the parent-child
%hierarchy for some graphical objects
%2018: the minimize checkbox is a child of the uix.BoxPanel
%2014: the minimize checkbox is a child of a uicontainer -> child of a HBox ->
%child of a the BoxPanel
%
% Syntax:
%       ph = findParentOfType(h,type)
%
% Inputs:
%       h - handle
%       type - type to look for
%
% Outputs:
%       ph - handle of parent object
%
% Example:
%       ph = findParentOfType(h,type)
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

lookingfor = true;
child = h;
while lookingfor
    parent = get(child,'Parent');
    if isa(parent,type) % the parent uix.BoxPanel was found
        lookingfor = false;
        ph = parent;
    elseif isempty(parent) % nothing was found
        ph = [];
        disp('findParentOfType: No parent of specified type found.');
        break;
    else % set the current parent to child and continue
        child = parent;
    end
end

return

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