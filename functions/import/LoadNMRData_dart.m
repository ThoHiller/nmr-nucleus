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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% start processing the files
% load the Matlab mat-file 
data = load(fullfile(in.path,in.name));
file = dir(fullfile(in.path,in.name));

% init stuff
parData = cell(1,1);
tmp = cell(1,1);
% check, if it is one or multiple depths
if size(data.se_vector_wc,2) > 1
    % commandline output
    disp([in.name,': importing NMR files ...']);

    nmrData = cell(1,size(data.se_vector_wc,2));
    for i = 1:size(data.se_vector_wc,2)
        % calculate amplitudes from water contents with the frequency-specific
        % multiplication factors
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
        
        % cretae parameter data
        parData{i}.acq_params_Tr = data.acq_params.Tr;
        parData{i}.depth = data.depth(i);
        parData{i}.Qs = data.extras.Qs(i);
        parData{i}.DCbus = data.extras.DC_bus(i);
        parData{i}.freq = data.extras.freq(i);
        parData{i}.phase = data.extras.phase(i);
        
        fields = fieldnames(parData{i});
        for j = 1:size(fields,1)
            tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',num2str(i),'}.',fields{j}]))];
        end
        d{1} = tmp;
        parData{i}.all = d;        
        clear d tmp
        
        % commandline output
        disp([in.name,': importing NMR files ',sprintf('%03d',i),...
            ' / ',sprintf('%03d',size(data.se_vector_wc,2))]);
    end
    
else
    % calculate amplitudes from water contents with the frequency-specific
    % multiplication factors
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
    
    % cretae parameter data
    parData{1}.acq_params_Tr = data.acq_params.Tr;
    parData{1}.depth = data.depth;
    parData{1}.Qs = data.extras.Qs;
    parData{1}.DCbus = data.extras.DC_bus;
    parData{1}.freq = data.extras.freq;
    parData{1}.phase = data.extras.phase;
   
    fields = fieldnames(parData{1});
    for j = 1:size(fields,1)
        tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',num2str(1),'}.',fields{j}]))];
    end
    d{1} = tmp;
    parData{1}.all = d;    
end

% save data to output struct
out.nmrData = nmrData;
out.parData = parData;

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