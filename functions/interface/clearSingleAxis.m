function clearSingleAxis(axh)
%clearSingleAxis clears an individual axis
%
% Syntax:
%       clearSingleAxis(axh)
%
% Inputs:
%       axh - axis handle
%
% Outputs:
%       none
%
% Example:
%       clearSingleAxis(gca)
%
% Other m-files required:
%       clearSingleAxis
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

%% get the parent of the axis and find possible legends
parent = get(axh,'Parent');
lgh = findobj('Type','legend','Parent',parent);
if ~isempty(lgh)
    delete(lgh);
end

%% look for specific tags and clear corresponding objects
ph = findall(axh,'Tag','SatPoints');
if ~isempty(ph); set(ph,'HandleVisibility','on'); end

ph = findall(axh,'Tag','fits');
if ~isempty(ph); set(ph,'HandleVisibility','on'); end

%% clear the axis itself
cla(axh);

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