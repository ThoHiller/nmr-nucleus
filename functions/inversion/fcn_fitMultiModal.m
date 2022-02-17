function F = fcn_fitMultiModal(x,iparam)
%fcn_fitMultiModal is the objective function for N free distribution
%fitting that is minimized with 'lsqnonlin'
%
% Syntax:
%       fcn_fitMultiModal(x,iparam)
%
% Inputs:
%       x - parameter vector
%           x(3*i-2) = mu (relaxation time)
%           x(3*i-1) = sigma (width of distribution)
%           x(3*i) = amp (relative amplitude)
%       iparam - struct that holds additional settings:
%                t : time vector
%                s : signal vector
%                T : relaxation times
%                e : noise vector / error weights (optional)
%
% Outputs:
%       F - residual
%
% Example:
%       F = fcn_fitMultiModal(x,params)
%
% Other m-files required:
%       createKernelMatrix
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

% get all neccessary parameters
flag = iparam.flag;
T1IRfac = iparam.T1IRfac;
nModes = iparam.nModes;
t = iparam.t;
s = iparam.s;
T = iparam.T;
Tb = iparam.Tb;
Td = iparam.Td;

% get the global (combined) RTD distribution
Tdist = 0;
for i = 1:nModes
    mu = exp(x(3*i-2));
    sigma = x(3*i-1);
    amp = x(3*i);
    
    % get the temporary RTD with current mu and sigma
    tmp = 1./( sigma*sqrt(2*pi)).*exp(-((log(T) - log(mu))/ sqrt(2)/sigma).^2);
    
    % scale the temporary RDT to current amplitude
    tmp = (tmp/sum(tmp)) * amp;
    
    % add the current temporary RTD to the global Tdist
    Tdist = Tdist + tmp;   
end

% get the kernel function to calculate the signal out of the global RTD
K = createKernelMatrix(t,T,Tb,Td,flag,T1IRfac);
si = K*Tdist';


% get error weights if available
if isfield(iparam,'e')
    e = iparam.e;
else
    e = ones(size(s));
end

% change output depending on solver
switch iparam.optim
    case 'on' % lsqnonlin
        % scale the residual
        F = e.*(si - s);
    case 'off' % fminsearchbnd
        F = e.*(si - s);
        SSE = sum(F.^2);
        F = SSE;
end

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2022 Thomas Hiller
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