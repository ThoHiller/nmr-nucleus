function [Lnew,W,Pi] = preprocL(L)
%preprocL  Pre-processing of L matrix in a discrete ill-posed problem
%
% [Lnew] = preprocL(L)
% [Lnew,W] = preprocL(L)
% [R,W,Pi] = preprocL(L)
%
% This function pre-processes any matrix L such that it can be used by all
% the functions of Regularization Tools.  There are no requirements on the
% dimensions or rank of L.  The output matrix Lnew is r-by-n, where r is
% the rank of L.  There is no need to use this function is L is known to
% have full row rank.
%
% If one or two output arguments are used, then for any x we have
%    || L x ||_2 = || Lnew x ||_2 ,
% and therefore in Regularization Tools one should replace L by Luse.
% The matrix W holds an approximate basis for the null space of Lnew.
%
% If three output arguments are used, then we return the factors of
% Lnew = R*Pi', and for any x we have
%    || L x ||_2 = || R Pi' x ||_2 .
% Hence one can replace L by R, x by xnew = Pi'*x; and A by Anew = A*pi.
% Pivoting ensures that the leading r-by-r submatrix of R is almost as well
% conditioned as possible (desirable when standard-form transformation
% "method 2" is used).  The matrix W holds an approximate basis for the
% null space of R as required in the function std_form.

% Per Christian Hansen, DTU Informatics, May 20, 2011.

[p,n] = size(L);

if p<n
    % The case p < n: pad L with zeros at the bottom.
    if nargout==1
        [r,Lnew,Pi] = hrrqr([L;zeros(n-p,n)]);
    else
        [r,Lnew,Pi,~,W] = hrrqr([L;zeros(n-p,n)]);
    end
else
    % Otherwise no padding is needed.
    if nargout==1
        [r,Lnew,Pi] = hrrqr(L);
    else
        [r,Lnew,Pi,~,W] = hrrqr(L);
    end
end

Lnew = Lnew(1:r,:);
if nargout<3, Lnew = Lnew*Pi'; end