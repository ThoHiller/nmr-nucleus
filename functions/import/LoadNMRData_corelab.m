function out = LoadNMRData_corelab(in)
%LoadNMRData_corelab loads NMR data as provided by Corelab
%
% Syntax:
%       out = LoadNMRData_corelab(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name
%       in.fileformat - 'corelab'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_corelab(in)
%
% Other m-files required:
%       none
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
if strcmpi(parData.SEQ,'t1')
    T1T2flag = 'T1';
elseif strcmpi(parData.SEQ,'cpmg')
    T1T2flag = 'T2';
end

switch T1T2flag
    case 'T1'
        parData = [];
        nmrData = [];
        
        helpdlg({'function: LoadNMRData_corelab',...
            'T1 data import not yet implemented'},'not implemented yet');
    case 'T2'
        files = dir(fullfile(in.path,[in.name,'*.dat']));
        
        % read the data file
        data = LoadDataFile(in.path,files.name);
        
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
        nmrData{1}.phase = data.phase;

        clear data
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 3
    % a T2 measurement has three columns
    data.flag = 'T2';
    data.time = d(:,1);
    data.signal = complex(d(:,2),d(:,3));
    [data.signal,data.phase] = rotateT2phase(data.signal);
else
    data.flag = '0';
    data.time = 0;
    data.signal = 0;
    data.phase = 0;
end

data.raw.time = data.time;
data.raw.signal = data.signal;

end

%% load parameter file
function [data] = LoadParameterFile(datapath,fname)

fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

d1 = cell(1,1);
for i = 1:size(d{1},1)
    str = char(d{1}(i));
    
    ispace = strfind(str,' ');
    if ~isempty(ispace)
        prop = str(1:ispace(1)-1);
        value = str(ispace(end)+1:end);
        valchk = str2double(value);
        
        str1 = [prop,' = ',value];
        d1{i} = str1;
        
        if isnan(valchk)
            if isempty(value)
                eval(['data.',prop,'='''';']);
            else
                eval(['data.',prop,'=''',value,''';']);
            end
        else
            eval(['data.',prop,'=',value,';']);
        end
    end
end
data.all{1} = d1';

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