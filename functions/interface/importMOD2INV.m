function importMOD2INV(src)
%importINV2INV imports data directly from the NUCLEUSmod GUI or and
%NUCLEUSmod data file
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
    case 'File'
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            [NMRfile,NMRpath] = uigetfile(import.path,'Choose NUCLEUSmod file');
        else
            % otherwise we start at the current working directory
            % 'pathstr' hold s the name of the chosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            [NMRfile,NMRpath] = uigetfile(pathstr,'Choose NUCLEUSmod file');
        end
        
        % only continue if user didn't cancel
        if sum([NMRpath NMRfile]) > 0
            fileID = dir(fullfile(NMRpath,NMRfile));
            % import the data
            datamod = load(fullfile(NMRpath,NMRfile),'data');
            datamod = datamod.data;
            data.import.NMRMOD.p = datamod.SAT.pressure;
            data.import.NMRMOD.Sd = datamod.SAT.Sdfull;
            data.import.NMRMOD.Si = datamod.SAT.Sifull;
            data.import.NMRMOD.dL = datamod.NMRMOD_GUI.pressure.DrainLevels;
            data.import.NMRMOD.iL = datamod.NMRMOD_GUI.pressure.ImbLevels;
            data.import.NMRMOD.psddata = datamod.psddata;
            data.import.NMRMOD.geom = datamod.GEOM;
            data.import.NMRMOD.nmr = datamod.NMR;
            data.import.NMRMOD.T1T2 = datamod.NMRMOD_GUI.nmr.toplot;
            data.import.NMRMOD.gui_pressure = datamod.NMRMOD_GUI.pressure;
        end
        
    case 'GUI'
        % check if GUI is open
        figmod = findobj('Tag','MOD');
        if ~isempty(figmod)
            % now check if there is data to use
            datamod = getappdata(figmod,'data');
            if isfield(datamod,'results')
                if isfield(datamod.results,'NMR')
                    % file info
                    fileID.name = 'NUCLEUSmod GUI';
                    fileID.date = datestr(now);
                    fileID.datenum = now;
                    fileID.bytes = 0;
                    
                    NMRpath = pwd;
                    NMRfile = 'NUCLEUSmod GUI';
                    % import the data
                    data.import.NMRMOD.p = datamod.results.SAT.pressure;
                    data.import.NMRMOD.Sd = datamod.results.SAT.Sdfull;
                    data.import.NMRMOD.Si = datamod.results.SAT.Sifull;
                    data.import.NMRMOD.dL = datamod.pressure.DrainLevels;
                    data.import.NMRMOD.iL = datamod.pressure.ImbLevels;
                    data.import.NMRMOD.psddata = datamod.results.psddata;
                    data.import.NMRMOD.geom = datamod.results.GEOM;
                    data.import.NMRMOD.nmr = datamod.results.NMR;
                    data.import.NMRMOD.T1T2 = datamod.nmr.toplot;
                    data.import.NMRMOD.gui_pressure = datamod.pressure;
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
    
    dL = data.import.NMRMOD.dL;
    iL = data.import.NMRMOD.iL;
    T1T2 = data.import.NMRMOD.T1T2;
    T1IRfac = 1;
    table = {true,0,1,'D'};
    
    c = 0;
    % first we import drainage NMR data
    for i = 1:numel(dL)
        % the individual file names
        c = c + 1;
        fnames(c).parfile = '';
        fnames(c).datafile = data.import.file;
        fnames(c).T2specfile = '';
        
        shownames{c} = ['NUCLEUSmod_',T1T2,'_drain_',num2str(i)];
        
        % the 'header' data
        data.import.NMR.data{c}.datfile = fileID.name;
        data.import.NMR.data{c}.date = fileID.date;
        data.import.NMR.data{c}.datenum = fileID.datenum;
        data.import.NMR.data{c}.bytes = fileID.bytes;
        % the NMR data
        data.import.NMR.data{c}.flag = T1T2;
        data.import.NMR.data{c}.T1IRfac = T1IRfac;
        data.import.NMR.data{c}.time = data.import.NMRMOD.nmr.t(:);
        switch T1T2
            case 'T1'
                data.import.NMR.data{c}.signal = data.import.NMRMOD.nmr.EdT1(dL(i),:)';
                data.import.NMR.data{c}.noise = data.import.NMRMOD.nmr.noise(dL(i),2);
            case 'T2'
                data.import.NMR.data{c}.signal = data.import.NMRMOD.nmr.EdT2(dL(i),:)';
                data.import.NMR.data{c}.noise = data.import.NMRMOD.nmr.noise(dL(i),4);
        end
        data.import.NMR.data{c}.phase = 0;
        data.import.NMR.data{c}.raw.time = data.import.NMR.data{c}.time;
        data.import.NMR.data{c}.raw.signal = data.import.NMR.data{c}.signal;
        
        data.import.NMR.para{c}.geom = data.import.NMRMOD.geom.type;
        data.import.NMR.para{c}.Tbulk = data.import.NMRMOD.nmr.Tb;
        if isfield(data.import.NMRMOD.nmr,'Td')
            data.import.NMR.para{c}.Tdiff = data.import.NMRMOD.nmr.Td;
        else
            data.import.NMR.para{c}.Tdiff = 1e6;
        end
        data.import.NMR.para{c}.rho = data.import.NMRMOD.nmr.rho;
        data.import.NMR.para{c}.porosity = data.import.NMRMOD.nmr.porosity;
        
        table{c,1} = true;
        table{c,2} = data.import.NMRMOD.p(dL(i));
        table{c,3} = data.import.NMRMOD.Sd(dL(i));
        table{c,4} = 'D';
    end
    
    % now we import imbibition NMR data
    for i = 1:numel(iL)
        % the individual file names
        c = c + 1;
        fnames(c).parfile = '';
        fnames(c).datafile = data.import.file;
        fnames(c).T2specfile = '';
        
        shownames{c} = ['NUCLEUSmod_',T1T2,'_imb_',num2str(i)];
        
        % the 'header' data
        data.import.NMR.data{c}.datfile = fileID.name;
        data.import.NMR.data{c}.date = fileID.date;
        data.import.NMR.data{c}.datenum = fileID.datenum;
        data.import.NMR.data{c}.bytes = fileID.bytes;
        % the NMR data
        data.import.NMR.data{c}.flag = T1T2;
        data.import.NMR.data{c}.T1IRfac = T1IRfac;
        data.import.NMR.data{c}.time = data.import.NMRMOD.nmr.t(:);
        switch T1T2
            case 'T1'
                data.import.NMR.data{c}.signal = data.import.NMRMOD.nmr.EiT1(iL(i),:)';
                data.import.NMR.data{c}.noise = data.import.NMRMOD.nmr.noise(iL(i),1);
            case 'T2'
                data.import.NMR.data{c}.signal = data.import.NMRMOD.nmr.EiT2(iL(i),:)';
                data.import.NMR.data{c}.noise = data.import.NMRMOD.nmr.noise(iL(i),3);
        end
        data.import.NMR.data{c}.phase = 0;
        data.import.NMR.data{c}.raw.time = data.import.NMR.data{c}.time;
        data.import.NMR.data{c}.raw.signal = data.import.NMR.data{c}.signal;
        
        data.import.NMR.para{c}.geom = data.import.NMRMOD.geom.type;
        data.import.NMR.para{c}.Tbulk = data.import.NMRMOD.nmr.Tb;
        if isfield(data.import.NMRMOD.nmr,'Td')
            data.import.NMR.para{c}.Tdiff = data.import.NMRMOD.nmr.Td;
        else
            data.import.NMR.para{c}.Tdiff = 1e6;
        end
        data.import.NMR.para{c}.rho = data.import.NMRMOD.nmr.rho;
        data.import.NMR.para{c}.porosity = data.import.NMRMOD.nmr.porosity;
        
        table{c,1} = true;
        table{c,2} = data.import.NMRMOD.p(iL(i));
        table{c,3} = data.import.NMRMOD.Si(iL(i));
        table{c,4} = 'I';
    end
    
    data.import.NMR.files = fnames;
    data.import.NMR.filesShort = shownames;
    
    % import pressure / saturation data
    data.pressure.unit = data.import.NMRMOD.gui_pressure.unit;
    data.pressure.unitfac = data.import.NMRMOD.gui_pressure.unitfac;
    data.pressure.table = table;
    
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