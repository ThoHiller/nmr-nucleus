function gui = readINIfile(gui)
%readINIfile imports the ini-File
%
% Syntax:
%       gui = readINIfile(gui)
%
% Inputs:
%       gui - figure gui elements structure
%
% Outputs:
%       gui
%
% Example:
%       gui = readINIfile(gui)
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

%% import ini-file
inifile = [gui.myui.inipath filesep gui.myui.inifile];
fid = fopen(inifile,'r');
inilines = textscan(fid,'%s','Delimiter','\n');
fclose(fid);
inilines = inilines{1};

%% process lines
for i = 1:size(inilines,1)
    tmp = char(inilines(i));
    if ~isempty(strfind(tmp,'='))
        ind = strfind(tmp,'=');
        prop = tmp(1:ind-1);
        value = tmp(ind+1:end);
        
        if strcmpi(prop,'version')
            inidata.version = value;
        elseif strcmpi(prop,'expertmode')
            inidata.expertmode = value;
        elseif strcmpi(prop,'invinfo')
            inidata.invinfo = value;
        elseif strcmpi(prop,'tooltips')
            inidata.tooltips = value;
        elseif strcmpi(prop,'colortheme')
            inidata.colortheme = value;
        elseif strcmpi(prop,'importpath')
            inidata.importpath = value;
        elseif strcmpi(prop,'lastimport')
            inidata.lastimport = value;
        elseif strcmpi(prop,'lastexport')
            inidata.lastexport = value;
        end
    end
end

if isstruct(inidata)
    gui.myui.inidata = inidata;
else
    gui.myui.inidata = [];
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