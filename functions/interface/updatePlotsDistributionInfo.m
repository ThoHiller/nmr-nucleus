function updatePlotsDistributionInfo
%updatePlotsDistributionInfo plots cut-offs and diffusion regime lines
%into the RTD and PSD axes of NUCLEUSinv
%
% Syntax:
%       showParameterInfo
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       showParameterInfo
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
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% check for uncertainty data
hasUncert = false;
if isfield(data,'results') && isfield(data.results,'invstd') && ...
        isfield(data.results.invstd,'uncert')
    hasUncert = true;
    uncert = data.results.invstd.uncert;
end

% default color
col = gui.myui.colors.axisL;

% RTD axis
ax = gui.axes_handles.rtd;

if hasUncert
    % uncertainty RTD calculation range
    rtd_range = uncert.statistics.RTD_bounds;
    rtd_range0 = data.invstd.time;
    yy = get(ax,'YLim');

    if rtd_range(1) > rtd_range0(1)
        line([rtd_range(1) rtd_range(1)],[yy(1) yy(2)],'Color',[0.25 0.25 0.25],...
            'LineStyle','-.','LineWidth',2,'Parent',ax,'Tag','infolines',...
            'HandleVisibility','off');
        text(rtd_range(1), yy(2)*0.5,'uncert stat bounds','Color',[0.25 0.25 0.25],...
            'FontSize',12,'Rotation',90,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','Tag','infolines','Parent',ax);
    end

    if rtd_range(2) < rtd_range0(2)
        line([rtd_range(2) rtd_range(2)],[yy(1) yy(2)],'Color',[0.25 0.25 0.25],...
            'LineStyle','-.','LineWidth',2,'Parent',ax,'Tag','infolines',...
            'HandleVisibility','off');
        text(rtd_range(2), yy(2)*0.5,'uncert stat bounds','Color',[0.25 0.25 0.25],...
            'FontSize',12,'Rotation',90,'HorizontalAlignment','center',...
            'VerticalAlignment','top','Tag','infolines','Parent',ax);
    end

else
    % CUT OFF info
    % time-scale dependent scaling
    switch data.process.timescale
        case 's'
            CBW = data.param.CBWcutoff/1000;
            BVI = data.param.BVIcutoff/1000;
        case 'ms'
            CBW = data.param.CBWcutoff;
            BVI = data.param.BVIcutoff;
    end

    xx = get(ax,'XLim');
    yy = get(ax,'YLim');
    line([CBW CBW],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
        'LineWidth',2,'Parent',ax,'Tag','infolines','HandleVisibility','off');
    line([BVI BVI],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
        'LineWidth',2,'Parent',ax,'Tag','infolines','HandleVisibility','off');

    if CBW > xx(1)
        xx1 = mean([log10(xx(1)) log10(CBW)]);
        text(10^xx1, yy(2)*0.9,'CBW','Color',col,...
            'FontSize',16,'HorizontalAlignment','center','Parent',ax,...
            'Tag','infolines');
    end
    if BVI > xx(1)
        if CBW > xx(1)
            xx2 = mean([log10(CBW) log10(BVI)]);
        else
            xx2 = mean([log10(xx(1)) log10(BVI)]);
        end
        text(10^xx2, yy(2)*0.9,'BVI','Color',col,...
            'FontSize',16,'HorizontalAlignment','center','Parent',ax,...
            'Tag','infolines');
    end
    if BVI < xx(2)
        xx3 = mean([log10(BVI) log10(xx(2))]);
        text(10^xx3, yy(2)*0.9,'BVM','Color',col,...
            'FontSize',16,'HorizontalAlignment','center','Parent',ax,...
            'Tag','infolines');
    end
end

% check for lsqlin "EchoFlag" and plot an info line if available
if strcmp(data.invstd.invtype,'NNLS') && ...
        strcmp(data.results.invstd.invparams.EchoFlag,'on')

    TEmin = data.results.nmrproc.t(1);
    rtd_range0 = data.invstd.time;
    yy = get(ax,'YLim');

    if TEmin/5 > rtd_range0(1)
        line([TEmin/5 TEmin/5],[yy(1) yy(2)],'Color',gui.myui.colors.RE,...
            'LineStyle','-.','LineWidth',2,'Parent',ax,'Tag','infolines',...
            'HandleVisibility','off');
        text(TEmin/5, yy(2)*0.5,'RTD<TE/5=0','Color',gui.myui.colors.RE,...
            'FontSize',12,'Rotation',90,'HorizontalAlignment','center',...
            'VerticalAlignment','bottom','Tag','infolines','Parent',ax);
    end
end


% diffusion regime info
% PSD axis
ax = gui.axes_handles.psd;

% surface relaxivity in [m/s]
rho = data.param.rho/1e6;
% diffusion coeff. of water [m^2/s]
D = 2.1e-9;
fast = 1*D/rho; % [m]
slow = 10*D/rho; % [m]
switch data.process.timescale
    case 'ms'
        fast = fast*1e3;
        slow = slow*1e3;
    otherwise
        % nothing to do
end

xx = get(ax,'XLim');
yy = get(ax,'YLim');
line([fast fast],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
    'LineWidth',2,'Parent',ax,'Tag','infolines','HandleVisibility','off');
line([slow slow],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
    'LineWidth',2,'Parent',ax,'Tag','infolines','HandleVisibility','off');

if fast > xx(1)
    xx2 = mean([log10(xx(1)) log10(fast)]);
    text(10^xx2, yy(2)*0.9,'fast','Color',col,...
        'FontSize',16,'HorizontalAlignment','center','Parent',ax,...
        'Tag','infolines');
end
if slow < xx(2)
    xx3 = mean([log10(slow) log10(xx(2))]);
    text(10^xx3, yy(2)*0.9,'slow','Color',col,...
        'FontSize',16,'HorizontalAlignment','center','Parent',ax,...
        'Tag','infolines');
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