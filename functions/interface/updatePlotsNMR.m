function updatePlotsNMR
%updatePlotsNMR plots the forward modeled NMR data in NUCLEUSmod
%
% Syntax:
%       updatePlotsNMR
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsNMR
%
% Other m-files required:
%       clearSingleAxis
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

% axis handle
ax = gui.axes_handles.nmr;
clearSingleAxis(ax);
hold(ax,'on');

if isfield(data.results,'NMR')  
    % drainage and imbibition levels
    indd = data.pressure.DrainLevels;
    indi = data.pressure.ImbLevels;
    
    % NMR data to plot
    NMR = data.results.NMR;
    
    mycol = flipud(parula(128));
    % color for the individual NMR signals
    colindd = getColorIndex(data.results.SAT.Sdfull(indd),128);
    colindi = getColorIndex(data.results.SAT.Sifull(indi),128);
    
    hold(ax,'on');
    switch data.nmr.toplot        
        case 'T1'            
            for i = 1:numel(indd)
                plot(NMR.t,NMR.EdT1(indd(i),:),'-','Color',mycol(colindd(i),:),...
                    'MarkerSize',5,'Parent',ax);
            end
            for i = 1:numel(indi)
                plot(NMR.t,NMR.EiT1(indi(i),:),'--','Color',mycol(colindi(i),:),...
                    'MarkerSize',10,'Parent',ax);
            end
            
        case 'T2'            
            for i = 1:numel(indd)
                plot(NMR.t,NMR.EdT2(indd(i),:),'-','Color',mycol(colindd(i),:),...
                    'MarkerSize',5,'Parent',ax);
            end
            for i = 1:numel(indi)
                plot(NMR.t,NMR.EiT2(indi(i),:),'--','Color',mycol(colindi(i),:),...
                    'MarkerSize',10,'Parent',ax);
            end            
    end
    
    % x-limits
    loglinx = get(gui.cm_handles.nmr_cm_xaxis,'Label');
    switch loglinx
        case 'x-axis -> lin' % log axes
            set(ax,'XScale','log','XLim',[NMR.t(2) max(NMR.t)],'XTickMode','auto');
        case 'x-axis -> log' % lin axes
            set(ax,'XScale','lin','XLim',[0 max(NMR.t)],'XTickMode','auto');
    end
    
    % y-limits
    logliny = get(gui.cm_handles.nmr_cm_yaxis,'Label');
    switch logliny
        case 'y-axis -> lin' % log axes
            set(ax,'YScale','log','YLim',[1e-4 1.01*data.nmr.porosity],'YTick',[1e-4 1e-3 1e-2 1e-1 1]);
        case 'y-axis -> log' % lin axes
            set(ax,'YScale','lin','YLim',[0 1.1*data.nmr.porosity],'YTick',linspace(0,data.nmr.porosity,6));
    end
    
    hold(ax,'off');
    grid(ax,'on');
    
    % axis labels
    set(get(ax,'XLabel'),'String','time [s]');
    if data.nmr.porosity < 1
        set(get(ax,'YLabel'),'String','water content [-]');
    else
        set(get(ax,'YLabel'),'String','amplitude [-]');
    end    
end

beautifyAxes(gui.figh);

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