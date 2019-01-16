function X = pptsvd(A,L,b,ks)
%PPTSVD  Piecewise polynomial truncated SVD
%
% X = pptsvd(A,L,b,k)
%
% Computes PP-TSVD solutions to problems with coefficient matrix A
% and right-hand side b.  The matrix L should be an approx. to a
% derivative operator, computed by means of get_l.
%
% The parameter k is a vector of truncation parameters, and the
% corresponding PP-TSVD solutions are stored as columns of X.

% Reference: P. C. Hansen & K. Mosegaard, "Piecewise polynomial solutions
% without a priori break points," Numer. Lin. Alg. Appl. 6 (1996), 513-524.

% Per Christian Hansen, DTU Informatics, Jan. 14, 2013.

% Find maximum number of singular values and vectors to use
maxk = max(ks)+2; % The "+2" fixes a bug in svds.

% Calculate the SVD.
[U,S,V] = svds(A,maxk);

% Allocate space for return variables.
X = zeros(size(A,2),length(ks));

z = zeros(size(A,2),1);
for i = 1:length(ks)
  % Which k to use
  k   = ks(i);
  
  % Calculate TSVD
  x_k = V(:,1:k)*diag(1./diag(S(1:k,1:k)))*(U(:,1:k)'*b);
  
  % Calculate l1 problem
  [z,res] = l1c(L, L*x_k, V(:,1:k)', zeros(k,1), zeros(0, size(z,1)), ...
      zeros(0,1), z);
  % In case of l1 failure print out warning.
  if res ~= 0
    disp(sprintf('Warning: l1c returned %d',res));
  end
  
  % Calculate PP-TSVD and insert result in return variables.
  X(:,i) = x_k - z;
end

%--------------------------------------------------------------

function [x,result] = l1c(A,b,C,d,E,f,x0)
% L1C Solve the discrete l1 linear approximation with linear constraints.
%
% [x,result] = L1C(A,b,C,d,E,f,x0) solves the l1 problem with linear
% constraints. Parameters according (1).
% 
% Solves a problem of the form:
%
% (1)           min||b-Ax||_1, Cx=d, Ex<=f
%
% Transforms the problem (1) into a simple linear problem and solves using
% a simplex based algorithm.
%
% Arguments A,b,C,d,E,f are explained by (1)
% 
% x0 is a starting guess which in some cases can speed up calculations.
% 
% x returns the calculated solution to (1)
%
% result returns an staus value:
%    0    : Optimal solution found
%    1    : No feasible solution to the constraints
%    2    : Calculations stopped prematurely because of rounding errors
%    3    : Maximum number of iterations reached

% Based upon the algorithm described in [1]
%
% [1] I. Barrodale and F. D. K. Roberts: An efficient algorithm 
% for discrete approximation with linear constraints.
% SIAM J. Numer. Anal., vol. 15,  No. 3, June 1978

% Last revised 17.06.1998


[m,n] = size(A);
  k   = size(C,1);
  l   = size(E,1);

% Adjust problem if having a starting guess
if nargin == 7
  b = b-A*x0;
  d = d-C*x0;
  f = f-E*x0;
end

toler = 10^(-16*2/3);
maxiter = 10*(m+k+l);
x = zeros(n,1);
result = -1;
mkl1 = m+k+l+1;
iter = 0;
wn = n;
kforce = 1;

% Setup Q

Q = full([ A b ;
           C d ;
	   E f ;
	   zeros(1,n+1) ]);

inbasis = n+(1:m+k+l);
insign  = ones(1,m+k+l);
outbasis = 1:n;
outsign  = ones(1,n);

index = find(Q(1:m+k+l,n+1) < 0);
insign(index) = ~insign(index);
Q(index,:) = -Q(index,:);

% Phase 1

% Setup phase 1 costs

cu = zeros(2,n+m+k+l);
cu(:,n+m+1:n+m+k) = 1;
if l > 0
  cu(2,n+m+k+1:n+m+k+l) = 1;
end
iu = cu;

% Compute marginal costs

t = (cu(1,inbasis) .* insign + cu(2,inbasis) .* ~insign);
Q(mkl1,:) = t*Q(1:m+k+l,:);

while 1,

  % Vector to enter basis

  zu = Q(mkl1,1:wn);
  zv = -zu - sum(cu(:,outbasis));

  s = outsign;
  i1 = ~iu(1,outbasis);
  i2 = ~iu(2,outbasis);

  zu = zu .* ((s & i1) | (~s & i2));
  zv = zv .* ((s & i2) | (~s & i1));

  if kforce == 1
    t = (outbasis <= n);
    [val ,index ] = max(zu .* t);
    [val2,index2] = max(zv .* t);

    if (isempty(val) & isempty(val2)) | ((val < toler) & (val2 < toler))
      if Q(mkl1,wn+1) < toler
        break;
      else
        kforce = 0;
      end
    end
  end
  if kforce == 0
    [val ,index ] = max(zu);
    [val2,index2] = max(zv);

    if (isempty(val) & isempty(val2)) | ((val < toler) & (val2 < toler))
      break;
    end
  end

  if val2 > val
    in = index2;
    Q(:,in) = -Q(:,in);
    Q(mkl1,in) = val2;
    outsign(in) = ~outsign(in);
  else
    in = index;
  end

  index = find(Q(1:m+k+l,in) > toler);

  while 1,

    if isempty(index)
      result = -2;   % Go to phase 2
      break;
    end

    [val,i] = min(Q(index,wn+1) ./ Q(index,in));
    out = index(i);
    index(i) = index(end);
    index = index(1:end-1);

    pivot = Q(out,in);

    i = inbasis(out);
    cuv = cu(1,i) + cu(2,i);

    if Q(mkl1,in) - cuv*pivot > toler
      Q(mkl1,:) = Q(mkl1,:) - cuv*Q(out,:);
      Q(out,:) = -Q(out,:);
      insign(out) = ~insign(out);
    else
      break;
    end

  end

  if result == -2
    result = -1;
    break;
  end;

  iter = iter + 1;

  Q(out,:) = Q(out,:)/pivot;

  RO = speye(mkl1);
  RO(:,out) = -Q(:,in);
  RO(out,out) = 1;

  Q(:,in) = 0;
  Q(out,in) = 1/pivot;

  Q = RO*Q;

  val = insign(out);
  insign(out) = outsign(in);
  outsign(in) = val;
  val = inbasis(out);
  inbasis(out) = outbasis(in);
  outbasis(in) = val;

  if iu(1,val) == 1 & iu(2,val) == 1
    Q(:,in) = Q(:,1);
    Q = Q(:,2:end);
    outbasis(in) = outbasis(1);
    outbasis = outbasis(2:end);
    outsign(in) = outsign(1);
    outsign = outsign(2:end);
    wn = wn - 1;
  end
end

if result == -1

  if Q(mkl1,wn+1) >= toler
    result = 1;
    return;
  end

  % Phase 2
  % Setup phase 2 costs

  cu = zeros(2,n+m+k+l);
  cu(:,n+1:n+m) = 1;
  index  = find(insign==1 & iu(1,inbasis)==1);
  index2 = find(insign==0 & iu(2,inbasis)==1);
  if ~isempty(index)
    cu(1,inbasis(index )) = 0;
  end
  if ~isempty(index2)
    cu(2,inbasis(index2)) = 0;
  end

  t = zeros(1,m+k+l);
  t(index)  = 1;
  t(index2) = 1;

  [s,index]  = find(t);
  [s,index2] = find(~t);

  ia = length(index);

  Q = [Q(index,:); Q(index2,:); Q(mkl1,:)];
  inbasis = [inbasis(index) inbasis(index2)];
  insign  = [ insign(index)  insign(index2)];

  % Compute marginal costs

  t = (cu(1,inbasis) .* insign + cu(2,inbasis) .* ~insign);
  Q(mkl1,:) = t*Q(1:m+k+l,:);

  while iter <= maxiter,

    % Vector to enter basis

    zu = Q(mkl1,1:wn);
    zv = -zu - sum(cu(:,outbasis));

    s = outsign;
    i1 = ~iu(1,outbasis);
    i2 = ~iu(2,outbasis);

    zu = zu .* ((s & i1) | (~s & i2));
    zv = zv .* ((s & i2) | (~s & i1));

    [val ,index ] = max(zu);
    [val2,index2] = max(zv);

    if (isempty(val) & isempty(val2)) | ((val < toler) & (val2 < toler))
      result = 0;
      break;
    end

    if val2 > val
      in = index2;
      Q(:,in) = -Q(:,in);
      Q(mkl1,in) = val2;
      outsign(in) = ~outsign(in);
    else
      in = index;
    end

    [val,out] = max(abs(Q(1:ia,in)));

    if (~isempty(val)) & (val > toler)
      Q([out ia],:) = Q([ia out],:);
      inbasis([out ia]) = inbasis([ia out]);
      insign([out ia])  = insign([ia out]);
      out = ia;
      ia = ia - 1;
      pivot = Q(out,in);
    else
      index = find(Q(1:m+k+l,in) > toler);

      while 1,

        if isempty(index)
          result = 2;
          break;
        end

        [val,i] = min(Q(index,wn+1) ./ Q(index,in));
        out = index(i);
        index(i) = index(end);
        index = index(1:end-1);

        pivot = Q(out,in);

        i = inbasis(out);
        cuv = cu(1,i) + cu(2,i);

        if ((insign(out) == 0 & iu(1,i) == 0) | (insign(out) == 1 & ...
	      iu(2,i) == 0)) & (Q(mkl1,in) - cuv*pivot > toler)
          Q(mkl1,:) = Q(mkl1,:) - cuv*Q(out,:);
          Q(out,:) = -Q(out,:);
          insign(out) = ~insign(out);
        else
          break;
        end
      end
    end

    if result == 2
      break;
    end

    iter = iter + 1;

    Q(out,:) = Q(out,:)/pivot;

    RO = speye(mkl1);
    RO(:,out) = -Q(:,in);
    RO(out,out) = 1;

    Q(:,in) = 0;
    Q(out,in) = 1/pivot;

    Q = RO*Q;

    val = insign(out);
    insign(out) = outsign(in);
    outsign(in) = val;
    val = inbasis(out);
    inbasis(out) = outbasis(in);
    outbasis(in) = val;

    if iu(1,val) == 1 & iu(2,val) == 1
      Q(:,in) = Q(:,1);
      Q = Q(:,2:end);
      outbasis(in) = outbasis(1);
      outbasis = outbasis(2:end);
      outsign(in) = outsign(1);
      outsign = outsign(2:end);
      wn = wn - 1;
    end
  end
end

if iter > maxiter
  result = 3;
elseif result == 0 | result == 2
  index = find(inbasis <= n & insign == 1);
  x(inbasis(index)) = Q(index,wn+1);
  index = find(inbasis <= n & insign == 0);
  x(inbasis(index)) = -Q(index,wn+1);
end

% Adjust result if a starting guess was given.
if nargin == 7
  x = x + x0;
end