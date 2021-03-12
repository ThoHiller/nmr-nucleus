function out = LoadNMRData_ibac(in)
%LoadNMRData_ibac imports NMR data from the PM5 and PM25
%
% Syntax:
%       out = LoadNMRData_ibac(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name
%       in.fileformat - 'pm5' or 'pm25'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_ibac(in)
%
% Other m-files required:
%       rotateT2phase
%
% Subfunctions:
%       LoadCPMGFile
%       LoadCPMGACQPFile
%       LoadDataFile
%       LoadInfFile
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

switch in.fileformat
    
    case 'pm5'
        
        % load Parameter file
        [parData] = LoadInfFile(in.path,in.name);        
        parData.parfile = in.name;
        
        [~,fname,~] = fileparts(in.name);
        % try to read cpmgacqp file
        file1 = dir(fullfile(in.path,[fname,'.cpmgacqp']));
        if ~isempty(file1)
            data = LoadCPMGACQPFile(in.path,file1.name);
        else
            % if it is not there try to read cpmg file
            file2 = dir(fullfile(in.path,[fname,'.cpmg']));
            if ~isempty(file2)
                data = LoadCPMGFile(in.path,file2.name);
            else
                data = [];
            end
        end
        
        % if data was imported continue
        if ~isempty(data)
            
            depths = parData.initialdepth:parData.incrindepth:...
                parData.initialdepth+parData.depths*parData.incrindepth-...
                parData.incrindepth;
            parData.finaldepth = depths(end);
            
            nmrData = cell(1,numel(depths));
            for i = 1:numel(depths)
                
                if ~isempty(file1)
                    file = file1;
                else
                    file = file2;
                end
                
                % get file statistics
                nmrData{i}.datfile = file.name;
                nmrData{i}.date = file.date;
                nmrData{i}.datenum = file.datenum;
                nmrData{i}.bytes = file.bytes;
                
                % save the NMR data
                nmrData{i}.flag = data.flag;
                nmrData{i}.T1IRfac = 1;
                nmrData{i}.phase = data.phase;
                
                nmrData{i}.time = data.time(data.depth==depths(i));
                nmrData{i}.raw.time = data.time(data.depth==depths(i));
                
                if ~isempty(file1)
                    % the time vector needs to be treated as well beacuse
                    % there are several values per echo
                    % get window length
                    wl = numel(nmrData{i}.time)/parData.T2echoes;
                    nmrData{i}.time = nmrData{i}.time(1:wl:end);
                    nmrData{i}.raw.time = nmrData{i}.time;
                    % get complex data from 'cpmgacqp' file
                    % first the real part of the signal
                    tmp = real(data.signal(data.depth==depths(i)));
                    % get the moving average
                    sr = movmean(tmp,wl);
                    % cut out the correct windows
                    sr = sr(ceil(wl/2):wl:end);
                    % do the same for the imag part
                    tmp = imag(data.signal(data.depth==depths(i)));
                    si = movmean(tmp,wl);
                    si = si(ceil(wl/2):wl:end);
                    % save the complex signal
                    nmrData{i}.signal = complex(sr,si);
                    % rotate phase to minimize imag part
                    [nmrData{i}.signal,nmrData{i}.phase] = rotateT2phase(nmrData{i}.signal);
                    nmrData{i}.raw.signal = nmrData{i}.signal;
                else
                    nmrData{i}.signal = data.signal(data.depth==depths(i));
                    nmrData{i}.raw.signal = data.signal(data.depth==depths(i));
                end
            end
            % save data to output struct
            out.parData = parData;
            out.nmrData = nmrData;
        end
        
    case 'pm25'
        
        % load Parameter file
        file = dir(fullfile(in.path,'*.par'));
        if ~isempty(file)
            [parData] = LoadParameterFile(in.path,file.name);
        end
        parData.parfile = file;
        
        % read dat-file
        file = dir(fullfile(in.path,'*decays.dat'));
        if ~isempty(file)
            data = LoadDataFile(in.path,file.name);
        else
            data = [];
        end
        
        % if data was imported continue
        if ~isempty(data)
            
            depths = parData.initDepth:parData.stepSize:parData.finalDepth;
            
            parData.depths = numel(depths);
            parData.initialdepth = parData.initDepth;
            parData.finaldepth = depths(end);
            
            nmrData = cell(1,numel(depths));
            for i = 1:numel(depths)
                % get file statistics
                nmrData{i}.datfile = file.name;
                nmrData{i}.date = file.date;
                nmrData{i}.datenum = file.datenum;
                nmrData{i}.bytes = file.bytes;
                
                % save the NMR data
                nmrData{i}.flag = data.flag;
                nmrData{i}.T1IRfac = 1;
                nmrData{i}.phase = data.phase;
                
                nmrData{i}.time = data.time;
                nmrData{i}.raw.time = data.time;
                
                nmrData{i}.signal = data.signal(:,i);
                nmrData{i}.raw.signal = data.signal(:,1);
            end
            % save data to output struct
            out.parData = parData;
            out.nmrData = nmrData;
        end
end

end

%% load NMR data file
function [data] = LoadCPMGFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 5
    data.flag = 'T2';
    data.depth = d(:,1);
    data.time = d(:,4)./1e3; % ms to s
    data.signal = d(:,5);
    data.phase = 0;
else
    data.flag = '0';
    data.time = 0;
    data.signal = 0;
    data.phase = 0;
end

end

%% load NMR data file
function [data] = LoadCPMGACQPFile(datapath,fname)

d = load(fullfile(datapath,fname));

if size(d,2) == 6
    data.flag = 'T2';
    data.depth = d(:,1);
    data.time = d(:,3)./1e3; % ms to s
    data.time1 = d(:,4)./1e3; % ms to s
    data.signal = complex(d(:,5),d(:,6));
    data.phase = 0;
else
    data.flag = '0';
    data.time = 0;
    data.signal = 0;
    data.phase = 0;
end

end

%% load NMR data file
function [data] = LoadDataFile(datapath,fname)

d = load(fullfile(datapath,fname));

data.flag = 'T2';
data.time = d(:,1)./1e3; % ms to s
data.signal = d(:,2:end);
data.phase = 0;

end

%% load parameter file
function [data] = LoadInfFile(datapath,fname)

fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

d1 = cell(1,1);
for i = 1:size(d{1},1)
    str = char(d{1}(i));
    
    % remove under scores
    str = strrep(str,'_','');
    % remove 'mü' string
    str = strrep(str,'mü','');
    % remove '&' string
    str = strrep(str,'&','');
    % find colon
    colon = strfind(str,':');
    % grep parameters
    if ~isempty(colon)
        prop = strtrim(str(1:colon(1)-1));
        value = strtrim(str(colon(1)+1:end));
        valchk = str2double(value);
        
        % remove empty spaces in property
        prop = strrep(prop,' ','');
        
        str1 = [prop,' = ',value];
        d1{i} = str1;
        prop = strrep(prop,'-','');
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

%% load parameter file
function [data] = LoadParameterFile(datapath,fname)

fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

d1 = cell(1,1);
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
% Copyright (c) 2020 Thomas Hiller
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