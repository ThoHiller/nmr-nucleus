function processNMRDataControl(fig,id)
%processNMRDataControl prepares simple NMR raw data processing 
%(eg. re-sampling, normalizing, etc.
%
% Syntax:
%       processNMRDataControl(fig,id)
%
% Inputs:
%       fig - NUCLEUSinv GUI handle
%       id - selected NMR signal
%
% Outputs:
%       none
%
% Example:
%       processNMRDataControl(gcf,1)
%
% Other m-files required:
%       processNMRData
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

%% get GUI data
data = getappdata(fig,'data');

% the current data set
nmrdata = data.import.NMR.data{id};

% the raw data
nmrraw.t = nmrdata.time;
nmrraw.s = nmrdata.signal;
if strcmp(nmrdata.flag,'T2')
    nmrraw.phase = nmrdata.phase;
end

% check if noise was calculated / estimated during import
% this value is used here
if isfield(nmrdata,'noise')
    nmrraw.noise = nmrdata.noise;
end

% gather all processing parameter
nmrproc.T1T2 = nmrdata.flag;
nmrproc.T1IRfac = nmrdata.T1IRfac;
nmrproc.timefac = data.process.timefac;
nmrproc.start = data.process.start;
nmrproc.end = data.process.end;
nmrproc.norm = data.process.norm;
nmrproc.gatetype = data.process.gatetype;
nmrproc.Nechoes = data.process.Nechoes;

[nmrraw,nmrproc] = processNMRData(nmrraw,nmrproc);
data.results.nmrraw = nmrraw;
data.results.nmrproc = nmrproc;
data.process.normfac = nmrproc.normfac;

% update GUI data
setappdata(fig,'data',data);

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