function out = LoadNMRData_bamtom(in)
%LoadNMRData_bamtom loads BAM TOM data
%
% Syntax:
%       out = LoadNMRData_bamtom(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.fileformat - 'bamtom'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_bamtom(in)
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
[parData] = LoadParameterFile(in.path,[in.name,'.par']);
% check if T1 or T2 data
if strcmp(parData.measurementType,'CPMG_Lift')
    T1T2flag = 'T2';
else
    T1T2flag = 'T1';
end

switch T1T2flag
    case 'T1'
        parData = [];
        nmrData = [];
        
        helpdlg({'function: LoadNMRData_bamtom',...
            'T1 data import not yet implemented'},'not yet implemented');
    case 'T2'
        
        % read all 'nslices' measurements
        nslices = parData.nSlices;
        
        nmrData = cell(1,nslices);
        for i = 1:nslices
            % find data file
            file = dir(fullfile(in.path,['*',sprintf('%03d',i),'.csv']));
            
            % read the data file
            data = LoadDataFile(in.path,file.name,T1T2flag);
            
            % save the NMR data
            nmrData{i}.flag = data.flag;
            nmrData{i}.T1IRfac = 1;
            nmrData{i}.time = data.time;
            nmrData{i}.signal = data.signal;
            nmrData{i}.raw = data.raw;
            nmrData{i}.phase = data.phase;
            nmrData{i}.phase_bam = data.phase_bam;
            clear data
            
            % get file statistics
            nmrData{i}.datfile = file.name;
            nmrData{i}.date = file.date;
            nmrData{i}.datenum = file.datenum;
            nmrData{i}.bytes = file.bytes;
        end
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname,flag)

d = importdata(fullfile(datapath,fname),'\t',3);

% phase
tmpstr = d.textdata{2,1};
colonstr = strfind(tmpstr,':');
data.phase_bam = str2double(tmpstr(colonstr+1:end-4));
% to compare the BAM TOM phase with the NUCLEUS fit phase shift and flip
% the phase value
data.phase_bam = -1*(data.phase_bam + pi);

% standard data
data.flag = flag;
data.time = d.data(:,1);
switch flag
    case 'T1'
        data.signal = d.data(:,2);
    case 'T2'
        data.signal = complex(d.data(:,2),d.data(:,3));
        [data.signal,data.phase] = rotateT2phase(data.signal);
end

% save raw data
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
    if ~isempty(str) && ~strcmp(str(1),'#')
        str = fixParameterString(str);
        if ~isempty(strfind(str,'coilName')) || ~isempty(strfind(str,'measurementType'))
            streq = strfind(str,'=');
            newstr = [str(1:streq(1)),'''',strtrim(str(streq(1)+1:end)),''''];
            str = newstr;
        end
        eval(['data.',str,';']);
    end
end
data.all = d;

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Thomas Hiller
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