function onMenuSubGUIs(src,~)
%onMenuSubGUIs handles the extra menu entries to open NUCLEUS sub GUIs
%
% Syntax:
%       onMenuSubGUIs
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuSubGUIs(src)
%
% Other m-files required:
%       PhaseView
%       ConductView
%       FixedTimeView
%       UncertView
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
data = getappdata(fig,'data');

%% label of the calling menu
label = get(src,'Label');

% chose the corresponding function
switch label
    case 'PhaseView GUI'
        if isfield(data,'results')
            if isfield(data.results,'nmrraw') &&...
                    isfield(data.results,'nmrproc')
                PhaseView(src);
            else
                helpdlg({'function: PhaseView',...
                    'Cannot continue because no data loaded or selected!'},...
                    'Load NMR data first.');
            end
        else
            helpdlg({'function: PhaseView',...
                'Cannot continue because no data loaded or selected!'},...
                'Load NMR data first.');
        end

    case 'ConductView GUI'
        ConductView(src);

    case 'FixedTimeView GUI'
        if strcmp(data.invstd.invtype,'mono') ||...
                strcmp(data.invstd.invtype,'free')
            FixedTimeView(src);
        else
            helpdlg({'function: FixedTimeView',...
                'Cannot continue because wrong inversion method!'},...
                'Wrong inversion method.');
        end

    case 'UncertView GUI'
        if isfield(data.results,'invstd')
            if isfield(data.results.invstd,'uncert')
                UncertView(src);
            else
                helpdlg({'function: UncertView',...
                    'Cannot continue because there is no data!'},...
                    'No uncertainty data.');
            end
        else
            helpdlg({'function: UncertView',...
                'Cannot continue because there is no data!'},...
                'No inversion data.');
        end
    case '2DInv GUI'
        if isfield(data.import,'T1T2map')
            Inv2DView(src);
        else
            helpdlg({'function: Inv2DView',...
                'Cannot continue because there is no data!'},...
                'No T1T2 data.');
        end
    case '2DMod GUI'
        Mod2DView(src);
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