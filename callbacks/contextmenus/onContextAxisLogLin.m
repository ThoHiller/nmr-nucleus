function onContextAxisLogLin(src,~)
%onContextAxisLogLin changes the label of an axis context menu which allows to
%switch the x-axis from log to lin scale and vice versa.
%
% Syntax:
%       onContextAxisLogLin
%
% Inputs:
%       src - Handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onContextAxisLogLin(src,~)
%
% Other m-files required:
%       updatePlotsSignal
%       updatePlotsJointInversion
%       updatePlotsNMR
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod, NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');

% get the label of the context menu
label = get(src,'Label');
% get the tag of the context menu
tag = get(src,'Tag');

% change the label depending on the current status
if ~isempty(strfind(label,'log')) % current axis is lin -> switch to log
    label = strrep(label,'log','lin');
else % current axis is log -> switch to lin
    label = strrep(label,'lin','log');    
end
set(src,'Label',label);

% call the respective functions that update the plot axes
switch fig_tag
    case 'INV'
        updatePlotsSignal;
        updatePlotsJointInversion;
    case 'MOD'
        updatePlotsNMR;
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