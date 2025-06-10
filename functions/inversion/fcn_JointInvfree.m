function [F,J,ig,XX] = fcn_JointInvfree(X,iparam)
%fcn_JointInvfree jointly estimates the pore size distribution and surface
%relaxivity "rho" via a non-linear multi-exponential fit
%
% Syntax:
%       fcn_JointInvfree(T,f)
%
% Inputs:
%       X - [PSD; rho]
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
t = iparam.t;
g = iparam.g;
Tb = iparam.Tb;
Td = iparam.Td;
T1T2 = iparam.T1T2;
T1IRfac = iparam.T1IRfac;
L = iparam.L;
lambda = iparam.lambda;
igeom = iparam.igeom;
IPS = iparam.IPS;

% length of relaxation time distr.
n = length(X)-1;
% amplitude of relaxation time distr.
x = X(1:n);
% surface relaxivity as scaled log10 value
rhos = 10^X(n+1);

%% switch depending on geometry
switch igeom.type
    case 'cyl'
        % for cylindrical pores SV is simply the full saturated S/V ratio
        SV = iparam.SVdata.SVF;
        
        % Kernel matrix
        Kf = zeros(length(t),length(SV));
        switch T1T2
            case 'T1'
                for i=1:length(SV)
                    Kf(:,i) = 1-T1IRfac.*exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                end
            case 'T2'
                for i=1:length(SV)
                    Kf(:,i) = exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                end
        end
        K = Kf;
        % Kernel matrix times saturation matrix
        XX = K.*IPS;
        
    case {'ang','poly'}
        % for angular and polygonal pores there are full saturation S/V and
        % partial saturation S/V ratios and amplitudes
        SV = iparam.SVdata.SVF;
        SVC = iparam.SVdata.SVC;
        Amp = iparam.SVdata.Ampl;
        TT = iparam.SVdata.TT;
        
        % Kernel matrix
        Kf = zeros(length(t),length(SV));
        switch T1T2
            case 'T1'
                for i=1:length(SV)
                    Kf(:,i) = 1-T1IRfac.*exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                end
                % Kernel matrix for partial saturation
                Kc = zeros(length(t),length(SV));
                for i=1:size(SVC,1)
                    Kc = Kc + ( squeeze(Amp(i,:,:)) .*...
                        ( 1-T1IRfac.*exp(-TT.*(rhos*squeeze(SVC(i,:,:)) + 1/Tb + 1/Td)) ));
                end
            case 'T2'
                for i=1:length(SV)
                    Kf(:,i) = exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                end
                % Kernel matrix for partial saturation
                Kc = zeros(length(t),length(SV));
                for i=1:size(SVC,1)
                    Kc = Kc + ( squeeze(Amp(i,:,:)) .*...
                        exp(-TT.*(rhos*squeeze(SVC(i,:,:)) + 1/Tb + 1/Td)) );
                end
        end
        % full saturation matrix
        K = Kf;
        % for partial saturation points use the Kc values
        K(IPS~=1) = Kc(IPS~=1);
        % Kernel matrix times saturation matrix
        XX = K;
end

% error weighing
if isfield(iparam,'W')
    e = 1./diag(iparam.W);
    W = diag(e);
    g = W*g';
    XX = W*XX;
    g = g';
end

% scale everything between [0,1]
maxS = max(g);
g = g./maxS;
XX = XX./maxS;

% corresponding signal g = Kf
ig = XX*x';
% residual
F1 = (ig - g');
% regularization
F2 = (lambda*L)*x';
% fcn should return the residual as output for lsqnonlin
% see e.g. Aster et al. S. 240 eq.10.4
F  = [F1; F2];

% jacobian - speeds up inversion!
J = 0;
if nargout > 1
    % see Mohnke, 2014 WRR paper for info
    
    % J = dGAMMA/df
    J = XX;
    
    switch T1T2
        case 'T1'
            % Jr = dGAMMA/drho
            % for T1 it's a bit more tricky because
            % d/drho 1-IR*exp(-t*rho*SV) = IR*t*SV * exp(-t*rho*SV)
            % where exp(-t*rho*SV) is essentially the T2 Kernel matrix
            
            % DD = exp(-t*rho*SV)
            switch igeom.type
                case 'cyl'
                    DD = zeros(length(t),length(SV));
                    for i=1:length(SV)
                        DD(:,i) = exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                    end
                    
                case {'ang','poly'}
                    % Kernel matrix for full saturation
                    DD = zeros(length(t),length(SV));
                    for i=1:length(SV)
                        DD(:,i) = exp(-t.*(rhos*SV(i) + 1/Tb + 1/Td));
                    end
                    % Kernel matrix for partial saturation
                    D = zeros(length(t),length(SV));
                    for i=1:size(SVC,1)
                        D = D + ( squeeze(Amp(i,:,:)).*...
                            exp(-TT.*(rhos*squeeze(SVC(i,:,:)) + 1/Tb + 1/Td)) );
                    end
                    DD(IPS~=1) = D(IPS~=1);
            end
            
            % and now using DD in the derivative:
            Jr = zeros(1,length(t));
            for i = 1:length(t)
                Jr(i) = t(i).*sum(x.*T1IRfac.*SV.*rhos.*DD(i,:));
            end
            
        case 'T2'
            % Jr = dGAMMA/drho
            % in the case of T2 the derivate of dGAMMA/drho is simple
            Jr = zeros(1,length(t));
            for i = 1:length(t)
                Jr(i) = t(i).*sum(-x.*SV.*rhos.*XX(i,:));
            end
    end
    
    JJ = [J Jr'];
    LL = [lambda*L 0*L(:,1)];
    J = [JJ;LL];
    
    % for final output scale the fitted signal back
    ig = XX*(x'.*maxS);
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