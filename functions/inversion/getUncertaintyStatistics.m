function out = getUncertaintyStatistics(T,RTDs,range,K0)
%getChi2 the chi2 of a NMR fit (noise weighted error quality)
%
% Syntax:
%       getChi2(signal,fit,noise)
%
% Inputs:
%       T - vector of relaxation time bins
%       RTDs - uncertainty relaxation time distributions
%       range - RTD min/max range to calculate statistics
%       K0 - "0"-Kernel to get E0
%
% Outputs:
%       out - struct with different statistical measures
%
% Example:
%       out = getUncertaintyStatistics(T,RTDs,range,K)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       none
%
% MAT-files required:
%       getAAD.m
%       getTLogMean.m
%
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% check data
[nDist,nT] = size(RTDs);

% check if the data size matches
if numel(T) == nT

    % RTD mask for all T-values within desired range
    mask = T >= range(1) & T <= range(2);

    % prepare temporary TLGM and E0
    TLGM_tmp = zeros(nDist,1);
    E0_tmp = zeros(nDist,1);
    % loop over all RTDs and get TLGM and E0
    for id = 1:nDist
        F = RTDs(id,:);
        TLGM_tmp(id,1) = getTLogMean(T,F,mask);
        E0_tmp(id,1) = K0(mask')*F(mask')';
    end

    % get statisitcal parameter
    out.RTD_bounds = range;
    out.Tlgm = [mean(TLGM_tmp) std(TLGM_tmp) getAAD(TLGM_tmp,0)];
    out.Tlgm_med = [median(TLGM_tmp) getAAD(TLGM_tmp,1)];
    out.E0 = [mean(E0_tmp) std(E0_tmp) getAAD(E0_tmp,0)];
    out.E0_med = [median(E0_tmp) getAAD(E0_tmp,1)];

else
    helpdlg({'function: getUncertainty Statistics',...
        'Cannot continue because data has incompatible size'},...
        'Check input!');
end

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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