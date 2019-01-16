function out = LoadNMRData_mouse(in)
%LoadNMRData_mouse loads NMR data saved by the MOUSE
%
% Syntax:
%       out = LoadNMRData_mouse(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.fileformat - 'mouse'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_mouse(in)
%
% Other m-files required:
%       fixParameterString
%
% Subfunctions:
%       LoadDataFile
%       LoadParameterFile
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% start processing the files
% load Parameter file
[parData] = LoadParameterFile(in.path,'acq.par');
% check if T1 or T2 data
if strcmp(parData.experiment,'T1Sat')
    T1T2flag = 'T1';
elseif strcmp(parData.experiment,'CPMGFast')
    T1T2flag = 'T2';
end

% find all data files
files = dir(fullfile(in.path,'*.dat'));

% remove not needed dat-files
switch T1T2flag
    case 'T1'
        files = files(~ismember({files.name},...
            {'2Ddata.dat','data2D.dat','T1Axis.dat'}));
    case 'T2'
        files = files(~ismember({files.name},...
            {'2Ddata.dat','data2D.dat','T2Axis.dat'}));
end

nmrData = cell(1,size(files,1));
for i = 1:size(files,1)
    % read the data file
    data = LoadDataFile(in.path,files(i).name,T1T2flag);
    
    % get file statistics
    nmrData{i}.datfile = files(i).name;
    nmrData{i}.date = files(i).date;
    nmrData{i}.datenum = files(i).datenum;
    nmrData{i}.bytes = files(i).bytes;
    
    % save the NMR data
    nmrData{i}.flag = data.flag;
    nmrData{i}.T1IRfac = 1;
    nmrData{i}.time = data.time;
    nmrData{i}.signal = data.signal;
    nmrData{i}.raw = data.raw;    
    clear data
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname,flag)

d = load(fullfile(datapath,fname));

if size(d,2) == 3
    data.flag = flag;
    data.time = d(:,1);
    switch flag
        case 'T1'
            data.signal = d(:,2);
        case 'T2'
            data.signal = complex(d(:,2),d(:,3));
    end
else
    data.flag = '0';
    data.time = 0;
    data.signal = 0;
end

data.raw.time = data.time;
data.raw.signal = data.signal;

end

%% load parameter file
function [data] = LoadParameterFile(datapath,fname)

fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

for i = 1:size(d{1},1)
    str = char(d{1}(i));
    str = fixParameterString(str);
    eval(['data.',str,';']);
end
data.all = d;

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