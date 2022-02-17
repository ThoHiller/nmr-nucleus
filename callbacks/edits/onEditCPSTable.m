function onEditCPSTable(src,~)
%onEditCPSTable updates entries made in the CPS table of NUCLEUSinv
%
% Syntax:
%       onEditCPSTable
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onEditCPSTable(src)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
% get its unique tag
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

%% apply changes to table
switch fig_tag
    case 'INV'
        % all table data
        table = get(gui.table_handles.invjoint_table,'Data');
        
        % apply the pressure unit factor for conversion to/from [Pa]
        p_tmp = cell2mat(table(:,2));
        p_tmp = p_tmp ./ data.pressure.unitfac;
        table(:,2) = num2cell(p_tmp,numel(p_tmp));
        
        % update the table data
        data.pressure.table = table;
        data = removeInversionFields(data);
        % update the Gui data
        setappdata(fig,'data',data);        
        updatePlotsSignal;
        
    case 'MOD'
        table = get(gui.table_handles.pressure_table,'Data');
        drain = cell2mat(table(:,3));
        imb = cell2mat(table(:,5));
        DrainLevels = 1:1:data.pressure.rangeN;
        ImbLevels = 1:1:data.pressure.rangeN;
        data.pressure.DrainLevels = DrainLevels(drain);
        data.pressure.ImbLevels = ImbLevels(imb);
        % update the Gui data
        setappdata(fig,'data',data);
        % update the CPS axis
        updatePlotsCPS;
        % update the NMR axis
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