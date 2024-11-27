function [Kreg,dat_inp,L,LD] = applyRegularization2D(K,order,Tvec,Dvec,indices,dat_vec,lambda)
%applyRegularization applies a manual regularization to the kernel matrix K
%
% Syntax:
%       applyRegularization2D(K,order,Tvec,Dvec,indices,dat_vec,lambda)
%
% Inputs:
%       K - Kernel matrix
%       order - smoothness constraint: '0', '1' or '2' for both dimensions
%               the same so far
%       Tvec - relaxation time vector: here T2
%       Dvec - diffusion / relaxation time vector: here T1
%       indices - struct holding tile indices
%       dat_vec - signal vector
%       lambda - 1x2 vector holding lambda for both dimensions
%
% Outputs:
%       Kreg - expanded (regularized) Kernel matrix
%       dat_inp - expanded signal vector
%       L - smoothness matrix regarding T dim
%       LD - smoothness matrix regarding D dim
%
% Example:
%       [Kreg,dat_inp,~,~] = applyRegularization2D(K,order,T2vec,T1vec,indices,dat_vec,lambda)
%
% Other m-files required:
%       get_l (from Regularization toolbox)
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

%% get lambda values
lamT = lambda(2); % T2
lamD = lambda(1); % T1

%% get column indices
col_end = indices.col_end;

% get first smoothness matrix
L = get_l(length(Tvec)*length(Dvec),order);

% regularization along first dimension, normally Tvec (here T2)
% loop necessary to correct the transitions among the tiles
for n = 1:length(Dvec)-1
        L(col_end(n)-order+1:col_end(n),col_end(n)+1:col_end(n)+order) = zeros(order);  
end
% first expanded kernel matrix
KregT = [K;lamT * L];

% regularization along second dimension, normally D (here T1)
LD = zeros(size(L,1)-order*length(Tvec),size(L,2));
for no = 1:order + 1
    for n = 1:size(LD,2) - (order) * length(Tvec)
         LD(n,n+(no-1)*length(Tvec)) = L(1,no); 
    end
end
% final expanded kernel matrix
Kreg = [KregT;lamD * LD];

% expanded data vector
dat_inp = dat_vec;
dat_inp(length(dat_vec)+1:length(dat_vec)+size(L,1)+size(LD,1),1) = 0;

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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


        
        
