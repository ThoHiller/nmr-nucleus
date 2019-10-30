function version = getVersionNoFromString(version_str)
%getVersionNoFromString converts the version string to a numeric value
%
% Syntax:
%       version = getVersionNoFromString(version_str)
%
% Inputs:
%       version_str - version str
%
% Outputs:
%       version - version as number
%
% Example:
%       version = getVersionNoFromString('0.1.5')
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% remove points
version_str = strrep(version_str,'.','');
% convert string to numeric value
version = str2double(version_str);

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Thomas Hiller
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