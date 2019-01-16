function onMenuExportData(src,~)
%onMenuExportData handles the calls from the export menu
%
% Syntax:
%       onMenuExportData
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExportData(src,~)
%
% Other m-files required:
%       exportData
%       exportINV
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

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
% get its unique tag
fig_tag = get(fig,'Tag');

% get the label of the menu entry
label = get(src,'Label');

switch fig_tag    
    case 'INV'        
        switch label            
            case 'NUCLEUSinv (raw)'
                exportINV('raw');
            case 'NUCLEUSinv (session)'
                exportINV('session');                
            case 'EXCEL single (std)'
                exportData(fig_tag,'excelS');
            case 'MAT single (std)'
                exportData(fig_tag,'matS');
            case 'MAT all (std)'
                exportData(fig_tag,'matA');                
            case 'EXCEL single (joint)'
                exportData(fig_tag,'excelJ');
            case 'MAT single (joint)'
                exportData(fig_tag,'matJ');
            case 'LIAG archive'
                exportData(fig_tag,'LIAG');
        end
        
    case 'MOD'        
        switch label            
            case 'NUCLEUSmod'
                exportData(fig_tag,'mat');
            case 'XLS file'
                exportData(fig_tag,'xls');
            case 'CSV file'
                exportData(fig_tag,'csv');
            case 'DAT files'
                exportData(fig_tag,'dat');
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