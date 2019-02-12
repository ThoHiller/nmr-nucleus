function gui = NUCLEUSinv_processINI(gui)
%NUCLEUSinv_processINI processes the ini-file
%
% Syntax:
%       gui = NUCLEUSinv_processINI(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       gui = NUCLEUSinv_processINI(gui)
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

%% ini-file should always be in the same folder as NUCLEUSinv.m
inipath = which('NUCLEUSinv.m');
inipath = fileparts(inipath);
gui.myui.inipath = inipath;
inifile = [inipath filesep gui.myui.inifile];

%% check if there is an ini-file
isfile = dir(inifile);

%% if yes read it, if not make one
if isempty(isfile)
    gui = makeINIfile(gui,'default');
else
    gui = readINIfile(gui);    
    % sanity checks
    version_equal = strcmp(gui.myui.version,gui.myui.inidata.version);
    if version_equal
        % check if the import path does exist
        ispath = dir(gui.myui.inidata.importpath);
        if isempty(ispath)
            % set the default one (example data)
            ind = strfind(gui.myui.inipath,'nucleus');
            importpath = [gui.myui.inipath(1:ind+6) filesep 'example_data'];
            gui.myui.inidata.importpath = importpath;
            % and update the ini-file
            gui = makeINIfile(gui,'update');
        end
    else
        % make a new ini-file
        gui = makeINIfile(gui,'default');
    end
end

return

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