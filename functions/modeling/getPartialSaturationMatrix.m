function IPS = getPartialSaturationMatrix(SatData,indt,imbdrain)
%getPartialSaturationMatrix calculates the partial saturation matrix to be
%used by the joint inversion. It has the size of the NMR kernel matrix and
%values between 0 and 1 to indicate the saturation.
%
% Syntax:
%       getPartialSaturationMatrix(SatData,indt,imbdrain)
%
% Inputs:
%       SatData - structure (output from 'getSaturationfromPressure')
%       indt - number of echoes/points per NMR signal
%       imbdrain - string indicating if a NMR signal is from the drainage
%                  or imbibition branch (e.g. 'DDID')
%
% Outputs:
%       IPS - partial saturation matrix (values between 0 and 1)
%
% Example:
%       IPS = getPartialSaturationMatrix(SatData,indt,imbdrain)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% allocate memory for IPS matrix
IPS = zeros(sum(indt),size(SatData.Sd,2));

%% assemble the matrix
for i = 1:numel(imbdrain)
    if i == 1
        if strcmp(imbdrain(i),'D') % drainage
            IPS(1:indt(1),:) = repmat(SatData.Sd(i,:),indt(1),1);
        elseif strcmp(imbdrain(i),'I') % imbibition
            IPS(1:indt(1),:) = repmat(SatData.Si(i,:),indt(1),1);
        end
    else
        if strcmp(imbdrain(i),'D') % drainage
            IPS(sum(indt(1:i-1))+1:sum(indt(1:i)),:) = repmat(SatData.Sd(i,:),indt(i),1);
        elseif strcmp(imbdrain(i),'I') % imbibition
            IPS(sum(indt(1:i-1))+1:sum(indt(1:i)),:) = repmat(SatData.Si(i,:),indt(i),1);
        end
    end
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