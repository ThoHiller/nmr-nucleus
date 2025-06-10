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
%       in.version - varying (dependent on fileformat)
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
%       LoadNMRData_ibac
%       LoadNMRData_mouse
%       LoadNMRData_liag
%       LoadNMRData_bgr
%       LoadNMRData_mousecpmg
%       LoadNMRData_bgrmat
%       LoadNMRData_helios
%       LoadNMRData_bamtom
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

%% select the routine depending on the file format
switch in.fileformat
    case 'bamtom'
        out = LoadNMRData_bamtom(in);
    case 'bgr'
        out = LoadNMRData_bgr(in);
    case 'bgrmat'
        out = LoadNMRData_bgrmat(in);
    case 'corelab'
        out = LoadNMRData_corelab(in);
    case {'dart','dartjrd'}
        out = LoadNMRData_dart(in);
    case 'field'
        out = LoadNMRData_field(in);
    case {'heliosCPMG','heliosSeries'}
        out = LoadNMRData_helios(in);
    case 'liag'
        out = LoadNMRData_liag(in);
    case 'mouse'
        out = LoadNMRData_mouse(in);
    case 'MouseCPMG'
        out = LoadNMRData_mousecpmg(in);
    case 'MouseLift'
        out = LoadNMRData_mouselift(in);
    case 'MouseT1T2'
        out = LoadNMRData_mouseT1T2(in);
    case 'mrsd'
        out = LoadNMRData_mrsmatlab(in);
    case 'rwth'
        out = LoadNMRData_rwth(in);
    case 'pm5'
        out = LoadNMRData_ibac(in);
    case 'pm25'
        out = LoadNMRData_ibac(in);
    case 'rocaT1T2'
        out = LoadNMRData_rocaT1T2(in);    
end

% if an imported T2 signal has no imaginary part, the noise is estimated
% from an exponential fit
if ~strcmp(in.fileformat,'heliosCPMG') && ~strcmp(in.fileformat,'heliosSeries')...
        && ~strcmp(in.fileformat,'dartSeries') && ~strcmp(in.fileformat,'dartT2logging')...
        && (isfield(in,'T1T2') && ~strcmp(in.T1T2,'T1'))
    for i = 1:numel(out.nmrData)
        if isreal(out.nmrData{i}.signal)    
            disp('NUCLUESinv import: Estimating noise from exponential fit ...');
            param.T1IRfac = out.nmrData{i}.T1IRfac;
            param.noise = 0;
            param.optim = 'off';
            param.Tfixed_bool = [0 0 0 0 0];
            param.Tfixed_val = [0 0 0 0 0];
            invstd = fitDataFree(out.nmrData{i}.time,out.nmrData{i}.signal,...
                out.nmrData{i}.flag,param,5);
            out.nmrData{i}.noise = invstd.rms;
            disp('NUCLUESinv import: done.')
        end
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