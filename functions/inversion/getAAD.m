function aad = getAAD(x,flag,dim)
%getAAD gets the average absolute deviation from the values in x
%
% Syntax:
%       getAAD(x,flag)
%
% Inputs:
%       x - values
%       flag - '0' (mean) or '1' (median)
%       dim - to calculate aad on
%
% Outputs:
%       aad - average absolute deviation
%
% Example:
%       aad = getAAD(TLGMvals,1)
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

%% check for Statistics Toolbox
Mver = ver;
hasStatBox = false;
for i = 1:size(Mver,2)
    if strfind(Mver(i).Name,'Statistics')
        hasStatBox = true;
        break
    end
end

% check flag
if nargin < 2 || isempty(flag)
    flag = 0;
end

% check dim
if nargin < 3 || isempty(dim)
    % get dimension
    dim = find(size(x)~=1,1);
    if isempty(dim)
        dim = 1;
    end
end

%% calculate AAD
if hasStatBox
    % use Statistics Toolbox built-in function 'mad'
    aad = mad(x,flag,dim);
else
    % get rid of NaNs and Infs 
    x(isnan(x)) = [];
    x(isinf(x)) = [];
    if flag == 0
        % get AAD from mean
        aad = mean(abs(x-mean(x,dim)),dim);
    elseif flag == 1
        % get AAD from median
        aad = median(abs(x-median(x,dim)),dim);
    else
        error('getAAD: flag must be 0 or 1');
    end
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