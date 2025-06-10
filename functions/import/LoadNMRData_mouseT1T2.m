function out = LoadNMRData_mouseT1T2(in)
%LoadNMRData_mouseT1T2 loads T1T2 NMR data from a typical folder structure
%produced by the Mouse PM25
%
% Syntax:
%       out = LoadNMRData_mouseT1T2(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.T1T2 - T1 / T2 flag
%       in.fileformat - 'MouseT1T2'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_mouseT1T2(in)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% start processing the files

% get data file info
datafile = dir(fullfile(in.path,in.name));

% parameter stuff
parData = LoadParameterFile(in.path,'acqu.par');
% default T1 and T2 axes
try
    time_1 = importdata(fullfile(in.path,'T1Axis.dat'));
    if ~isempty(time_1)
        parData.nrPntsT1 = numel(time_1);
        parData.tMin = time_1(1);
        parData.tMax = time_1(end);
        parData.T1Axis = time_1(:)./1e3; % to [s]
    else
        parData.T1Axis = logspace(log10(parData.tMin),log10(parData.tMax),parData.nrPntsT1);
    end
catch
    parData.T1Axis = logspace(log10(parData.tMin),log10(parData.tMax),parData.nrPntsT1);
end
try
    time_2 = importdata(fullfile(in.path,'T2Axis.dat'));
    if ~isempty(time_2)
        parData.nrEchoes = numel(time_2);
        parData.T2Axis = time_2./1e3; % to [s]
    else
        parData.T2Axis = parData.echoTime:parData.echoTime:parData.echoTime*parData.nrEchoes;
    end
catch
    parData.T2Axis = parData.echoTime:parData.echoTime:parData.echoTime*parData.nrEchoes;
end
parData.T1Axis = parData.T1Axis(:)'; % row vector in [s]
parData.T2Axis = parData.T2Axis(:); % column vector in [s]

switch in.importflag
    case 'T1'
        % load data
        data = LoadDataFileT1(in.path,in.name,parData,in.Nechos);

        % get file statistics
        nmrData{1}.datfile = datafile.name;
        nmrData{1}.date = datafile.date;
        nmrData{1}.datenum = datafile.datenum;
        nmrData{1}.bytes = datafile.bytes;

        % save the NMR data
        nmrData{1}.flag = data.flag;
        nmrData{1}.T1IRfac = 1;
        nmrData{1}.time = data.time;
        nmrData{1}.signal = data.signal;
        nmrData{1}.raw = data.raw;

    case 'T1T2map'
        % load data
        data = LoadDataFile(in.path,in.name,in.T1T2,parData);

        nmrData = cell(1,1);
        for j1 = 1:numel(data)
            % get file statistics
            nmrData{j1}.datfile = datafile.name;
            nmrData{j1}.date = datafile.date;
            nmrData{j1}.datenum = datafile.datenum;
            nmrData{j1}.bytes = datafile.bytes;

            % save the NMR data
            nmrData{j1}.flag = data(j1).flag;
            nmrData{j1}.T1IRfac = 1;
            nmrData{j1}.time = data(j1).time;
            nmrData{j1}.signal = data(j1).signal;
            nmrData{j1}.raw = data(j1).raw;
            if strcmp(in.T1T2,'T2')
                nmrData{j1}.phase = data(j1).phase;
            end
        end

end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function data = LoadDataFile(datapath,fname,flag,pardata)

% first read the file
d = importdata(fullfile(datapath,fname));

% create echo time vector
time = pardata.T2Axis;

data = struct;
disp('NUCLUESinv Mouse T1T2 import: reading T_recov ...');
for j1 = 1:numel(pardata.T1Axis)
    disp(['T_recov: ',sprintf('%d',j1),' / ',num2str(numel(pardata.T1Axis))]);
    re = d(j1,:);
    re = re(:);

    data(j1).flag = flag;
    data(j1).raw.time = time;
    data(j1).time = time;

    % fit the data to estimate a dummy imag part
    param.T1IRfac = 1;
    param.noise = 0;
    param.optim = 'off';
    param.Tfixed_bool = [0 0 0 0 0];
    param.Tfixed_val = [0 0 0 0 0];
    invstd_tmp = fitDataFree(time,re,'T2',param,5);
    sigma = invstd_tmp.rms;
    [~,im] = addNoiseToSignal(re,0,sigma);

    % create the new complex signal
    tmp_s = complex(re,im);

    % save the data
    data(j1).raw.signal = tmp_s;
    data(j1).signal = data(j1).raw.signal;
    data(j1).phase = 0;
end
disp('NUCLUESinv Mouse T1T2 import: reading T_recov ... done');
end

%%
function data = LoadDataFileT1(datapath,fname,pardata,Nechos)

% first read the file
d = importdata(fullfile(datapath,fname));

% create echo time vector
time = pardata.T1Axis;

% number of echoes
maxTE = size(d,2);
% get T1 curve from averaging of first Nechos
tmp_s = mean(d(:,1:min([maxTE Nechos])),2);

data.flag = 'T1';
data.raw.time = time;
data.time = time;

% save the data
data.raw.signal = tmp_s;
data.signal = data.raw.signal;
end

%% load parameter file
function [data] = LoadParameterFile(datapath,fname)

fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

for i = 1:size(d{1},1)
    str = char(d{1}(i));
    str = fixParameterString(str);
    eval(['data.',str,';']); %#ok<EVLDOT>
end
data.all = d;

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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
