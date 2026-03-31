function [index,varargout] = getLambdaFromLCurve(rho,eta,lam,plotit)
%getLambdaFromLCurve estimates the regularization parameter lambda according
%to the curvature of the L-curve
%
% Syntax:
%       getLambdaFromLCurve(rho,eta,lam,plotit)
%
% Inputs:
%       rho - residual norm
%       eta - model norm
%       lam - lambda values
%       plotit - plot switch (0 (default) or 1)
%
% Outputs:
%       index - index of optimal lambda
%
% Example:
%       index = getLambdaFromLCurve(rho,eta,lambda_range,0)
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

% rho and eta as column vectors
rho = rho(:);
eta = eta(:);

% log of rho and eta
% rho = log10(rho);
% eta = log10(eta);

phi = zeros(numel(eta)-2,1);
curv = zeros(numel(eta)-2,1);
for i = 2:numel(eta)-1
   % 3 Points
   P1 = [rho(i-1) eta(i-1)];
   P2 = [rho(i) eta(i)];
   P3 = [rho(i+1) eta(i+1)];
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
    f0 = figure; clf(f0);
    ax1 = subplot(211,'Parent',f0);
    hold(ax1,'on');
    loglog(rho ,eta ,'o-','Parent',ax1);
    loglog(rho(index),eta(index),'r+','MarkerSize',12,'Parent',ax1);
    set(ax1,'XScale','log','YScale','log');
    xlabel('residual norm |Gm-d|_2');
    ylabel('model norm |Lm|_2');

    ax2 = subplot(212,'Parent',f0);
    hold(ax2,'on');
    plot(lam,curv,'o-','Parent',ax2);
    plot(lam(index),curv(index),'rx','MarkerSize',12,'Parent',ax2);
    set(ax2,'XScale','log');
    xlabel('regularization parameter \lambda');
    ylabel('curvature');
    
    % alternative approach
    % rr = rho - min(rho);
    % ee = eta - min(eta);
    % rr = rr./max(rr);
    % ee = ee./max(ee);
    % ss = rr+ee;
    % ax3 = subplot(313,'Parent',f0);
    % hold(ax3,'on');
    % plot(lam,rr,'-','DisplayName','rn','Parent',ax3);
    % plot(lam,ee,'-','DisplayName','xn','Parent',ax3);
    % plot(lam,ss,'-','DisplayName','rn+xn','Parent',ax3);
    % indx = find(ss==min(ss));    
    % plot(lam(indx),ss(indx),'kx','MarkerSize',12,'DisplayName','min(rn+xn)','Parent',ax3);
    % plot(lam(index),ss(index),'rx','MarkerSize',12,'DisplayName','min(Lcurve)','Parent',ax3);
    % set(ax3,'XScale','log');
    % lh = legend(ax3);
    % set(lh,'FontSize',10);
end

if nargout > 1
    varargout{1} = rho;
    varargout{2} = eta;
    varargout{3} = curv;
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