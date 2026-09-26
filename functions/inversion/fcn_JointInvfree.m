function [F,J,ig,K] = fcn_JointInvfree(X,iparam)
%fcn_JointInvfree jointly estimates the pore size distribution and surface
%relaxivity "rho" via a non-linear multi-exponential fit
%This is a clean restructured rewrite, initiated from the migration of the
%code to python with Claude Code
%
% Syntax:
%       fcn_JointInvfree(X,iparam)
%
% Inputs:
%       X - X(1:N) = PSD; X(N+1) = log10(rho)
%       iparam - struct that hold additional parameters:
%                t : augmented time vector
%                g : augmented signal vector
%                Tb : bulk relaxation time
%                Td : diffusion relaxation time
%                T1T2 : 'T1' / 'T2' flag
%                T1IRfac : either '1' or '2' depending on T1 method
%                L : smoothness constraint
%                lambda : regularization parameter
%                igeom : geometry structure data
%                IPS : saturation status matrix
%                SVdata : corner saturation data
%
% Outputs:
%       F - residual
%       J - Jacobian (optional)
%       ig - fitted signal (optional)
%       XX - augmented Kernel matrix (optional)
%
% Example:
%       [F,J,ig,XX] = fcn_JointInvfree(X,iparam)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% input parameters
t = iparam.t(:);
g = iparam.g(:);

Tb = iparam.Tb;
Td = iparam.Td;
mode = iparam.T1T2;
geom = iparam.igeom.type;

L = iparam.L;
lambda = iparam.lambda;

IPS = iparam.IPS;

N = numel(X)-1;
f = X(1:N).';

eta = X(end);
rho = 10.^eta;
% d(rho)/d(log10(rho))
drho_deta = log(10)*rho;

% full saturated surface-to-volume ratio
SV = iparam.SVdata.SVF(:).';

% combine Tb and Td
Rb = 1/Tb + 1/Td;

Nt = numel(t);
Nr = numel(SV);

%% 1. fully saturated kernel
rateFull = rho.*SV + Rb;
Efull = exp(-t .* rateFull);

switch mode
    case 'T2'
        % kernel
        Kf = Efull;

        % derivative dK / d(log10(rho))
        dKf = -drho_deta .* (t .* SV) .* Efull;

    case 'T1'
        q = iparam.T1IRfac;
        % kernel
        Kf = 1 - q.*Efull;

        % derivative dK / d(log10(rho))
        dKf = q .* drho_deta .* (t .* SV) .* Efull;
end

%% 2. geometry
switch geom
    % Cylindrical pores:
    % either completely water filled or completely empty
    case 'cyl'
        K  = Kf .* IPS;
        dKdEta = dKf .* IPS;

        % Angular / polygonal pores:
        % partial saturation possible
    case {'ang','poly'}

        SVC = iparam.SVdata.SVC;
        Amp = iparam.SVdata.Ampl;
        TT = iparam.SVdata.TT;
        % initialize final partial saturation corner kernel and its
        % derivative
        Kc = zeros(Nt,Nr);
        dKcEta = zeros(Nt,Nr);

        Nc = size(SVC,1);
        % Sum individual corner contributions
        for c = 1:Nc
            svc = squeeze(SVC(c,:,:));
            amp = squeeze(Amp(c,:,:));
            rateCorner = rho.*svc + Rb;
            % relaxivity within a corner
            Ecorner = exp(-TT .* rateCorner);

            switch mode
                case 'T2'
                    % kernel scaled by individual amplitudes
                    Kcorner = amp .* Ecorner;
                    % derivative
                    dKcorner = -drho_deta .* amp .* TT .* svc .* Ecorner;

                case 'T1'
                    q = iparam.T1IRfac;
                    % kernel scaled by individual amplitudes
                    Kcorner = amp .* (1 - q.*Ecorner);
                    % derivative
                    dKcorner = q .* drho_deta .* amp .* TT .* svc .* Ecorner;
            end

            % partial saturation corner kernel and its derivative
            Kc = Kc + Kcorner;
            dKcEta = dKcEta + dKcorner;
        end

        % Initially assume full saturation
        K = Kf;
        dKdEta = dKf;

        % if any, replace partially saturated points by corner water
        idxPartial = (IPS ~= 1);
        K(idxPartial) = Kc(idxPartial);
        dKdEta(idxPartial) = dKcEta(idxPartial);
end

%% 3. Physical NMR forward model
ig = K*f;

%% 4. Physical Jacobian
if nargout > 1
    % PSD amplitudes; upper left part of the Jacobian is simply the kernel
    Jf = K;
    % log10(surface relaxivity)
    % upper right part is the GAMMA fcn in Mohnke, 2014 WRR
    Jrho = dKdEta*f;
    % combined physical Jacobian
    Jphys = [Jf, Jrho];
end


%% 5. Raw NMR residual
resNMR = ig - g;

%% 6. Weight residuals by measurement uncertainty
% iparam.W contains standard deviations:
% Wsigma = diag(sigma)
% We therefore need
%  r_weighted = r./sigma
% and
%  J_weighted = J./sigma
if isfield(iparam,'W') && ~isempty(iparam.W)

    % Extract standard deviations
    sigma = diag(iparam.W);

    % Safety checks
    if numel(sigma) ~= numel(resNMR)
        error(['Number of standard deviations does not match ', ...
            'number of NMR residuals.']);
    end
    if any(~isfinite(sigma))
        error('Standard deviations contain NaN or Inf.');
    end
    if any(sigma <= 0)
        error('All standard deviations must be > 0.');
    end

    % Weighted least-squares residual
    resNMR = resNMR./sigma;

    % Same operation must be applied to Jacobian rows
    if nargout > 1
        Jphys = Jphys./sigma;
    end
end

%% 7. Optional CONSTANT numerical scaling
% IMPORTANT:
% "scale" must be calculated OUTSIDE this function.
% Never use:
% scale = max(signal) 
% here. This was one of the former bugs.
if isfield(iparam,'scale') && ~isempty(iparam.scale)
    scale = iparam.scale;
else
    scale = 1;
end

if ~isscalar(scale) || ~isfinite(scale) || scale <= 0
    error('iparam.scale must be a finite positive scalar.');
end

% apply the scaling
resNMR = resNMR / scale;

% Same operation must be applied to Jacobian
if nargout > 1
    JNMR = Jphys / scale;
end

%% 8. Regularization
resReg = lambda * L * f;

%% 9. Complete residual
% fcn should return the residual as output for lsqnonlin
% see e.g. Aster et al. S. 240 eq.10.4
F = [resNMR;
    resReg];

%% 10. Complete Jacobian
if nargout > 1
    % rho is currently not regularized, hence the zeros on the right
    JReg = [lambda*L, zeros(size(L,1),1)];

    J = [JNMR;
        JReg];
end

end

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
