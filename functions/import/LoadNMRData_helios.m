function out = LoadNMRData_helios(in)
%LoadNMRData_helios loads BGR NMR data from a typical folder structure 
%produced by the Helios NMR Scanner 
%
% Syntax:
%       out = LoadNMRData_helios(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.T1T2 - T1 / T2 flag
%       in.fileformat - 'helios'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_helios(in)
%
% Other m-files required:
%       fixParameterString
%
% Subfunctions:
%       LoadDataFile
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% start processing the files

% read the data file
datafile = dir(fullfile(in.path,in.name));
[data,parData] = LoadDataFile(in.path,in.name,in.T1T2);

% get file statistics
nmrData.datfile = datafile.name;
nmrData.date = datafile.date;
nmrData.datenum = datafile.datenum;
nmrData.bytes = datafile.bytes;

% save the NMR data
nmrData.flag = data.flag;
nmrData.T1IRfac = 1;
nmrData.time = data.time;
nmrData.signal = data.signal;
nmrData.raw = data.raw;
if strcmp(in.T1T2,'T2')
    nmrData.phase = data.phase;
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data,pardata] = LoadDataFile(datapath,fname,flag)

A = importdata(fullfile(datapath,fname),'\t');
t_echo = A(1,2);
n_echo = A(1,3);

time = t_echo:t_echo:t_echo*n_echo;
time = time(:);
re = -A(2,1:length(time));
im = -A(3,1:length(time));
re = re(:);
im = im(:);

data.flag = flag;
data.time = time;
data.signal = complex(re,im);
[data.signal,data.phase] = rotateT2phase(data.signal);

data.raw.time = data.time;
data.raw.signal = data.signal;

pardata.t_echo = t_echo; 
pardata.n_echo = n_echo; 

end
%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2021 Stephan Costabel
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
