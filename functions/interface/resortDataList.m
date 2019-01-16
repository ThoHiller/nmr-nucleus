function resortDataList(label)
%resortDataList resorts the NMR signal entries either by name or date
%
% Syntax:
%       resortDataList
%
% Inputs:
%       label - 'name' or 'date'
%
% Outputs:
%       none
%
% Example:
%       resortDataList('date')
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
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

% only continue if there is data (INVdata is an easy indicator if data
% was actually imported)
if ~isempty(INVdata)
    % check how  many files are there and gather the data
    N = length(data.import.NMR.filesShort);
    time = zeros(N,1);
    names = cell(1,1);
    for i = 1:N
        time(i,1) = data.import.NMR.data{i}.datenum;
        names{i}  = data.import.NMR.filesShort{i};
    end
    
    % get a new index vector depending on the chosen sort method
    switch label        
        case 'name'
            [~,ix] = sort(names);
            ix     = ix';
        case 'date'
            [~,ix] = sort(time);
    end
    
    % now apply changes - resort the imported data
    data.import.NMR.data = {data.import.NMR.data{ix'}}; %#ok<*CCAT1>
    data.import.NMR.para = {data.import.NMR.para{ix'}};
    data.import.NMR.files = data.import.NMR.files(ix);
    data.import.NMR.filesShort = {data.import.NMR.filesShort{ix'}};
    % and resort possible already stored inversion data
    INVdata = {INVdata{ix(:)}}';
    
    % update the listbox entries
    shownames = get(gui.listbox_handles.signal,'String');
    set(gui.listbox_handles.signal,'String',{shownames{ix}});
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);    
else
    % if there is no data to sort throw a help dialog
    helpdlg('Nothing to do because there is no data loaded!',...
        'resortDataList: Load NMR data first.');
end

% update the GUI data
setappdata(fig,'data',data);
setappdata(fig,'INVdata',INVdata);

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