function data = removeInversionFields(data)
%removeInversionFields deletes all inversion result fields from NUCLEUSinv
%data struct
%
% Syntax:
%       data = removeInversionFields(data)
%
% Inputs:
%       data - GUI data struct
%
% Outputs:
%       data
%
% Example:
%       data = removeInversionFields(data)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% if results exists delete all available data
if isfield(data,'results')
    if isfield(data.results,'invstd')
        data.results = rmfield(data.results,'invstd');
    end
    if isfield(data.results,'invjoint')
        data.results = rmfield(data.results,'invjoint');
    end
    if isfield(data.results,'lcurve')
        data.results = rmfield(data.results,'lcurve');
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