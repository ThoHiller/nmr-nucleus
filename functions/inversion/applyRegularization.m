function [Kreg,lambda] = applyRegularization(K,g,L,lambda_in,flag,order,noise_level)
%applyRegularization applies regularization procedures from the
%Regularization toolbox from P. Hansen -- for all methods (except "manual")
%the regularization parameter lambda is determined by different criterias
%and using a SVD
%
% Syntax:
%       applyRegularization(K,g,L,lambda_in,flag,order,noise_level)
%
% Inputs:
%       K - Kernel matrix
%       g - signal
%       lambda_in - regularization parameter
%       flag - flag for regularization method:
%              'manual', 'gcv_tikh', 'gcv_trunc', 'gcv_damp', 'discrep', 
%       order - smoothnes constraint: '0', '1' or '2'
%       noise_level - noise level for 'discrep' method (discrepancy principle)
%
% Outputs:
%       Kreg - expanded (regularized) Kernel matrix
%       lambda - determined lambda
%
% Example:
%       [Kr,lam] = applyRegularization(K,s,L,lambdain,flag,Lorder,noise)
%
% Other m-files required:
%       Regularization Toolbox
%       csvd
%       cgsvd
%       gcv
%       discrep
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

switch flag    
    case 'manual'
        Kreg = [K;lambda_in*L];
        lambda = lambda_in;
        
    case 'gcv_tikh'
        if order == 0
            [U,s,~] = csvd(K);
            [lambda,~,~] = gcv(U,s,g,'tikh',0);
        else
            [U,s,~,~,~] = cgsvd(K,L);
            [lambda,~,~] = gcv(U,s,g,'tikh',0);            
        end
        Kreg = [K;lambda*L];
        
    case 'gcv_trunc'
        if order == 0
            [U,s,~] = csvd(K);
            [lambda,~,~] = gcv(U,s,g,'tsvd',0);
        else
            [U,s,~,~,~] = cgsvd(K,L);
            [lambda,~,~] = gcv(U,s,g,'tgsv',0);
        end
        Kreg = [K;lambda*L];
        
    case 'gcv_damp'
        if order == 0
            [U,s,~] = csvd(K);
            [lambda,~,~] = gcv(U,s,g,'dsvd',0);
        else
            [U,s,~,~,~] = cgsvd(K,L);
            [lambda,~,~] = gcv(U,s,g,'dgsv',0);
        end
        Kreg = [K;lambda*L];
        
    case 'discrep'
        delta = sqrt(length(g))*noise_level;
        if order == 0
            [U,s,V] = csvd(K);
            [~,lambda] = discrep(U,s,V,g,delta);
        else
            [U,s,X,~,~] = cgsvd(K,L);
            [~,lambda] = discrep(U,s,X,g,delta);
        end
        Kreg = [K;lambda*L];
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