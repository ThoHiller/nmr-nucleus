function updatePlotsIterChi
%updatePlotsIterChi plots the results of the chi2 iteration
%in NUCLEUSinv
%
% Syntax:
%       updatePlotsIterChi
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsIterChi
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get colors
col = gui.myui.colors;

% get NMR data
nmrraw = data.results.nmrraw;
nmrproc = data.results.nmrproc;
if isfield(data.results,'iterchi2')
    lc = data.results.iterchi2;
end

%% chi square plot
ax = gui.axes_handles.rtd;
clearSingleAxis(ax);
hold(ax,'on');
set(gui.cm_handles.axes_rtd_view,'Enable','off');

plot(1:numel(lc.lambda),abs(1-lc.chi2),'o-','Color',col.RE,'Parent',ax);
% limits
set(ax,'XScale','lin','XLim',[0.5 numel(lc.lambda)+0.5],'XTickMode','auto');
set(ax,'YScale','log',...
    'YLim',[10^floor(log10(min(abs(1-lc.chi2)))) 10^ceil(log10(max(abs(1-lc.chi2))))]);
set(ax,'YScale','log');

line(get(ax,'XLim'),[lc.chitol lc.chitol],'LineStyle','--',...
        'Color',[0.5 0.5 0.5],'Parent',ax);
text(0.5,lc.chitol,'  chi tol.','FontSize',11,...
        'VerticalAlignment','bottom','HorizontalAlignment','left','Parent',ax);
% labels
set(get(ax,'XLabel'),'String','number of iterations');
set(get(ax,'YLabel'),'String','|1-\chi^2|');
text(10^mean(log10(get(ax,'XLim'))),10^mean(log10(get(ax,'YLim'))),...
    ['\lambda=',sprintf('%5.4e',lc.lambda(end))],'Parent',ax,'FontSize',12);
% grid
grid(ax,'on');


%% RMS plot
ax = gui.axes_handles.psd;
clearSingleAxis(ax);
hold(ax,'on');
set(gui.cm_handles.axes_psd_view,'Enable','off');

plot(1:numel(lc.lambda),lc.RMS,'o-','Color',col.RE,'Parent',ax);
% limits
set(ax,'XScale','lin','XLim',[0.5 numel(lc.lambda)+0.5],'XTickMode','auto');

% noise level
if nmrproc.noise > 0
    line(get(ax,'XLim'),[nmrproc.noise nmrproc.noise],'LineStyle','--',...
        'Color',[0.5 0.5 0.5],'Parent',ax);
    text(numel(lc.lambda),nmrproc.noise,'noise level  ','FontSize',11,...
        'VerticalAlignment','bottom','HorizontalAlignment','right','Parent',ax);
    set(ax,'YScale','log','YLim',[min([min(lc.RMS) nmrproc.noise])*0.75 max(lc.RMS)*1.1]);
else
    set(ax,'YScale','log','YLim',[min(lc.RMS)*0.75 max(lc.RMS)*1.1]);
end

% labels
set(get(ax,'XLabel'),'String','number of iterations');
set(get(ax,'YLabel'),'String','RMS');
% grid
grid(ax,'on');

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