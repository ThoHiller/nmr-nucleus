function onMenuExtraFindDuplicates(src,~)
%onMenuExtraFindDuplicates finds duplicate NMR signals (mostly a HELIOS issue)
%
% Syntax:
%       onMenuExtraFindDuplicates(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraFindDuplicates(src)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

hasData = false;
if isfield(data.import,'NMR')
    hasData = true;
end

if hasData

    %% 1. before we do anything, sort the data by date (time)
    time = zeros(numel(data.import.NMR.filesShort),1);
    timestamp = zeros(numel(data.import.NMR.filesShort),1);
    for i = 1:numel(data.import.NMR.filesShort)
        time(i,1) = data.import.NMR.data{i}.datenum;
        timestamp(i,1) = data.import.NMR.para{i}.timestamp;
    end
    [~,ix] = sort(time);
    % now apply changes - resort the imported data
    data.import.NMR.data = {data.import.NMR.data{ix'}}; %#ok<*CCAT1>
    data.import.NMR.para = {data.import.NMR.para{ix'}};
    data.import.NMR.files = data.import.NMR.files(ix);
    data.import.NMR.filesShort = {data.import.NMR.filesShort{ix'}};
    % the timestamps can also indicate duplicate signals
    timestamp = timestamp(ix);
    dts = [0; diff(timestamp)];
    % and resort possible already stored inversion data
    INVdata = {INVdata{ix(:)}}';
    % update the listbox entries
    shownames = get(gui.listbox_handles.signal,'String');
    set(gui.listbox_handles.signal,'String',{shownames{ix}});
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);

    %% 2. checking starts at the second signal
    dup_ids = zeros(1,1);
    keep_ids = 1:1:numel(data.import.NMR.data);
    keep_ids = keep_ids(:);
    c = 0;
    for i1 = 2:numel(data.import.NMR.data)

        s0 = data.import.NMR.data{i1-1}.signal;
        s1 = data.import.NMR.data{i1}.signal;

        if s0==s1
            c = c + 1;
            dup_ids(c,1) = i1;
            keep_ids(keep_ids == i1) = [];
        end
    end
    % if we found something, ask what to do
    if sum(dup_ids) > 0
        answer = questdlg('What to do with the duplicate signals?',...
            'Duplicates Found',...
            'Keep & Mark','Delete','Nothing','Delete');
        switch answer
            case 'Keep & Mark'
                shownames = data.import.NMR.filesShort;
                for i1 = 1:numel(dup_ids)
                    shownames{dup_ids(i1)} = [shownames{dup_ids(i1)},'_dup'];
                end
                data.import.NMR.filesShort = shownames;
                set(gui.listbox_handles.signal,'String',shownames);
                set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);

                msgbox([num2str(numel(dup_ids)),...
                    ' signals have been marked as duplicate.']);

            case 'Delete'
                ix = keep_ids;
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

                msgbox([num2str(numel(dup_ids)),' signals have been deleted.']);

            case 'Nothing'
        end
    else
        msgbox('No duplicate signals have been found.');
    end

    % update the GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'INVdata',INVdata);

else
    helpdlg('Nothing to do because there is no data loaded!',...
        'onMenuExtraFindDuplicates: Load NMR data first.');
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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