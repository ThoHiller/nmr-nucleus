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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% default color is grey
col = [0.5 0.5 0.5];

%% CUT OFF info
% RTD axis
ax = gui.axes_handles.rtd;

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
    'LineWidth',2,'Parent',ax,'Tag','infolines');
line([BVI BVI],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
    'LineWidth',2,'Parent',ax,'Tag','infolines');

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

%% diffusion regime info
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
    'LineWidth',2,'Parent',ax,'Tag','infolines');
line([slow slow],[yy(1) yy(2)],'Color',col,'LineStyle','--',...
    'LineWidth',2,'Parent',ax,'Tag','infolines');

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