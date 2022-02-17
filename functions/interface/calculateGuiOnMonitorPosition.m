function pos = calculateGuiOnMonitorPosition(aspect_ratio)
%calculateGuiOnMonitorPosition gets GUI position from monitor size
%and given aspect ratio
%
% Syntax:
%       pos = calculateGuiOnMonitorPosition(aspect_ratio)
%
% Inputs:
%       aspect_ratio - desired aspect ratio of the GUI
%
% Outputs:
%       pos - position on screen
%
% Example:
%       pos = calculateGuiOnMonitorPosition(16/10)
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

%% get the monitor layout
scr = get(0,'MonitorPosition');
if size(scr,1) > 1
    % find main screen
    ind = find(scr(:,1)==1 & scr(:,2)==1);
    sw = scr(ind,3); % width
    sh = scr(ind,4); % height
else
    sw = scr(3); % width
    sh = scr(4); % height
end

%% GUI positioning
if any(sh<800)
    gh = 600; % reference height for small screens
else
    gh = 730; % reference height
end
% reference width
gw = ceil(gh*aspect_ratio); % 960 or 1152
% GUI position
pos = round([(sw-gw)/2 (sh-gh)/3 gw gh]);

return

%------------- END OF CODE --------------

% License:
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