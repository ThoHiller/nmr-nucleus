function out = runLcurveIterative(lparam,iparam,gui)
%runLcurveIterative performs an iterative L-curve calculation. This routine
%uses the iterative L-curve approach described in Cultrera, 2020, IOP
%SciNotes, Vol. 1 (No. 2) 025004, https://doi.org/10.1088/2633-1357/abad0d
%
% Syntax:
%       out = runLcurveIterative(lparam,iparam,gui)
%
% Inputs:
%       lparam - struct with l-curve settings
%       iparam - struct with inversion settings
%       gui - main NUCLEUS gui struct
%
% Outputs:
%       out - struct holding output data
%
% Example:
%       out = runLcurveIterative(lparam,iparam,gui)
%
% Other m-files required:
%       displayStatusText
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

% status bar information
infostring = 'L-curve calculation ... ';
displayStatusText(gui,infostring);

% init lambda1 and lambda4
l1 = lparam.lambda_range(1);
l4 = lparam.lambda_range(2);
% termination threshold
epsilon = 0.01;
% define golden ratio phi
phi = (1+sqrt(5))/2;
% get lambda2 and lambda3
l2 = 10^((log10(l4)+phi*log10(l1))/(1+phi));
l3 = 10^(log10(l1)+(log10(l4)-log10(l2)));

% first four lambda values
lam = [l1 l2 l3 l4];
CHI2 = zeros(size(lam));
XN = zeros(size(lam));
RN = zeros(size(lam));

for i = 1:length(lam)
    switch lparam.dim
        case 1
            iparam.lambda = lam(i);
            invdata = lparam.func(lparam.t,lparam.s,iparam);           
        case 2
            iparam.lamT1 = lparam.lambdaFactor*lam(i);
            iparam.lamT2 = lam(i);
            invdata = lparam.func(lparam.data,iparam);
    end
    % output data
    CHI2(i) = invdata.chi2;
    RN(i) = invdata.rn;
    XN(i) = invdata.xn;
end

% temporarily store them
lc.lambda = lam;
lc.RMS = CHI2;
lc.RN = RN;
lc.XN = XN;

P(:,1) = RN;
P(:,2) = XN;

% start iterating
keep_running = true;
count = 0;
while keep_running

    % calculate curvature
    C2 = getMengerCurvature(P(1:3,:));
    C3 = getMengerCurvature(P(2:4,:));

    if C3 <= 0
        % disp('C3 < 0');
        c3smaller0 = true;
        while c3smaller0
            count = count + 1;
            lam(4) = lam(3);
            P(4,:) = P(3,:);
            lam(3) = lam(2);
            P(3,:) = P(2,:);
            lam(2) = 10^((log10(lam(4))+phi*log10(lam(1)))/(1+phi));
            switch lparam.dim
                case 1
                    iparam.lambda = lam(2);
                    invdata = lparam.func(lparam.t,lparam.s,iparam);
                case 2
                    iparam.lamT1 = lparam.lambdaFactor*lam(i);
                    iparam.lamT2 = lam(i);
                    invdata = lparam.func(lparam.data,iparam);
            end
            % output data
            P(2,1) = invdata.rn;
            P(2,2) = invdata.xn;
            C3 = getMengerCurvature(P(2:4,:));
            % disp(['C3 iter:', num2str(C3)]);
            lc.lambda = [lc.lambda lam(2)];
            lc.RMS = [lc.RMS invdata.chi2];
            lc.RN = [lc.RN invdata.rn];
            lc.XN = [lc.XN invdata.xn];

            if C3 > 0
                c3smaller0 = false;
            end
        end
    end

    if C2 > C3
        % disp('C2 > C3');
        lam_opt = lam(2);
        lam(4) = lam(3);
        P(4,:) = P(3,:);
        lam(3) = lam(2);
        P(3,:) = P(2,:);
        lam(2) = 10^((log10(lam(4))+phi*log10(lam(1)))/(1+phi));
        switch lparam.dim
            case 1
                iparam.lambda = lam(2);
                invdata = lparam.func(lparam.t,lparam.s,iparam);
            case 2
                iparam.lamT1 = lparam.lambdaFactor*lam(2);
                iparam.lamT2 = lam(2);
                invdata = lparam.func(lparam.data,iparam);
        end
        % output data
        P(2,1) = invdata.rn;
        P(2,2) = invdata.xn;
        lc.lambda = [lc.lambda lam(2)];
        lc.RMS = [lc.RMS invdata.chi2];
        lc.RN = [lc.RN invdata.rn];
        lc.XN = [lc.XN invdata.xn];
    else
        % disp('C2 < C3');
        lam_opt = lam(3);
        lam(1) = lam(2);
        P(1,:) = P(2,:);
        lam(2) = lam(3);
        P(2,:) = P(3,:);
        lam(3) = 10^(log10(lam(1))+(log10(lam(4))-log10(lam(2))));
        switch lparam.dim
            case 1
                iparam.lambda = lam(3);
                invdata = lparam.func(lparam.t,lparam.s,iparam);
            case 2
                iparam.lamT1 = lparam.lambdaFactor*lam(3);
                iparam.lamT2 = lam(3);
                invdata = lparam.func(lparam.data,iparam);
        end
        % output data
        P(3,1) = invdata.rn;
        P(3,2) = invdata.xn;
        lc.lambda = [lc.lambda lam(3)];
        lc.RMS = [lc.RMS invdata.chi2];
        lc.RN = [lc.RN invdata.rn];
        lc.XN = [lc.XN invdata.xn];
    end
    count = count + 1;

    % GUI feedback
    displayStatusText(gui,[infostring,' iteration: ',...
        num2str(count),' lambda opt: ',num2str(lam_opt)]);

    % check epsilon
    if (lam(4)-lam(1))/lam(4) < epsilon
        keep_running = false;
    end
end

[~,ix] = sort(lc.lambda);
% get optimal lambda index within sorted lambda values
out.index = find(ix==numel(lc.lambda));
out.lambda = lc.lambda(ix);
out.RMS = lc.RMS(ix);
out.RN = lc.RN(ix);
out.XN = lc.XN(ix);

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2025 Thomas Hiller
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