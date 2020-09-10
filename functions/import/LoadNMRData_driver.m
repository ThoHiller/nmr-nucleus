function out = LoadNMRData_driver(in)
%LoadNMRData_driver loads NMR raw data from different file formats
%
% Syntax:
%       out = LoadNMRData_driver(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name (optional)
%       in.fileformat - varying
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_driver(in)
%
% Other m-files required:
%       LoadNMRData_rwth
%       LoadNMRData_field
%       LoadNMRData_dart
%       LoadNMRData_corelab
%       LoadNMRData_mouse
%       LoadNMRData_liag
%       LoadNMRData_bgr
%       LoadNMRData_bgr2
%       LoadNMRData_bgrmat
%       LoadNMRData_bamtom
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

%% select the routine depending on the file format
switch in.fileformat
    case 'bamtom'
        out = LoadNMRData_bamtom(in);
    case 'bgr'
        out = LoadNMRData_bgr(in);
    case 'bgr2'
        out = LoadNMRData_bgr2(in);
    case 'bgrmat'
        out = LoadNMRData_bgrmat(in);
    case 'corelab'
        out = LoadNMRData_corelab(in);
    case 'dart'
        in.version = 2; % use the updated mat-file format
        out = LoadNMRData_dart(in);
    case 'field'
        out = LoadNMRData_field(in);
    case 'liag'
        out = LoadNMRData_liag(in);
    case 'mouse'
        out = LoadNMRData_mouse(in);
    case 'rwth'
        out = LoadNMRData_rwth(in);
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