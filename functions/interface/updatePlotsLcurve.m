function updatePlotsLcurve
%updatePlotsLcurve plots the results of the L-curve calculation
%in NUCLEUSinv
%
% Syntax:
%       updatePlotsLcurve
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsLcurve
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
% See also: NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
% get colors
col = gui.myui.colors;

% get data
nmrraw = data.results.nmrraw;
nmrproc = data.results.nmrproc;
if isfield(data.results,'lcurve')
    lc = data.results.lcurve;
end

%% L-Curve
ax = gui.axes_handles.rtd;
clearSingleAxis(ax);
hold(ax,'on');
set(gui.cm_handles.axes_rtd_view,'Enable','off');

loglog(lc.RN,lc.XN,'o-','Color',col.RE,'Parent',ax);
loglog(lc.RN(lc.index),lc.XN(lc.index),'r+','Parent',ax);
% limits
set(ax,'XScale','log','XLim',[min(lc.RN)*0.95 max(lc.RN)*1.05]);
set(ax,'YScale','log','YLim',[min(lc.XN)*0.95 max(lc.XN)*1.05]);
% labels
set(get(ax,'XLabel'),'String','residual norm |Gm-d|_{2}');
set(get(ax,'YLabel'),'String','model norm |Lm|_{2}');
text(10^mean(log10(get(ax,'XLim'))),10^mean(log10(get(ax,'YLim'))),...
    ['\lambda=',sprintf('%4.3e',lc.lambda(lc.index))],'Parent',ax,'FontSize',12);
% grid
grid(ax,'on');


%% RMS
ax = gui.axes_handles.psd;
clearSingleAxis(ax);
hold(ax,'on');
set(gui.cm_handles.axes_psd_view,'Enable','off');

loglog(lc.lambda,lc.RMS,'o-','Color',col.RE,'Parent',ax);
loglog(lc.lambda(lc.index),lc.RMS(lc.index),'r+','Parent',ax);
% limits
ticks = log10(min(lc.lambda)):1:log10(max(lc.lambda));
set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],...
    'XTick',10.^ticks);

% noise level
if nmrproc.noise > 0
    line(get(ax,'XLim'),[nmrproc.noise nmrproc.noise],'LineStyle','--',...
        'Color',[0.5 0.5 0.5],'Parent',ax);
    text(10^(ticks(end)),nmrproc.noise*1.1,'noise level  ','FontSize',11,...
        'HorizontalAlignment','right','Parent',ax);
    set(ax,'YScale','log','YLim',[min([min(lc.RMS) nmrproc.noise])*0.75 max(lc.RMS)*1.1]);
else
    set(ax,'YScale','log','YLim',[min(lc.RMS)*0.75 max(lc.RMS)*1.1]);
end

% labels
set(get(ax,'XLabel'),'String','regularization parameter \lambda');
set(get(ax,'YLabel'),'String','RMS');
text(10^mean(log10(get(ax,'XLim'))),10^mean(log10(get(ax,'YLim'))),...
    ['\lambda=',sprintf('%4.3e',lc.lambda(lc.index))],'Parent',ax,'FontSize',12);
% grid
grid(ax,'on');

% finalize
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