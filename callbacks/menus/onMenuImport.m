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
%       importCalibrationData
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');

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
            case 'Excel'
                importEXCELdata(src);
            case 'Ascii'
                importASCIIdata(src);
            case 'Calibration'
                importCalibrationData;
            case 'Lab'
                importNMRdata(src);
            otherwise
                helpdlg({'function: onMenuImport','Menu tag no known.'},...
                    'menu not known')
        end
        % update the lastimport data within the ini-file
        gui = getappdata(fig,'gui');
        gui.myui.inidata.lastimport = [menu_tag,'_',label];
        setappdata(fig,'gui',gui);
        gui = makeINIfile(gui,'update');
        % and the menu entry itself
        set(gui.menu.file_import_lastimport,'Label',label,...
            'Tag',menu_tag,'Callback',@onMenuImport)
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