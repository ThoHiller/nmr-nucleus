function out = LoadNMRData_rwth(in)
%LoadNMRData_rwth loads RWTH NMR data (saved by the old Prospa version)
%
% Syntax:
%       out = LoadNMRData_rwth(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name
%       in.fileformat - 'rwth'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_rwth(in)
%
% Other m-files required:
%       rotateT2phase
%
% Subfunctions:
%       LoadDataFile
%       LoadParameterFile
%       LoadT2SpectrumFile
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
[parData] = LoadParameterFile(in.path,[in.name,'.par']);
% check if T1 or T2 data
if strcmp(parData.macroName,'t1')
    T1T2flag = 'T1';
elseif strcmp(parData.macroName,'cpmgfast')
    T1T2flag = 'T2';
end

% find all data files
files = dir(fullfile(in.path,[in.name,'*.dat']));

% sort by date
[~,idx] = sort([files.datenum]);
files  = files(idx);

% the following lines are a bit nasty but the only way
% (at least I think so)
% first remove the T2spec-files from the file list
c = 0;
index = zeros(size(files,1),1);
for i = 1:size(files,1)
    if isempty(strfind(files(i).name,'T2spec'))
        c = c + 1;
        index(c,1) = i;
    end
end
index(index==0) = [];

% now check for a number at the end of the filename
% this indicates a set
ln = length(in.name);
c = 0;
index1 = zeros(size(index,1),1);
for i = 1:size(index,1)
    ind = strfind(files(index(i)).name,in.name);
    str = files(index(i)).name(ind+ln:end-4);
    if isfinite(str2double(str))
        c = c + 1;
        index1(c,1) = index(i);
    end
end
index1(index1==0) = [];

% multiple measurements with only one parameter file
if size(files,1) >= 2 && ~isempty(index1)
    % now we keep only the relevant ones
    files = files(index1);
    
    % commandline output
    disp([in.name,': importing NMR files ...']);
    
    nmrData = cell(1,size(files,1));
    for i = 1:size(files,1)
        % read the data file
        data = LoadDataFile(in.path,files(i).name);
        
        % get file statistics
        nmrData{i}.datfile = files(i).name;
        nmrData{i}.date = files(i).date;
        nmrData{i}.datenum = files(i).datenum;
        nmrData{i}.bytes = files(i).bytes;
        
        % save the NMR data
        if i == 1
            nmrData{i}.flag = data.flag;
            nmrData{i}.T1IRfac = 1;
            nmrData{i}.time = data.time;
            nmrData{i}.signal = data.signal;
            nmrData{i}.raw = data.raw;
        else
            nmrData{i}.flag = data.flag;
            nmrData{i}.T1IRfac = 1;
            nmrData{i}.time = nmrData{1}.time;
            nmrData{i}.signal = data.signal;
            nmrData{i}.raw = data.raw;
        end
        clear data
        
        % if T2 data read the T2spec file
        if strcmp(T1T2flag,'T2')
            data = LoadT2SpectrumFile(in.path,[files(i).name(1:end-4),...
                '_T2spec.dat']);
            nmrData{i}.specfile = [files(i).name(1:end-4),'_T2spec.dat'];
            if i == 1
                nmrData{i}.T2t = data.t2;
                nmrData{i}.T2f = data.Amp;
            else
                nmrData{i}.T2t = nmrData{1}.T2t;
                nmrData{i}.T2f = data.Amp;
            end
            clear data
        end
        
        % commandline output
        disp([in.name,': importing NMR files ',sprintf('%03d',i),...
            ' / ',sprintf('%03d',size(files,1))]);
    end
    
else % single measurement
    % read the data file
    data = LoadDataFile(in.path,[in.name,'.dat']);
    
    % get file statistics
    nmrData{1}.datfile = [in.name,'.dat'];
    nmrData{1}.date = files.date;
    nmrData{1}.datenum = files.datenum;
    nmrData{1}.bytes = files.bytes;
    
    % save the NMR data
    nmrData{1}.flag = data.flag;
    nmrData{1}.T1IRfac = 1;
    nmrData{1}.time = data.time;
    nmrData{1}.signal = data.signal;
    nmrData{1}.raw = data.raw;
    clear data
    
    % if T2 data read the T2spec file
    if strcmp(T1T2flag,'T2')
        data = LoadT2SpectrumFile(in.path,[in.name,'_T2spec.dat']);
        nmrData{1}.specfile = [in.name,'_T2spec.dat'];
        nmrData{1}.T2t = data.t2;
        nmrData{1}.T2f = data.Amp;
        clear data
    end
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 2
    % a T1 measurement has two columns
    data.flag = 'T1';
    data.time = d(:,1);
    data.signal = d(:,2);
elseif size(d,2) == 3
    % a T2 measurement has three columns where the time column is missing
    data.flag = 'T2';
    data.time = 0;
    data.signal = complex(d(:,1),d(:,2));
    data.signal = rotateT2phase(data.signal);
elseif size(d,2) == 4
    % a T2 measurement has four columns
    data.flag = 'T2';
    data.time = d(:,1);
    data.signal = complex(d(:,2),d(:,3));
    data.signal = rotateT2phase(data.signal);
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

%% load T2 spectrum from Prospa
function [data] = LoadT2SpectrumFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 1
    data.Amp = d(:,1);
elseif size(d,2) == 2
    data.t2  = d(:,1);
    data.Amp = d(:,2);
end

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