function updatePlotsGeometryType(ax)
%updatePlotsGeometryType plots the cross-sectional shape as a reference
%
% Syntax:
%       updatePlotsGeometryType
%
% Inputs:
%       ax - axes handle where to plot the geometry
%
% Outputs:
%       none
%
% Example:
%       updatePlotsGeometryType
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
% See also: NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
colors = gui.myui.colors;

% clear the current axis
cla(ax);
hold(ax,'on');

% check the geometry type and plot the cross-sectional shape
if strcmp(data.geometry.type,'cyl') == 1 % cylindrical
    r = data.geometry.modes(1,1);
    phi = linspace(0,2*pi,360);
    x = r.*cos(phi);
    y = r.*sin(phi);
    plot(x,y,'-','Color',colors.axisL,'LineWidth',2,'Parent',ax);
else % right angular & % polygonal
    if numel(data.results.psddata.psd) == 1
        P = data.results.GEOM.Points;
    else
        P = squeeze(data.results.GEOM.Points(1,:,:));
    end
    patch('Vertices',P,'Faces',1:1:size(P,1),'FaceColor','none',...
        'FaceAlpha',0,'EdgeColor',colors.axisL,'LineWidth',2,'Parent',ax);
end

% axis settings
axis(ax,'equal');
axis(ax,'tight');
set(ax,'XScale','lin','XLim',get(ax,'XLim').*[1.3 1.3],'XTick',[]);
set(ax,'XTickLabel','','YTickLabel','','Color','none',...
    'XColor','none','YColor','none');

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