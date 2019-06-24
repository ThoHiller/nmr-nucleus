function showParameterInfo
%showParameterInfo shows the parameter file info (if available)
%in an extra figure
%
% Syntax:
%       showParameterInfo
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       showParameterInfo
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

%% proceed if there is data
if isfield(data.import,'NMR')
    % gather the parameter data for the current selected file
    id = get(gui.listbox_handles.signal,'Value');
    if ~isempty(id)
        if isfield(data.import.NMR.para{id},'all')
            all = data.import.NMR.para{id}.all{1};
            
            fname = data.import.NMR.filesShort{id};
            info = cell(1,1);
            for i = 1:size(all,1)
                tmpstr = all{i,1};
                ind = strfind(tmpstr,'=');
                if ~isempty(ind)
                    info{i,1} = tmpstr(1:ind(1)-1);
                    info{i,2} = tmpstr(ind(1)+1:end);
                end
            end
            f1 = figure('Name',[fname,' Parameter Info'],'NumberTitle','off',...
                'ToolBar','none','MenuBar','none');
            pos0 = get(fig,'Position');
            pos1 = get(f1,'Position');
            cent(1) = (pos0(1)+pos0(3)/2);
            cent(2) = (pos0(2)+pos0(4)/2);
            set(f1,'Position',[cent(1)-pos1(3)/2 pos0(2) pos1(3) pos0(4)+25]);
            % draw the uitable
            th = uitable('Parent',f1,'Data',info,'ColumnName',{'Property','Value'});
            % adjust the column widths
            pos = get(f1,'Position');
            w = (pos(3)-80)/2;
            set(th,'Position',[20 20 pos(3)-40 pos(4)-40],'ColumnWidth',{w w});
        end
    else
        helpdlg({'function: showParameterInfo',...
            'Cannot continue because no data is selected!'},...
            'Select NMR data first.');
    end
else
    helpdlg({'function: showParameterInfo',...
            'Cannot continue because no data is loaded!'},...
            'Load NMR data first.');
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