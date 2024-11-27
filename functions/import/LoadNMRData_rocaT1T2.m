function out = LoadNMRData_rocaT1T2(in)
%LoadNMRData_rocaT1T2 loads T1T2 NMR data from a typical folder structure
%produced by the Magritek Rock Core Analyzer
%
% Syntax:
%       out = LoadNMRData_rocaT1T2(in)
%
% Inputs:
%       in - input structure
%       in.path - data path
%       in.T1T2 - T1 / T2 flag
%       in.fileformat - 'rocaT1T2'
%
% Outputs:
%       out - output structure
%       out.parData - parameter file data
%       out.nmrData - NMR data
%
% Example:
%       out = LoadNMRData_helios(in)
%
% Other m-files required:
%       fixParameterString
%
% Subfunctions:
%       LoadDataFile
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

% read the data file
datafile = dir(fullfile(in.path,in.name));
% load Parameter file
parData = LoadParameterFile(in.path,'acqu.par');
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

% save data to output struct
out.parData = parData;
out.nmrData = nmrData;

end

%% load NMR data file
function data = LoadDataFile(datapath,fname,flag,pardata)

% first read the file
d = importdata(fullfile(datapath,fname));

% create echo time vector
time = pardata.echoTime:pardata.echoTime:pardata.echoTime*pardata.nrEchoes;
time = time(:)./1e6; % to [s]

% swicth on/off debug plots
do_debug = false;

%% start of DEBUG part
if do_debug
    figure; %#ok<*UNRCH>
    ax1 = subplot(131);
    ax2 = subplot(132);
    ax3 = subplot(133);
    hold([ax1 ax2 ax3],'on');
    id_last = size(d,1);
    id_test = round(linspace(1,id_last-1,8));
    for j1 = [id_test id_last]
        re = d(j1,1:2:end);
        im = d(j1,2:2:end);

        mag = abs(complex(re,im));

        if j1 < id_last
            LS = '-';
        else
            LS = '--';
        end
        plot(time,re','LineStyle',LS,'DisplayName',['row',sprintf('%d',j1)],'Parent',ax1);
        plot(time,im','LineStyle',LS,'DisplayName',['row',sprintf('%d',j1)],'Parent',ax2);
        plot(time,mag','LineStyle',LS,'DisplayName',['row',sprintf('%d',j1)],'Parent',ax3);

    end
    hold([ax1 ax2 ax3],'off');
    set([ax1 ax2 ax3],'XScale','log');
    set(get(ax1,'Xlabel'),'String','time [s]');
    set(get(ax2,'Xlabel'),'String','time [s]');
    set(get(ax3,'Xlabel'),'String','time [s]');
    set(get(ax1,'Ylabel'),'String','Real part');
    set(get(ax2,'Ylabel'),'String','Imag part');
    set(get(ax3,'Ylabel'),'String','Magntiude sqrt(Re^2+Im^2)');

    figure;
    ax1 = subplot(131);
    ax2 = subplot(132);
    ax3 = subplot(133);
    hold([ax1 ax2 ax3],'on');
    for j1 = id_test
        re = d(j1,1:2:end)-d(id_last,1:2:end);
        im = d(j1,2:2:end)-d(id_last,2:2:end);

        mag = abs(complex(re,im));

        plot(time,re','DisplayName',['row',sprintf('%d',j1)],'Parent',ax1);
        plot(time,im','DisplayName',['row',sprintf('%d',j1)],'Parent',ax2);
        plot(time,mag','DisplayName',['row',sprintf('%d',j1)],'Parent',ax3);

    end
    hold([ax1 ax2 ax3],'off');
    set([ax1 ax2 ax3],'XScale','log');
    set(get(ax1,'Xlabel'),'String','time [s]');
    set(get(ax2,'Xlabel'),'String','time [s]');
    set(get(ax3,'Xlabel'),'String','time [s]');
    set(get(ax1,'Ylabel'),'String','Real part');
    set(get(ax2,'Ylabel'),'String','Imag part');
    set(get(ax3,'Ylabel'),'String','Magntiude sqrt(Re^2+Im^2)');
end
% end of DEBUG part

%
% correction after Hürliman 2001, JMR 148
% last row is the correction signal
dref = d(end,:);
% the data without the last row
d = d(1:end-1,:);
% subtract the correction signal from all other signals
d = d - dref;

% rotate the longest delay time (last row) and get its phase
dlong = complex(d(end,1:2:end),d(end,2:2:end));
[dlong_rot,dlong_phase] = rotateT2phase(dlong);

if do_debug
    figure;
    subplot(121);
    plot(time,real(dlong)); hold on
    plot(time,imag(dlong));
    xlabel('time [s]');
    ylabel('amplitude');
    title('from file');
    subplot(122);
    plot(time,real(dlong_rot)); hold on
    plot(time,imag(dlong_rot));
    xlabel('time [s]');
    ylabel('amplitude');
    title('after rotation');

    plotphase = zeros(pardata.tauSteps,1);
end

data = struct;
for j1 = 1:pardata.tauSteps
    re = d(j1,1:2:end);
    im = d(j1,2:2:end);
    re = re(:);
    im = im(:);
    data(j1).flag = flag;
    data(j1).raw.time = time;
    data(j1).time = time;

    tmp_s = complex(re,im);

    % rotate the signal with an angle within reference phase +- 5deg
    [tmp_s,tmp_phase] = rotateT2phase(tmp_s,'stdIm',...
        [dlong_phase-deg2rad(5) dlong_phase+deg2rad(5)]);

    % save the data
    data(j1).raw.signal = tmp_s;
    data(j1).signal = data(j1).raw.signal;
    data(j1).phase = tmp_phase;
    
    if do_debug
        plotphase(j1) = tmp_phase;
    end
end
if do_debug
    figure;
    plot(rad2deg(plotphase));
    xlabel('row number');
    ylabel('phase angle [deg]');

    figure;
    ax1 = subplot(131);
    ax2 = subplot(132);
    ax3 = subplot(133);
    hold([ax1 ax2 ax3],'on');
    for j1 = id_test
        re = real(data(j1).raw.signal);
        im = imag(data(j1).raw.signal);

        mag = abs(complex(re,im));

        plot(time,re','DisplayName',['row',sprintf('%d',j1)],'Parent',ax1);
        plot(time,im','DisplayName',['row',sprintf('%d',j1)],'Parent',ax2);
        plot(time,mag','DisplayName',['row',sprintf('%d',j1)],'Parent',ax3);

    end
    hold([ax1 ax2 ax3],'off');
    set([ax1 ax2 ax3],'XScale','log');
    set(get(ax1,'Xlabel'),'String','time [s]');
    set(get(ax2,'Xlabel'),'String','time [s]');
    set(get(ax3,'Xlabel'),'String','time [s]');
    set(get(ax1,'Ylabel'),'String','Real part');
    set(get(ax2,'Ylabel'),'String','Imag part');
    set(get(ax3,'Ylabel'),'String','Magntiude sqrt(Re^2+Im^2)');
end

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
