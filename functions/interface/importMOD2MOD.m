function importMOD2MOD
%importMOD2MOD imports previously saved NUCLEUSmod data back into the GUI
%
% Syntax:
%       importMOD2MOD
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       importMOD2MOD
%
% Other m-files required:
%       NUCLEUSmod_updateInterface
%       updatePlotsPSD
%       updatePlotsCPS
%       updatePlotsNMR
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get file name
NMpath = -1;
NMfile = -1;
[NMfile,NMpath] = uigetfile(pwd,'Choose NUCLEUSmod file');

% only continue if user didn't cancel
if sum([NMpath NMfile]) > 0
    % load the file
    guidata = load(fullfile(NMpath,NMfile));
    guidata = guidata.data;
    % and copy the data
    data.geometry = guidata.NMRMOD_GUI.geometry;
    data.pressure = guidata.NMRMOD_GUI.pressure;
    data.nmr = guidata.NMRMOD_GUI.nmr;
    data.results.constants = guidata.constants;
    data.results.GEOM = guidata.GEOM;
    data.results.NMR = guidata.NMR;
    data.results.psddata = guidata.psddata;
    data.results.SAT = guidata.SAT;
    
    % update GUI data
    setappdata(fig,'data',data);
    % update the interface
    NUCLEUSmod_updateInterface;
    % update the axes
    updatePlotsPSD;
    % update the axes
    updatePlotsCPS;
    updatePlotsNMR;
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