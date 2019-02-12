function calculateGeometry
%calculateGeometry calculates the shape dependent geometry parameters
%needed for the forward calculation by NUCLEUSmod
%
% Syntax:
%       calculateGeometry
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       calculateGeometry
%
% Other m-files required:
%       clearAllAxes
%       createPSD
%       getGeometryParameter
%       getPressureRangeFromPSD
%       NUCLEUSmod_updateInterface
%       updatePlotsPSD
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

% when a new geometry is calculated all axes get cleared
clearAllAxes(fig);

% set geometry dependent parameters
switch data.geometry.type    
    case 'cyl' % cylindrical        
        GEOM.type = data.geometry.type;
        
    case 'ang' % rectangular        
        GEOM.type = data.geometry.type;
        data.geometry.alpha = 90;
        data.geometry.gamma = data.geometry.alpha - data.geometry.beta;
        GEOM.angles = [data.geometry.alpha data.geometry.beta data.geometry.gamma];
        
    case 'poly' % polygonal        
        GEOM.type = data.geometry.type;
        GEOM.polyN = data.geometry.polyN;        
end

% switch depending on whether a single pore or a pore size distribution is
% used
switch data.geometry.ispsd    
    case 0 % single pore        
        psddata.psd = 1;
        psddata.r = data.geometry.modes(1,1);
        
        % the range should extent the desired the size by two orders of
        % magnitude in both directions
        minval = 10^(floor(log10(psddata.r))-2);
        maxval = 10^(ceil(log10(psddata.r))+2);
        data.geometry.range = [minval maxval];
        
    case 1 % PSD        
        modesN = data.geometry.modesN;
        mymodes = data.geometry.modes(1:modesN,:);
        mymodes(:,1) = mymodes(:,1);
        N = data.geometry.rangeN;        
        psddata = createPSD(data.geometry.range,mymodes,N,1);        
end

% the global output variable with geometry data for all radii
GEOM.radius = psddata.r';
GEOM = getGeometryParameter(GEOM);
% update the global data structure
data.results.psddata = psddata;
data.results.GEOM = GEOM;
% get pressure range values from PSD range
prange = getPressureRangeFromPSD(GEOM,psddata);
data.pressure.range = prange;
% update the GUI data
setappdata(fig,'data',data);
% update the interface
NUCLEUSmod_updateInterface;
% update the axes
updatePlotsPSD;

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