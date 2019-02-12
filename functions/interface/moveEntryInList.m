function moveEntryInList(inc)
%moveEntryInList moves entries one place up or down in NMR signal list
%
% Syntax:
%       moveEntryInList(inc)
%
% Inputs:
%       inc - increment by which the list entry is moved ('-1' or '1')
%
% Outputs:
%       none
%
% Example:
%       moveEntryInList(inc)
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

% which NMR signal
idx = get(gui.listbox_handles.signal,'Value');
% how many names(entries) are there in total
nnames = numel(get(gui.listbox_handles.signal,'String'));
% new position
newidx = idx+inc;
% all positions
ix = 1:1:nnames;

% proceed if a signal was chosen and if it is not already at top or bottom
% position
if ~isempty(idx) && (newidx>=1 && newidx<=nnames)    
    % swap positions
    ix(idx) = newidx;
    ix(newidx) = idx;
    
    % now apply changes
    data.import.NMR.data = {data.import.NMR.data{ix}}; %#ok<*CCAT1>
    data.import.NMR.para = {data.import.NMR.para{ix}};
    data.import.NMR.files = data.import.NMR.files(ix);
    data.import.NMR.filesShort = {data.import.NMR.filesShort{ix}};
    INVdata = {INVdata{ix(:)}}';
    
    % update listbox
    shownames = get(gui.listbox_handles.signal,'String');
    set(gui.listbox_handles.signal,'String',{shownames{ix}});
    set(gui.listbox_handles.signal,'Value',[],'Max',2,'Min',0);
    
    % update GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'INVdata',INVdata);
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