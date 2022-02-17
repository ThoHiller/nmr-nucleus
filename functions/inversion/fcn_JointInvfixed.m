function [F,varargout] = fcn_JointInvfixed(X,iparam)
%fcn_JointInvfixed performs the "fixed" joint inversion using the RTD of
%the full saturation NMR signal and NMR signals at partial saturation to
%"calibrate" the surface relaxivity "rho"
%
% Syntax:
%       fcn_JointInvfixed(X,iparam)
%
% Inputs:
%       X - log10 value of the surface relaxivity
%       iparam - struct that holds additional settings:
%                   t           : time vector (all NMR signals)
%                   g           : signal vector (all NMR signals)
%                   indt        : number of echoes/points per NMR signal
%                   Tb          : bulk relaxation time
%                   Td          : diffusion relaxation time
%                   T1T2        : flag between 'T1' or 'T2' inversion
%                   T1IRfac     : either '1' or '2' depending on T1 method
%                   SatImbDrain : string indicating if a NMR signal is from
%                                 the drainage or imbibition branch (e.g. 'DDID')
%                   p           : pressure values
%                   igeom       : geometry struct
%                   x           : relaxation time vector
%                   f           : relaxation time distribution (RTD)
%
% Outputs:
%       F - norm of the residual vector
%       varargout - cell that holds several more data
%                   ig      : fitted NMR signals
%                   XX      : Kernel matrix
%                   igeom   : final geometry struct
%                   iSAT    : final pressure/saturation struct       
%
% Example:
%       F = fcn_JointInvfixed(X,iparam)
%
% Other m-files required:
%       getConstants
%       getCornerNMRparameter
%       getGeometryParameter
%       getPartialSaturationMatrix
%       getSaturationFromPressureBatch
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
indt = iparam.indt;
Tb = iparam.Tb;
Td = iparam.Td;
T1T2 = iparam.T1T2;
T1IRfac = iparam.T1IRfac;
SatImbDrain = iparam.SatImbDrain;
p = iparam.p;
igeom = iparam.igeom;
x = iparam.x;
f = iparam.f;
constants = getConstants;

%% wait-bar option
wbopts.show = false;

%% surface relaxivity as log10 value
rhos = 10^X(1);

%% switch depending on geometry
switch igeom.type    
    case 'cyl'        
        % new PSD with updated rhos
        ipsddata.r = x.*2.*rhos;
        ipsddata.psd = f;
        % new saturation state
        igeom.radius = ipsddata.r';
        igeom = getGeometryParameter(igeom);
        iSAT = getSaturationFromPressureBatch(igeom,p,ipsddata,constants,wbopts);
        IPS = getPartialSaturationMatrix(iSAT,indt,SatImbDrain);
        
        % get the surface-to-volume ratio
        SV = igeom.P0./igeom.A0;
        
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
        % new PSD with updated rhos
        ipsddata.r = x.*igeom.a.*rhos;
        ipsddata.psd = f;
        igeom.radius = ipsddata.r';
        % new saturation state
        igeom = getGeometryParameter(igeom);
        iSAT = getSaturationFromPressureBatch(igeom,p,ipsddata,constants,wbopts);        
        IPS = getPartialSaturationMatrix(iSAT,indt,SatImbDrain);
        
        % get the amplitudes and surface-to-volume ratios for the partially
        % saturated corners
        SVdata = getCornerNMRparameter(igeom,iSAT,indt,SatImbDrain);
        SVdata.TT = repmat(t',[1 length(SVdata.SVF)]);
        
        SV  = SVdata.SVF';
        SVC = SVdata.SVC;
        Amp = SVdata.Ampl;
        TT  = SVdata.TT;
        
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
        
        K = Kf;
        K(IPS~=1) = Kc(IPS~=1);
        % Kernel matrix times saturation matrix
        XX = K;
        
    otherwise
        % nothing to do
end

%% weighting
if isfield(iparam,'W')
    g = iparam.W*g';
    XX = iparam.W*XX;
    g = g';
end

%% corresponding signal g = Kf
ig = XX*f';

%% residual
F = norm(ig - g');

%% output
if nargout > 1
    varargout{1} = ig;
    varargout{2} = XX;
    varargout{3} = igeom;
    varargout{4} = iSAT;
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