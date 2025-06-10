function out = LoadNMRData_mrsmatlab(in)
%LoadNMRData_mrsmatlab loads already preprocessed MRSMatlab SNMR data
%
% Syntax:
%       out = LoadNMRData_mrsmatlab(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.fileformat - 'mrsd'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%       out.pressData - pressure data
%
% Example:
%       out = LoadNMRData_mrsmatlab(in)
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

%% load the Matlab mat-file
data = load(fullfile(in.path,in.name),'-mat');
data = data.proclog;
% "dir" the file to get some file statistics
file = dir(fullfile(in.path,in.name));

% init stuff
parData = cell(1,1);
tmp = cell(1,1);

% number of signals
Nq = size(data.Q,2);

nmrData = cell(1,Nq);
q = zeros(Nq,1);
for i = 1:Nq
    % save file statistics
    nmrData{i}.datfile = file.name;
    nmrData{i}.date = file.date;
    nmrData{i}.datenum = file.datenum+i*1000;
    nmrData{i}.bytes = file.bytes;

    nmrData{i}.flag = 'T2';
    nmrData{i}.T1IRfac = 1;
    % time vector
    nmrData{i}.time = data.Q(i).rx.sig(2).t(:);
    if nmrData{i}.time(1) == 0
        nmrData{i}.time(1) = nmrData{i}.time(2) - (nmrData{i}.time(3)-nmrData{i}.time(2))/2;
    end
    nmrData{i}.signal = data.Q(i).rx.sig(2).V(:).*1e9;
    nmrData{i}.phase = 0;

    nmrData{i}.signal = mrsrotate(nmrData{i}.signal,nmrData{i}.time,...
        data.Q(i).rx.sig(2).fit(4),data.Q(i).rx.sig(2).fit(3));

    % raw data
    nmrData{i}.raw.time = nmrData{i}.time;
    nmrData{i}.raw.signal = nmrData{i}.signal;

    parData{i}.q = data.Q(i).q;
    parData{i}.file = ['q',sprintf('%d',i),' (', sprintf('%4.3f',data.Q(i).q),' As)'];
    parData{i}.device = data.device;
    q(i) = data.Q(i).q;

    fields = fieldnames(parData{i});
    for j = 1:size(fields,1)
        tmp{j,1} = [fields{j},'=',num2str(eval(['parData{',...
            num2str(i),'}.',fields{j}]))];
    end
    d{1} = tmp;
    parData{i}.all = d;
    clear d tmp
end

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;
out.q = q;

end

%%
function rotV = mrsrotate(V,t,phase,df)
% function rotV = mrs_rotate(V,t,phase,df)
% rotate complex NMR FID data
% after rotation real part contains NMR and noise imaginary part only noise
% Input: 
%       V: complex FID
%       phase, df: after fitting of FID
%       t: time according to the fit
   
rotV = complex(abs(V).*cos(angle(V) - phase - 2*pi*df.*t),...
               abs(V).*sin(angle(V) - phase - 2*pi*df.*t));

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