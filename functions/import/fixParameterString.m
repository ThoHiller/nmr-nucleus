function str = fixParameterString(str)
%fixParameterString cleans parameter file lines when the properties have a
%leading number; e.g. "90Amplitude" is changed to "Amplitude90"
%
% Syntax:
%       str = fixParameterString(str)
%
% Inputs:
%       str - string as read from a single line of the parameter file
%
% Outputs:
%       str - fixed string (cleared leading numbers)
%
% Example:
%       'Amplitude90= -7' = fixParameterString('90Amplitude = -7')
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

%% check for 90 at beginning
if strncmpi(str,'90',2)
    streq = strfind(str,'=');
    strnew = [strtrim(str(3:streq(1)-1)),'90 ',str(streq(1):end)];
    str = strnew;
end
%% check for 180 at beginning
if strncmpi(str,'180',3)
    streq = strfind(str,'=');
    strnew = [strtrim(str(4:streq(1)-1)),'180 ',str(streq(1):end)];
    str = strnew;
end
%% check for " and make it ''
str = strrep(str,'"','''');

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