function index = getLambdaFromLCurve(rho,eta,plotit)
%getLambdaFromLCurve estimates the regularization paramater lambda according
%to the curvature of the L-curve
%
% Syntax:
%       getLambdaFromLCurve(rho,eta,plotit)
%
% Inputs:
%       rho - residual norm
%       eta - model norm
%       plotit - plot switch (0 (default) or 1)
%
% Outputs:
%       index - index of optimal lambda
%
% Example:
%       index = getLambdaFromLCurve(rho,eta,0)
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


%% default plot option is 0 ('off')
if nargin < 3
    plotit = 0;
end

% rho and eta as column vectors
rho = rho(:);
eta = eta(:);

% log of rho and eta
lrho = log10(rho);
leta = log10(eta);

phi = zeros(numel(eta)-2,1);
curv = zeros(numel(eta)-2,1);
for i = 2:numel(leta)-1
   % 3 Points
   P1 = [lrho(i-1) leta(i-1)];
   P2 = [lrho(i) leta(i)];
   P3 = [lrho(i+1) leta(i+1)];
   v1 = P1-P2;
   v2 = P3-P2;
   % angle phi and curvature at point P2
   phi(i-1,1) = acosd((dot(v1,v2))/(norm(v1)*norm(v2)));
   % curvature formula 2*sin(phi)/|x-z| with phi being the angle xyz in y
   curv(i-1,1) = 2*sind(phi(i-1,1))/norm(P1-P3);
end
% extend the curvature vector to numel(rho) length
curv = [0;curv;0];
% find maximum curvature
index = find(curv==max(curv));

% plot (optional)
if plotit == 1
    figure;
    loglog(rho ,eta ,'o-'); hold on;
    loglog(rho(index),eta(index),'r+');
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