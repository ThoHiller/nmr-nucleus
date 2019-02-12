function out = NUCLEUSinv_loadDefaults
%NUCLEUSinv_loadDefaults loads default GUI data values
%
% Syntax:
%       out = NUCLEUSinv_loadDefaults
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       defaults = NUCLEUSinv_loadDefaults
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% import file format
% input raw data file format
% can be 'rwth' | 'field' | 'dart' | 'corelab' | 'liag' | 'mouse' | 'bgr'
% 'bgr2' | 'bgrmat'
out.import.fileformat = 'rwth';

%% relaxation time distribution (RTD) plot style
% plot switch for frequency ('freq') or cumulative ('cum') distribution
out.info.RTDflag = 'freq';
out.info.PSDflag = 'freq';
out.info.PSDJflag = 'freq';
% flags indicating expert mode / joint inversion / inversion info / tool
% tips
out.info.ExpertMode = 'off';
out.info.JointInv = 'off';
out.info.InvInfo = 'on';
out.info.ToolTips = 'off';
% Optimization and Statistics toolbox availability is checked later 
out.info.optim = 'off';
out.info.stat = 'off';

%% process panel defaults
% first data sample of the signal
out.process.start = 1;
% last data sample of the signal (0 resets it to take the full signal)
out.process.end = 0;
% re-sampling (gating) of the raw signal 'log' | 'lin' | 'none'
% depends on signal type 'T1' or 'T2'
out.process.gatetype = 'log';
% normalize signal to 1 (no=0, yes=1)
out.process.norm = 0;
% scale factor for normalization
out.process.normfac = 1;
% time scale of the signal 's' | 'ms'
out.process.timescale = 's';
% corresponding scale factor (s=1) | (ms=1000)
out.process.timefac = 1;

%% petrophysical parameters panel
% surface relaxivity [µm/s]
out.param.rho = 10;  
% surface to volume ratio factor a [-] 1/T = rho*(S/V) = rho*a/R
out.param.a = 2;      
% T cutoff time between clay bound (CBW) and irreducible water (BVI) in [ms]
out.param.CBWcutoff = 3;   
% T cutoff time between irreducible (BVI) and movable water (BVM) in [ms]
out.param.BVIcutoff = 33;
% calibration sample volume
out.param.calibVol = 1;
% calibration sample NMR amplitude
out.param.calibAmp = 1;   
% sample volume
out.param.sampVol = 1;

% NMR porosity calibration data
% calibration volume (water
out.calib.vol = 1;
% calibration amplitude (water)
out.calib.amp = 1;
% calibration factor
out.calib.fac = 1;
% calibration name
out.calib.name = '';

%% standard inversion panel defaults
% inversion methods to choose from
% 'mono' | 'free' | 'NNLS' | 'ILA'
out.invstd.invtype = 'ILA';
% when inversion method is 'free' choose No. of free relaxation times
out.invstd.freeDT = 2;
% regularization options for multi-exponential fitting routines
% 'NNLS' and 'ILA'
out.invstd.regtype = 'auto';
% smoothness constraint (order) for multi-exponential fitting routines
% 'NNLS' and 'ILA'
out.invstd.Lorder = 1;
% regularization parameter for multi-exponential fitting routines
% 'NNLS' and 'ILA'
out.invstd.lambda = -1;
% L-curve range (lambda) for multi-exponential fitting routine 'NNLS'
out.invstd.lambdaR = [1e-3 1e2];
% initial L-curve range (lambda) for multi-exponential fitting routine
% 'NNLS'
out.invstd.lambdaRinit = [1e-3 1e2];
% number of lambda values in L-curve
out.invstd.NlambdaR = 20;
% range for RTD [min max] in [s]
out.invstd.time = [1e-4 1e2];
% number of points per decade in RTD
out.invstd.Ntime = 30;
% noise level (taken from data if available)
out.invstd.noise = 0;
% water bulk relaxation time [s]
out.invstd.Tbulk = 1e6;
% porosity value between 0 and 1 [-]
out.invstd.porosity = 1;

%% joint inversion panel defaults
% joint inversion methods to choose 'free' | 'fixed' | 'shape'
out.invjoint.invtype = 'free';
% pore size distribution in [m]
out.invjoint.radii = [1e-8 1e-2];
% No. of steps per decade in pore size distribution
out.invjoint.Nradii = 25;
% regularization options for joint inversion 'free'
out.invjoint.regtype = 'manual';
% smoothness constraint (order) for joint inversion 'free'
out.invjoint.Lorder = 1;
% regularization parameter for joint inversion 'free'
out.invjoint.lambda = 1;
% L-curve range (lambda) for joint inversion 'free'
out.invjoint.lambdaR = [1e-3 1e2];
% initial L-curve range (lambda) for joint inversion 'free'
out.invjoint.lambdaRinit = [1e-3 1e2];
out.invjoint.NlambdaR = 20;
% available pore geometries 'cyl' | 'ang' | 'poly'
out.invjoint.geometry_type = 'cyl';
% number of polygon sides for geometry 'poly' (3 to 12)
out.invjoint.polyN = 3;
% angle alpha [deg] - fixed to 90°
out.invjoint.alpha = 90;
% angle beta [deg] - changed by user
out.invjoint.beta = 60;
% gamma [deg] - alpha-beta
out.invjoint.gamma = 30;
% start value rho [µm/s]
out.invjoint.rhostart = 20;
% sart value beta [deg]
out.invjoint.anglestart = 25;

% pressure settings
% CPS table initial values (use,p,S,drain/imb)
out.pressure.table = {true,0,1,'D'}; 
% pressure units 'Pa' | 'kPa' | 'MPa' | 'bar'
out.pressure.unit = 'Pa';
% corresponding scale factors - 1 | 1e-3 | 1e-6 | 1e-5
out.pressure.unitfac = 1;

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