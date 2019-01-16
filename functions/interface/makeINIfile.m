function gui = makeINIfile(gui,method)
%makeINIfile creates or updates the ini-File
%
% Syntax:
%       gui = makeINIfile(gui)
%
% Inputs:
%       gui - figure gui elements structure
%       method - 'default' or 'update'
%
% Outputs:
%       gui
%
% Example:
%       gui = makeINIfile(gui,'default')
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

%% open ini-file
inifile = [gui.myui.inipath filesep gui.myui.inifile];
fid = fopen(inifile,'w');

%% gather output data
switch method
    case 'default'        
        inidata.version = gui.myui.version;
        inidata.expertmode = 'off';
        inidata.invinfo = 'on';
        inidata.tooltips = 'off';
        inidata.colortheme = 'standard';
        ind = strfind(gui.myui.inipath,'nucleus');
        importpath = [gui.myui.inipath(1:ind+6) filesep 'example_data'];
        inidata.importpath = importpath;
        inidata.lastimport = 'Lab_RWTH ascii';
        gui.myui.inidata = inidata;
        
    case 'update'
        inidata = gui.myui.inidata;
end

content{1,1} = 'NUCLEUSinv';
content{end+1,1} = ['version=',inidata.version];
content{end+1,1} = ' ';
content{end+1,1} = ['expertmode=',inidata.expertmode];
content{end+1,1} = ['invinfo=',inidata.invinfo];
content{end+1,1} = ['tooltips=',inidata.tooltips];
content{end+1,1} = ['colortheme=',inidata.colortheme];
content{end+1,1} = ' ';
content{end+1,1} = ['importpath=',inidata.importpath];
content{end+1,1} = ['lastimport=',inidata.lastimport];

%% write content to file
for i = 1:size(content,1)
    fprintf(fid,'%s\n',content{i});
end

%% close file
fclose(fid);

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