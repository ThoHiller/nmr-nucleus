function prange = getPressureRangeFromPSD(geom,psddata)
%getPressureRangeFromPSD estimates pressure range for the CPS curve
%that needs to be calculated for a given PSD.
%
% Syntax:
%       getPressureRangeFromPSD(geom,psddata)
%
% Inputs:
%       geom - geometry structure (output from 'getGeometryParameters')
%       psddata - PSD structure (output from 'createPSD')
%
% Outputs:
%       prange - min and max values for the CPS curve
%
% Example:
%       prange = getPressureRangeFromPSD(geom,psddata)
%
% Other m-files required:
%       getConstants
%       getCriticalPressure
%       getGeometryParameter
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also:
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% default physical constants
constants  = getConstants;

%% find the values where the PSD is above 1e-4 (only the relevant part)
rmin_idx = find(psddata.psd > 1e-4,1,'first');
rmax_idx = find(psddata.psd > 1e-4,1,'last');

%% size dependent threshold pressures
% min R <-> max P
geom_tmp = geom;
geom_tmp.radius = psddata.r(rmin_idx);
geom_tmp = getGeometryParameter(geom_tmp);
[Pci1,Pcd1] = getCriticalPressure(geom_tmp,constants);
% max R <-> min P
geom_tmp = geom;
geom_tmp.radius = psddata.r(rmax_idx);
geom_tmp = getGeometryParameter(geom_tmp);
[Pci2,Pcd2] = getCriticalPressure(geom_tmp,constants);

%% pressure range (after some rounding)
prange(1) = 10^(floor(log10(min([Pci2 Pcd2]))));
prange(2) = 10^(ceil(log10(max([Pci1 Pcd1]))));

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