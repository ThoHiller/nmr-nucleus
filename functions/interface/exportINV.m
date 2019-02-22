function exportINV(format,varargin)
%exportINV exports NUCLEUSinv GUI data to a mat-file
%in two different ways based on the input variable 'format'. If 'raw' is
%chosen, only the previously imported NMR raw data gets exported to a
%mat-file to speed-up data import later. If 'session' is chosen, all data
%and GUI settings are saved as a snapshot to continue working on it at a
%later point in time.
%
% Syntax:
%       exportINV(format)
%
% Inputs:
%       format - string being either 'raw' or 'session'
%       varargin - holds a struct 'silent' for automated saving
%
% Outputs:
%       none
%
% Example:
%       exportINV('raw')
%       exportINV('session')
%
% Other m-files required:
%       displayStatusText
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

% default is non-silent mode
dosilent = false;
if nargin > 1
    dosilent = true;
    silent = varargin{1};
    sfile = silent.sname;
end

switch format    
    case 'raw'
        % proceed if there is data
        if isfield(data.import,'NMR')
            
            % display info text
            displayStatusText(gui,'Exporting NMR raw data to mat-file ...');
            % create export struct
            savedata.data  = data.import.NMR.data;
            savedata.para  = data.import.NMR.para;
            savedata.files = data.import.NMR.files;
            savedata.filesShort = data.import.NMR.filesShort;
            
            % save to default file at local data path
            save(fullfile(data.import.path,'NUCLEUSinv_raw.mat'),'savedata');
            clear savedata;
            
            % display info text
            displayStatusText(gui,'Exporting NMR raw data to mat-file ... done');
            
        else
            helpdlg({'function: exportINV',...
                'Cannot continue because no data is loaded!'},...
                'Load NMR data first.');
        end
        
    case 'session'        
        INVdata = getappdata(fig,'INVdata');
        % proceed if there is data
        if ~isempty(INVdata)
            % display info text
            if ~dosilent
                displayStatusText(gui,'Exporting GUI session to mat-file ...');
            end
            savedata.myui = gui.myui;
            savedata.data = data;
            savedata.INVdata = INVdata;
            savedata.id = get(gui.listbox_handles.signal,'Value');
            
            
            if dosilent
                save(fullfile(sfile),'savedata');
                clear savedata;
            else
                % session file name
                sfilename = 'NUCLEUSinv_session';
                
                % ask for folder and maybe new name
                if isfield(data.import,'path')
                    [sfile,spath] = uiputfile('*.mat',...
                        'Save session file',...
                        fullfile(data.import.path,[sfilename,'.mat']));
                else
                    [sfile,spath] = uiputfile('*.mat',...
                        'Save session file',...
                        fullfile(pwd,[sfilename,'.mat']));
                end
                
                % if user didn't cancel save session
                if sum([sfile spath]) > 0
                    save(fullfile(spath,sfile),'savedata');
                    clear savedata;
                    
                    % display info text
                    displayStatusText(gui,'Exporting GUI session to mat-file ... done');
                else
                    % display info text
                    displayStatusText(gui,'Exporting GUI session to mat-file ... canceled');
                end
            end
        else
            helpdlg({'function: exportINV',...
                'Cannot continue because no data is loaded!'},...
                'Load NMR data first.');
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