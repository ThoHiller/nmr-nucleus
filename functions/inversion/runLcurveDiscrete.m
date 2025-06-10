function out = runLcurveDiscrete(lparam,iparam,gui)
%runLcurevDiscrete performs a L-curev calculation at discrete lambda values
%
% Syntax:
%       out = runLcurveDiscrete(lparam,iparam,gui)
%
% Inputs:
%       lparam
%       iparam
%       gui
%
% Outputs:
%       out
%
% Example:
%       out = runLcurveDiscrete(lparam,iparam,gui)
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

% init output variables
CHI2 = zeros(size(lparam.lambda_range));
XN = zeros(size(lparam.lambda_range));
RN = zeros(size(lparam.lambda_range));

% status bar information
infostring = 'L-curve calculation ... ';
displayStatusText(gui,infostring);

% the L-curve calculation
for i = 1:length(lparam.lambda_range)
    switch lparam.dim
        case 1
            iparam.lambda = lparam.lambda_range(i);
            invdata = lparam.func(lparam.t,lparam.s,iparam);            
        case 2
            iparam.lamT1 = lparam.lambdaFactor*lparam.lambda_range(i);
            iparam.lamT2 = lparam.lambda_range(i);
            invdata = lparam.func(lparam.data,iparam);
    end

    % output data
    CHI2(i) = invdata.chi2;
    RN(i) = invdata.rn;
    XN(i) = invdata.xn;
    
    % GUI feedback
    displayStatusText(gui,[infostring,...
        num2str(i),' / ',num2str(numel(lparam.lambda_range)),...
        ' lambda: ',num2str(lparam.lambda_range(i))]);
end

% get optimal lambda
out.index = getLambdaFromLCurve(RN,XN,0);
out.lambda = lparam.lambda_range;
out.RMS = CHI2;
out.RN = RN;
out.XN = XN;

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