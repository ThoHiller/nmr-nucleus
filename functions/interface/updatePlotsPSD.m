function updatePlotsPSD
%updatePlotsPSD plots the pore size distribution in NUCLEUSmod
%
% Syntax:
%       updatePlotsPSD
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsPSD
%
% Other m-files required:
%       beautifyAxes
%       clearSingleAxis
%       updatePlotsGeometryType
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
colors = gui.myui.colors;

% get the results
results = data.results;

% clear the PSD axes
ax = gui.axes_handles.geo;
clearSingleAxis(ax);
hold(ax,'on')

% check if it is a single pore or a pore size distribution (PSD)
% the radius is plotted in [µm] hence the factor 1e6
switch data.geometry.ispsd    
    case 0        
        stem(results.GEOM.radius,1,'o-','Color',colors.axisL,'LineWidth',2,'Parent',ax);
        set(ax,'XScale','log','XLim',data.geometry.range);
        set(ax,'YLim',[0 1.1],'YTick',0:0.2:1);
        
    case 1        
        isfreqchecked = get(gui.cm_handles.geo_cm_viewfreq,'Checked');        
        switch isfreqchecked            
            case 'on'                
                plot(results.psddata.r,results.psddata.psd,'-','Color',colors.axisL,'LineWidth',2,'Parent',ax);
                xticks = log10(min(results.psddata.r)):1:log10(max(results.psddata.r));
                set(ax,'XScale','log','XLim',[min(results.psddata.r) max(results.psddata.r)],'XTick',10.^xticks);
                set(ax,'YLim',[0 max(results.psddata.psd)*1.1],'YTickMode','auto');
                set(get(ax,'YLabel'),'String','frequency [-]');
                
            case 'off'                
                plot(results.psddata.r,cumsum(results.psddata.psd),'-','Color',colors.axisL,'LineWidth',2,'Parent',ax);
                xticks = log10(min(results.psddata.r)):1:log10(max(results.psddata.r));
                set(ax,'XScale','log','XLim',[min(results.psddata.r) max(results.psddata.r)],'XTick',10.^xticks);
                set(ax,'YLim',[0 1.1],'YTickMode','auto');
                set(get(ax,'YLabel'),'String','cumulative [-]');
                
            otherwise                
                warndlg({'updatePlotsPSD:','Something is utterly wrong.'});
        end        
end

% axis settings
grid(ax,'on');
set(get(ax,'XLabel'),'String','equiv. pore size [m]');

beautifyAxes(gui.figh);
updatePlotsGeometryType(gui.axes_handles.type);

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