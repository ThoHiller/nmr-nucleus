function out = getFitErrors(s,sfit,noise,varargin)
%getFitErrors calculates all relevant fitting errors for the NMR inversion
%routines
%
% Syntax:
%       getFitErrors(signal,fit,noise,varargin)
%
% Inputs:
%       s - NMR signal
%       sfit - fitted NMR signal
%       noise - data noise
%       varargin - 'W' error weighing matrix after gating
%
% Outputs:
%       out - output structure
%             residual: residual vector
%             errnorm1: L1 norm
%             errnorm2: L2 norm
%             resnorm : L2 norm
%             mse     : mean squared error
%             rms     : root mean square error
%             chi2    : "chi-square" estimate
%
% Example:
%       errors = getFitErrors(signal,fit,noise)
%
% Other m-files required:
%       getChi2
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% check for weighing matrix W
isW = false;
if nargin > 3
    % error weighing matrix from time gating
    W = varargin{1};
    isW = true;
end

%% residuals
residual = s-sfit;

%% L1 norm
errnorm1 = sum(abs(residual));

%% L2 norm (squared residual norm)
% in general the output of the Matlab fitting functions ("resnorm")
% is similar as to write "norm(residual).^2"
errnorm2 = sum(abs(residual.^2));

%% MSE (mean squared error)
mse = mean(residual.^2);

%% RMS and X2
if isW
    % weighted RMS error
    % residual is weighted with the amount of echoes N per time gate
    % NOTE: if "N per gate" is too large, the RMS estimation breaks down
    N = (noise./diag(W)).^2;    
    rms = sqrt (sum(N.*(residual).^2) / length(residual));
    % X2 estimate
    chi2 = getChi2(s,sfit,diag(W));
else    
    % RMS error
    rms = sqrt( sum(residual.^2) / length(residual) );
    % X2 estimate
    chi2 = getChi2(s,sfit,noise);
end

%% output struct
out.residual = residual;
out.errnorm1 = errnorm1;
out.errnorm2 = errnorm2;
out.resnorm = errnorm2;
out.mse = mse;
out.rms = rms;
out.chi2 = chi2;

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