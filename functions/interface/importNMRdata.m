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
%       importDataHelios
%       loadGUIParameters
%       loadGUIrawdata
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
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
    if strcmp(label,'Dart (jrd)')
        data.import.fileformat = 'dartjrd';
    elseif strcmp(label,'BAM TOM')
        data.import.fileformat = 'bamtom';
    elseif strcmp(label,'BGR mat')
        data.import.fileformat = 'bgrmat';
    elseif strcmp(label,'BGR std')
        data.import.fileformat = 'bgr';
    elseif strcmp(label,'CoreLab ascii')
        data.import.fileformat = 'corelab';
    elseif strcmp(label,'DART')
        data.import.fileformat = 'dart';
    elseif strcmp(label,'GGE ascii')
        data.import.fileformat = 'rwth';
    elseif strcmp(label,'GGE field')
        data.import.fileformat = 'field';
    elseif strcmp(label,'GGE Dart')
        data.import.fileformat = 'dart';
    elseif strcmp(label,'HeliosCPMG')
        data.import.fileformat = 'heliosCPMG';
    elseif strcmp(label,'HeliosSeries')
        data.import.fileformat = 'heliosSeries';
    elseif strcmp(label,'LIAG core')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'LIAG from project')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'LIAG last project')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'LIAG single')
        data.import.fileformat = 'liag';
    elseif strcmp(label,'MOUSE')
        data.import.fileformat = 'mouse';
    elseif strcmp(label,'MouseCPMG')
        data.import.fileformat = 'MouseCPMG';
    elseif strcmp(label,'MouseLift')
        data.import.fileformat = 'MouseLift';
    elseif strcmp(label,'MouseT1T2')
        data.import.fileformat = 'MouseT1T2';
    elseif strcmp(label,'MRSMatlab (FIT)')
        data.import.fileformat = 'mrsd';
    elseif strcmp(label,'PM5')
        data.import.fileformat = 'pm5';
    elseif strcmp(label,'PM25')
        data.import.fileformat = 'pm25';
    elseif strcmp(label,'RoCA T1T2')
        data.import.fileformat = 'rocaT1T2';
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

        % if there is no raw-file import from folder/file
        if isempty(isfile)
            % import data
            data.import.path = NMRpath;
            data.import.file = -1;
            displayStatusText(gui,'Reading NMR Data ...');
            % call the corresponding subroutines
            switch label
                case {'BAM TOM','BGR std','CoreLab ascii','GGE ascii',...
                        'GGE field'}
                    [data,gui] = importDataGeneral(data,gui);
                case 'GGE Dart'
                    data.import.file = NMRfile;
                    % the data in the example folder is an older type
                    if contains(NMRpath,'nucleus\example_data\dart')
                        data.import.version = 1;
                    else
                        data.import.version = 2;
                    end
                    [data,gui] = importDataDart(data,gui);
                case 'DART'
                    data.import.file = NMRfile;
                    data.import.version = 3;
                    [data,gui] = importDataDart(data,gui);
                case 'MOUSE'
                    [data,gui] = importDataMouse(data,gui);
                case 'LIAG single'
                    [data,gui] = importDataLIAG(data,gui);
                case 'LIAG core'
                    [data,gui] = importDataLIAGcore(data,gui);
                case {'LIAG from project','LIAG last project'}
                    [data,gui] = importDataLIAGproject(data,gui);
                    % make the Petro Panel visible as default
                    tmp_h = gui.myui.heights(2,:);
                    tmp_h(3) = gui.myui.heights(2,3);
                    % but the CPS panel stays minimized
                    tmp_h(5) = gui.myui.heights(1,3);
                    set(gui.panels.main,'Heights',tmp_h);
                    set(gui.panels.petro.main,'Minimized',false);
                case 'BGR mat'
                    data.import.file = NMRfile;
                    [data,gui] = importDataBGRmat(data,gui);
                case 'MouseCPMG'
                    [data,gui] = importDataMouseCPMG(data,gui);
                case 'MouseLift'
                    [data,gui] = importDataBGRlift(data,gui);
                case 'MouseT1T2'
                    [data,gui] = importDataBGRMouseT1T2(data,gui);
                case 'HeliosCPMG'
                    data.import.file = NMRfile;
                    [data,gui] = importDataHeliosCPMG(data,gui);
                case 'HeliosSeries'
                    data.import.file = NMRfile;
                    [data,gui] = importDataHeliosSeries(data,gui);
                case {'PM5','PM25'}
                    data.import.file = NMRfile;
                    [data,gui] = importDataIBAC(data,gui);
                case 'Dart (jrd)'
                    data.import.file = NMRfile;
                    [data,gui] = importDataDartSeries(data,gui);
                case 'RoCA T1T2'
                    data.import.file = NMRfile;
                    [data,gui] = importDataRoCAT1T2(data,gui);
                case 'MRSMatlab (FIT)'
                    data.import.file = NMRfile;
                    [data,gui] = importDataMRSMatlab(data,gui);
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
                    data.import.LIAG.Tbulk = data.calib.Tbulk;%INVdata{id}.results.invstd.T2;
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
        % if the 2D window is open, update it
        if ~isempty(findobj('Tag','2DINV'))
            % but only if there is 2D data loaded
            if isfield(data.import,'T1T2map')
                Inv2DView(gui.menu.extra_T1T2map);
            else
                helpdlg({'function: importNMRdata',...
                    'Careful: 2D GUI is open but 1D data set was imported'},...
                    'Import Notification');
            end
        end
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
    case {'BAM TOM','BGR std','CoreLab ascii','GGE ascii','GGE field',...
            'HeliosCPMG','HeliosSeries','LIAG core','LIAG single',...
            'MOUSE','MouseCPMG','MouseLift','MouseT1T2','PM25','Dart (jrd)',...
            'RoCA T1T2'}
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
    case {'GGE Dart','DART','BGR mat','NMR mat'}
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
    case 'MRSMatlab (FIT)'
        % if there is already a data folder present we start from here
        if isfield(import,'path')
            [NMRfile,NMRpath] = uigetfile('*.mrsd','Choose mrsd Data file',import.path);
        else
            % otherwise we start at the current working dircetory
            % 'foldername' hold s the name of the choosen data path
            here = mfilename('fullpath');
            [pathstr,~,~] = fileparts(here);
            [NMRfile,NMRpath] = uigetfile('*.mrsd','mrsd Choose Data file',pathstr);
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
function [data,gui] = importDataMouseCPMG(data,gui)

csv_t2path = dir(fullfile(data.import.path,'CPMG'));
csv_t2path = csv_t2path(~ismember({csv_t2path.name},{'.','..'}));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(csv_t2path)
    for i = 1:size(csv_t2path,1)
        in.T1T2 = 'T2';
        in.path = fullfile(data.import.path,'CPMG',csv_t2path(i).name);
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);

        for j = 1:size(out.nmrData,2)
            % the individual file names
            c = c + 1;
            fnames(c).parfile = 'acqu.par';
            fnames(c).datafile = out.nmrData{j}.datfile;
            fnames(c).T2specfile = '';

            shownames{c} = ['T2_',csv_t2path(i).name,'_',fnames(c).datafile];

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

if isempty(csv_t2path)
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
function [data,gui] = importDataBGRliftSingle(data,gui)

% first check whether T1 or T2 was measured...
% by analyzing the name of data folder
ind = find(data.import.path == filesep);
checkT1T2 = data.import.path(ind(end-1)+1:ind(end)-1);
if strcmp(checkT1T2,'t1test')
    in.T1T2 = 'T1';
elseif strcmp(checkT1T2,'T1auto')
    in.T1T2 = 'T1';
elseif strcmp(checkT1T2,'cpmgfastautotest')
    in.T1T2 = 'T2';
elseif strcmp(checkT1T2,'cpmgfastauto')
    in.T1T2 = 'T2';
else
    disp('Please chose an original Prospa folder for Mouse Lift data!');
end

% % there should be folders with integer values in their names
% t1t2path = data.import.path;

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(data.import.path)
    %    for i = 1:size(t1t2path,1)
    in.path = data.import.path;
    in.fileformat = data.import.fileformat;
    out = LoadNMRData_driver(in);

    for j = 1:size(out.nmrData,2)
        % the individual file names
        c = c + 1;
        fnames(c).parfile = 'acq.par';
        fnames(c).datafile = out.nmrData{j}.datfile;

        shownames{c} = [in.T1T2,'_',fnames(c).datafile];

        % the NMR data
        % here we fix the time scale from [ms] to [s]
        if max(out.nmrData{j}.time) > 100
            out.nmrData{j}.time = out.nmrData{j}.time/1000;
            out.nmrData{j}.raw.time = out.nmrData{j}.raw.time/1000;
        end
        data.import.NMR.data{c} = out.nmrData{j};
        data.import.NMR.para{c} = out.parData;
    end
else
    helpdlg('No data folders in the given directory.','onMenuImport: No data.');
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataBGRlift(data,gui)

% 1) show all folders and ask for sample
subdirs = dir(data.import.path);
% remove the dot-dirs
subdirs = subdirs(~ismember({subdirs.name},{'.','..'}));

fnames = {subdirs.name};
[indx,~] = listdlg('PromptString','Choose data set:',...
    'SelectionMode','multiple',...
    'ListString',fnames);

% first check whether T1 or T2 was measured
ind = find(data.import.path == filesep);
checkT1T2 = data.import.path(ind(end)+1:end);
if strcmp(checkT1T2,'t1test')
    in.T1T2 = 'T1';
elseif strcmp(checkT1T2,'T1auto')
    in.T1T2 = 'T1';
elseif strcmp(checkT1T2,'cpmgfastautotest')
    in.T1T2 = 'T2';
elseif strcmp(checkT1T2,'cpmgfastauto')
    in.T1T2 = 'T2';
else
    helpdlg('No original data folder','onMenuImport: No data.');
end

% now ask for stacking
answer = questdlg('Do you want to stack the slices?');
switch answer
    case 'Yes'
        doSliceStack = true;
        % if stacking ask for stack-rotate-order
        answer = questdlg('Select stack-rotate-order:',...
            'Select order', ...
            'stack-rotate (default)','rotate-stack','Cancel','stack-rotate (default)');
        switch answer
            case 'stack-rotate'
                StackFirst = true;
            case 'rotate-stack'
                StackFirst = false;
            otherwise
                StackFirst = true;
        end
    otherwise
        doSliceStack = false;
end

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(indx)
    for i = indx
        in.path = fullfile(data.import.path,subdirs(i).name);
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);

        if doSliceStack
            % the individual file names
            c = c + 1;
            fnames(c).parfile = 'acq.par';
            fnames(c).datafile = out.nmrData{1}.datfile;

            shownames{c} = [in.T1T2,'_',subdirs(i).name];

            % use the meta data from the first slice
            % fix the time scale from [ms] to [s]
            if max(out.nmrData{1}.time) > 100
                out.nmrData{1}.time = out.nmrData{1}.time/1000;
                out.nmrData{1}.raw.time = out.nmrData{1}.raw.time/1000;
            end
            % import into GUI data struct
            data.import.NMR.data{c} = out.nmrData{1};

            % stacking
            for j = 1:size(out.nmrData,2)
                if j == 1
                    signal = out.nmrData{j}.signal;
                else
                    signal = signal + out.nmrData{j}.signal;
                end
            end
            signal = signal./size(out.nmrData,2);

            % now rotate after the stacking
            if StackFirst
                [signal,phase] = rotateT2phase(signal);
                data.import.NMR.data{c}.phase = phase;
                data.import.NMR.data{c}.signal = signal;
                data.import.NMR.data{c}.raw.signal = signal;
            else
                % no rotation after stacking
                data.import.NMR.data{c}.signal = signal;
                data.import.NMR.data{c}.raw.signal = signal;
            end

            % parameter data
            data.import.NMR.para{c} = out.parData;
        else

            for j = 1:size(out.nmrData,2)
                % the individual file names
                c = c + 1;
                fnames(c).parfile = 'acq.par';
                fnames(c).datafile = out.nmrData{j}.datfile;

                shownames{c} = [in.T1T2,'_',subdirs(i).name,'_',fnames(c).datafile];

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
else
    helpdlg('No data folders in the given directory.','onMenuImport: No data.');
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataBGRMouseT1T2(data,gui)

% first ask the user if it is a series of T1 measurements or one T1T2map
answer = questdlg('Is this a series of T1 measurements or one T1-T2 map?', ...
    'Mouse T1T2 import','T1 series','T1-T2 map','T1-T2 map');
switch answer
    case 'T1 series'
        is_T1 = true;
    case 'T1-T2 map'
        is_T1 = false;
    otherwise
        is_T1 = false;
end

% there should be some folders with names ...
% ... similar to the data filenames inside them
datpath = dir(data.import.path);
datpath = datpath(~ismember({datpath.name},{'.','..'}));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

% ask the user for the amount of T2 echoes to sum for the T1 curve
prompt = {'Enter T2 #echos for one T1 point'};
dlgtitle = 'How many T2 echos';
fieldsize = [1 45];
if is_T1
    definput = {'30'};
else
    definput = {'3'};
end
answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
Nechos = str2double(answer{1});

if is_T1
    % load a series of T1-T2 data and extract only the T1 curves
    c = 0;
    if ~isempty(datpath)
        content = datpath;
        for j = 1:size(content,1)
            in.T1T2 = 'T2';
            in.name = 'data2D.dat';
            in.path = fullfile(data.import.path,content(j).name);
            in.fileformat = data.import.fileformat;
            in.importflag = 'T1';
            in.Nechos = Nechos;
            out = LoadNMRData_driver(in);

            for j1 = 1:numel(out.nmrData)
                % the individual file names
                c = c + 1;
                fnames(c).parfile = 'acqu.par';
                fnames(c).datafile = out.nmrData{j1}.datfile;
                fnames(c).T2specfile = '';

                shownames{c} = ['T1_',content(j).name];

                data.import.NMR.data{c} = out.nmrData{j1};
                data.import.NMR.para{c} = out.parData;
            end

        end
    end
else
    % load a single T1-T2 data set
    c = 0;
    if ~isempty(datpath)
        content = datpath;
        for j = 1:size(content,1)
            if strcmp(content(j).name,'data2D.dat')
                in.T1T2 = 'T2';
                in.name = content(j).name;
                in.path = fullfile(data.import.path);
                in.fileformat = data.import.fileformat;
                in.importflag = 'T1T2map';
                out = LoadNMRData_driver(in);

                for j1 = 1:numel(out.nmrData)
                    % the individual file names
                    c = c + 1;
                    fnames(c).parfile = 'acqu.par';
                    fnames(c).datafile = out.nmrData{j1}.datfile;
                    fnames(c).T2specfile = '';

                    shownames{c} = ['T2_',content(j).name,'_',sprintf('%03d',j1)];

                    data.import.NMR.data{c} = out.nmrData{j1};
                    data.import.NMR.para{c} = out.parData;
                end
            end
        end

        % save the recovery time vector for later use
        t_recov = out.parData.T1Axis;
        t2 = out.parData.T2Axis;
        t2N = numel(t2);
        data.import.T1T2map.t_recov = t_recov(:);
        data.import.T1T2map.t1N = numel(t_recov);
        data.import.T1T2map.t2 = t2;
        data.import.T1T2map.t2N = t2N;

        % add the stacked signal to the data
        flag = 'T1';
        time = data.import.T1T2map.t_recov;
        signal = zeros(numel(data.import.NMR.data),1);
        for i1 = 1:numel(data.import.NMR.data)
            signal(i1) = mean(real(data.import.NMR.data{i1}.signal(1:Nechos)));
        end

        disp('NUCLUESinv import: Estimating noise from exponential fit ...');
        param.T1IRfac = 1;
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

        data.import.NMR.data{c+1} = data_new{1};
        data.import.NMR.para{c+1} = para_new{1};
        fnames(c+1).datafile = 'T1_merged.dat';
        shownames{c+1} = 'T1_merged';
        % set global echo time
        data.inv2D.prop.te = data.import.NMR.para{1}.echoTime/1e6; % [s]
        % set T1 SR/IR factor
        data.inv2D.inv.T1IRfac = 1; % PM25 Mouse does SR
    end

end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;
end

%%
function [data,gui] = importDataHeliosCPMG(data,gui)

% first check the subpaths
% there should be some folders with names ...
% ... similar to the data filenames inside them
datpath = dir(data.import.path);
datpath = datpath(~ismember({datpath.name},{'.','..'}));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(datpath)
    for i = 1:size(datpath,1)
        % does datpath.name points to a folder?
        if datpath(i).isdir
            % check if datpath.name includes regular Helios data files
            content = dir([data.import.path,filesep,datpath(i).name]);
            content = content(~ismember({content.name},{'.','..'}));
            % only keep hrd-files
            content = content(contains({content.name},'.hrd'));
            % remove reference hrd-files
            content = content(~contains({content.name},'_ref.hrd'));
            for j = 1:size(content,1)
                in.T1T2 = 'T2';
                in.name = content(j).name;
                in.path = fullfile(data.import.path,filesep,datpath(i).name);
                in.fileformat = data.import.fileformat;
                out = LoadNMRData_driver(in);

                % the individual file names
                c = c + 1;
                fnames(c).parfile = '';
                fnames(c).datafile = out.nmrData.datfile;
                fnames(c).T2specfile = '';
                shownames{c} = ['T2_',datpath(i).name];

                data.import.NMR.data{c} = out.nmrData;
                data.import.NMR.para{c} = out.parData;
            end
        end
    end
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataHeliosSeries(data,gui)

% first ask the user if it is pure T2 data or T2 data belonging to a T1
% measurement to generate T1-T2 maps
answer = questdlg('Is this series a T1 measurement or pure T2?', ...
    'HELIOS import', ...
    'T1','T2','T2');
switch answer
    case 'T1'
        is_T1 = true;
    case 'T2'
        is_T1 = false;
    otherwise
        is_T1 = false;
end

% now ask for manualS stacking (only for T2 data)
if ~is_T1
    answer = questdlg('Do you want to stack several files?','Stack Dialog','No');
    switch answer
        case 'Yes'
            doStack = true;
            prompt = {'Enter No. of files to stack together'};
            dlgtitle = 'Stack Value';
            fieldsize = [1 40];
            definput = {'16'};
            answer2 = inputdlg(prompt,dlgtitle,fieldsize,definput);
            if ~isempty(answer2)
                nstacks = str2double(answer2{1,1});
            else
                doStack = false;
            end
        otherwise
            doStack = false;
    end
end

% now check the subpaths
% there should be some folders with names ...
% ... similar to the data filenames inside them
datpath = dir(data.import.path);
datpath = datpath(~ismember({datpath.name},{'.','..'}));
% remove any subfolder within the data directory
datpath = datpath(~ismember([datpath.isdir],true));
% only keep hrd-files
datpath = datpath(contains({datpath.name},'.hrd'));
% remove reference hrd-files
datpath = datpath(~contains({datpath.name},'_ref.hrd'));
% remove duplicate hrd-files
datpath = datpath(~contains({datpath.name},'.dup'));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(datpath)
    content = datpath;
    if is_T1
        t_recov = zeros(floor(numel(content)/2),2);
    end
    for j = 1:size(content,1)
        in.T1T2 = 'T2';
        in.name = content(j).name;
        in.path = fullfile(data.import.path);
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);
        % the individual file names
        c = c + 1;
        fnames(c).parfile = '';
        fnames(c).datafile = out.nmrData.datfile;
        fnames(c).T2specfile = '';
        if is_T1
            shownames{c} = content(j).name;
        else
            shownames{c} = ['T2_',content(j).name];
        end

        data.import.NMR.data{c} = out.nmrData;
        data.import.NMR.para{c} = out.parData;

        % collect recovery times in case of T1 data set
        if is_T1
            t_recov(c,1) = out.parData.t_recov;
            t_recov(c,2) = out.nmrData.phase;
        end
    end

    % in case of T1 data, use the phase of the signal with the longest
    % recovery time to rotate the other signals
    if is_T1
        phase = t_recov(t_recov(:,1)==max(t_recov(:,1)),2);
        for i1 = 1:numel(data.import.NMR.data)
            % the original raw data
            s = data.import.NMR.data{i1}.raw.signal;
            s =  s * exp(1i*(-data.import.NMR.data{i1}.phase));
            % s_rot is the rotated signal
            s_rot = s .* exp(1i*phase);
            % write the rotated signal back to the data struct
            data.import.NMR.data{i1}.signal = s_rot;
            data.import.NMR.data{i1}.phase = phase;

            % get the shortest T2 signal length
            if i1 == 1
                t2N = numel(data.import.NMR.data{i1}.raw.time);
            else
                t2N = min([t2N numel(data.import.NMR.data{i1}.raw.time)]);
            end
            t2 = data.import.NMR.data{i1}.raw.time(1:t2N);
        end

        % for convenience, sort the data by recovery time
        [t_s,ix] = sort(t_recov(:,1));
        data.import.NMR.data = data.import.NMR.data(ix);
        data.import.NMR.para = data.import.NMR.para(ix);
        fnames = fnames(ix);
        shownames = shownames(ix);

        % save the recovery time vector for later use
        data.import.T1T2map.t_recov = t_s(:,1)/1000;
        data.import.T1T2map.t1N = numel(data.import.T1T2map.t_recov);
        data.import.T1T2map.t2 = t2;
        data.import.T1T2map.t2N = t2N;

        % ask if the single measurements should be "stacked" to one T1
        % curve
        answer = questdlg('Do you want a single T1 curve or a T1-T2 map?', ...
            'HELIOS import', ...
            'single T1','T1-T2 map','T1-T2 map');
        switch answer
            case 'single T1'
                singleT1 = true;
            case 'T1-T2 map'
                singleT1 = false;
        end

        if singleT1
            % ask how many T2-echos should be stacked together to one T1
            % point
            prompt = {'Enter T2 #echos for one T1 point'};
            dlgtitle = 'How many T2 echos';
            fieldsize = [1 45];
            definput = {'3'};
            answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
            Nechos = str2double(answer{1});

            flag = 'T1';
            time = data.import.T1T2map.t_recov;
            signal = zeros(numel(data.import.NMR.data),1);
            for i1 = 1:numel(data.import.NMR.data)
                signal(i1) = mean(real(data.import.NMR.data{i1}.signal(1:Nechos)));
            end

            disp('NUCLUESinv import: Estimating noise from exponential fit ...');
            param.T1IRfac = 2;
            param.noise = 0;
            param.optim = data.info.has_optim;
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
            % remove the 2D data
            data.import = rmfield(data.import,'T1T2map');

            data_new{1}.flag = flag;
            data_new{1}.T1IRfac = param.T1IRfac;
            data_new{1}.time = time;
            data_new{1}.signal = signal;
            data_new{1}.noise = noise;
            data_new{1}.raw.time = time;
            data_new{1}.raw.signal = signal;

            % use the last sub folder as name
            pn = regexp(datpath(1).folder, filesep, 'split');

            fnames = fnames(1);
            shownames = shownames(1);
            shownames{1} = [pn{end},'_T1_merged'];

            data.import.NMR.data = data_new;
            data.import.NMR.para = para_new;
        else
            prompt = {'Enter T2 #echos for one T1 point for the merged T1 curve'};
            dlgtitle = 'How many T2 echos';
            fieldsize = [1 45];
            definput = {'3'};
            answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
            Nechos = str2double(answer{1});

            % add the stacked signal to the data
            flag = 'T1';
            time = data.import.T1T2map.t_recov;
            signal = zeros(numel(data.import.NMR.data),1);
            for i1 = 1:numel(data.import.NMR.data)
                signal(i1) = mean(real(data.import.NMR.data{i1}.signal(1:Nechos)));
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

            data.import.NMR.data{numel(t_s)+1} = data_new{1};
            data.import.NMR.para{numel(t_s)+1} = para_new{1};
            fnames(numel(t_s)+1).datafile = 'T1_merged.dat';
            shownames{numel(t_s)+1} = 'T1_merged';
            % set global echo time
            data.inv2D.prop.te = data.import.NMR.para{1}.t_echo;
            % set T1 SR/IR factor
            data.inv2D.inv.T1IRfac = 2; % Helios default
        end
    else % pure T2 data
        % do restacking if desired
        if doStack
            % before stacking, sort the data by date (time)
            N = length(shownames);
            time = zeros(N,1);
            for i = 1:N
                time(i,1) = data.import.NMR.data{i}.datenum;
            end
            [~,ix] = sort(time);
            % now apply changes - resort the imported data
            data.import.NMR.data = {data.import.NMR.data{ix'}}; %#ok<*CCAT1>
            data.import.NMR.para = {data.import.NMR.para{ix'}};
            fnames = fnames(ix);
            shownames = {shownames{ix'}};

            c = 0;
            % prepare data variables
            datanew = cell(1,1);
            paranew = cell(1,1);
            fnamesnew = fnames(1);
            shownamesnew = cell(1,1);
            tmp_signal = zeros(size(data.import.NMR.data{1}.signal));
            % loop over all already imported files
            for i1 = 1:numel(fnames)
                % stack up files
                tmp_signal = tmp_signal + data.import.NMR.data{i1}.signal;
                % check if stack count is reached
                if mod(i1,nstacks)==0
                    % current stack has finished
                    c = c + 1;
                    % save data
                    datanew{c} = data.import.NMR.data{i1};
                    datanew{c}.signal = tmp_signal./nstacks;
                    datanew{c}.raw.signal = tmp_signal./nstacks;

                    paranew{c} = data.import.NMR.para{i1};
                    paranew{c}.Nscans = paranew{c}.Nscans*nstacks;
                    paranew{c}.all{1,1}{6} = ['Nscans = ',num2str(paranew{c}.Nscans)];

                    fnamesnew(c) = fnames(i1);
                    shownamesnew{c} = [shownames{i1},'_',num2str(nstacks)];

                    % reset the tmp_signal to zero
                    tmp_signal = zeros(size(data.import.NMR.data{1}.signal));
                end
            end
            data.import.NMR.data = datanew;
            data.import.NMR.para = paranew;

            fnames = fnamesnew;
            shownames = shownamesnew;
        end
    end
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataDartSeries(data,gui)

% first ask the user if it is pure T2 data or T2 data belonging to a T1
% measurement to generate a T1 signal or a T1-T2 map
answer = questdlg('What kind of data you want to import?', ...
    'DART import', ...
    'single T1','T1-T2 map','T2 (log)','T2 (log)');
switch answer
    case 'single T1'
        is_T1 = true;
        singleT1 = true;
    case 'T1-T2 map'
        is_T1 = true;
        singleT1 = false;
    otherwise
        is_T1 = false;
        singleT1 = false;
end

% now check the subpaths
% there should be some folders with names ...
% ... similar to the data filenames inside them
datpath = dir(data.import.path);
datpath = datpath(~ismember({datpath.name},{'.','..'}));
% remove any subfolder within the data directory
datpath = datpath(~ismember([datpath.isdir],true));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

useburst = 0;
stackfreq = 1;
c = 0;
if ~isempty(datpath)
    content = datpath;
    if is_T1
        t_recov = zeros(1,2);
    else
        depth = zeros(1,1);
    end
    for j = 1:size(content,1)
        if strcmp(content(j).name(end-3:end),'.jrd')
            c = c + 1;

            in.T1T2 = 'T2';
            in.name = content(j).name;
            in.path = fullfile(data.import.path);
            in.fileformat = data.import.fileformat;
            in.version = 4;
            out = LoadNMRData_driver(in);
            
            % ask for burst usage and frequency stacking
            if c == 1 & out.hasburst == 1
                answer = questdlg('Do you want to use the burst?', ...
                'DART import', ...
                'Yes','No','Yes');
                switch answer
                    case 'Yes'
                        useburst = 1;
                    otherwise
                        useburst = 0;
                end
            end
            if c == 1 & out.Nfreq > 1
                answer = questdlg('Do you want to stack frequencies?', ...
                'DART import', ...
                'F1 only','F2 only','F1+F2','F1+F2');
                switch answer
                    case 'F1 only'
                        stackfreq = 1;
                    case 'F2 only'
                        stackfreq = 2;
                    case 'F1+F2'
                        stackfreq = 3;
                end
            end

            if useburst
                for i1 = 1:numel(out.nmrData)/2
                    sig = real(out.nmrData{i1}.signal);
                    burst = real(out.nmrData{i1+out.Nfreq}.signal);
                    
                    burst_echoes = out.parData{i1+out.Nfreq}.n_echo;
                    ms = mean(sig(2:burst_echoes));
                    mb = mean(burst(2:burst_echoes));

                    burst_shift = complex(burst+(ms-mb),imag(out.nmrData{i1+out.Nfreq}.signal));
                    out.nmrData{i1}.signal(1:burst_echoes) = burst_shift;
                    out.nmrData{i1}.raw.signal = out.nmrData{i1}.signal;
                end
            end

            if stackfreq == 1
                fnames(c).parfile = '';
                fnames(c).datafile = out.nmrData{1}.datfile;
                fnames(c).T2specfile = '';
                shownames{c} = content(j).name;
                data.import.NMR.data{c} = out.nmrData{1};
                data.import.NMR.para{c} = out.parData{1};

            elseif stackfreq == 2
                fnames(c).parfile = '';
                fnames(c).datafile = out.nmrData{2}.datfile;
                fnames(c).T2specfile = '';
                shownames{c} = content(j).name;
                data.import.NMR.data{c} = out.nmrData{2};
                data.import.NMR.para{c} = out.parData{2};

            elseif stackfreq == 3
                fnames(c).parfile = '';
                fnames(c).datafile = out.nmrData{1}.datfile;
                fnames(c).T2specfile = '';
                shownames{c} = content(j).name;

                tmp1 = out.nmrData{1};
                tmp2 = out.nmrData{2};
                signal = (tmp1.signal + tmp2.signal)./2;
                
                out.nmrData{1}.signal = signal;
                out.nmrData{1}.raw.signal = signal;
                data.import.NMR.data{c} = out.nmrData{1};
                data.import.NMR.para{c} = out.parData{1};
            end            

            % collect recovery times in case of T1 data set
            if is_T1
                t_recov(c,1) = out.parData{1}.t_recov;
                t_recov(c,2) = out.nmrData{1}.phase;
            else
                % try to collect depth values
                depth(c,1) = data.import.NMR.para{c}.depth;
            end
        end
    end

    % in case if T1 data, use the phase of the signal with the longest
    % recovery time to rotate the other signals
    if is_T1
        phase = t_recov(t_recov(:,1)==max(t_recov(:,1)),2);
        for i1 = 1:numel(data.import.NMR.data)
            % the original raw data
            s = data.import.NMR.data{i1}.raw.signal;
            % s_rot is the rotated signal
            s_rot = s .* exp(1i*phase);
            % write the rotated signal back to the data struct
            data.import.NMR.data{i1}.signal = s_rot;
            data.import.NMR.data{i1}.phase = phase;

            % get the shortest T2 signal length
            if i1 == 1
                t2N = numel(data.import.NMR.data{i1}.raw.time);
            else
                t2N = min([t2N numel(data.import.NMR.data{i1}.raw.time)]);
            end
            t2 = data.import.NMR.data{i1}.raw.time(1:t2N);
        end

        % for convenience, sort the data by recovery time
        [t_s,ix] = sort(t_recov(:,1));
        data.import.NMR.data = data.import.NMR.data(ix);
        data.import.NMR.para = data.import.NMR.para(ix);
        fnames = fnames(ix);
        shownames = shownames(ix);

        % save the recovery time vector for later use
        data.import.T1T2map.t_recov = t_s(:,1)/1000;
        data.import.T1T2map.t1N = numel(data.import.T1T2map.t_recov);
        data.import.T1T2map.t2 = t2;
        data.import.T1T2map.t2N = t2N;

        % ask how many T2-echos should be stacked together to one T1
        % point
        prompt = {'Enter T2 #echos for one T1 point for the merged T1 curve'};
        dlgtitle = 'How many T2 echos';
        fieldsize = [1 45];
        definput = {'3'};
        answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
        Nechos = str2double(answer{1});

        flag = 'T1';
        time = data.import.T1T2map.t_recov;
        signal = zeros(numel(data.import.NMR.data),1);
        for i1 = 1:numel(data.import.NMR.data)
            signal(i1) = mean(real(data.import.NMR.data{i1}.signal(1:Nechos)));
        end

        disp('NUCLUESinv import: Estimating noise from exponential fit ...');
        param.T1IRfac = 1;
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

        if singleT1
            % finally create a new "import" data set
            data_new = data.import.NMR.data(1);
            para_new = data.import.NMR.para(1);
            data.import = rmfield(data.import,'T1T2map');

            data_new{1}.flag = flag;
            data_new{1}.T1IRfac = param.T1IRfac;
            data_new{1}.time = time;
            data_new{1}.signal = signal;
            data_new{1}.noise = noise;
            data_new{1}.raw.time = time;
            data_new{1}.raw.signal = signal;

            fnames = fnames(1);
            shownames = {'T1_merged'};

            data.import.NMR.data = data_new;
            data.import.NMR.para = para_new;
        else
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

            data.import.NMR.data{numel(t_s)+1} = data_new{1};
            data.import.NMR.para{numel(t_s)+1} = para_new{1};
            fnames(numel(t_s)+1).datafile = 'T1_merged.dat';
            shownames{numel(t_s)+1} = 'T1_merged';
            % set global echo time
            data.inv2D.prop.te = data.import.NMR.para{1}.t_echo;
            % set T1 SR/IR factor
            data.inv2D.inv.T1IRfac = 1; % Dart default
        end
    else
        % T2 data
        data.import.BAM.use_z = true;
        data.import.BAM.z_unit = 'm';
        data.import.BAM.zslice = depth - data.import.NMR.para{1}.stick_up_height;
        for i1 = 1:numel(shownames)
            tmp = shownames{i1};
            shownames{i1} = ['z:',sprintf('%05.2f',depth(i1)),'m ',tmp];
        end
    end
end

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataDart(data,gui)

in.path = fullfile(data.import.path);
in.name = data.import.file;
in.fileformat = data.import.fileformat;
in.version = data.import.version;
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

% update the global data structure
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

end

%%
function [data,gui] = importDataRoCAT1T2(data,gui)

% there should be some folders with names ...
% ... similar to the data filenames inside them
datpath = dir(data.import.path);
datpath = datpath(~ismember({datpath.name},{'.','..'}));
% remove any subfolder within the data directory
datpath = datpath(~ismember([datpath.isdir],true));

fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);

c = 0;
if ~isempty(datpath)
    content = datpath;
    for j = 1:size(content,1)
        if strcmp(content(j).name,'data2.csv')
            in.T1T2 = 'T2';
            in.name = content(j).name;
            in.path = fullfile(data.import.path);
            in.fileformat = data.import.fileformat;
            out = LoadNMRData_driver(in);

            for j1 = 1:numel(out.nmrData)
                % the individual file names
                c = c + 1;
                fnames(c).parfile = 'acqu.par';
                fnames(c).datafile = out.nmrData{j1}.datfile;
                fnames(c).T2specfile = '';

                shownames{c} = ['T2_',content(j).name,'_',sprintf('%03d',j1)];

                data.import.NMR.data{c} = out.nmrData{j1};
                data.import.NMR.para{c} = out.parData;
            end
        end
    end

    % save the recovery time vector for later use
    t2 = data.import.NMR.data{1}.time;
    t2N = numel(t2);
    t_recov = logspace(log10(out.parData.minTau),log10(out.parData.maxTau),out.parData.tauSteps);
    data.import.T1T2map.t_recov = t_recov(:)./1e3; % to [s]
    data.import.T1T2map.t1N = numel(data.import.T1T2map.t_recov);
    data.import.T1T2map.t2 = t2;
    data.import.T1T2map.t2N = t2N;

    % add the stacked signal to the data
    Nechos = 1;
    flag = 'T1';
    time = data.import.T1T2map.t_recov;
    signal = zeros(numel(data.import.NMR.data),1);
    for i1 = 1:numel(data.import.NMR.data)
        signal(i1) = mean(real(data.import.NMR.data{i1}.signal(1:Nechos)));
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

    data.import.NMR.data{c+1} = data_new{1};
    data.import.NMR.para{c+1} = para_new{1};
    fnames(c+1).datafile = 'T1_merged.dat';
    shownames{c+1} = 'T1_merged';
    % set global echo time
    data.inv2D.prop.te = data.import.NMR.para{1}.echoTime/1e6; % [s]
    % set T1 SR/IR factor
    data.inv2D.inv.T1IRfac = 2; % Rock Core Analyzer default(?)
end

% update the global data structure
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
        data.import.BAM.z_unit = '탆';
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
function [data,gui] = importDataLIAGcore(data,gui)

% get all subfolders containing a measurement at a certain heigth
subdirs = dir(data.import.path);
% remove the dot-dirs
subdirs = subdirs(~ismember({subdirs.name},{'.','..'}));

% now get the background data ("Leermessung")
bgPath = uigetdir(data.import.path,'Choose Background Data Path');
isbgPath = false;
if bgPath == 0
    disp('NUCLEUSinv: LIAG core import: No background file provided.');
else
    isbgPath = true;
    in.path = fullfile(bgPath);
    in.fileformat = data.import.fileformat;
    bgout = LoadNMRData_driver(in);
    ref1.t = bgout.nmrData{1}.time;
    ref1.s = bgout.nmrData{1}.signal;
    [ref1.s,~] = rotateT2phase(ref1.s);
end

% get the Position file
[posFile,posFilePath] = uigetfile('*.*','Choose Lift Position File',data.import.path);
isposFile = false;
if posFilePath == 0
    disp('NUCLEUSinv: LIAG core import: No position file provided.');
else
    isposFile = true;
    % import LIAG lift file
    buffer = fileread(fullfile(posFilePath,posFile));

    % get the time stamps of the lift positions
    substr = 'Zeit:' ;
    loc = strfind(buffer, substr);
    timepoint = cell(1,1);
    for i = 1:length(loc)
        timestr = strtrim(buffer(loc(i)+numel(substr):loc(i)+numel(substr)+19));
        timepoint{i} = datetime(timestr,'InputFormat','dd.MM.yyyy HH:mm:ss');
    end
    % ignore the first time stamp
    t_range = [datenum(timepoint{2}), datenum(timepoint{3})];
    % get the z coords
    substr = 'Z1=';
    loc = strfind(buffer, substr) ;
    z_range(1) = sscanf(buffer(loc+numel(substr):loc+numel(substr)+10),'%f',1);
    substr = 'Z2=';
    loc = strfind(buffer, substr) ;
    z_range(2) =  sscanf(buffer(loc+numel(substr):loc+numel(substr)+10),'%f',1);
end

% import the NMR data
count = 0;
levels = zeros(size(subdirs));
nmrDataTMP = cell(1,1);
for i = 1:numel(subdirs)
    if ~isnan(str2double(subdirs(i).name))

        % import the NMR file
        in.path = fullfile(data.import.path,subdirs(i).name,'T2CPMG');
        in.fileformat = data.import.fileformat;
        out = LoadNMRData_driver(in);

        % if there is a position file
        if isposFile
            % keep only files within the correct time range
            if out.nmrData{1}.datenum > t_range(1) && out.nmrData{1}.datenum < t_range(2)
                count = count + 1;
                % interpolate the z position via the time stamp of the NMR file
                levels(count) = interp1(t_range,z_range,out.nmrData{1}.datenum,'linear');
                nmrDataTMP{count} = out;
            end
        else % just read everything
            count = count + 1;
            levels(count) = str2double(subdirs(i).name);
            nmrDataTMP{count} = out;
        end
    end
end
% cut off data that is not part of the scan
levels = levels(1:count);
% sort in ascending order
[levels,idx] = sort(levels);

% sort the NMR data accordingly
fnames = struct;
% shownames is just a dummy to hold all data file names that
% will be shown in the listbox
shownames = cell(1,1);
for c = 1:numel(levels)
    % the individual file names
    fnames(c).parfile = 'acqu.par';
    fnames(c).datafile = nmrDataTMP{idx(c)}.nmrData{1}.datfile;
    fnames(c).T2specfile = '';

    shownames{c} = fnames(c).datafile;
    tmp = shownames{c};
    if isposFile
        shownames{c} = [tmp,': ',sprintf('%4d',floor(levels(c))),'mm'];
    else
        shownames{c} = [tmp,' level:',sprintf('%d',levels(c))];
    end
    out = nmrDataTMP{idx(c)};

    % the NMR data
    % here we fix the time scale to [s] if neccessary
    TE = out.parData.echoTime; % [탎]
    if out.nmrData{1}.time(1) == TE/1e3
        % change [ms] to [s]
        out.nmrData{1}.time = out.nmrData{1}.time/1e3;
        out.nmrData{1}.raw.time = out.nmrData{1}.raw.time/1e3;
    elseif out.nmrData{1}.time(1) == TE
        % change [탎] to [s] -> very unlikely
        out.nmrData{1}.time = out.nmrData{1}.time/1e6;
        out.nmrData{1}.raw.time = out.nmrData{1}.raw.time/1e6;
    end
    data.import.NMR.data{c} = out.nmrData{1};
    data.import.NMR.para{c} = out.parData;

    % subtract the background signal is one is available
    if isbgPath
        % get the original signal
        s = data.import.NMR.data{c}.signal;
        % if the background signal is longer than the signal cut it, if
        % not extend it with zeros
        if numel(ref1.s) > numel(s)
            tmp_r = ref1.s(1:numel(s));
        else
            tmp_r = zeros(size(s));
            tmp_r(1:numel(ref1.s)) = ref1.s;
        end
        s = complex(real(s)-real(tmp_r),imag(s)-imag(tmp_r));

        % sign check
        if real(s(1:3))<0
            s = s*-1;
        end

        % rotate phase again - TEST
        [s,~] = rotateT2phase(s);

        % update signal
        data.import.NMR.data{c}.signal = s;
        data.import.NMR.data{c}.raw.signal = s;
    end
end
if isposFile
    data.import.LIAGCORE.use_z = true;
else
    data.import.LIAGCORE.use_z = false;
end
data.import.LIAGCORE.zslice = levels;

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
    data.import.LIAG.Tbulk_keep_fit = false;
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
function [data,gui] = importDataMRSMatlab(data,gui)

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

    shownames{c} = out.parData{j}.file;

    data.import.NMR.data{c} = out.nmrData{j};
    data.import.NMR.para{c} = out.parData{j};
end

data.import.MRSMATLAB.q = out.q;
data.import.NMR.files = fnames;
data.import.NMR.filesShort = shownames;

answer = questdlg('Stack all or stack individually', ...
    'MRSD import', ...
    'all','individual','none','none');

switch answer
    case 'all'
        s = zeros(size(data.import.NMR.data{1}.signal));
        for c = 1:numel(data.import.NMR.data)
            s = s + data.import.NMR.data{c}.signal;
        end
        s = s./numel(data.import.NMR.data);

    case 'individual'
        [indx,~] = listdlg('PromptString','Select pulse moments:',...
            'SelectionMode','multi',...
            'ListString',shownames);

        if ~isempty(indx)
            s = zeros(size(data.import.NMR.data{1}.signal));
            for c = indx
                s = s + data.import.NMR.data{c}.signal;
            end
            s = s./numel(indx);
        end
end

switch answer
    case {'all','individual'}
        tmpdata = data.import.NMR.data{1};
        tmpdata.signal = s;
        tmpdata.raw.signal = s;

        data.import.NMR.data = cell(1,1);
        data.import.NMR.data{1} = tmpdata;

        tmppar = data.import.NMR.para{1};
        data.import.NMR.para = cell(1,1);
        data.import.NMR.para{1} = tmppar;

        fnames = fnames(1);
        shownames = cell(1,1);
        shownames{1} = fnames.datafile;

        data.import.NMR.files = fnames;
        data.import.NMR.filesShort = shownames;
    otherwise
        % nothing to do
end

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
    eval(['data.',str,';']); %#ok<EVLDOT>
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