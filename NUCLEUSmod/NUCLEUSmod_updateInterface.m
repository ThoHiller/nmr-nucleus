function NUCLEUSmod_updateInterface
%NUCLEUSmod_updateInterface updates all GUI elements
%
% Syntax:
%       NUCLEUSmod_updateInterface
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSmod_updateInterface
%
% Other m-files required:
%       none
% Subfunctions:
%       updateGeometryRange
%       updateGeometryModesN
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

%% update geometry panel
% geometry type dependent
switch data.geometry.type    
    case 'cyl'
        
        % geometry type popup
        set(gui.popup_handles.geometry_type,'Value',1);
        
        % polygon sides and corresponding angle beta
        set(gui.popup_handles.polyN,'Enable','off');
        set(gui.edit_handles.beta,'Enable','off');
        
        % angles
        set(gui.edit_handles.alpha,'String','');
        set(gui.edit_handles.beta,'String','');
        set(gui.edit_handles.gamma,'String','');
        
    case 'ang'
        
        % geometry type popup
        set(gui.popup_handles.geometry_type,'Value',2);
        
        % polygon sides and corresponding angle beta
        set(gui.popup_handles.polyN,'Enable','off');
        set(gui.edit_handles.beta,'Enable','on');
        
        % angles
        set(gui.edit_handles.alpha,'String',num2str(data.geometry.alpha));
        set(gui.edit_handles.beta,'String',num2str(data.geometry.beta));
        set(gui.edit_handles.gamma,'String',num2str(data.geometry.gamma));
        
    case 'poly'
        
        % geometry type popup
        set(gui.popup_handles.geometry_type,'Value',3);
        
        % polygon sides and corresponding angle beta
        set(gui.popup_handles.polyN,'Enable','on',...
            'Value',data.geometry.polyN-2);
        set(gui.edit_handles.beta,'Enable','off');
        
        % angles
        set(gui.edit_handles.alpha,'String','');
        set(gui.edit_handles.beta,'String',num2str(data.geometry.beta));
        set(gui.edit_handles.gamma,'String','');      
end

% single pore or PSD range and PSd modes
gui = updateGeometryRange(gui,data.geometry.ispsd,data.geometry.modesN);
gui = updateGeometryModesN(gui,data.geometry.ispsd,data.geometry.modesN,...
    data.geometry.modes);

%% update pressure panel
% IFT and water surface contact angle
set(gui.edit_handles.sigma,'String',num2str(data.pressure.sigma));
set(gui.edit_handles.theta,'String',num2str(data.pressure.theta));

% pressure range dicretization
switch data.pressure.loglin
    case 1 % log
        set(gui.popup_handles.loglin,'Value',1);
    case 0 % lin
        set(gui.popup_handles.loglin,'Value',2);
end

% pressure unit
switch data.pressure.unit
    case 'Pa'
        data.pressure.unitfac = 1;
        set(gui.popup_handles.units,'Value',1);
    case 'kPa'
        data.pressure.unitfac = 1e-3;
        set(gui.popup_handles.units,'Value',2);
    case 'MPa'
        data.pressure.unitfac = 1e-6;
        set(gui.popup_handles.units,'Value',3);
    case 'bar'
        data.pressure.unitfac = 1e-5;
        set(gui.popup_handles.units,'Value',4); 
end

% pressure range
set(gui.edit_handles.press_range_min,...
    'String',num2str(data.pressure.range(1)*data.pressure.unitfac));
set(gui.edit_handles.press_range_max,...
    'String',num2str(data.pressure.range(2)*data.pressure.unitfac));

% CPS table
if isfield(data.results,'SAT')
    updateCPSTable('update');
else
    updateCPSTable('clear');
end

%% update NMR panel
% all edit fields
set(gui.edit_handles.Tbulk,'String',num2str(data.nmr.Tbulk));
set(gui.edit_handles.rho,'String',num2str(data.nmr.rho));
set(gui.edit_handles.TE,'String',num2str(data.nmr.TE));
set(gui.edit_handles.echosN,'String',num2str(data.nmr.echosN));
set(gui.edit_handles.noise,'String',num2str(data.nmr.noise));
set(gui.edit_handles.porosity,'String',num2str(data.nmr.porosity));

end

%% sub functions
function gui = updateGeometryRange(gui,ispsd,modesN)

switch ispsd
    case 0 % single pore
        set(gui.popup_handles.singlepsd,'Value',1);
        set(gui.edit_handles.range_min,'Enable','off');
        set(gui.edit_handles.range_max,'Enable','off');
        set(gui.edit_handles.rangeN,'Enable','off');
        set(gui.popup_handles.modesN,'Enable','off','Value',modesN);        
    case 1 % PSD
        set(gui.popup_handles.singlepsd,'Value',2);
        set(gui.edit_handles.range_min,'Enable','on');
        set(gui.edit_handles.range_max,'Enable','on');
        set(gui.edit_handles.rangeN,'Enable','on');
        set(gui.popup_handles.modesN,'Enable','on','Value',modesN);      
end
end

function gui = updateGeometryModesN(gui,ispsd,modesN,modes)

% set the values
set(gui.edit_handles.mode1,'String',num2str(modes(1,1)));
set(gui.edit_handles.sig1,'String',num2str(modes(1,2)));
set(gui.edit_handles.amp1,'String',num2str(modes(1,3)));
set(gui.edit_handles.mode2,'String',num2str(modes(2,1)));
set(gui.edit_handles.sig2,'String',num2str(modes(2,2)));
set(gui.edit_handles.amp2,'String',num2str(modes(2,3)));
set(gui.edit_handles.mode3,'String',num2str(modes(3,1)));
set(gui.edit_handles.sig3,'String',num2str(modes(3,2)));
set(gui.edit_handles.amp3,'String',num2str(modes(3,3)));

% enable / disable
switch modesN    
    case 1        
        switch ispsd            
            case 0 % single pore                
                set(gui.edit_handles.sig1,'Enable','off');
                set(gui.edit_handles.amp1,'Enable','off');
                set(gui.edit_handles.mode2,'Enable','off');
                set(gui.edit_handles.sig2,'Enable','off');
                set(gui.edit_handles.amp2,'Enable','off');
                set(gui.edit_handles.mode3,'Enable','off');
                set(gui.edit_handles.sig3,'Enable','off');
                set(gui.edit_handles.amp3,'Enable','off');                
            case 1 % PSD with 1 mode                
                set(gui.edit_handles.sig1,'Enable','on');
                set(gui.edit_handles.amp1,'Enable','on');
                set(gui.edit_handles.mode2,'Enable','off');
                set(gui.edit_handles.sig2,'Enable','off');
                set(gui.edit_handles.amp2,'Enable','off');
                set(gui.edit_handles.mode3,'Enable','off');
                set(gui.edit_handles.sig3,'Enable','off');
                set(gui.edit_handles.amp3,'Enable','off');
        end        
    case 2 % PSD with 2 modes        
        set(gui.edit_handles.sig1,'Enable','on');
        set(gui.edit_handles.amp1,'Enable','on');
        set(gui.edit_handles.mode2,'Enable','on');
        set(gui.edit_handles.sig2,'Enable','on');
        set(gui.edit_handles.amp2,'Enable','on');
        set(gui.edit_handles.mode3,'Enable','off');
        set(gui.edit_handles.sig3,'Enable','off');
        set(gui.edit_handles.amp3,'Enable','off');        
    case 3 % PSD with 3 modes        
        set(gui.edit_handles.sig1,'Enable','on');
        set(gui.edit_handles.amp1,'Enable','on');
        set(gui.edit_handles.mode2,'Enable','on');
        set(gui.edit_handles.sig2,'Enable','on');
        set(gui.edit_handles.amp2,'Enable','on');
        set(gui.edit_handles.mode3,'Enable','on');
        set(gui.edit_handles.sig3,'Enable','on');
        set(gui.edit_handles.amp3,'Enable','on');   
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