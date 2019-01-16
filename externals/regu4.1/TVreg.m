function x = TVreg(A,b,lambda)
%TVREG  Total Variation regularization (one-dimensional problem)
%
%  x = TVreg(A,b,lambda)
%
% Solves the problem
%    || A x - b ||_2^2 + lambda^2 || L1 x||_1
% where L1 is the first derivative matrix, and || L1 x||_1 is
% the Total Variation of x.

% Tobias Lindstrøm Jensen, Aalborg University and Per Christian
% Hansen, DTU Informatics, September 20, 2009.

% Reference: S. Boyd and L. Vandenberghe, "Convex Optimization,"
% Cambridge University Press, 2004.

% Set parameters.
n = length(b); % Problem size.
m = 2*(n-1);   % Another problem dimension.
mu  = 20;      % Reduction factor.
tau = 0.001;   % Stopping criterion.
alpha = 0.01;  % Minimum improvement measure.
beta  = 0.5;   % Stepsize decrement.
Nitmax = 150;  % Maximum number of Newton iterations.

% Predefined quantitites.
D = -spdiags(ones(n-1,1),0,n-1,n) + spdiags(ones(n-1,1),1,n-1,n);
G = [D, -speye(n-1); -D, -speye(n-1)];
q = [-2*A'*b; lambda^2*ones(n-1,1)];
twoATA = 2*(A'*A);

% The orginal objective function.
f = @(x) norm(A*x-b,2)^2 + lambda^2 * sum(abs(D*x));

% Newton objective function with barrier.    
fnt = @(z,t) norm(A*z(1:n)-b,2)^2 + lambda^2 * sum(z(n+1:end)) - ...
             (1/t)*(sum(log(-G*z)));

% Starting point. Make sure we start at a feasible point, i.e.,
% in the domain of the log-barrier function.
x0 = b;
s0 = abs((D*x0)*1.1);
z = [x0;s0];

% Outher loop for barrier, decreasing t.
t = 1;
dznt = 0*z;
barrierflag = true;
while barrierflag 

    % Inner loop, Newtons method for unconstrained optimization.
    Nit = 0;
    newtonflag = true;
    while newtonflag
        
        Nit = Nit + 1;
        if Nit == Nitmax
            error(['Max number of Newton iterations reached. '...
                'Probably lambda is too small.'])
        end
        
        y   = -G*z;
        gpy = 1./y;
        w   = -1./(y.*y);
        gfz = [twoATA*z(1:n)+q(1:n)-(1/t)*(-(D'*(gpy(1:n-1)-gpy(n:end))));
               q(n+1:end)-(1/t)*(-(-gpy(1:n-1)-gpy(n:end)))];
        
        % Set up the Schur complement system.
        H22inv = spdiags(-t*(1./(w(1:n-1)+w(n:end))),0,n-1,n-1);
        mB1pB2 = spdiags(-(1/t)*(-w(1:n-1)+w(n:end)),0,n-1,n-1 );
        H21    = ( mB1pB2 *D );
        B1pB2  = spdiags(-(1/t)*((w(1:n-1)+w(n:end))),0,n-1,n-1);
        H11    = D'*B1pB2*D;
        
        % Use regularization to solve the system.
        M   = twoATA + H11 - H21'*H22inv*H21;
        rhs = -gfz(1:n)-H21'*H22inv*(-gfz(n+1:end));
                dznt(1:n) = ( M + 1e-8*norm(M,'fro')*eye(n) ) \ rhs;
        dznt(n+1:end) = H22inv*(-gfz(n+1:end)-H21*dznt(1:n));
        gdznt = gfz'*dznt;
        
        if -gdznt <= 1e-8, newtonflag = false; end
    
        linesearch = true;
        sts = 1;
        while linesearch
            if -G*(z+sts*dznt) > 0 & ...
                    fnt(z+sts*dznt,t) < fnt(z,t)+alpha*sts*gdznt
                linesearch = false;
            else
                sts = beta*sts;
            end
        end
        
        z = z + sts*dznt;
      
    end % Newton iteration.
    
    if  f(z(1:n)) > m/t && (m/t)/(-m/t+f(z(1:n)))<tau
        barrierflag = false;
    else
        t = mu*t;
    end
    
end % Barrier method.

% Extract the solution.
x = z(1:n);