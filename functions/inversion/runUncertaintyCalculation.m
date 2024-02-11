function runUncertaintyCalculation
%runUncertaintyCalculation caluclates inverison statistics in some kind of
%bootstrapping manner
%
% Syntax:
%       runUncertaintyCalculation
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       runUncertaintyCalculation
%
% Other m-files required:
%       estimateUncertainty.m
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
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

% id of the chosen NMR signal
id = get(gui.listbox_handles.signal,'Value');

if ~isempty(id) && ~isempty(INVdata) && isstruct(INVdata{id})
    % get original inversion data
    INVdata0 = INVdata{id};
    invstd = INVdata0.results.invstd; % results from original inversion
    invtype = INVdata0.invstd.invtype;

    % original fit parameter
    iparam = invstd.invparams;

    % uncertainty parameter
    uparam.id = id;
    uparam.time = INVdata0.results.nmrproc.t;
    uparam.signal = INVdata0.results.nmrproc.s;
    % can be set when switching the inversion method
    switch invtype
        case {'LU','NNLS'}
            uparam.uncert.Method = 'RMS_bound';
        case 'MUMO'
            uparam.uncert.Method = 'RMS_free';
    end
    uparam.uncert.Thresh = data.uncert.Thresh;
    uparam.uncert.chi2_range = [0 100];
    uparam.uncert.mnorm_range = [0 1.5*invstd.xn];
    uparam.uncert.N = data.uncert.N;
    uparam.uncert.Max = data.uncert.Max;
    invstd = estimateUncertainty(invtype,invstd,iparam,uparam);

    % save updated inversion results
    data.results.invstd = invstd;
    INVdata0.results.invstd = invstd;

    % update INVdata
    INVdata{id} = INVdata0;
    % update GUI data
    setappdata(fig,'data',data);
    % update GUI INVdata
    setappdata(fig,'INVdata',INVdata);

    % update plots and INFO fields
    updatePlotsSignal;
    updatePlotsDistribution;
    updateInfo(gui.plots.SignalPanel);
    % if the UncertView window is open update it
    if ~isempty(findobj('Tag','UNCERTVIEW'))
        UncertView(gui.menu.extra_uncert);
    end
else
    helpdlg('Cannot start calculation because there is no suitable data!',...
        'Perform inversion first.');
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2023 Thomas Hiller
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