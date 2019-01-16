function constants = getConstants
%getConstants provides some physical constants to the forward calculation
%routines for the capillary pressure saturation curves
%
% Syntax:
%       getConstants
%
% Inputs:
%       none
%
% Outputs:
%       constants - output struct with physical constants
%
% Example:
%       constants = getConstants
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
% See also:
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% gravitational acceleration
constants.gravity = 9.81; % [m/s^2]
% surface tension
constants.sigma = 7.28e-2; % [N/m]
% contact angle of liquid gas interface
constants.theta = 0; % [deg]
% density of water
constants.density = 999.97; % [kg/m^3]
% dynamic viscosity of water
constants.dynvisc = 0.001; % [Pa s = 1cP]
% HAMAKER constant
constants.hamaker_sv = -6e-20; % [J]
% hydraulic gradient
constants.hyd_grad = 1; % [Pa/m]
% 2D Young-Laplace factor
constants.sigfac = 1;

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