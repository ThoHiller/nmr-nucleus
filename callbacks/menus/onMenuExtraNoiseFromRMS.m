function onMenuExtraNoiseFromRMS(src,~)
%onMenuExtraNoiseFromRMS estimates noise from the RMS of a fit
%(useful eg for T1 data)
%
% Syntax:
%       onMenuExtraNoiseFromRMS(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraNoiseFromRMS(src)
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

% id of the chosen NMR signal
id = get(gui.listbox_handles.signal,'Value');

% check if there is inversion data
if ~isempty(id) && ~isempty(INVdata) && isstruct(INVdata{id})

    % get original inversion data
    INVdata0 = INVdata{id};
    invstd = INVdata0.results.invstd; % results from original inversion
    rms = invstd.rms;
    
    % update data struct
    data.invstd.noise = rms;
    data.results.nmrproc.noise = rms;
    if data.results.nmrproc.isgated
        e = rms ./ sqrt(data.results.nmrproc.N);
        W = diag(e);
        data.results.nmrproc.e = e;
        data.results.nmrproc.W = W;
    else
        e = rms*ones(size(data.results.nmrproc.s));
        data.results.nmrproc.e = e;
    end
    INVdata0.invstd = data.invstd;
    INVdata0.results.nmrproc = data.results.nmrproc;

    % update the GUI data
    INVdata{id} = INVdata0;
    setappdata(fig,'data',data);
    setappdata(fig,'INVdata',INVdata);

else
    helpdlg('Cannot start calculation because there is no suitable data!',...
        'Perform inversion first.');
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