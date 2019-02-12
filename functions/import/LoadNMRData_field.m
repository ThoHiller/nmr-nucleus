function out = LoadNMRData_field(in)
%LoadNMRData_field loads RWTH field NMR data (Blümich group bore-hole tool)
%
% Syntax:
%       out = LoadNMRData_field(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name
%       in.fileformat - 'field'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_field(in)
%
% Other m-files required:
%       rotateT2phase
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
if strcmpi(parData.experiment,'t1')
    T1T2flag = 'T1';
elseif strcmpi(parData.experiment,'cpmgfast') ||...
        strcmpi(parData.experiment,'CPMG_drying2D')
    T1T2flag = 'T2';
end

switch T1T2flag
    case 'T1'
        parData = [];
        nmrData = [];
        
        helpdlg({'function: LoadNMRData_field',...
            'T1 data import not yet implemented'},'not implemented yet');
        
    case 'T2'        
        % find all data files
        files1 = dir(fullfile(in.path,[in.name,'*.dat']));
        
        % check if it is a single or multiple measurement(s)
        if numel(files1) > 1            
            % command line output
            disp([in.name,': importing NMR files ...']);
            
            nmrData = cell(1,size(files1,1));
            for i = 1:numel(files1)
                % read the data file
                data = LoadDataFile(in.path,files1(i).name);
                
                % get file statistics
                nmrData{i}.datfile = files1(i).name;
                nmrData{i}.date = files1(i).date;
                nmrData{i}.datenum = files1(i).datenum;
                nmrData{i}.bytes = files1(i).bytes;
                
                % save the NMR data
                nmrData{i}.flag = data.flag;
                nmrData{i}.T1IRfac = 1;
                nmrData{i}.time = data.time;
                nmrData{i}.signal = data.signal;
                nmrData{i}.raw = data.raw;                
                clear data
                
                % command line output
                disp([in.name,': importing NMR files ',sprintf('%03d',i),...
                    ' / ',sprintf('%03d',numel(files1))]);
            end
            
        else
            % single measurement
            if isempty(files1)
                files2 = dir(fullfile(in.path,'data.dat'));
                files = files2;
            else
                files = files1;
            end
            
            if ~isempty(files)
                % read the data file
                data = LoadDataFile(in.path,files.name);
                
                % get file statistics
                nmrData{1}.datfile = files.name;
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
            end            
        end
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 3
    data.flag = 'T2';
    % [ms] to [s]
    if d(1,1) > 1e-2
        data.time = d(:,1)/1000;
    else
        data.time = d(:,1);
    end
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