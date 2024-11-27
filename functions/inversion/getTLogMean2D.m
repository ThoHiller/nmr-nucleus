function [TLGM,TMAX] = getTLogMean2D(T1,T2,f,varargin)
%getTLogMean calculates the T logmean value out of a relaxation time
%distribution
%
% Syntax:
%       getTLogMean2D(T1,T2,f)
%
% Inputs:
%       T1 - T1 relaxation times
%       T2 - T2 relaxation times
%       f - 2D distribution
%       varargin - 2 1x2 vectors giving a range [Tmin Tmax] for both
%       dimensions
%
% Outputs:
%       TLGM - vector [T1tlgm T2tlgm] -> 2D log mean value of RTD
%       TMAX - vector [T1tmax T2tmax] -> 2D maximum of RTD
%
% Example:
%       [TLGM,TMAX] = getTLogMean2D(T1,T2,f)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% calculate TLGM
% check input
if nargin > 3
    T1range = varargin{1};
    T2range = varargin{2};
else
    % use full T1 and T2 range for calculation
    T1range = [min(T1) max(T1)];
    T2range = [min(T2) max(T2)];
end

% make T1-T2 2D map
[X,Y] = meshgrid(T2,T1);

% calc TLGM of entire map
mask1 = Y >= T1range(1) & Y <= T1range(2);
mask2 = X >= T2range(1) & X <= T2range(2);
x_m1 = 10^(sum(sum(log10(X(mask2)) .* f(mask2)/sum(sum(f(mask2))))));
y_m1 = 10^(sum(sum(log10(Y(mask1)) .* f(mask1)/sum(sum(f(mask1))))));

% calc TMAX of entire map
f1 = f.*mask1.*mask2;
[ix,iy] = find(f1==max(f1(:)));
x_max1 = X(ix,iy);
y_max1 = Y(ix,iy);

% calc TMAX of entire map
% mask1 = T1 >= T1range(1) & T1 <= T1range(2);
% mask2 = T2 >= T2range(1) & T2 <= T2range(2);
% T1lim = T1(mask1);
% T2lim = T2(mask2);
% [dummy1] = max(f,[],2);
% [~,ii1] = max(dummy1(mask1));
% [dummy2] = max(f,[],1);
% [~,ii2] = max(dummy2(mask2));
% x_max = T2lim(ii2);
% y_max = T1lim(ii1);

% save results
TLGM = [y_m1 x_m1]; % [T1tlgm T2tlgm]
% TMAX = [y_max x_max]; % [T1tmax T2tmax]
TMAX = [y_max1 x_max1]; % [T1tmax T2tmax]

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