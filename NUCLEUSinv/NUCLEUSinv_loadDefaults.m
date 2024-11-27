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
% Author: see AUTHORS.md
% email: see AUTHORS.md
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
% plot switch for uncertainty line / patch plot
out.info.RTDuncert = 'lines';
% flags indicating expert mode / joint inversion / inversion info / tool
% tips
out.info.ExpertMode = 'off';
out.info.JointInv = 'off';
out.info.InvInfo = 'on';
out.info.ToolTips = 'off';
% Optimization and Statistics toolbox availability is checked later 
% lsqnonneg is the default lsq-solver
out.info.has_optim = 'off';
out.info.solver = 'lsqnonneg';
out.info.stat = 'off';
% LSQLIN Echo flag: RTDs<TE/5=0 (default is off)
out.info.EchoFlag = 'off';

%% process panel defaults
% first data sample of the signal
out.process.start = 1;
% last data sample of the signal (0 resets it to take the full signal)
out.process.end = 0;
% re-sampling (gating) of the raw signal 'log' | 'lin' | 'none'
% depends on signal type 'T1' or 'T2'
out.process.gatetype = 'log';
% gateing flag for convenience
out.process.isgated = false;
% maximum number of echoes per gate
out.process.Nechoes = 50;
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
% 'mono' | 'free' | 'NNLS' | 'LU'
out.invstd.invtype = 'NNLS';
% when inversion method is 'free' choose No. of free relaxation times
out.invstd.freeDT = 2;
% option to fix some of the 'free' relaxation times to a certain value
out.invstd.Tfixed_bool = [0 0 0 0 0];
out.invstd.Tfixed_val = [0 0 0 0 0];
% regularization options for multi-exponential fitting routines
% 'NNLS' and 'LU'
out.invstd.regtype = 'manual';
% smoothness constraint (order) for multi-exponential fitting routines
% 'NNLS' and 'LU'
out.invstd.Lorder = 1;
% regularization parameter for multi-exponential fitting routines
% 'NNLS' and 'LU'
out.invstd.lambda = 1;
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
% diffusion relaxation time [s]
out.invstd.Tdiff = 1e6;
% porosity value between 0 and 1 [-]
out.invstd.porosity = 1;

% uncertainty flag (intended for batch use)
out.uncert.use = 1;
% default uncertainty calculation method
out.uncert.Method = 'RMS_bound';
% uncertaintyx treshold (only need for method 'threshold')
out.uncert.Thresh = 0.05;
% number of uncertainty models to calculate
out.uncert.N = 10;
% number of unsuccesful tries before calculation stops
out.uncert.Max = 1e4;

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
% lower and upper boundary for rho [µm/s]
out.invjoint.rhobounds = [0.01 1000];
% sart value beta [deg]
out.invjoint.anglestart = 25;

% pressure settings
% CPS table initial values (use,p,S,drain/imb)
out.pressure.table = {true,0,1,'D'}; 
% pressure units 'Pa' | 'kPa' | 'MPa' | 'bar'
out.pressure.unit = 'Pa';
% corresponding scale factors - 1 | 1e-3 | 1e-6 | 1e-5
out.pressure.unitfac = 1;

%% 2D inversion GUI settings
% system / fluid properties
% diffusion coefficient [m²/s]
out.inv2D.prop.D = 2.025e-9;
% gradient [T/m]
out.inv2D.prop.G0 = 0;
% echo time [s]
out.inv2D.prop.te = 200e-6;
% start echo
out.inv2D.prop.first = 1;
% last echo
out.inv2D.prop.last = 1;

% inversion settings
% IR/SR factor
out.inv2D.inv.T1IRfac = 2;
% IR kernel type (1 or 2)
out.inv2D.inv.IRtype = 1;
% T1 range minimum [s]
out.inv2D.inv.T1min = 1e-4;
% T1 range maximum [s]
out.inv2D.inv.T1max = 10;
% T1 number of points in range
out.inv2D.inv.T1N = 51;
% T2 range minimum [s]
out.inv2D.inv.T2min = 1e-4;
% T2 range maximum [s]
out.inv2D.inv.T2max = 10;
% T2 number of points in range
out.inv2D.inv.T2N = 51;
% T1 regularization parameter lambda
out.inv2D.inv.T1lambda = 5;
% T1 order of smoothness constraint
out.inv2D.inv.T1order = 1;
% T2 regularization parameter lambda
out.inv2D.inv.T2lambda = 2;
% T2 order of smoothness constraint
out.inv2D.inv.T2order = 1;

% information settings / properties
% T1 minimum [s]
out.inv2D.info.T1min = 1e-3;
% T1 maximum [s]
out.inv2D.info.T1max = 1;
% T2 minimum [s]
out.inv2D.info.T2min = 1e-3;
% T2 minimum [s]
out.inv2D.info.T2max = 1;
% initial amplitude E0 [a.u.]
out.inv2D.info.E0 = 0;
% T1 log mean time
out.inv2D.info.T1tlgm = 0;
% T2 log mean time
out.inv2D.info.T2tlgm = 0;
% T1 maximum time
out.inv2D.info.T1tmax = 0;
% T2 maximum time
out.inv2D.info.T2tmax = 0;

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