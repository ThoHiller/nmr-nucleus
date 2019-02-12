function updatePlotsCPS
%updatePlotsCPS plots the CPS curve into the corresponding NUCLEUSmod axis
%
% Syntax:
%       updatePlotsCPS
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsCPS
%
% Other m-files required:
%       none
%
% Subfunctions:
%       plotSaturationLevelsCPS
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

% only proceed if there is cps data
if isfield(data.results,'SAT')
    % get the cps axis handle
    ax = gui.axes_handles.cps;
    % clear previously plotted data
    ph = findall(ax,'Tag','SatPoints');
    if ~isempty(ph)
        set(ph,'HandleVisibility','on')
    end
    cla(ax);
    
    % get pressure
    SAT = data.results.SAT;    
    plotpress = SAT.pressure .* data.pressure.unitfac;
    xlstring = ['pressure [',data.pressure.unit,']'];
    
    % plot the cps data
    hold(ax,'on');
    plot(plotpress,SAT.Sdfull,'k-','LineWidth',2,'Parent',ax);
    plot(plotpress,SAT.Sifull,'k--','LineWidth',2,'Parent',ax);
    
    % depending on the pressure spacing adjust the x-axis
    switch data.pressure.loglin
        case 0 % lin
            set(ax,'XScale','lin','XTickMode','auto');
            set(ax,'XLim',[plotpress(1) plotpress(end)]);
        case 1 % log
            set(ax,'XScale','log');
            xticks = log10(plotpress(1)):1:log10(plotpress(end));
            set(ax,'XLim',[plotpress(1) plotpress(end)],'XTick',10.^xticks);
    end
    
    % y-axis
    set(ax,'YLim',[-0.1 1.1],'YTick',0:0.25:1);
    grid(ax,'on');
    % labels and legend
    set(get(ax,'XLabel'),'String',xlstring);
    set(get(ax,'YLabel'),'String','saturation [-]');
    legend(ax,'drain','imb','Location','best')
    % update GUI data
    setappdata(fig,'gui',gui);
    % now add the saturation level points on the curves
    plotSaturationLevelsCPS(data,ax);
end

end

%%
function plotSaturationLevelsCPS(data,ax)

% get saturation and pressure
SAT = data.results.SAT;
plotpress = SAT.pressure .* data.pressure.unitfac;

% clear previously plotted points
ph = findall(ax,'Tag','SatPoints');
if ~isempty(ph)
    set(ph,'HandleVisibility','on')
    delete(ph);
end

% get the different levels
indd = data.pressure.DrainLevels;
indi = data.pressure.ImbLevels;

% get the index on the colormap
mycol = flipud(parula(128));
colindd = getColorIndex(SAT.Sdfull(indd),128);
colindi = getColorIndex(SAT.Sifull(indi),128);
% and plot the points on the CPS curve
for i = 1:numel(indd)
    plot(plotpress(indd(i)),SAT.Sdfull(indd(i)),'s','Color',mycol(colindd(i),:),...
        'MarkerSize',8,'Parent',ax,'HandleVisibility','off','Tag','SatPoints');
end
for i = 1:numel(indi)
    plot(plotpress(indi(i)),SAT.Sifull(indi(i)),'o','Color',mycol(colindi(i),:),...
        'MarkerSize',8,'Parent',ax,'HandleVisibility','off','Tag','SatPoints');
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