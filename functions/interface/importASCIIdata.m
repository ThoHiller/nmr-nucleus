function importASCIIdata(src)
%importASCIIdata imports NMR data from ASCII files
%
% Syntax:
%       importASCIIdata(src)
%
% Inputs:
%       src - handle to the calling uimenu
%
% Outputs:
%       none
%
% Example:
%       importASCIIdata(src)
%
% Other m-files required:
%       cleanupGUIData
%       clearAllAxes
%       enableGUIelements;
%       NUCLEUSinv_updateInterface;
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

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% T1 or T2 data?
T1T2 = get(src,'Label');

% get file name
ASCIIpath = -1; %#ok<*NASGU> 
ASCIIfile = -1;
if isfield(data.import,'path')
    [ASCIIfile,ASCIIpath] = uigetfile(fullfile(data.import.path,'*.*'),...
        'Choose ASCII file','MultiSelect','on');
else
    [ASCIIfile,ASCIIpath] = uigetfile(fullfile(pwd,'*.*'),...
        'Choose ASCII file','MultiSelect','on');
end

% only continue if user didn't cancel
if sum(ASCIIpath) > 0    
    % check if there is more than one file
    % multiple file names are stored in a cell array
    if ischar(ASCIIfile)
        tmp = cell(1,1);
        tmp{1} = ASCIIfile;
        clear ASCIIfile;
        ASCIIfile = tmp;
        clear tmp;
    end
    
    % remove info field if any
    ih = findobj('Tag','inv_info');
    if ~isempty(ih); delete(ih); end
    
    % remove old fields and data
    data = cleanupGUIData(data);
    
    data.import.fileformat = 'ascii';
    data.import.path = ASCIIpath;
    data.import.file = ASCIIfile{1};
    
    % update the path-info string
    tmpstr = ASCIIpath;
    if length(tmpstr)>50
        set(gui.text_handles.data_path,'String',['...',tmpstr(end-50:end)],...
            'HorizontalAlignment','left');
    else
        set(gui.text_handles.data_path,'String',tmpstr,...
            'HorizontalAlignment','left');
    end
    set(gui.text_handles.data_path,'TooltipString',tmpstr);
    
    fnames = struct;
    % shownames is just a dummy to hold all data file names that
    % will be shown in the listbox
    shownames = cell(1,1);
    
    c = 0;
    for ifile = 1:numel(ASCIIfile)        
        % get some file infos
        fileID = dir(fullfile(ASCIIpath,ASCIIfile{ifile}));
        
        tmp = importdata(fullfile(ASCIIpath,ASCIIfile{ifile}));

        % only continue if there is data
        if ~isempty(tmp)            
            if isstruct(tmp)
                tmp_data = tmp.data;
            else
                tmp_data = tmp;
            end

            if ifile == 1
                % at first run ask some parameters
                % time unit
                answer = questdlg('What is the time unit?', ...
                'ASCII import', ...
                'µs','ms','s','µs');
                switch answer
                    case 'µs'
                        t_fac = 1e-6;
                    case 'ms'
                        t_fac = 1e-3;
                    case 's'
                        t_fac = 1;
                end
                % time column
                cols = 1:size(tmp_data,2);
                cols_c = cell(1,1);
                for i1 = 1:numel(cols)
                    cols_c{i1} = num2str(i1);
                end
                [ind_time,~] = listdlg('PromptString','Time Column:',...
                'SelectionMode','single','ListString',cols_c);
            end
            
            % the individual file names
            c = c + 1;
            fnames(c).parfile = '';
            fnames(c).datafile = data.import.file;
            fnames(c).T2specfile = '';
            
            shownames{c} = ASCIIfile{ifile};
            
            % the 'header' data
            data.import.NMR.data{c}.datfile = fileID.name;
            data.import.NMR.data{c}.date = fileID.date;
            data.import.NMR.data{c}.datenum = fileID.datenum;
            data.import.NMR.data{c}.bytes = fileID.bytes;
            
            % the NMR data
            data.import.NMR.data{c}.flag = T1T2;
            data.import.NMR.data{c}.time = t_fac.*tmp_data(:,ind_time);
            % switch between T1 and T2 data
            switch T1T2
                case 'T1'
                    data.import.NMR.data{c}.signal = tmp_data(:,ind_time+1);
                    data.import.NMR.data{c}.phase = 0;

                    % try saturation recovery (SR) first
                    param.T1IRfac = 1;
                    param.noise = 0;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = [0 0 0 0 0];
                    param.Tfixed_val = [0 0 0 0 0];
                    noise1 = zeros(5,2);
                    for i1 = 1:5
                        invstd1 = fitDataFree(data.import.NMR.data{c}.time,data.import.NMR.data{c}.signal,...
                        data.import.NMR.data{c}.flag,param,i1);
                        noise1(i1,1) = i1;
                        noise1(i1,2) = invstd1.rms;
                    end                    

                    % now inversion recovery (IR)
                    param.T1IRfac = 2;
                    param.noise = 0;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = [0 0 0 0 0];
                    param.Tfixed_val = [0 0 0 0 0];
                    noise2 = zeros(5,2);
                    for i1 = 1:5
                        invstd2 = fitDataFree(data.import.NMR.data{c}.time,data.import.NMR.data{c}.signal,...
                        data.import.NMR.data{c}.flag,param,i1);
                        noise2(i1,1) = i1;
                        noise2(i1,2) = invstd2.rms;
                    end

                    [idr,~] = find(isnan(noise1));
                    noise1(idr,:) = [];
                    [idr,~] = find(isnan(noise2));
                    noise2(idr,:) = [];

                    [idr1,~] = find(noise1(:,2)==min(noise1(:,2)));
                    [idr2,~] = find(noise2(:,2)==min(noise2(:,2)));

                    if noise1(idr1,2) < noise2(idr2,2)
                        % data is possibly SR
                        T1IRfac = 1;
                        nExp = noise1(idr1,1);
                    else
                        % data is possibly IR
                        T1IRfac = 2;
                        nExp = noise2(idr2,1);
                    end
                    param.T1IRfac = T1IRfac;
                    param.noise = 0;
                    param.optim = data.info.has_optim;
                    param.Tfixed_bool = [0 0 0 0 0];
                    param.Tfixed_val = [0 0 0 0 0];
                    invstd = fitDataFree(data.import.NMR.data{c}.time,data.import.NMR.data{c}.signal,...
                        data.import.NMR.data{c}.flag,param,nExp);

                    % save the "dummy" RMS as noise estimate
                    data.import.NMR.data{c}.noise = invstd.rms;
                case 'T2'
                    T1IRfac = 1;
                    if size(tmp_data,2)>=ind_time+2
                        tmp_signal = complex(tmp_data(:,ind_time+1),tmp_data(:,ind_time+2));
                        [tmp_signal,tmp_phase] = rotateT2phase(tmp_signal);
                        data.import.NMR.data{c}.signal = tmp_signal;
                        data.import.NMR.data{c}.phase = tmp_phase;
                    else
                        data.import.NMR.data{c}.signal = tmp_data(:,ind_time+1);
                        data.import.NMR.data{c}.phase = 0;

                        % noise estimate
                        param.T1IRfac = 1;
                        param.noise = 0;
                        param.optim = data.info.has_optim;
                        param.Tfixed_bool = [0 0 0 0 0];
                        param.Tfixed_val = [0 0 0 0 0];
                        invstd = fitDataFree(data.import.NMR.data{c}.time,data.import.NMR.data{c}.signal,...
                            data.import.NMR.data{c}.flag,param,5);
                        % save the "dummy" RMS as noise estimate
                        data.import.NMR.data{c}.noise = invstd.rms;
                    end
            end
            data.import.NMR.data{c}.T1IRfac = T1IRfac;
            data.import.NMR.data{c}.raw.time = data.import.NMR.data{c}.time;
            data.import.NMR.data{c}.raw.signal = data.import.NMR.data{c}.signal;
            
            % dummy parameter data
            data.import.NMR.para{c} = 0;
        end        
    end
    
    % save file names
    data.import.NMR.files = fnames;
    data.import.NMR.filesShort = shownames;
    
    % update the ini-file
    gui.myui.inidata.importpath = data.import.path;
    gui = makeINIfile(gui,'update');
    
    % update the list of file names
    set(gui.listbox_handles.signal,'String',data.import.NMR.filesShort);
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
    
    % create a global INVdata struct for every file in the list
    if isstruct(getappdata(fig,'INVdata'))
        setappdata(fig,'INVdata',[]);
    end
    INVdata = cell(length(data.import.NMR.filesShort),1);
    setappdata(fig,'INVdata',INVdata);
    
    % clear all axes
    clearAllAxes(gui.figh);
    
    % update GUI data and interface
    setappdata(fig,'data',data);
    setappdata(fig,'gui',gui);
    enableGUIelements('ASCII');
    NUCLEUSinv_updateInterface;    
end

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