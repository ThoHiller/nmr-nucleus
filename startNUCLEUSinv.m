function startNUCLEUSinv
%startNUCLEUSinv is the start script that prepares the Matlab path and
%starts the NUCLEUSinv GUI
%
% Syntax:
%       startNUCLEUSinv
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       startNUCLEUSinv
%
% Other m-files required:
%       NUCLEUSinv.m
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

%% add paths
thisfile = mfilename('fullpath');
thispath = fileparts(thisfile);
addpath(genpath(fullfile(thispath,'callbacks')),'-end');
addpath(genpath(fullfile(thispath,'externals')),'-end');
addpath(genpath(fullfile(thispath,'functions')),'-end');
addpath(genpath(fullfile(thispath,'NUCLEUSinv')),'-end');

%% start GUI
NUCLEUSinv;

end

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