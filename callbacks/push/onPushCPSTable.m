function onPushCPSTable(src,~)
%onPushStop handles all three push buttons on the CPS panel of the joint
%inversion in NUCLEUSinv
%
% Syntax:
%       onPushStop
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPushStop(src,~)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get button label
label = get(src,'String');

% proceed depending on label
switch label
    case '+' % ADD button
        % add one row to the table bottom
        updateCPSTableSize(1);
        
    case '-' % DEL button
        % delete one row from the table bottom
        updateCPSTableSize(-1);
        
    case 'LOAD' % LOAD button
        % import CPS data from file
        importCPSdata;
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
% SOFTWARE