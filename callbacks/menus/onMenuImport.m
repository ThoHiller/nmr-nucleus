function onMenuImport(src,~)
%onMenuImport handles the import menu entries
%
% Syntax:
%       onMenuImport
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuImport(src)
%
% Other m-files required:
%       importASCIIdata
%       importEXCELdata
%       importINV2INV
%       importMOD2INV
%       importMOD2MOD
%       importNMRdata
%       uncheckImportMenus
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
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');

label = get(src,'Label');
menu_tag = get(src,'Tag');

switch fig_tag    
    case 'MOD'
        importMOD2MOD;
        
    case 'INV'        
        uncheckImportMenus;
        set(src,'Checked','on');
        switch menu_tag
            case 'NUCLEUSinv'
                importINV2INV(src);
            case 'NUCLEUSmod'
                importMOD2INV(src);
            case 'NUCLEUSmod2d'
                importMOD2D2INV(src);
            case 'Excel'
                importEXCELdata(src);
            case 'Ascii'
                importASCIIdata(src);
            case 'Lab'
                importNMRdata(src);
            otherwise
                helpdlg({'function: onMenuImport','Menu tag not known.'},...
                    'menu not known')
        end
        
        % activate the PhaseView GUI in case real data is imported
        switch menu_tag
            case 'NUCLEUSmod'
                set(gui.menu.extra_phaseview,'Enable','off');
            otherwise
                set(gui.menu.extra_phaseview,'Enable','on');
        end
        
        % get updated gui data
        gui = getappdata(fig,'gui');
        % update the "last import" value within the ini-file     
        gui.myui.inidata.lastimport = [menu_tag,'_',label];
        setappdata(fig,'gui',gui);
        gui = makeINIfile(gui,'update');
        % and the menu entry itself
        switch label
            case 'LIAG from project'
                label = 'LIAG last project';
                set(gui.menu.file_import_lastimport,'Label',label,...
                    'Tag',menu_tag,'Callback',@onMenuImport)
            otherwise
                set(gui.menu.file_import_lastimport,'Label',label,...
                    'Tag',menu_tag,'Callback',@onMenuImport);
        end
        setappdata(fig,'gui',gui);
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