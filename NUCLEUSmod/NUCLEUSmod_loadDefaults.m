function out = NUCLEUSmod_loadDefaults
%NUCLEUSmod_loadDefaults loads default GUI data values
%
% Syntax:
%       out = NUCLEUSmod_loadDefaults
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       defaults = NUCLEUSmod_loadDefaults
%
% Other m-files required:
%       none
% Subfunctions:
%       none
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% geometry panel defaults
% available pore geometries 'cyl' | 'ang' | 'poly'
out.geometry.type = 'cyl';
% equivalent pore radius [m]
% NOTE: for 'ang' & 'poly' the radius is the 'cyl'-area-equivalent radius
out.geometry.radius = 1e-5;
% PSD radius range [min max] in [m]
out.geometry.range = [1e-7 1e-3];
% number of points per decade in PSD
out.geometry.rangeN = 100;
% number of polygon sides for geometry 'poly' (3 to 12)
out.geometry.polyN = 3;
% angle alpha [deg] - fixed to 90°
out.geometry.alpha = 90;
% angle beta [deg] - changed by user
out.geometry.beta = 45;
% gamma [deg] - alpha-beta
out.geometry.gamma = 45;
% PSD or single pore (single pore is default)
out.geometry.ispsd = 0;
% PSD can have 3 modes - for each mode [mean sigma amplitude] in [m]
out.geometry.modes = [1e-5 0.3 1; 3e-6 0.3 0.5; 1e-6 0.3 0.25];
% number of modes in PSD
out.geometry.modesN = 1;

%% pressure panel defaults
% interfacial tension between water and air [N/m]
out.pressure.sigma = 0.0728;
% surface contact angle of water [deg]
out.pressure.theta = 0;
% log-distributed pressure values (log=1, lin=0)
out.pressure.loglin = 1;
% pressure units 'Pa' | 'kPa' | 'MPa' | 'bar'
out.pressure.unit = 'Pa';
% corresponding scale factors - 1 | 1e-3 | 1e-6 | 1e-5
out.pressure.unitfac = 1;
% pressure range [min max] always in [Pa]
out.pressure.range = [1e3 1e5];
% number of values in pressure range
out.pressure.rangeN = 50;

%% NMR panel defaults
% echo time [µs]
out.nmr.TE = 1000;
% number of echoes
out.nmr.echosN = 1001;
% noise level [%]
out.nmr.noise = 0;
% water bulk relaxation time [s]
out.nmr.Tbulk = 2;
% surface relaxivity [µm/s]
out.nmr.rho = 10;
% porosity value between 0 and 1 [-]
out.nmr.porosity = 1;
% plot T2 data as default
out.nmr.toplot = 'T2';
% use linear x-axes as default (log=1, lin=2)
out.nmr.loglinx = 2;
% use linear y-axes as default (log=1, lin=2)
out.nmr.logliny = 2;


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