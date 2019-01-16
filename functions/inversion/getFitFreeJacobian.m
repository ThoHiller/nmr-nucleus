function J = getFitFreeJacobian(x,t,flag)
%getFitFreeJacobian calculates the Jacobi matrix for the NMR inversion
%using a free number of relaxation times 'fitDataFree'
%
% Syntax:
%       getFitFreeJacobian(x,t,flag)
%
% Inputs:
%       x - the fittet Amplitudes x(1:2:end) and relaxation times
%           x(2:2:end)
%       t - time vector
%       flag - either 'T1' or 'T2'
%
% Outputs:
%       J - Jacobi matrix with size [length(t) length(x)]
%
% Example:
%       J = getFitFreeJacobian(x,t,'T2')
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

%% init J
J = zeros(length(t),length(x));
switch flag
    case 'T1'
        for i = 1:length(x)/2
            J(:,2*i-1) = 1-exp(-t./x(2*i));
            J(:,2*i) = -( x(2*i-1).*t.*exp(-t./x(2*i)) ) / (x(2*i)^2);
        end
        
    case 'T2'
        for i = 1:length(x)/2
            J(:,2*i-1) = exp(-t./x(2*i));
            J(:,2*i) = ( x(2*i-1).*t.*exp(-t./x(2*i)) ) / (x(2*i)^2);
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