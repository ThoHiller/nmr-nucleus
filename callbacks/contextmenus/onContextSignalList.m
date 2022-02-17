function onContextSignalList(src,~)
%onContextSignalList handles the calls from the context menu of the data
%listbox
%
% Syntax:
%       onContextSignalList
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onContextSignalList(src,~)
%
% Other m-files required:
%       resortDataList
%       moveEntryInList
%       onPushRun
%       clearInversion
%       saveInversion
%       removeSignalFromList
%       useSignalAsCalibration
%       runInversionBatch
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

% get the tag of the context menu
tag = get(src,'Tag');
% get the label of the context menu
label = get(src,'Label');
% get the id of the signal in the list
id = get(gui.listbox_handles.signal,'Value');

% depending on the current label and tag call the corresponding function
switch tag
    case 'sort'
        switch label
            case 'by name'
                resortDataList('name');                
            case 'by date'
                resortDataList('date');
            case 'flip list'
                resortDataList('flip');    
            case [char(hex2dec('2191')),'up']
                moveEntryInList(-1);
            case [char(hex2dec('2193')),'down']
                moveEntryInList(1);
            otherwise
                disp(['onContextSignalList ',tag,' ',label,...
                    ': Something is utterly wrong.']);
        end
    case 'single'
        switch label
            case 'run'
                onPushRun(gui.push_handles.invstd_run);
            case 'clear'
                clearInversion(id);
            case 'save'
                exportData('INV','matS');
            case 'use as calib.'
                useSignalAsCalibration(id);
            case 'remove'
                removeSignalFromList(id);
            otherwise
                disp(['onContextSignalList ',tag,' ',label,...
                    ': Something is utterly wrong.']);
        end
    case 'all'
        switch label
            case 'run'
                runInversionBatch;
            case 'clear'
                clearInversion('all');
            case 'save'
                exportData('INV','matA');
            otherwise
                disp(['onContextSignalList ',tag,' ',label,...
                    ': Something is utterly wrong.']);
        end
    otherwise
        disp(['onContextSignalList ',tag,': Something is utterly wrong.']);
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