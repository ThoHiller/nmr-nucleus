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

% importdata is rather slow for row data
% A = importdata(fullfile(datapath,fname),'\t');

% first read the file to get the number of echos
fid = fopen(fullfile(datapath,fname));
A0 = textscan(fid,'%f','Delimiter','\n');
fclose(fid);
% now read all three lines
fid = fopen(fullfile(datapath,fname));
A1 = textscan(fid,'%f',A0{1}(3));
A2 = textscan(fid,'%f',A0{1}(3));
A3 = textscan(fid,'%f',A0{1}(3));
fclose(fid);
% and stitch them together
A = [A1{1}';A2{1}';A3{1}'];

t_echo = A(1,2);
n_echo = A(1,3);
freq = A(1,4);
Nscans = A(1,5);
t_recov = A(1,9); % HELIOS
t_rep = A(1,14); % HELIOS
timestamp = A(1,42); % HELIOS

time = t_echo:t_echo:t_echo*n_echo;
time = time(:);
re = A(2,1:length(time));
im = A(3,1:length(time));
re = re(:);
im = im(:);

data.flag = flag;
data.raw.time = time;
data.raw.signal = complex(re,im);
% the HELIOS phase is generally around 140°, hence we give a range for
% finding the optimal phase angle
[data.signal,data.phase] = rotateT2phase(data.raw.signal,'stdIm',...
    [deg2rad(90) deg2rad(155)]);

data.time = data.raw.time;
data.raw.signal = data.signal;

pardata.t_echo = t_echo;
pardata.n_echo = n_echo;
pardata.t_recov = t_recov;
pardata.t_rep = t_rep;
pardata.freq = freq;
pardata.Nscans = Nscans;
pardata.timestamp = timestamp;
d{1}{1,1} = ['t_echo = ',num2str(t_echo)];
d{1}{2,1} = ['n_echo = ',num2str(n_echo)];
d{1}{3,1} = ['t_recov = ',num2str(t_recov)];
d{1}{4,1} = ['t_rep = ',num2str(t_rep)];
d{1}{5,1} = ['freq = ',num2str(freq)];
d{1}{6,1} = ['Nscans = ',num2str(Nscans)];
pardata.all = d;

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
