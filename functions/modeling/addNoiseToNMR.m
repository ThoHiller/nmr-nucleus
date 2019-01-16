function [signalN,noise] = addNoiseToNMR(signal,mu,sigma)
%addNoiseToNMR adds noise with mean 'mu' and standard deviation 'sigma' to
%a synthetic NMR signal
%
% Syntax:
%       addNoiseToNMR(time,signal,varargin)
%
% Inputs:
%       signal - vector or matrix containing the NMR data
%       mu - mean of the Gaussian noise (generally 0)
%       sigma - standard deviation of the Gaussian noise
%
% Outputs:
%       signalN - NMR signal with noise
%       noise - noise vector/matrix
%
% Example:
%       [sN,e] = applyGatesToSignal(time,signal,'type','log')
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

% generate the noise
noise = mu + (sigma.*randn(size(signal)));

% and the noisy signal
signalN = signal + noise;

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