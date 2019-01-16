function onPopupPressureUnits(src,~)
%onPopupPressureUnits select pressure unit ("Pa", "kPa", "MPa" or "bar")
%
% Syntax:
%       onPopupPressureUnits
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupPressureUnits(src,~)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
%       NUCLEUSmod_updateInterface
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
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');

% get the value of the popup menu
value = get(src,'Value');

% set the corresponding pressure unit
switch value    
    case 1 % Pa        
        data.pressure.unit = 'Pa';
        data.pressure.unitfac = 1;
        
    case 2 % kPa        
        data.pressure.unit = 'kPa';
        data.pressure.unitfac = 1e-3;
        
    case 3 % MPa        
        data.pressure.unit = 'MPa';
        data.pressure.unitfac = 1e-6;
        
    case 4 % bar        
        data.pressure.unit = 'bar';
        data.pressure.unitfac = 1e-5;
end

% update GUI data
setappdata(fig,'data',data);

% update interface
switch fig_tag    
    case 'INV'
        NUCLEUSinv_updateInterface;
    case 'MOD'
        NUCLEUSmod_updateInterface;
        % update the CPS axis
        updatePlotsCPS;
end

end