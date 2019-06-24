function data = cleanupGUIData(data)
%cleanupGUIData removes unnecessary fields from the global "data" struct
%
% Syntax:
%       data = cleanupGUIData(data)
%
% Inputs:
%       data - global GUI data struct
%
% Outputs:
%       data
%
% Example:
%       data = cleanupGUIData(data)
%
% Other m-files required:
%       clearAllAxes
%       createPSD
%       getGeometryParameter
%       getPressureRangeFromPSD
%       NUCLEUSmod_updateInterface
%       updatePlotsPSD
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

%% remove all temporary fields
if isfield(data.import,'NMR')
    data.import = rmfield(data.import,'NMR');
end

if isfield(data.import,'NMRMOD')
    data.import = rmfield(data.import,'NMRMOD');
end

if isfield(data.import,'BGR')
    data.import = rmfield(data.import,'BGR');
end

if isfield(data.import,'LIAG')
    data.import = rmfield(data.import,'LIAG');
end

if isfield(data.import,'BAM')
    data.import = rmfield(data.import,'BAM');
end

if isfield(data,'results')
    data = rmfield(data,'results');
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