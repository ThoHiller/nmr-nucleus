function [TLGM,index] = getTLogMean(T,f)
%getTLogMean calculates the T logmean value out of a relaxation time
%distribution
%
% Syntax:
%       getTLogMean(T,f)
%
% Inputs:
%       T - relaxation times
%       f - distribution
%
% Outputs:
%       TLGM - log mean value of relaxation time distribution
%       index - closest relaxation time in spectrum (optional)
%
% Example:
%       [TLGM,index] = getTLogMean(T,f)
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
% make everything a column vector
T = T(:);
f = f(:);

% get TLGM
TLGM = 10.^(sum(f.*log10(T))./sum(f));

% if desired get the closest T
if nargout == 2
    index = find(abs(T-TLGM)==min(abs(T-TLGM)));
end

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