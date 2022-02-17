function importCPSdata
%importCPSdata imports CPS data from an ASCII dat-file. See the "examples"
%folder for an example file layout
%
% Syntax:
%       importCPSdata
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       importCPSdata
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get import field
import = data.import;

% if NMR data was previously loaded form that path start there
if isfield(import,'path')
    [CPSfile,CPSpath] = uigetfile(fullfile(import.path,'*.dat;*.*'),...
        'Choose CPS data file');    
else
    % otherwise we start at the current working directory
    % 'foldername' hold s the name of the chosen data path
    here = mfilename('fullpath');
    [pathstr,~,~] = fileparts(here);
    [CPSfile,CPSpath] = uigetfile(fullfile(pathstr,'*.dat;*.*'),...
        'Choose CPS data file');    
end

if CPSfile > 0 % USer didn't cancel    
    % import the CPS data
    tmp = importdata(fullfile(CPSpath,CPSfile));
    
    if isfield(tmp,'colheaders')        
        % get the pressure unit
        ind1 = strfind(tmp.colheaders{1},'[');
        ind2 = strfind(tmp.colheaders{1},']');
        data.pressure.unit = tmp.colheaders{1}(ind1+1:ind2-1);
        
        switch data.pressure.unit
            case 'Pa'
                data.pressure.unitfac = 1;
            case 'kPa'
                data.pressure.unitfac = 1e-3;
            case 'MPa'
                data.pressure.unitfac = 1e-6;
            case 'bar'
                data.pressure.unitfac = 1e-5;
        end
        
        % write the data to the table
        table = cell(1,1);
        for i = 1:size(tmp.data,1)
            table{i,1} = true;
            table{i,2} = tmp.data(i,1)/data.pressure.unitfac;
            table{i,3} = tmp.data(i,2);
            table{i,4} = 'D';
        end        
        data.pressure.table = table;
        % update GUI data
        setappdata(fig,'data',data);
        % update interface
        NUCLEUSinv_updateInterface;
    else
        helpdlg({'importCPSdata:','Something is wrong with the CPS data file.',...
            'Check the required file layout.'},'CPS import error');
    end
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