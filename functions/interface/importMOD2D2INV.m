function importMOD2D2INV(src)
%importMOD2D2INV imports data directly from the NUCLEUSmod 2D GUI
%
% Syntax:
%       importMOD2INV(src)
%
% Inputs:
%       src - handle to the calling uimenu
%
% Outputs:
%       none
%
% Example:
%       importMOD2INV(src)
%
% Other m-files required:
%       clearAllAxes
%       enableGUIelements
%       NUCLEUSinv_updateInterface
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

% remove old fields and data
data = cleanupGUIData(data);

% check import format and load the data
label = get(src,'Label');

% get file name
NMRpath = -1;
NMRfile = -1;
switch label
    case '2D GUI'
        % check if GUI is open
        figmod = findobj('Tag','2DMOD');
        if ~isempty(figmod)
            % now check if there is data to use
            datamod = getappdata(figmod,'data');
            if isfield(datamod,'results')
                if isfield(datamod.results,'mod2D')
                    % file info
                    fileID.name = 'NUCLEUSmod 2D GUI';
                    fileID.date = string(datetime("now"));
                    fileID.datenum = convertTo(datetime("now"),"datenum");
                    fileID.bytes = 0;
                    
                    NMRpath = pwd;
                    NMRfile = 'NUCLEUSmod 2D GUI';
                    % import the data
                    data.import.NMRMOD.nmr = datamod.results.mod2D.data;
                else
                    helpdlg({'importNUCLEUSmod:',...
                        'No data in NUCLEUSmod to use.'},'no data');
                end
            else
                helpdlg({'importNUCLEUSmod:',...
                    'No data in NUCLEUSmod to use.'},'no data');
            end
        else
            helpdlg({'importNUCLEUSmod:',...
                'NUCLEUSmod is not open.'},'not found');
        end
    otherwise
        helpdlg({'importNUCLEUSmod2d:',...
                'NUCLEUSmod 2D is not open.'},'not found');
end

% if data was imported we can proceed
if isfield(data.import,'NMRMOD')
    data.import.fileformat = 'NMRMOD';
    data.import.path = NMRpath;
    data.import.file = NMRfile;
    
    % update the path-info string
    if NMRfile > 0
        tmpstr = fullfile(NMRpath,NMRfile);
    else
        tmpstr = NMRpath;
    end
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
    
    T1T2 = 'T2';
    T1IRfac = datamod.nmr.T1IRfac;
    
    c = 0;
    for i = 1:numel(data.import.NMRMOD.nmr)
        % the individual file names
        c = c + 1;
        fnames(c).parfile = '';
        fnames(c).datafile = data.import.file;
        fnames(c).T2specfile = '';
        
        shownames{c} = ['NUCLEUSmod_',T1T2,'_2D_',num2str(i)];
        
        % the 'header' data
        data.import.NMR.data{c}.datfile = fileID.name;
        data.import.NMR.data{c}.date = datestr(addtodate(fileID.datenum,-numel(data.import.NMRMOD.nmr)+i,'minute'));
        data.import.NMR.data{c}.datenum = addtodate(fileID.datenum,-numel(data.import.NMRMOD.nmr)+i,'minute');
        data.import.NMR.data{c}.bytes = fileID.bytes;
        % the NMR data
        data.import.NMR.data{c}.flag = T1T2;
        data.import.NMR.data{c}.T1IRfac = T1IRfac;
        data.import.NMR.data{c}.time = data.import.NMRMOD.nmr(i).t(:);

        data.import.NMR.data{c}.signal = data.import.NMRMOD.nmr(i).s(:);
        data.import.NMR.data{c}.noise = data.import.NMRMOD.nmr(i).noise;

        data.import.NMR.data{c}.phase = 0;
        data.import.NMR.data{c}.raw.time = data.import.NMR.data{c}.time;
        data.import.NMR.data{c}.raw.signal = data.import.NMR.data{c}.signal;
        
        % data.import.NMR.para{c}.geom = data.import.NMRMOD.geom.type;
        data.import.NMR.para{c}.Tbulk = datamod.prop.Tbulk;
        data.import.NMR.para{c}.Tdiff = 1e6;
        data.import.NMR.para{c}.t_echo = datamod.nmr.T2te;
        data.import.NMR.para{c}.rho = 100;
        data.import.NMR.para{c}.porosity = 1;
    end
    
    % set T2 echo time
    data.inv2D.prop.te = datamod.nmr.T2te;

    % save the recovery time vector for later use
    data.import.T1T2map.t_recov = datamod.results.mod2D.t_recov(:);
    data.import.T1T2map.t2 = data.import.NMR.data{1}.time;
    data.import.T1T2map.t2N = numel(data.import.NMR.data{1}.time);

    % add the stacked signal to the data
    flag = 'T1';
    time = data.import.T1T2map.t_recov;
    signal = zeros(numel(data.import.NMR.data),1);
    for i1 = 1:numel(data.import.NMR.data)
        % signal(i1,1) = mean(real(data.import.NMR.data{i1}.signal(1:3)));
        signal(i1,1) = real(data.import.NMR.data{i1}.signal(1));
    end
    disp('NUCLUESinv import: Estimating noise from exponential fit ...');
    param.T1IRfac = 2;
    param.noise = 0;
    param.optim = 'off';
    param.Tfixed_bool = [0 0 0 0 0];
    param.Tfixed_val = [0 0 0 0 0];
    for i1 = 1:5
        invstd = fitDataFree(time,signal,flag,param,i1);
        if i1 == 1
            noise = invstd.rms;
        else
            noise = min([noise invstd.rms]);
        end
    end
    disp('NUCLUESinv import: done.')
    % finally create a new "import" data set
    data_new = data.import.NMR.data(1);
    para_new = data.import.NMR.para(1);

    data_new{1}.flag = flag;
    data_new{1}.T1IRfac = param.T1IRfac;
    data_new{1}.time = time;
    data_new{1}.signal = signal;
    data_new{1}.noise = noise;
    data_new{1}.raw.time = time;
    data_new{1}.raw.signal = signal;

    data.import.NMR.data{numel(time)+1} = data_new{1};
    data.import.NMR.para{numel(time)+1} = para_new{1};
    fnames(numel(time)+1).datafile = 'T1_merged.dat';
    shownames{numel(time)+1} = 'T1_merged';

    data.import.NMR.files = fnames;
    data.import.NMR.filesShort = shownames;

    % update the list of file names
    set(gui.listbox_handles.signal,'String',data.import.NMR.filesShort);
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
    
    % create a global INVdata struct for every file in the list
    if isstruct(getappdata(fig,'INVdata'))
        setappdata(fig,'INVdata',[]);
    end
    INVdata = cell(length(data.import.NMR.filesShort),1);
    setappdata(fig,'INVdata',INVdata);
    
    %  clear all axes
    clearAllAxes(gui.figh);
    
    % enable GUI data and interface
    setappdata(fig,'data',data);
    setappdata(fig,'gui',gui);
    enableGUIelements('MOD');
    NUCLEUSinv_updateInterface;
else
    helpdlg({'importNUCLEUSmod:',...
        'NUCLEUSmod data import unsuccessful.'},'import error');
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