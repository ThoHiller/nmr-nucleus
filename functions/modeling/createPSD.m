function data = createPSD(range,modes,N,normswitch)
%createPSD adds noise with mean 'mu' and standard deviation 'sigma' to
%a synthetic NMR signal
%
% Syntax:
%       createPSD(range,modes,N,normswitch)
%
% Inputs:
%       range - min and max "radii" of the PSD
%       modes - [mu sigma amp] (e.g. [1e-5 2e-1 1;4e-5 2e-1 0.1])
%       N - points per decade
%       normswitch - normalize everything to 1
%
% Outputs:
%       data - output struct with fields:
%           r   : x-values of the PSD
%           psd : amplitudes of the PSD
%
% Example:
%       data = createPSD([1e-9 1e-4],[1e-6 0.3 1],30,0)
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

%% create the sampling points of the PSD
a = log10(range(1));
b = log10(range(2));
Ndec = abs(a-b);
p = logspace(a,b,ceil(Ndec*N));

%% gather the PSD
psd = zeros(size(modes,1),length(p));
PSD = zeros(1,length(p));
for i = 1:size(modes,1)
    mu = modes(i,1);
    sigma = modes(i,2);
    psd(i,:) = 1./( sigma*sqrt(2*pi)).*exp(-((log(p) - log(mu))/ sqrt(2)/sigma).^2);
    
    % scale to amplitude
    psd(i,:) = (psd(i,:)/max(psd(i,:))) * modes(i,3);
    
    % add the psd per mode
    PSD = PSD + psd(i,:);
end

%% normalize so that everything adds up to 1
if normswitch == 1
    PSD = PSD./sum(PSD);
end

data.r = p;
data.psd = PSD;

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