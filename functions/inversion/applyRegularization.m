function [Kreg,lambda] = applyRegularization(K,g,L,lambda_in,flag,order,noise_level)
%applyRegularization applies regularization procedures from the
%Regularization toolbox from P. Hansen -- for all methods (except "manual")
%the regularization parameter lambda is determined by different criteria
%and using a SVD
%
% Syntax:
%       applyRegularization(K,g,L,lambda_in,flag,order,noise_level)
%
% Inputs:
%       K - Kernel matrix
%       g - signal
%       L - smoothness constraint matrix
%       lambda_in - regularization parameter
%       flag - flag for regularization method:
%              'manual', 'gcv_tikh', 'gcv_trunc', 'gcv_damp', 'discrep',
%       order - smoothness constraint: '0', '1' or '2'
%       noise_level - noise level for 'discrep' method (discrepancy principle)
%
% Outputs:
%       Kreg - expanded (regularized) Kernel matrix; the number of extra
%              rows is NOT always size(L,1) (truncated/damped SVD/GSVD),
%              extend the data vector by size(Kreg,1)-length(g) zeros
%       lambda - determined lambda (for 'gcv_trunc': the truncation index
%                k, i.e. the number of retained singular values)
%
% Example:
%       [Kr,lam] = applyRegularization(K,s,L,lambda_in,flag,Lorder,noise)
%
% Other m-files required:
%       Regularization Toolbox
%       csvd
%       cgsvd
%       gcv
%       discrep
%
% Subfunctions:
%       getGCVparameter
%       getTruncatedSystem
%       getDampedSystem
%       getGSVDComponents
%       restoreCurrentFigure
%
% MAT-files required:
%       none
%
% See also:
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

switch flag
    case 'manual'
        Kreg = [K;lambda_in*L];
        lambda = lambda_in;
        
    case 'gcv_tikh'
        % Tikhonov: filter factors s^2/(s^2+lambda^2), i.e. [K;lambda*L]
        if order == 0
            [U,s,~] = csvd(K);
            lambda = getGCVparameter(U,s,g,'tikh');
        else
            [U,s,~,~,~] = cgsvd(K,L);
            lambda = getGCVparameter(U,s,g,'tikh');
        end
        Kreg = [K;lambda*L];

    case 'gcv_trunc'
        % truncated SVD / GSVD: GCV returns the NUMBER k of retained
        % (generalized) singular values - not a Tikhonov lambda. Using k
        % in [K;k*L] (as done before) mixes two different methods.
        if order == 0
            [U,s,~] = csvd(K);
            k = getGCVparameter(U,s,g,'tsvd');
        else
            [U,s,~,~,~] = cgsvd(K,L);
            k = getGCVparameter(U,s,g,'tgsv');
        end
        Kreg = getTruncatedSystem(K,L,order,k);
        % "lambda" output = truncation index k
        lambda = k;

    case 'gcv_damp'
        % damped SVD / GSVD: filter factors s/(s+lambda) (gamma/(gamma+lambda))
        % -- a different lambda scale than Tikhonov, so [K;lambda*L] (as
        % done before) is not the damped solution
        if order == 0
            [U,s,~] = csvd(K);
            lambda = getGCVparameter(U,s,g,'dsvd');
        else
            [U,s,~,~,~] = cgsvd(K,L);
            lambda = getGCVparameter(U,s,g,'dgsv');
        end
        Kreg = getDampedSystem(K,L,order,lambda);
        
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
            if isnan(lambda)
                lambda = 1;
                errmsg = {'Regul. Box: discrep.m failed!';'Using Lambda=1 as fall back.'};
                errordlg(errmsg,'applyRegularization: Error!');
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

return

%%  subfunction: GCV parameter without plotting into the GUI
function reg_min = getGCVparameter(U,s,g,method)
% gcv.m of the Regularization Tools takes FOUR input arguments (the
% former fifth argument '0' made every gcv_* call fail with "Too many
% input arguments") and always plots the GCV function into the current
% axes. The plot is therefore redirected into an invisible temporary
% figure so that no GUI axes are overwritten.
hPrev = get(0,'CurrentFigure');
hTmp = figure('Visible','off');
try
    reg_min = gcv(U,s,g,method);
catch ME
    delete(hTmp);
    restoreCurrentFigure(hPrev);
    rethrow(ME);
end
delete(hTmp);
restoreCurrentFigure(hPrev);
return

function restoreCurrentFigure(hPrev)
if ~isempty(hPrev) && ishghandle(hPrev)
    set(0,'CurrentFigure',hPrev);
end

return

%%  subfunction: truncated SVD / GSVD as an augmented LSQ system
function Kreg = getTruncatedSystem(K,L,order,k)
% Returns Kreg = [K_k; w*P_d] such that the unconstrained least-squares
% solution of Kreg*f = [g; 0] is exactly the truncated SVD (order 0) or
% truncated GSVD (order > 0) solution:
%   - K_k contains only the k retained (generalized) singular components
%     (plus, for the GSVD, the unregularized null space of L)
%   - P_d projects onto the discarded components, which are thereby
%     forced to zero (any w > 0 gives the TSVD/TGSVD solution)
% The weight w is the smallest retained (generalized) singular value, so
% that with the non-negativity constraint of LSQNONNEG/LSQLIN discarded
% components are penalized at the truncation level.
% NOTE: the calling routine has to extend the data vector by
% size(Kreg,1)-length(g) zeros.
[m,n] = size(K);
if order == 0
    [U,S,V] = svd(full(K),'econ');
    s = diag(S);
    k = max(1,min(k,numel(s)));
    if m < n
        % complete the basis with the null space of K
        V = [V null(V')];
    end
    Kk = U(:,1:k)*diag(s(1:k))*V(:,1:k)';
    Kreg = [Kk; s(k)*V(:,k+1:n)'];
else
    [X,Xinv,sigma,mu,nNull] = getGSVDComponents(K,L);
    % gamma = sigma/mu; the null space of L (mu = 0) has gamma = Inf and
    % is always retained (like tgsvd.m of the Regularization Tools)
    gamma = sigma./mu;
    [~,ord] = sort(gamma,'descend');
    nKeep = max(nNull+1,min(n,nNull+k));
    keep = ord(1:nKeep);
    disc = ord(nKeep+1:end);
    Kk = K*X(:,keep)*Xinv(keep,:);
    w = sigma(keep(end));
    Kreg = [Kk; w*Xinv(disc,:)];
end

return

%%  subfunction: damped SVD / GSVD as an augmented LSQ system
function Kreg = getDampedSystem(K,L,order,lambda)
% The damped SVD solution f = sum_i s_i/(s_i+lambda) * (u_i'g/s_i) * v_i
% is the minimizer of
%   ||K*f - g||^2 + lambda*||diag(sqrt(s))*V'*f||^2
% i.e. of [K; sqrt(lambda)*diag(sqrt(s))*V']*f = [g; 0].
% For the damped GSVD (filter gamma/(gamma+lambda), gamma = sigma/mu)
% the penalty is lambda*sum_i sigma_i*mu_i*y_i^2 with y = inv(X)*f.
% NOTE: the calling routine has to extend the data vector by
% size(Kreg,1)-length(g) zeros.
[m,n] = size(K);
if order == 0
    [~,S,V] = svd(full(K),'econ');
    s = diag(S);
    P = diag(sqrt(lambda*s))*V';
    if m < n
        % null space of K: zero component (minimum-norm DSVD solution)
        P = [P; sqrt(lambda*s(end))*null(V')'];
    end
    Kreg = [K; P];
else
    [~,Xinv,sigma,mu] = getGSVDComponents(K,L);
    Kreg = [K; diag(sqrt(lambda*sigma.*mu))*Xinv];
end

return

%%  subfunction: GSVD components of the matrix pair (K,L)
function [X,Xinv,sigma,mu,nNull] = getGSVDComponents(K,L)
% cgsvd: K = U*C*inv(X), L = V*S*inv(X) (compact GSVD, requires m >= n).
% sigma and mu are taken as the column norms of K*X and L*X, which is
% independent of the internal ordering of cgsvd's output.
[m,n] = size(K);
if m < n
    error('applyRegularization:GSVD',...
        ['Truncated/damped GSVD requires at least as many data points ',...
        'as model parameters (%d < %d). Increase #gates or decrease model space.'],m,n);
end
[~,sm,X,~,Xinv] = cgsvd(K,L);
sigma = sqrt(sum((K*X).^2,1))';
mu = sqrt(sum((L*X).^2,1))';
% number of components in the null space of L (not regularized)
nNull = n - size(sm,1);

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