function importNMRdata(src)
%importNMRdata is the general import routine for NMR data
%
% Syntax:
%       importNMRdata(src)
%
% Inputs:
%       src - handle of the calling menu
%
% Outputs:
%       none
%
% Example:
%       importNMRdata(src)
%
% Other m-files required:
%       cleanupGUIData
%       clearAllAxes
%       displayStatusText
%       enableGUIelements('NMR');
%       LoadNMRData_driver
%       NUCLEUSinv_updateInterface
%
% Subfunctions:
%       getNMRPathFile
%       importDataBGR
%       importDataBGRmat
%       importDataDart
%       importDataGeneral
%       importDataLIAG
%       importDataLIAGproject
%       importDataMouse
%       loadGUIParameters
%       loadGUIrawdata
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% try is used to catch any import error
% often the wrong input file format is the case
try
    % check what import format is chosen
    label = get(src,'Label');
    
    % set file format for later use
    if strcmp(label,'GGE ascii')
        data.import.fileformat = 'rwth';
    elseif strcmp(label,'GGE field')
        data.import.fileformat = 'field';
    elseif strcmp(label,'GGE Dart')
        data.import.fileformat = 'dart';
    elseif strcmp(label,'CoreLab ascii')
        data.import.fileformat = 'corelab';
    elseif strcmp(label,'MOUSE')
        data.import.fileformat = 'mouse';
    elseif strcmp(label,'LIAG single')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'LIAG from project')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'LIAG last project')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'BGR std')
        data.import.fileformat = 'bgr';
    elseif strcmp(label,'BGR org')
        data.import.fileformat = 'bgr2';
    elseif strcmp(label,'BGR mat')
        data.import.fileformat = 'bgrmat';
    elseif strcmp(label,'BAM TOM')
        data.import.fileformat = 'bamtom';
    elseif strcmp(label,'PM5')
        data.import.fileformat = 'pm5';
    elseif strcmp(label,'PM25')
        data.import.fileformat = 'pm25';
    else
        helpdlg('Something is utterly wrong.','onMenuImport: Choose again.');
    end
    
    % remove info field if any
    ih = findobj('Tag','inv_info');
    if ~isempty(ih); delete(ih); end
    
    % depending on the import format get the corresponding path / file
    [NMRpath,NMRfile] = getNMRPathFile(label,data.import);
    
    % only continue if user didn't cancel
    if sum([NMRpath NMRfile]) > 0
        %  remove old fields and data
        data = cleanupGUIData(data);
        
        % check for mat-file with GUI rawdata and import data
        isfile = dir(fullfile(NMRpath,'NUCLEUSinv_raw.mat'));
        
        % if there is nor raw-file import from folder/file
        if isempty(isfile)
            % import data
            data.import.path = NMRpath;
            data.import.file = -1;
            displayStatusText(gui,'Reading NMR Data ...');
            % call the corresponding subroutines
            switch label
                case {'GGE ascii','GGE field','CoreLab ascii','BGR std',...
                        'BAM TOM'}
                    [data,gui] = importDataGeneral(data,gui);
                case 'Dart'
                    data.import.file = NMRfile;
                    [data,gui] = importDataDart(data,gui);
                case 'MOUSE'
                    [data,gui] = importDataMouse(data,gui);
                case 'LIAG single'
                    [data,gui] = importDataLIAG(data,gui);
                case {'LIAG from project','LIAG last project'}
                    [data,gui] = importDataLIAGproject(data,gui);
                    % make the Petro Panel visible as default
                    tmp_h = gui.myui.heights(2,:);
                    tmp_h(3) = gui.myui.heights(2,3);
                    % but the CPS panel stays minimized
                    tmp_h(5) = gui.myui.heights(1,3);
                    set(gui.panels.main,'Heights',tmp_h);
                    set(gui.panels.petro.main,'Minimized',false);
                case 'BGR org'
                    [data,gui] = importDataBGR(data,gui);
                case 'BGR mat'
                    data.import.file = NMRfile;
                    [data,gui] = importDataBGRmat(data,gui);
                case {'PM5','PM25'}
                    data.import.file = NMRfile;
                    [data,gui] = importDataIBAC(data,gui);
            end
            displayStatusText(gui,'Reading NMR Data ... done');
        else
            % import from mat-file
            displayStatusText(gui,'Importing NMR raw data from mat-file ...');
            data = loadGUIrawdata(data,NMRpath,NMRfile);
            displayStatusText(gui,'Importing NMR raw data from mat-file ... done');
        end
        
        % update the path info field with "NMRpath" ("NMRfile")
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
        enableGUIelements('NMR');
        
        % special treatment of LIAG projects
        switch label
            case {'LIAG from project','LIAG last project'}
                cpath = data.import.LIAG.calibrationpath;
                % check if this calibration file was already used
                isfile = dir(fullfile(cpath,'NUCLEUS_calibData.mat'));
                if ~isempty(isfile)
                    id = 2;
                    % if data is there reuse it
                    calib = load(fullfile(cpath,isfile.name),'calib');
                    INVdata{id} = calib.calib;
                    data.calib = INVdata{id}.calib;
                    data.import.LIAG.Tbulk = INVdata{id}.results.invstd.T2;
                    setappdata(fig,'INVdata',INVdata);
                    setappdata(fig,'data',data);
                    % color the list entry
                    strL = get(gui.listbox_handles.signal,'String');
                    str1 = strL{id};
                    str2 = ['<HTML><BODY bgcolor="rgb(',...
                        sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',...
                        str1,'</BODY></HTML>'];
                    strL{id} = str2;
                    set(gui.listbox_handles.signal,'String',strL);
                end
            otherwise
        end
        % update GUI interface
        NUCLEUSinv_updateInterface;
    end
    
catch ME
    % show error message in case import fails
    errmsg = {ME.message;[ME.stack(1).name,' Line: ',num2str(ME.stack(1).line)];...
        'Check File Format settings.'};
    errordlg(errmsg,'importNMRdata: Error!');
    
end

end

%%
function [NMRpath,NMRfile] = getNMRPathFile(label,import)

NMRpath = -1;
NMRfile = -1;
% for almost all import cases we load a folder ... but not for all
switch label
    case {'GGE ascii','GGE field','CoreLab ascii','MOUSE','LIAG single',...
            'BGR std','BGR org','BAM TOM','PM25'}
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            NMRpath = uigetdir(import.path,'Choose Data Path');
        else
            % otherwise we start at the current working dircetory
            % 'NMRpath' holds the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            NMRpath = uigetdir(pathstr,'Choose Data Path');
        end
    case 'LIAG from project'
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            NMRpath = uigetdir(import.path,'Choose Project Path');
        else
            % otherwise we start at the current working dircetory
            % 'NMRpath' holds the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            NMRpath = uigetdir(pathstr,'Choose Project Path');
        end
    case 'LIAG last project'
        % there is already a data folder and we use this one
        if isfield(import,'path')
            NMRpath = import.path;
        else
            % otherwise we start at the current working dircetory
            % 'NMRpath' holds the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            NMRpath = uigetdir(pathstr,'Choose Project Path');
        end
    case {'GGE Dart','BGR mat','NMR mat'}
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            [NMRfile,NMRpath] = uigetfile(import.path,'Choose Data file');
        else
            % otherwise we start at the current working dircetory
            % 'foldername' hold s the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            [NMRfile,NMRpath] = uigetfile(pathstr,'Choose Data file');
        end
    case 'PM5'
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            NMRpath = uigetdir(import.path,'Choose PM5 Data Path');
        else
            % otherwise we start at the current working dircetory
            % 'NMRpath' holds the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            NMRpath = uigetdir(pathstr,'Choose PM5 Data Path');
        end
        
        % check if there are multiple inf-files available
        % if yes -> choose one
        inffiles = dir(fullfile(NMRpath,'*.inf'));
        if numel(inffiles) > 1
            [NMRfile,NMRpath] = uigetfile(fullfile(NMRpath,'*.inf'),...
                'Choose INF file');
        elseif numel(inffiles) == 1
            NMRfile = inffiles.name;            
        end
end

end

%%
function [data,gui] = importDataBGR(data,gui)

% first check the subpaths
% there should be 'cpmgfastauto' and 't1test'
t1path = dir(fullfile(data.import.path,'t1test'));
t1path = t1path(~ismember({t1path.name},{'.','..'}));
t2path = dir(fullfile(data.import.path,'cpmgfastauto'));
t2path = t2path(~ismember({t2path.name},{'.','..'}));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(t1path)
    for i = 1:size(t1path,1)
        in.T1T2 = 'T1';
        in.path = fullfile(data.import.path,'t1test',t1path(i).name);
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);
        
        for j = 1:size(out.nmrData,2)
            % the individual file names
            c = c + 1;
            fnames(c).parfile = 'acq.par';
            fnames(c).datafile = out.nmrData{j}.datfile;
            
            shownames{c} = ['T1_',t1path(i).name,'_',fnames(c).datafile];
            
            % the NMR data
            % here we fix the time scale from [ms] to [s]
            if max(out.nmrData{j}.time) > 100
                out.nmrData{j}.time = out.nmrData{j}.time/1000;
                out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
            end
            data.import.NMR.data{c} = out.nmrData{j};
            data.import.NMR.para{c} = out.parData;
        end
    end
end

if ~isempty(t2path)
    for i = 1:size(t2path,1)
        in.T1T2 = 'T2';
        in.path = fullfile(data.import.path,'cpmgfastauto',t2path(i).name);
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);
        
        for j = 1:size(out.nmrData,2)
            % the individual file names
            c = c + 1;
            fnames(c).parfile = 'acq.par';
            fnames(c).datafile = out.nmrData{j}.datfile;
            fnames(c).T2specfile = '';
            
            shownames{c} = ['T2_',t2path(i).name,'_',fnames(c).datafile];
            
            % the NMR data
            % here we fix the time scale from [ms] to [s]
            if max(out.nmrData{j}.time) > 100
                out.nmrData{j}.time = out.nmrData{j}.time/1000;
                out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
            end
            data.import.NMR.data{c} = out.nmrData{j};
            data.import.NMR.para{c} = out.parData;
        end
    end
end

if isempty(t1path) && isempty(t2path)
    helpdlg('No data folders in the given directory.','onMenuImport: No data.');
else
    % update the global data structure
    data.import.NMR.files = fnames;
    data.import.NMR.filesShort = shownames;
end

end

%%
function [data,gui] = importDataBGRmat(data,gui)

in.path = fullfile(data.import.path);
in.name = data.import.file;
in.fileformat = data.import.fileformat;
out = LoadNMRData_driver(in);

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
table = {true,0,1,'D'};
for j = 1:size(out.nmrData,2)
    % the individual file names
    c = c + 1;
    fnames(c).parfile = '';
    fnames(c).datafile = data.import.file;
    fnames(c).T2specfile = '';
    
    shownames{c} = out.parData{j}.file;
    
    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData{j};
    
    if isfield(out,'pressData')
        % convert hPa to Pa
        table{c,1} = true;
        table{c,2} = out.pressData.p(j)*1e2;
        table{c,3} = out.pressData.S(j);
        table{c,4} = 'D';
    end
end

% global Tbulk
data.invstd.Tbulk = out.parData{1}.Tbulk;
% global porosity
data.import.BGR.porosity = out.parData{1}.porosity;

data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

% import pressure / saturation data
if isfield(out,'pressData')
    data.pressure.unit = 'kPa';
    data.pressure.unitfac = 1e-3;
    data.pressure.table = table;
end

end

%%
function [data,gui] = importDataDart(data,gui)

in.path = fullfile(data.import.path);
in.name = data.import.file;
in.fileformat = data.import.fileformat;
out = LoadNMRData_driver(in);

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
for j = 1:size(out.nmrData,2)
    % the individual file names
    c = c + 1;
    fnames(c).parfile = '';
    fnames(c).datafile = data.import.file;
    fnames(c).T2specfile = '';
    
    shownames{c} = ['depth_',sprintf('%04.3f',out.parData{j}.depth)];
    
    % the NMR data
    % here we fix the time scale from [ms] to [s]
    if max(out.nmrData{j}.time) > 100
        out.nmrData{j}.time = out.nmrData{j}.time/1000;
        out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
    end
    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData{j};
end

data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataGeneral(data,gui)

% look for all files ending with '.par'
% should exist for T1 and T2 measurements
filenames = dir(fullfile(data.import.path,'*.par'));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

% loop over all found files and import the data
c = 0;
in.path = data.import.path;
for i = 1:size(filenames,1)
    ind = strfind(filenames(i).name,'.');
    ind = max(ind);
    in.name = filenames(i).name(1:ind-1);
    in.fileformat = data.import.fileformat;
    out = LoadNMRData_driver(in);
    
    for j = 1:size(out.nmrData,2)
        % the individual file names
        c = c + 1;
        fnames(c).parfile = filenames(i).name;
        fnames(c).datafile = out.nmrData{j}.datfile;
        if strcmp(out.nmrData{j}.flag,'T2') && isfield(out.nmrData{j},'specfile')
            fnames(c).T2specfile = out.nmrData{j}.specfile;
        else
            fnames(c).T2specfile = '';
        end
        shownames{c} = fnames(c).datafile;
        
        % the NMR data
        % here we fix the time scale from [ms] to [s]
        if max(out.nmrData{j}.time) > 100
            out.nmrData{j}.time = out.nmrData{j}.time/1000;
            out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
        end
        data.import.NMR.data{c} = out.nmrData{j};
        data.import.NMR.para{c} = out.parData;
    end
end

switch data.import.fileformat
    case 'bamtom'
        nslices = out.parData.nSlices;
        ncsvfiles = numel(fnames);
        
        % check for background file ("Leermessung")
        has_bg = false;
        for i = 1:numel(fnames)
            if ~isempty(strfind(fnames(i).datafile,'000'))
                has_bg = true;
                index_bg = i;
                break;
            end
        end
        
        if has_bg
            % background data set
            bg = data.import.NMR.data{index_bg};
            
            % vector of indices of the files that get corrected
            ind_files = 1:1:ncsvfiles;
            ind_files(ind_files==index_bg) = [];
            
            for i = ind_files                
                % subtract the background signal
                s = data.import.NMR.data{i}.signal;
                s_bg = bg.signal;
                % if the background signal is longer than the signal cut it
                if numel(s_bg) > numel(s)
                    tmp_s = s_bg(1:numel(s));
                else % if not pad it with zeros
                    tmp_s = zeros(size(s));
                    tmp_s(1:numel(s_bg)) = s_bg;
                end
                s = complex(real(s)-real(tmp_s),imag(s)-imag(tmp_s));
                % update original data set
                data.import.NMR.data{i}.signal = s;                
            end
            
            % check if the number of slices is equal to the number of files
            % (excluding the background file)
            if nslices == numel(ind_files)
                % create z-vector
                p = out.parData;
                zslice = linspace(p.startPos,p.endPos,p.nSlices)';
                data.import.BAM.use_z = true;
                data.import.BAM.zslice = zslice;
                if numel(zslice) > 1
                    c = 0;
                    for i = ind_files
                        c = c + 1;
                        tmp = shownames{i};
                        shownames{i} = [tmp,' z:',sprintf('%5.4f',zslice(c))];
                    end
                end
            else
                data.import.BAM.use_z = false;
                data.import.BAM.zslice = 1:1:max([numel(ind_files) 1]);
            end
            
        else
            if nslices == ncsvfiles
                % create z-vector
                p = out.parData;
                zslice = linspace(p.startPos,p.endPos,p.nSlices)';
                data.import.BAM.use_z = true;
                data.import.BAM.zslice = zslice;
                if numel(zslice) > 1
                    for i = 1:numel(zslice)
                        tmp = shownames{i};
                        shownames{i} = [tmp,' z:',sprintf('%5.4f',zslice(i))];
                    end
                end
            else
                data.import.BAM.use_z = false;
                data.import.BAM.zslice = 1:1:ncsvfiles;
            end
        end    
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataLIAG(data,gui)

in.path = fullfile(data.import.path);
in.fileformat = data.import.fileformat;
out = LoadNMRData_driver(in);

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
for j = 1:size(out.nmrData,2)
    % the individual file names
    c = c + 1;
    fnames(c).parfile = 'acqu.par';
    fnames(c).datafile = out.nmrData{j}.datfile;
    fnames(c).T2specfile = '';
    
    shownames{c} = fnames(c).datafile;
    
    % the NMR data
    % here we fix the time scale to [s] if neccessary
    TE = out.parData.echoTime; % [탎]
    if out.nmrData{j}.time(1)== TE/1e3
        % change [ms] to [s]
        out.nmrData{j}.time = out.nmrData{j}.time/1e3;
        out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1e3;
    elseif out.nmrData{j}.time(1)== TE
        % change [탎] to [s] -> very unlikely
        out.nmrData{j}.time = out.nmrData{j}.time/1e6;
        out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1e6;
    end
    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData;
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataLIAGproject(data,gui)

% 1) show all folders and ask for sample
subdirs = dir(data.import.path);
% remove the dot-dirs
subdirs = subdirs(~ismember({subdirs.name},{'.','..'}));

fnames = {subdirs.name};
[indx,~] = listdlg('PromptString','Select Sample:',...
    'SelectionMode','single',...
    'ListString',fnames);

if ~isempty(indx)
    % 2) check corresponding SampleParameter.par file for reference and
    % calibration sample and other parameters
    datapath = fullfile(data.import.path,fnames{indx});
    % load SampleParameter file for sample
    [SampleParameter] = loadGUIParameters(datapath,'SampleParameters.par');
    if isfield(SampleParameter,'sampleVolume')
        dataVol = SampleParameter.sampleVolume;
    else
        dataVol = 1;
    end
    
    % 2a) background file #1
    backgroundFile1 = SampleParameter.backgroundFile;
    if isempty(backgroundFile1)
        bnames = {subdirs.name};
        bnames(indx) = [];
        [indb,~] = listdlg('PromptString','Select Background File:',...
            'SelectionMode','single',...
            'ListString',bnames);
        if ~isempty(indb)
            backgroundFile1 = bnames{indb};
        else
            backgroundFile1 = '';
        end
    end
    if ~isempty(backgroundFile1)
        ind = strfind(backgroundFile1,filesep);
        if ~isempty(ind)
            backgroundFile1 = backgroundFile1(ind(end)+1:end);
        end
        fileInList = ismember(fnames,{backgroundFile1});
        if any(fileInList)
            backgroundpath1 = fullfile(data.import.path,fnames{fileInList});
        end
    else
        backgroundpath1 = '';
        backgroundFile1 = '';
    end
    backVol = 1;
    
    % 2b) calibration file
    c = 0;
    if isfield(SampleParameter,'calibrationFile0')
        c = c + 1;
        calibrationFiles{c} = SampleParameter.calibrationFile0;
    end
    if isfield(SampleParameter,'calibrationFile1')
        c = c + 1;
        calibrationFiles{c} = SampleParameter.calibrationFile1;
    end
    if isfield(SampleParameter,'calibrationFile2')
        c = c + 1;
        calibrationFiles{c} = SampleParameter.calibrationFile2;
    end
    if isfield(SampleParameter,'calibrationFile3')
        c = c + 1;
        calibrationFiles{c} = SampleParameter.calibrationFile3;
    end
    
    % find the non-empty one
    ind = ismember(calibrationFiles,{''});
    % there are three possibilities: 0, 1 and more than 1 calib. files    
    calibrationFiles(ind) = [];
    if isempty(calibrationFiles)
        cnames = {subdirs.name};
        cnames(indx) = [];
        [indc,~] = listdlg('PromptString','Select Calibration File:',...
            'SelectionMode','single',...
            'ListString',cnames);
        if ~isempty(indc)
            calibrationFiles = cnames{indc};
        else
            calibrationFiles = '';
        end        
    else
        % if there are more than one let the user select the correct one
        if numel(calibrationFiles) > 1
            [ind,~] = listdlg('PromptString','Select Calibration File:',...
                'SelectionMode','single',...
                'ListString',calibrationFiles);
            calibrationFiles = calibrationFiles{ind};
        else
            calibrationFiles = calibrationFiles{1};
        end
    end
    if ~isempty(calibrationFiles)
        ind = strfind(calibrationFiles,filesep);
        if ~isempty(ind)
            calibrationFiles = calibrationFiles(ind(end)+1:end);
        end
        fileInList = ismember(fnames,{calibrationFiles});
        if any(fileInList)
            calibrationpath = fullfile(data.import.path,fnames{fileInList});
        end
    else
        calibrationpath = '';
        calibrationFiles = '';
    end
    
    if ~isempty(calibrationpath)
        [SampleParameterC] = loadGUIParameters(calibrationpath,'SampleParameters.par');
        if isfield(SampleParameterC,'sampleVolume')
            calibVol = SampleParameterC.sampleVolume;
        else
            calibVol = 1;
        end
        
        % 2a) background file #2
        backgroundFile2 = SampleParameterC.backgroundFile;
        if isempty(backgroundFile2)
            bnames = {subdirs.name};
            bnames(indx) = [];
            [indb,~] = listdlg('PromptString','Select Background File for Calibration:',...
                'SelectionMode','single',...
                'ListString',bnames);
            if ~isempty(indb)
                backgroundFile2 = bnames{indb};
            else
                backgroundFile2 = '';
            end  
        end
        if ~isempty(backgroundFile2)
            ind = strfind(backgroundFile2,filesep);
            if ~isempty(ind)
                backgroundFile2 = backgroundFile2(ind(end)+1:end);
            end
            fileInList = ismember(fnames,{backgroundFile2});
            if any(fileInList)
                backgroundpath2 = fullfile(data.import.path,fnames{fileInList});
            end
        else
            backgroundpath2 = '';
            backgroundFile2 = '';
        end
    else
        calibVol = 1;
        backgroundpath2 = '';
        backgroundFile2 = '';
    end
    
    % 3) now load the data
    workpaths = {datapath,calibrationpath,backgroundpath1,backgroundpath2};
    workfiles = {fnames{indx},[calibrationFiles,' - calibration'],...
        [backgroundFile1,' - backgroundS'],[backgroundFile2,' - backgroundC']};
    out = cell(size(workpaths));
    count = 0;
    keep = false(size(workpaths));
    for i = 1:numel(workpaths)
        if ~isempty(workpaths{i})
            workdirs = dir(workpaths{i});
            workdirs = workdirs(~ismember({workdirs.name},{'.','..'}));
            isT2 = ismember({workdirs.name},{'T2CPMG'});
            if any(isT2)
                keep(i) = true;
                count = count + 1;
                T2path = fullfile(workdirs(isT2).folder,workdirs(isT2).name);
                in.path = T2path;
                in.fileformat = data.import.fileformat;
                out{i} = LoadNMRData_driver(in);
            end
        end
    end    
    
    if isempty(backgroundpath1)
        ref1 = struct;
    else
        background1 = out{3};
        % get the background data 1
        ref1.t = background1.nmrData{1}.time;
        ref1.s = background1.nmrData{1}.signal;
        [ref1.s,~] = rotateT2phase(ref1.s);
    end
    
    if isempty(backgroundpath2)
        ref2 = struct;
    else
        background2 = out{4};
        % get the background data 2
        ref2.t = background2.nmrData{1}.time;
        ref2.s = background2.nmrData{1}.signal;
        [ref2.s,~] = rotateT2phase(ref2.s);
    end
    
    workpaths = workpaths(keep);
    workfiles = workfiles(keep);
    out = out(keep);
    
    ffnames = struct;
    % shownames is just a dummy to hold all data file names that
    % will be shown in the listbox
    shownames = cell(1,1);
    
    for i = 1:count
        ffnames(i).parfile = 'acqu.par';
        ffnames(i).datafile = workfiles{i};
        ffnames(i).T2specfile = '';
        
        shownames{i} = ffnames(i).datafile;
        
        % the NMR data
        % here we fix the time scale to [s] if neccessary
        TE = out{i}.parData.echoTime; % [탎]
        if out{i}.nmrData{1}.time(1)== TE/1e3
            % change [ms] to [s]
            out{i}.nmrData{1}.time = out{i}.nmrData{1}.time/1e3;
            out{i}.nmrData{1}.raw.time = out{i}.nmrData{1}.raw.time/1e3;
        elseif out{i}.nmrData{1}.time(1)== TE
            % change [탎] to [s] -> very unlikely
            out{i}.nmrData{1}.time = out{i}.nmrData{1}.time/1e6;
        out{i}.nmrData{1}.raw.time = out{i}.nmrData{1}.raw.time/1e6;
        end
        
        data.import.NMR.data{i} = out{i}.nmrData{1};
        data.import.NMR.para{i} = out{i}.parData;
        data.import.NMR.para{i}.SampleParameter = SampleParameter;
        
        % subtract the background signal
        s = data.import.NMR.data{i}.signal;
        if i==1 && isfield(ref1,'s')
            % if the background signal is longer than the signal cut it, if
            % not extend it with zeros
            if numel(ref1.s) > numel(s)
                tmp_r = ref1.s(1:numel(s));
            else
                tmp_r = zeros(size(s));
                tmp_r(1:numel(ref1.s)) = ref1.s;
            end
            s = complex(real(s)-real(tmp_r),imag(s)-imag(tmp_r));
        elseif i==2 && isfield(ref2,'s')
            % if the background signal is longer than the signal cut it, if
            % not extend it with zeros
            if numel(ref2.s) > numel(s)
                tmp_r = ref2.s(1:numel(s));
            else
                tmp_r = zeros(size(s));
                tmp_r(1:numel(ref2.s)) = ref2.s;
            end
            s = complex(real(s)-real(tmp_r),imag(s)-imag(tmp_r));
        end        
        data.import.NMR.data{i}.signal = s;
        data.import.NMR.data{i}.raw.signal = s;
        
        if ~isempty(strfind(workfiles{i},' - background'))
            data.import.LIAG.sampleVol(i) = backVol;
        elseif ~isempty(strfind(workfiles{i},' - calibration'))
            data.import.LIAG.sampleVol(i) = calibVol;
        elseif isempty(strfind(workfiles{i},' - background')) &&...
                isempty(strfind(workfiles{i},' - calibration'))
            data.import.LIAG.sampleVol(i) = dataVol;
        end
    end
    data.import.LIAG.Tbulk = 1e6;
    data.import.LIAG.workpaths = workpaths;
    data.import.LIAG.datapath = datapath;
    data.import.LIAG.calibrationpath = calibrationpath;
    data.import.LIAG.backgroundpath1 = backgroundpath1;
    data.import.LIAG.backgroundpath2 = backgroundpath2;
    
    % update the global data structure
    data.import.NMR.files = ffnames;
    data.import.NMR.filesShort = shownames;
    
end

end

%%
function [data,gui] = importDataMouse(data,gui)

in.path = fullfile(data.import.path);
in.fileformat = data.import.fileformat;
out = LoadNMRData_driver(in);

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
for j = 1:size(out.nmrData,2)
    % the individual file names
    c = c + 1;
    fnames(c).parfile = 'acq.par';
    fnames(c).datafile = out.nmrData{j}.datfile;
    fnames(c).T2specfile = '';
    
    shownames{c} = ['T2_',fnames(c).datafile];
    
    % the NMR data
    % here we fix the time scale from [ms] to [s]
    if max(out.nmrData{j}.time) > 100
        out.nmrData{j}.time = out.nmrData{j}.time/1000;
        out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
    end
    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData;
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataIBAC(data,gui)

in.path = fullfile(data.import.path);
in.name = data.import.file;
in.fileformat = data.import.fileformat;
out = LoadNMRData_driver(in);

nslices = out.parData.depths;
nfiles = size(out.nmrData,2);

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
for j = 1:size(out.nmrData,2)
    % the individual file names
    c = c + 1;
    fnames(c).parfile = out.parData.parfile;
    fnames(c).datafile = out.nmrData{j}.datfile;
    fnames(c).T2specfile = '';
    
    shownames{c} = [fnames(c).datafile];

    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData;
end

% check if the number of depth levels is equal to the number of
% measurements
if nslices == nfiles
    % create z-vector
    p = out.parData;
    zslice = linspace(p.initialdepth,p.finaldepth,p.depths)';
    data.import.IBAC.use_z = true;
    data.import.IBAC.zslice = zslice;
    if numel(zslice) > 1
        c = 0;
        for i = 1:nfiles
            c = c + 1;
            tmp = shownames{i};
            shownames{i} = [tmp,' z:',sprintf('%05d',zslice(c))];
        end
    end
else
    data.import.IBAC.use_z = false;
    data.import.IBAC.zslice = 1:1:max([nfiles 1]);
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function data = loadGUIParameters(datapath,fname)
fid = fopen(fullfile(datapath,fname));
d = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
data = struct;
for i = 1:size(d{1},1)
    str = char(d{1}(i));
    str = fixParameterString(str);
    eval(['data.',str,';']);
end

end

%%
function data = loadGUIrawdata(data,NMRpath,NMRfile)

load(fullfile(NMRpath,'NUCLEUSinv_raw.mat'),'savedata');

data.import.file = NMRfile;
data.import.path = NMRpath;
data.import.NMR = savedata;

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