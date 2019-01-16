function calculateNMRporosity
%calculateNMRporosity rescales the NMR signals from saturation (0,1) to
%water content by multiplying with the given porosity value
%
% Syntax:
%       calculateNMRporosity
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       calculateNMRporosity
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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','MOD');
data = getappdata(fig,'data');

%% only proceed if the porosity is smaller than 1
if data.nmr.porosity < 1
    data.results.NMR.EiT1 = data.nmr.porosity.*data.results.NMR.raw.EiT1;
    data.results.NMR.EdT1 = data.nmr.porosity.*data.results.NMR.raw.EdT1;
    data.results.NMR.EiT2 = data.nmr.porosity.*data.results.NMR.raw.EiT2;
    data.results.NMR.EdT2 = data.nmr.porosity.*data.results.NMR.raw.EdT2;
else
    % reset the NMR signals with the raw data (without noise)
    data.results.NMR.EiT1 = data.results.NMR.raw.EiT1;
    data.results.NMR.EdT1 = data.results.NMR.raw.EdT1;
    data.results.NMR.EiT2 = data.results.NMR.raw.EiT2;
    data.results.NMR.EdT2 = data.results.NMR.raw.EdT2;
end

% save the porosity value
data.results.NMR.porosity = data.nmr.porosity;
% update the GUI data
setappdata(fig,'data',data);

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