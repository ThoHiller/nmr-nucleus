function K = createKernelMatrix(t,T,Tbulk,Tflag,T1IRfac)
%createKernelMatrix creates a Kernel matrix from signal time vector "t"
%and relaxation time vector "T"
%
% Syntax:
% createKernelMatrix(t,T,Tbulk,Tflag,T1IRflag)
%
% Inputs:
%       t - signal time vector
%       T - relaxation times vector
%       Tbulk - bulk relaxation time
%       Tflag - 'T1' or 'T2'
%       T1IRfac - 1 or 2 (Sat. or Inv. Recovery)
%
% Outputs:
%       K - Kernel matrix size(length(t),length(T))
%
% Example:
%       K = createKernelMatrix(t,T,2,'T1')
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

%% init data
K = zeros(length(t),length(T));
tr = repmat(t(:),[1,numel(T)]);
Tr = repmat(T,[numel(t),1]);

%% calculate K
switch Tflag    
    case 'T1'
        K = 1-T1IRfac.*(exp(-tr./Tr).*exp(-tr./Tbulk));
    case 'T2'              
        K = exp(-tr./Tr).*exp(-tr./Tbulk);
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