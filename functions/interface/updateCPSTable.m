function updateCPSTable(method)
%updateCPSTable updates the CPS table in NUCLEUSmod
%
% Syntax:
%       updateCPSTable
%
% Inputs:
%       method
%
% Outputs:
%       none
%
% Example:
%       updateCPSTable
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
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

switch method
    case 'clear'        
        switch data.pressure.loglin
            case 0 % lin
                pressure = linspace(data.pressure.range(1),...
                    data.pressure.range(2),data.pressure.rangeN);
            case 1 % log
                pressure = logspace(log10(data.pressure.range(1)),...
                    log10(data.pressure.range(2)),data.pressure.rangeN);
        end
        % gather all neccessary data
        unit = data.pressure.unit;
        unitfac = data.pressure.unitfac;
        
        % table column headers
        cheader = {['p [',unit,']'],'S-drain [-]','select',...
            'S-imb [-]','select'};
        
        % generate a fresh table
        table = cell(1,1);
        for i = 1:data.pressure.rangeN
            table{i,1} = pressure(i).*unitfac;
            table{i,2} = [];            
            table{i,3} = false;            
            table{i,4} = [];            
            table{i,5} = false;
        end
        % update table
        set(gui.table_handles.pressure_table,'Data',table,'ColumnName',cheader);
        
    case 'update'
        if isfield(data.results,'SAT')
            % gather all neccessary data
            unit = data.pressure.unit;
            unitfac = data.pressure.unitfac;
            pressure = data.results.SAT.pressure;
            Sdrain = data.results.SAT.Sdfull;
            Simb = data.results.SAT.Sifull;
            DrainLevels = data.pressure.DrainLevels;
            ImbLevels = data.pressure.ImbLevels;
            
            % table column headers
            cheader = {['p [',unit,']'],'S-drain [-]','select',...
                'S-imb [-]','select'};
            
            % generate a fresh table
            table = cell(1,1);
            for i = 1:data.pressure.rangeN
                table{i,1} = pressure(i).*unitfac;
                table{i,2} = Sdrain(i);
                if any(DrainLevels==i)
                    table{i,3} = true;
                else
                    table{i,3} = false;
                end
                table{i,4} = Simb(i);
                if any(ImbLevels==i)
                    table{i,5} = true;
                else
                    table{i,5} = false;
                end
            end
            % update table
            set(gui.table_handles.pressure_table,'Data',table,...
                'ColumnName',cheader);
            % update GUI data
            setappdata(fig,'data',data);
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