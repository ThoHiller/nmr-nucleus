function importINV2INV(src)
%importINV2INV imports a previously saved NUCLEUSinv session
%back into the GUI
%
% Syntax:
%       importINV2INV(src)
%
% Inputs:
%       src - handle to the calling uimenu
%
% Outputs:
%       none
%
% Example:
%       importINV2INV(src)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%       updatePlotsSignal
%       updatePlotsDistribution
%       updatePlotsIterChi
%       updatePlotsLcurve
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

% get the file name
Sessionpath = -1;
Sessionfile = -1;
% if there is already a data folder present we start from here
if isfield(data.import,'path')
    [Sessionfile,Sessionpath] = uigetfile(data.import.path,...
        'Choose NUCLEUSinv session file');
else
    % otherwise we start at the current working directory
    % 'pathstr' hold s the name of the chosen data path
    here = mfilename('fullpath');
    [pathstr,~,~] = fileparts(here);
    [Sessionfile,Sessionpath] = uigetfile(pathstr,...
        'Choose NUCLEUSinv session file');
end

% only continue if user didn't cancel
if sum(Sessionpath) > 0    
    % check if it is a valid session file
    tmp = load(fullfile(Sessionpath,Sessionfile),'savedata');
    savedata = tmp.savedata;
    if isfield(savedata,'data') && isfield(savedata,'id') && ...
            isfield(savedata,'INVdata')
        
        % check import uimenu
        set(src,'Checked','on');
        
        % get the data from the mat file
        data = savedata.data;
        INVdata = savedata.INVdata;
        
        % update GUI data
        setappdata(fig,'data',data);
        setappdata(fig,'INVdata',INVdata);
        
        % update the path info field with "path" ("file")
        if data.import.file > 0
            tmpstr = fullfile(data.import.path,data.import.file);
        else
            tmpstr = data.import.path;
        end
        if length(tmpstr)>50
            set(gui.text_handles.data_path,'String',['...',tmpstr(end-50:end)],...
                'HorizontalAlignment','left');
        else
            set(gui.text_handles.data_path,'String',tmpstr,...
                'HorizontalAlignment','left');
        end
        set(gui.text_handles.data_path,'TooltipString',tmpstr);
        
        % update the list of file names
        set(gui.listbox_handles.signal,'String',data.import.NMR.filesShort);
        set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
        
        % update GUI interface
        NUCLEUSinv_updateInterface;
        
        % color the file names where there is an inversion set
        for id = 1:size(INVdata,1)
            if isstruct(INVdata{id})
                strL = get(gui.listbox_handles.signal,'String');
                str1 = strL{id};
                str2 = ['<HTML><BODY bgcolor="rgb(',...
                    sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),')">',...
                    str1,'</BODY></HTML>'];
                strL{id} = str2;
                set(gui.listbox_handles.signal,'String',strL);
            end
        end

        % set focus on last file used in previous session
        set(gui.listbox_handles.signal,'Value',savedata.id);
        
        % show corresponding file data
        updatePlotsSignal;
        if isstruct(INVdata{savedata.id})            
            if isfield(data,'results')
                if isfield(data.results,'invstd')
                    updatePlotsDistribution;
                end
                if isfield(data.results,'lcurve')
                    updatePlotsLcurve;
                end
                if isfield(data.results,'iterchi2')
                    updatePlotsIterChi;
                end
            end
        end        
    else
        helpdlg({'importINV2INV:';...
            'This seems to be not a valid NUCLEUSinv session file'},...
            'No session data found');
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