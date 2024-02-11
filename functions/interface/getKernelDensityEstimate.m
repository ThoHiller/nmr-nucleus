function [f,x] = getKernelDensityEstimate(y)
%getKernelDensityEstimate computes the one dimensional kernel density estimate
%
% Syntax:
%       [f,x] = getKernelDensityEstimate(y)
%
% Inputs:
%       y - values / samples
%
% Outputs:
%       f - density values
%       x - sample points
%
% Example:
%       [f,x] = getKernelDensityEstimate(y)
%
% Other m-files required:
%       kde.m
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% check for Matlab version and Statistics Toolbox
useinternalKDE = false;
% Matlab version
v = ver('MATLAB');
ind = strfind(v.Version,'.');
% major number
vMajor = str2double(v.Version(1:ind-1));
% minor number
vMinor = str2double(v.Version(ind+1:end));
% check version
if vMajor > 9 || (vMajor == 9 && vMinor >= 9)
    if ~isMATLABReleaseOlderThan("R2023b")
        % use internal 'kde' for versions R2023b and newer
        useinternalKDE = true;
    end
end

% check Statistics Toolbox
hasStatBox = false;
Mver = ver;
for i = 1:size(Mver,2)
    if strfind(Mver(i).Name,'Statistics')
        hasStatBox = true;
    end
end

%% get the kernel density estimate
if hasStatBox
    % Statistics ToolBox
    [f,x] = ksdensity(y);
else
    if useinternalKDE
        % 2023b built-in kde
        [f,x] = kde(y);
    else
        % before 2023b use FEX kde in 'externals' folder
        [~,f,x] = kde(y,numel(y));
    end
end

end

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