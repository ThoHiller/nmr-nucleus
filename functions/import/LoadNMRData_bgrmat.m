function out = LoadNMRData_bgrmat(in)
%LoadNMRData_bgrmat loads already preprocessed BGR NMR data; check the
%individual documentation for the data fields
%
% Syntax:
%       out = LoadNMRData_bgrmat(in)
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
%       out.pressData - pressure data
%
% Example:
%       out = LoadNMRData_bgrmat(in)
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

%% load the Matlab mat-file 
data = load(fullfile(in.path,in.name));
data = data.data;
% "dir" the file to get some file statistics
file = dir(fullfile(in.path,in.name));

% init stuff
parData = cell(1,1);
tmp = cell(1,1);

% number of signals
Nsig = size(data.sig,2);
% saturation S
S = zeros(1,Nsig);

% check, if it is one or multiple NMR measurements
if Nsig > 1
    nmrData = cell(1,Nsig);
    for i = 1:Nsig
        % save file statistics
        nmrData{i}.datfile = file.name;
        nmrData{i}.date = file.date;
        nmrData{i}.datenum = file.datenum;
        nmrData{i}.bytes = file.bytes;
    
        % check if T1 or T2 data
        if ~isempty(strfind(data.method,'T2'))
            nmrData{i}.flag = 'T2';
        else
            nmrData{i}.flag = 'T1';
        end
        
        switch nmrData{i}.flag
            case 'T1'
                % time vector
                nmrData{i}.time = data.sig(i).t;
                if ~isempty(strfind(data.method,'inv'))
                    nmrData{i}.T1IRfac = 2;
                else
                    nmrData{i}.T1IRfac = 1;
                end
                nmrData{i}.signal = data.sig(i).V;
                % porosity
                % for the MOUSE data the V_re is normalized to WC and not V
                % as for the Maran data
                if abs(data.sig(1).V(end)) > 0.7
                    porosity = abs(data.sig(1).V_re(end));
                else
                    porosity = abs(data.sig(1).V(end));
                end
                % saturation
                saturation = abs(data.sig(i).V(end))/abs(data.sig(1).V(end));
                % normalize signal to 1
                nmrData{i}.signal = nmrData{i}.signal./nmrData{i}.signal(end);                
            case 'T2'
                nmrData{i}.T1IRfac = 1;
                % time vector
                nmrData{i}.time = data.sig(i).t;                
                if isfield(data.sig(i),'V_im')
                    nmrData{i}.signal = complex(data.sig(i).V_re,data.sig(i).V_im);
                    % if there is an imag part the signal gets phase corrected
                    [nmrData{i}.signal,parData{i}.phase] = rotateT2phase(nmrData{i}.signal);
                else
                    nmrData{i}.signal = data.sig(i).V_re;
                end
                % porosity
                porosity = abs(data.sig(1).V(1));
                % saturation
                saturation = abs(data.sig(i).V(1))/abs(data.sig(1).V(1));
                % normalize signal to 1
                nmrData{i}.signal = nmrData{i}.signal./real(nmrData{i}.signal(1));
        end
        
        % normalize all signals to saturation
        nmrData{i}.signal = saturation.*nmrData{i}.signal;
        
        % raw data
        nmrData{i}.raw.time = nmrData{i}.time;
        nmrData{i}.raw.signal = nmrData{i}.signal;

        % create some parameter data
        if iscell(data.sig(i).file)
            parData{i}.file = data.sig(i).file{1};
        else
            parData{i}.file = data.sig(i).file;
        end        
        parData{i}.Tbulk = data.T_bulk(i);
        parData{i}.porosity = porosity;
        parData{i}.saturation = saturation;
        
        fields = fieldnames(parData{i});
        for j = 1:size(fields,1)
            tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',...
                num2str(i),'}.',fields{j}]))];
        end
        d{1} = tmp;
        parData{i}.all = d;
        S(i) = parData{i}.saturation;
        
        clear d tmp
    end

    % and the pressure data
    pressData.p = data.h;
    pressData.S = S;
else
    parData = [];
    nmrData = [];
    pressData = [];
    helpdlg({'function: LoadNMRData_bgrmat',...
            'single data import not yet implemented'},'not implemented yet');
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;
out.pressData = pressData;

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