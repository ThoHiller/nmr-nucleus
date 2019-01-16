function importEXCELdata(src)
%importEXCELdata imports NMR data from Excel files
%all sheets are tested; if there is an CPS data sheet this can also be
%imported upon request
%
% Syntax:
%       importEXCELdata(src)
%
% Inputs:
%       src - handle to the calling uimenu
%
% Outputs:
%       none
%
% Example:
%       importEXCELdata(src)
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% T1 or T2 data?
T1T2 = get(src,'Label');

% get file name
EXCELpath = -1;
EXCELfile = -1;
if isfield(data.import,'path')
    [EXCELfile,EXCELpath] = uigetfile(fullfile(data.import.path,...
        '*.xls;*.xlsx'),'Choose Excel file');
else
    [EXCELfile,EXCELpath] = uigetfile(fullfile(pwd,'*.xls;*.xlsx'),...
        'Choose Excel file');
end

% only continue if user didn't cancel
if sum([EXCELpath EXCELfile]) > 0    
    % get some file infos
    fileID = dir(fullfile(EXCELpath,EXCELfile));
    [status,sheets,~] = xlsfinfo(fullfile(EXCELpath,EXCELfile));

    if ~isempty(status)        
        % remove info field if any
        ih = findobj('Tag','inv_info');
        if ~isempty(ih); delete(ih); end
        
        % remove old fields and data
        data = cleanupGUIData(data);
        
        data.import.fileformat = 'excel';
        data.import.path = EXCELpath;
        data.import.file = EXCELfile;
        
        % update the path-info string
        if EXCELfile > 0
            tmpstr = fullfile(EXCELpath,EXCELfile);
        else
            tmpstr = EXCELpath;
        end
        if length(tmpstr)>50
            set(gui.text_handles.data_path,'String',['...',tmpstr(end-50:end)],...
                'HorizontalAlignment','left');
        else
            set(gui.text_handles.data_path,'String',tmpstr,...
                'HorizontalAlignment','left');
        end
        set(gui.text_handles.data_path,'TooltipString',tmpstr);
        
        % check for possible CPS data sheet
        [indx1,tf1] = listdlg('PromptString',{'If available select CPS data sheet'},...
            'Name','Choose CPS data','ListSize',[250 200],...
            'SelectionMode','single','OKString','Apply',...
            'CancelString','No CPS data','ListString',sheets);
        
        % if there is a CPS data sheet import the data
        if tf1 == 1
            % get cps sheet name
            cps_sheet = sheets{indx1};
            % remove that sheet from the list
            % all others should be NMR data sheets
            sheets(indx1) = [];
            % import the data
            cps_data = xlsread(fullfile(EXCELpath,EXCELfile),cps_sheet);
            
            % ask for the pressure unit
            pressure_units = {'Pa','kPa','MPa','bar'};
            unit_factors = [1 1e-3 1e-6 1e-5];
            [indx2,tf2] = listdlg('PromptString','Select Pressure unit:',...
            'Name','Choose presure unit','ListSize',[250 200],...
            'SelectionMode','single','ListString',pressure_units);
            if tf2 == 1
                table = {true,0,1,'D'};                
                for i = 1:size(cps_data,1)
                    table{i,1} = true;
                    table{i,2} = cps_data(i,1)/unit_factors(indx2);
                    table{i,3} = cps_data(i,2);
                    table{i,4} = 'D';
                end
                % import pressure / saturation data
                data.pressure.unit = pressure_units{indx2};
                data.pressure.unitfac = unit_factors(indx2);    
                data.pressure.table = table;
            else
                helpdlg({'importEXCELdata:','CPS data was not imported',...
                    ' due to missing pressure unit.'},'No data import');
            end
        end
        
        % preceed with NMR data import
        fnames = struct;
        % shownames is just a dummy to hold all data file names that
        % will be shown in the listbox
        shownames = cell(1,1);
        
        % we assume there is data on every sheet
        c = 0;
        for s = 1:numel(sheets)            
            num = xlsread(fullfile(EXCELpath,EXCELfile),sheets{s});
            
            % only continue if there is data
            if ~isempty(num)                
                % the individual file names
                c = c + 1;
                fnames(c).parfile = '';
                fnames(c).datafile = data.import.file;
                fnames(c).T2specfile = '';
                
                shownames{c} = sheets{s};
                
                % the 'header' data
                data.import.NMR.data{c}.datfile = fileID.name;
                data.import.NMR.data{c}.date = fileID.date;
                data.import.NMR.data{c}.datenum = fileID.datenum;
                data.import.NMR.data{c}.bytes = fileID.bytes;
                
                % the NMR data
                data.import.NMR.data{c}.flag = T1T2;
                data.import.NMR.data{c}.time = num(:,1);
                if size(num,2)>2
                    data.import.NMR.data{c}.signal = complex(num(:,2),num(:,3));
                else
                    data.import.NMR.data{c}.signal = num(:,2);
                end
                data.import.NMR.data{c}.T1IRfac = 1;
                data.import.NMR.data{c}.raw.time = data.import.NMR.data{c}.time;
                data.import.NMR.data{c}.raw.signal = data.import.NMR.data{c}.signal;
                
                % dummy parameter data
                data.import.NMR.para{c} = 0;
            end            
        end
        
        % save file names
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
        
        % clear all axes
        clearAllAxes(gui.figh);
        
        % update GUI data and interface
        setappdata(fig,'data',data);
        setappdata(fig,'gui',gui);
        enableGUIelements('EXCEL');
        NUCLEUSinv_updateInterface;        
    else
        helpdlg({'importEXCELdata:','File is not a valid Excel file'},...
            'File not recognized');
    end
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