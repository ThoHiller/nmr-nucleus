function changeColorTheme(fig_tag,th)
%changeColorTheme changes the color theme of the calling figure
%
% Syntax:
%       changeColorTheme(fig_tag,th)
%
% Inputs:
%       fig_tag - tag of the calling figure ('INV' or 'MOD')
%       th - color theme ('standard', 'basic' or 'dark')
%
% Outputs:
%       none
%
% Example:
%       changeColorTheme('INV','basic')
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag',fig_tag);
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');
myui = gui.myui;

% update the colors
myui.colors = getColorTheme(fig_tag,th);

% update ini-file
myui.inidata.colortheme = th;
gui.myui = myui;
gui = makeINIfile(gui,'update');
        
% switch depending on the calling figure
switch fig_tag
    case 'INV'        
        % update the GUI elements
        set(gui.panels.data.main,'TitleColor',myui.colors.BoxDAT,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.process.main,'TitleColor',myui.colors.BoxPRC,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.petro.main,'TitleColor',myui.colors.BoxCBW,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.invstd.main,'TitleColor',myui.colors.BoxINV,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.invjoint.main,'TitleColor',myui.colors.BoxCPS,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.plots.SignalPanel,'BackgroundColor',myui.colors.TabSIG);
        set(gui.plots.DistPanel,'BackgroundColor',myui.colors.TabDIST);
        set(gui.plots.CPSPanel,'TitleColor',myui.colors.BoxCPS,...
            'ForegroundColor',myui.colors.BoxTitle);
        
        % check if there is data and change the colors accordingly
        gui.myui = myui;
        setappdata(fig,'gui',gui);
        if isfield(data,'results')
            updatePlotsSignal;
            if isfield(data.results,'invstd')
                updatePlotsDistribution;
                for i = 1:size(INVdata,1)
                    if isstruct(INVdata{i})
                        % color the background
                        strL = get(gui.listbox_handles.signal,'String');
                        str1 = data.import.NMR.filesShort{i};
                        str2 = ['<HTML><BODY bgcolor="rgb(',...
                            sprintf('%d,%d,%d',gui.myui.colors.listINV.*255),...
                            ')">',str1,'</BODY></HTML>'];
                        strL{i} = str2;
                        set(gui.listbox_handles.signal,'String',strL);
                    end
                end
            end
            if isfield(data.results,'invjoint')
                updatePlotsJointInversion;
            end
        end
        
    case 'MOD'        
        % update the GUI elements
        set(gui.panels.geometry.main,'TitleColor',myui.colors.GEO,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.cps.main,'TitleColor',myui.colors.CPS,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.panels.nmr.main,'TitleColor',myui.colors.NMR,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.plots.GeoPanel,'TitleColor',myui.colors.GEO,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.plots.CPSPanel,'TitleColor',myui.colors.CPS,...
            'ForegroundColor',myui.colors.BoxTitle);
        set(gui.plots.NMRPanel,'TitleColor',myui.colors.NMR,...
            'ForegroundColor',myui.colors.BoxTitle);
        gui.myui = myui;
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