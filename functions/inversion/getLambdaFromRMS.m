function index = getLambdaFromRMS(lambda,rms,plotit)
%getLambdafromRMS estimates the regularization parameter lambda according
%to the RMS-error of the corresponding lambda value ... it is a kind of
%quick and dirty approach and does not always give the optimal value
%
% Syntax:
%       getLambdaFromRMS(lambda,rms,plotit)
%
% Inputs:
%       lambda - range of lambda values
%       rms - corresponding rms values
%       plotit - plot switch (0 (default) or 1)
%
% Outputs:
%       index - index of optimal lambda
%
% Example:
%       index = getLambdaFromRMS(lambda,rms,0)
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


%% default plot option is 0 ('off')
if nargin < 3
    plotit = 0;
end

% lambda and rms as column vectors
lambda = lambda(:);
rms = rms(:);

% ratio between adjacent rms values
ratio = 1 - (rms(1:end-1)./rms(2:end));

% spread of the rms values
spread = round(max(rms)/min(rms));
% threshold value
thresh = spread*1e-3;
% index of optimal lambda
index = find(ratio>thresh,1,'first');

% plot (optional)
if plotit == 1
    figure;
    semilogx(10.^lambda ,rms ,'o-'); hold on;
    semilogx(10.^lambda(index),rms(index),'r+');
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