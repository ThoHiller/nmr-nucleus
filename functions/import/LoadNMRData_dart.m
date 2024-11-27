function out = LoadNMRData_dart(in)
%LoadNMRData_dart loads RWTH NMR data (recorded with the Dart device); the
%Dart data comes already as a mat-file and consists always of T2-CPMG
%measurements
%
% Syntax:
%       out = LoadNMRData_dart(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.name - file name
%       in.fileformat - 'dart'
%       in.version - different input routines for different DART versions
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_dart(in)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       none
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

switch in.version
    case 1
        % load the Matlab mat-file
        data = load(fullfile(in.path,in.name));
        file = dir(fullfile(in.path,in.name));

        % init stuff
        parData = cell(1,1);
        tmp = cell(1,1);
        % check, if it is one or multiple depths
        if size(data.se_vector_wc,2) > 1
            % command line output
            disp([in.name,': importing NMR files ...']);

            nmrData = cell(1,size(data.se_vector_wc,2));
            for i = 1:size(data.se_vector_wc,2)
                % calculate amplitudes from water contents with the
                % frequency-specific multiplication factors
                if data.extras.freq(i) <= 4.9e+05 && data.extras.freq(i) >= 4.7e+05 % frequency 1
                    se_vector_amp = data.se_vector_wc(:,i)./10.414;
                elseif extras.freq(i) <= 4.4e+05 && data.extras.freq(i) >= 4.2e+05 % frequency 2
                    se_vector_amp = data.se_vector_wc(:,i)./8.429;
                end

                % get file statistics
                nmrData{i}.datfile = file.name;
                nmrData{i}.date = file.date;
                nmrData{i}.datenum = file.datenum;
                nmrData{i}.bytes = file.bytes;

                % save the NMR data
                nmrData{i}.flag = 'T2';
                nmrData{i}.T1IRfac = 1;
                nmrData{i}.time = data.time;
                nmrData{i}.signal = se_vector_amp;
                nmrData{i}.raw.time = data.time;
                nmrData{i}.raw.signal = se_vector_amp;
                nmrData{i}.phase = data.extras.phase(i);

                % create parameter data
                parData{i}.acq_params_Tr = data.acq_params.Tr;
                parData{i}.depth = data.depth(i);
                parData{i}.Qs = data.extras.Qs(i);
                parData{i}.DCbus = data.extras.DC_bus(i);
                parData{i}.freq = data.extras.freq(i);

                fields = fieldnames(parData{i});
                for j = 1:size(fields,1)
                    tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',...
                        num2str(i),'}.',fields{j}]))];
                end
                d{1} = tmp;
                parData{i}.all = d;
                clear d tmp

                % command line output
                disp([in.name,': importing NMR files ',sprintf('%03d',i),...
                    ' / ',sprintf('%03d',size(data.se_vector_wc,2))]);
            end

        else
            % calculate amplitudes from water contents with the
            % frequency-specific multiplication factors
            if data.extras.freq <= 4.9e+05 && data.extras.freq >= 4.7e+05 % frequency 1
                se_vector_amp = data.se_vector_wc./10.414;
            elseif extras.freq <= 4.4e+05 && extras.freq >= 4.2e+05 % frequency 2
                se_vector_amp = data.se_vector_wc./8.429;
            end

            % get file statistics
            nmrData{1}.datfile = file.name;
            nmrData{1}.date = file.date;
            nmrData{1}.datenum = file.datenum;
            nmrData{1}.bytes = file.bytes;

            % save the NMR data
            nmrData{1}.flag = 'T2';
            nmrData{1}.T1IRfac = 1;
            nmrData{1}.time = data.time;
            nmrData{1}.signal = se_vector_amp;
            nmrData{1}.raw.time = data.time;
            nmrData{1}.raw.signal = se_vector_amp;
            nmrData{1}.phase = data.extras.phase;

            % create parameter data
            parData{1}.acq_params_Tr = data.acq_params.Tr;
            parData{1}.depth = data.depth;
            parData{1}.Qs = data.extras.Qs;
            parData{1}.DCbus = data.extras.DC_bus;
            parData{1}.freq = data.extras.freq;

            fields = fieldnames(parData{1});
            for j = 1:size(fields,1)
                tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',...
                    num2str(1),'}.',fields{j}]))];
            end
            d{1} = tmp;
            parData{1}.all = d;
        end

    case 2
        % load the Matlab mat-file
        data = load(fullfile(in.path,in.name));
        file = dir(fullfile(in.path,in.name));

        % init stuff
        parData = cell(1,size(data.jpd.stack.se,1));
        tmp = cell(1,1);
        % check, if it is one or multiple depths
        if size(data.jpd.stack.se,1) > 1
            % command line output
            disp([in.name,': importing NMR files ...']);

            nmrData = cell(1,size(data.jpd.stack.se,1));
            for i = 1:size(data.jpd.stack.se,1) % loop over all depths
                % get file statistics
                nmrData{i}.datfile = file.name;
                nmrData{i}.date = datestr(data.jpd.acq_time(i));
                nmrData{i}.datenum = data.jpd.acq_time(i);
                nmrData{i}.bytes = file.bytes;

                % save the NMR data
                nmrData{i}.flag = 'T2';
                nmrData{i}.T1IRfac = 1;
                nmrData{i}.time = data.jpd.stack.time(1,1:end)';
                nmrData{i}.signal = data.jpd.stack.se(i,1:end)';
                nmrData{i}.raw.time = data.jpd.stack.time(1,1:end)';
                nmrData{i}.raw.signal = data.jpd.stack.se(i,1:end)';
                nmrData{i}.phase = 0;

                % create parameter data
                parData{i}.acq_params_Tr = 4;
                parData{i}.depth = data.jpd.depth_raw(i);

                fields = fieldnames(parData{i});
                for j = 1:size(fields,1)
                    tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',num2str(i),'}.',fields{j}]))];
                end
                d{1} = tmp;
                parData{i}.all = d;
                clear d tmp

                % command line output
                disp([in.name,': importing NMR files ',sprintf('%03d',i),...
                    ' / ',sprintf('%03d',size(data.jpd.stack.se,1))]);
            end

        else
            % get file statistics
            nmrData{1}.datfile = file.name;
            nmrData{1}.date = file.date;
            nmrData{1}.datenum = file.datenum;
            nmrData{1}.bytes = file.bytes;

            % save the NMR data
            nmrData{1}.flag = 'T2';
            nmrData{1}.T1IRfac = 1;
            nmrData{1}.time = data.jpd.stack.time(1,1:end)';
            nmrData{1}.signal = data.jpd.stack.se(1,1:end)';
            nmrData{1}.raw.time = data.jpd.stack.time(1,1:end)';
            nmrData{1}.raw.signal = data.jpd.stack.se(1,1:end)';
            nmrData{1}.phase = 0;

            % create parameter data
            parData{1}.acq_params_Tr = 4;
            parData{1}.depth = data.jpd.depth_raw(1);

            fields = fieldnames(parData{1});
            for j = 1:size(fields,1)
                tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',num2str(1),'}.',fields{j}]))];
            end
            d{1} = tmp;
            parData{1}.all = d;
        end

    case 3 % University of Vienna
        % load the Matlab mat-file
        data = load(fullfile(in.path,in.name));
        file = dir(fullfile(in.path,in.name));

        disp([in.name,': importing NMR data ...']);

        % init stuff
        tmp = cell(1,1);
        nmrData = cell(1,numel(data.jpd.depth));
        parData = cell(1,numel(data.jpd.depth));

        for i = 1:numel(data.jpd.depth) % loop over all depths
            % get file statistics
            nmrData{i}.datfile = file.name;
            nmrData{i}.date = file.date;
            nmrData{i}.datenum = file.datenum;
            nmrData{i}.bytes = file.bytes;

            % save the NMR data
            nmrData{i}.flag = 'T2';
            nmrData{i}.T1IRfac = 1;
            nmrData{i}.time = data.jpd.freq_stack.time(1,1:end)';
            nmrData{i}.signal = data.jpd.freq_stack.se(i,1:end)';
            nmrData{i}.raw.time = data.jpd.freq_stack.time(1,1:end)';
            nmrData{i}.raw.signal = data.jpd.freq_stack.se(i,1:end)';
            nmrData{i}.phase = 0;

            % create parameter data
            parData{i}.depth = data.jpd.depth(i);
            parData{i}.depth_units = data.jpd.depth_units;
            parData{i}.depth_offset = data.state_proc.depth_offset;
            parData{i}.stack_method = data.state_proc.stack_method;
            parData{i}.phase_method = data.state_proc.phase_method;
            parData{i}.d_avg = data.state_proc.d_avg;
            parData{i}.reg_factor = data.state_proc.reg_factor;
            parData{i}.min_T2 = data.state_proc.min_T2;
            parData{i}.doDCscale = data.state_proc.doDCscale;

            fields = fieldnames(parData{i});
            for j = 1:size(fields,1)
                tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',num2str(i),'}.',fields{j}]))];
            end
            d{1} = tmp;
            parData{i}.all = d;
            clear d tmp

            % command line output
            disp([in.name,': importing NMR data from depth: ',...
                sprintf('%3.2f',data.jpd.depth(i)),' ',data.jpd.depth_units]);
        end

    case 4 % Aarhus T1T2
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

    case 5 % Dart T2 logging
        % read the data file
        datafile = dir(fullfile(in.path,in.name));
        [data,parData] = LoadDataFileLogging(in.path,in.name,in.T1T2);

        nmrData = cell(1,1);
        for nn = 1:numel(data)
            % get file statistics
            nmrData{nn}.datfile = datafile.name;
            nmrData{nn}.date = datafile.date;
            nmrData{nn}.datenum = datafile.datenum;
            nmrData{nn}.bytes = datafile.bytes;

            % save the NMR data
            nmrData{nn}.flag = data{nn}.flag;
            nmrData{nn}.T1IRfac = 1;
            nmrData{nn}.time = data{nn}.time;
            nmrData{nn}.signal = data{nn}.signal;
            nmrData{nn}.raw = data{nn}.raw;
            if strcmp(in.T1T2,'T2')
                nmrData{nn}.phase = data{nn}.phase;
            end
        end
end

% save data to output struct
out.nmrData = nmrData;
out.parData = parData;

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
t_recov = A(1,57); % DART

time = t_echo:t_echo:t_echo*n_echo;
time = time(:);
re = A(2,1:length(time));
im = A(3,1:length(time));
re = re(:);
im = im(:);

data.flag = flag;
data.raw.time = time;
data.raw.signal = complex(re,im);
[data.signal,data.phase] = rotateT2phase(data.raw.signal);

data.time = data.raw.time;

pardata.t_echo = t_echo;
pardata.n_echo = n_echo;
pardata.t_recov = t_recov;
pardata.freq = freq;
pardata.Nscans = Nscans;
d{1}{1,1} = ['t_echo = ',num2str(t_echo)];
d{1}{2,1} = ['n_echo = ',num2str(n_echo)];
d{1}{3,1} = ['t_recov = ',num2str(t_recov)];
d{1}{4,1} = ['freq = ',num2str(freq)];
d{1}{5,1} = ['Nscans = ',num2str(Nscans)];
pardata.all = d;

end

%% load NMR data file
function [data,pardata] = LoadDataFileLogging(datapath,fname,flag)

% importdata is rather slow for row data
% A = importdata(fullfile(datapath,fname),'\t');

% first read the file to get the number of echos
fid = fopen(fullfile(datapath,fname));
A0 = textscan(fid,'%f','Delimiter','\n');
fclose(fid);

% get the number of Echos
n_echo = A0{1}(3);
N = numel(A0{1});
% reshape the data
A1 = reshape(A0{1},[n_echo N/n_echo]);
A2 = A1';

data = cell(1,1);
pardata = cell(1,1);
for nn = 1:size(A2,1)/3
    t_echo = A2(3*nn-2,2);
    n_echo = A2(3*nn-2,3);
    freq = A2(3*nn-2,4);
    Nscans = A2(3*nn-2,5);
    depth = A2(3*nn-2,9);
    t_wait = A2(3*nn-2,14);
    time = t_echo:t_echo:t_echo*n_echo;
    re = A2(3*nn-1,1:length(time));
    im = A2(3*nn,1:length(time));
    time = time(:);
    re = re(:);
    im = im(:);
    data{nn}.flag = flag;
    data{nn}.raw.time = time;
    data{nn}.raw.signal = complex(re,im);
    data{nn}.time = data{nn}.raw.time;
    [data{nn}.signal,data{nn}.phase] = rotateT2phase(data{nn}.raw.signal);

    pardata{nn}.t_echo = t_echo;
    pardata{nn}.n_echo = n_echo;
    pardata{nn}.freq = freq;
    pardata{nn}.Nscans = Nscans;
    pardata{nn}.depth = depth;
    pardata{nn}.t_wait = t_wait;
    d{1}{1,1} = ['t_echo = ',num2str(t_echo)];
    d{1}{2,1} = ['n_echo = ',num2str(n_echo)];
    d{1}{3,1} = ['freq = ',num2str(freq)];
    d{1}{4,1} = ['Nscans = ',num2str(Nscans)];
    d{1}{5,1} = ['depth = ',num2str(depth)];
    d{1}{6,1} = ['t_wait = ',num2str(t_wait)];
    pardata{nn}.all = d;
end


% figure;
% subplot(211);
% plot(data{1}.time,real(data{1}.signal),'k'); hold on
% plot(data{1}.time,imag(data{1}.signal),'k--','LineWidth',1);
% plot(data{3}.time,real(data{3}.signal),'r');
% plot(data{3}.time,imag(data{3}.signal),'r--','LineWidth',1);
% set(gca,'XScale','log','YScale','lin');
% subplot(212);
% plot(data{2}.time,real(data{2}.signal),'k'); hold on
% plot(data{2}.time,imag(data{2}.signal),'k--','LineWidth',1);
% plot(data{4}.time,real(data{4}.signal),'r');
% plot(data{4}.time,imag(data{4}.signal),'r--','LineWidth',1);
% set(gca,'XScale','log','YScale','lin');

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