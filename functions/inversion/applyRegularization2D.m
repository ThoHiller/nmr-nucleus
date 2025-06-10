function [Kreg,lambda] = applyRegularization2D(K,g,LT,LD,lambda_in,flag,order,noise_level)
%applyRegularization applies regularization procedures from the
%Regularization toolbox from P. Hansen -- for all methods (except "manual")
%the regularization parameter lambda is determined by different criteria
%and using a SVD
%
% Syntax:
%       applyRegularization(K,g,LT2,LT1,lambda_in,flag,order,noise_level)
%
% Inputs:
%       K - Kernel matrix
%       g - signal
%       LT,LD - smoothness constraint matrices
%       lambda_in - regularization parameter
%       flag - flag for regularization method:
%              'manual', 'gcv_tikh', 'gcv_trunc', 'gcv_damp', 'discrep',
%       order - smoothness constraint: '0', '1' or '2'
%       noise_level - noise level for 'discrep' method (discrepancy principle)
%
% Outputs:
%       Kreg - expanded (regularized) Kernel matrix
%       lambda - determined lambda
%
% Example:
%       [Kr,lam] = applyRegularization(K,s,LT2,LT1,lambda_in,flag,Lorder,noise)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

% combined smoothness matrix
L = [LT;LD];

switch flag
    case 'manual'
        Kreg = [K;lambda_in(1)*LT;lambda_in(2)*LD];
        lambda = lambda_in;

    case {'gcv_tikh','gcv_trunc','gcv_damp'}
        try
            if order == 0
                [U,s,~] = csvd(K);
            else
                [U,s,~,~,~] = cgsvd(K,L);
            end
            switch flag
                case 'gcv_tikh'
                    [lambda,~,~] = gcv(U,s,g,'tikh',0);
                case 'gcv_trunc'
                    [lambda,~,~] = gcv(U,s,g,'tsvd',0);
                case 'gcv_damp'
                    [lambda,~,~] = gcv(U,s,g,'dsvd',0);
            end
            Kreg = [K;lambda*L];
        catch ME
            % show error message in case cgsvd fails
            errmsg = {ME.message;[ME.stack(1).name,' Line: ',num2str(ME.stack(1).line)];...
                'Regul. Box: cgsvd.m failed!';'Increase #gates or decrease model space.';'Using Lambda=1 as fall back.'};
            errordlg(errmsg,'applyRegularization: Error!');
            lambda = 1;
            Kreg = [K;lambda*L];
        end

    case 'discrep'
        delta = sqrt(length(g))*noise_level;
        try
            if order == 0
                [U,s,V] = csvd(K);
                [~,lambda] = discrep(U,s,V,g,delta);
            else
                [U,s,X,~,~] = cgsvd(K,L);
                [~,lambda] = discrep(U,s,X,g,delta);
            end
            Kreg = [K;lambda*L];
        catch ME
            % show error message in case discrep fails
            errmsg = {ME.message;[ME.stack(1).name,' Line: ',num2str(ME.stack(1).line)];...
                'Regul. Box: discrep.m failed!';'Using Lambda=1 as fall back.'};
            errordlg(errmsg,'applyRegularization: Error!');
            lambda = 1;
            Kreg = [K;lambda*L];
        end
end

% the GUI needs two lambda values
if numel(lambda) == 1
    lambda(2) = lambda(1);
end

return

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