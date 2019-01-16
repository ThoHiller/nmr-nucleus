function isatlevels = getSaturationLevelData(SAT,satlevels,imbdrain)
%getSaturationLevelData finds the indices on the capillary pressure saturation
%(CPS) curve at given saturations 'satlevels'.
%
% Syntax:
%       getSaturationLevelData(SAT,satlevels,imbdrain)
%
% Inputs:
%       SAT - structure (output from 'getSaturationfromPressure')
%       satlevels - saturation levels
%       imbdrain - string indicating if a NMR signal is from the drainage
%                  or imbibition branch (e.g. 'DDID')
%
% Outputs:
%       isatlevels - indices on the CPS curve
%
% Example:
%       isatlevels = getSaturationLevelData(SAT,[1 0.8 0.5],'DDI')
%           -> will find the indices on the CPSC at 100%(D-drainage),
%              80%(D-drainage) and 50%(I-imbibition) saturation
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
% See also:
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% check if the sizes match
if numel(satlevels) == numel(imbdrain)    
    isatlevels = zeros(size(satlevels));
    for i = 1:numel(satlevels)
        if satlevels(i) == 1
            % full saturation should be the first one
            isatlevels(i) = 1;
        else
            % partial saturation
            if strcmp(imbdrain(i),'D') % either drainage
                isatlevels(i) = find(min(abs(SAT.Sdfull-satlevels(i)))==abs(SAT.Sdfull-satlevels(i)),1,'first');
            elseif strcmp(imbdrain(i),'I') % or imbibition
                isatlevels(i) = find(min(abs(SAT.Sifull-satlevels(i)))==abs(SAT.Sifull-satlevels(i)),1,'first');
            end
        end
    end
    
else
    disp('ERROR in getSaturationLevelData: satlevels and imbdrain do not have the same length.');
    isatlevels = [];
end

return

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