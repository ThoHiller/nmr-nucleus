function [F,varargout] = fcn_JointInvshape(X,iparam)
%fcn_JointInvshape performs the "shape" joint inversion using the RTD of
%the full saturation NMR signal and NMR signals at partial saturation to
%"calibrate" the surface relaxivity "rho". Additionally it tries to find
%the "second" angle inside a right angular triangle by using NMR signals
%from the drainage and imbibition branch.
%
% Syntax:
%       fcn_JointInvshape(X,iparam)
%
% Inputs:
%       X - parameter vector:
%               X(1) : log10 value of the surface relaxivity
%               X(2) : second angle beta of the right angular triangle
%
%       iparam - struct that holds additional settings:
%                   t           : time vector (all NMR signals)
%                   g           : signal vector (all NMR signals)
%                   indt        : number of echoes/points per NMR signal
%                   Tb          : bulk relaxation time
%                   Td          : diffusion relaxation time
%                   T1T2        : flag between 'T1' or 'T2' inversion
%                   T1IRfac     : either '1' or '2' depending on T1 method
%                   SatImbDrain : string indicating if a NMR signal is from
%                                 the drainage or imbibition branch
%                                 (e.g. 'DDID')
%                   p           : pressure values
%                   igeom       : geometry struct
%                   x           : surface relaxation time vector
%                   f           : relaxation time distribution (RTD)
%                   W           : diagonal matrix containing standard
%                                 deviations of the NMR data (optional)
%
% Outputs:
%       F - norm of the weighted residual vector
%
%       varargout - cell that holds several more data:
%                   ig      : fitted NMR signals (physical, unweighted)
%                   XX      : kernel matrix (physical, unweighted)
%                   igeom   : final geometry struct
%                   iSAT    : final pressure/saturation struct
%
% Example:
%       F = fcn_JointInvshape(X,iparam)
%
% Other m-files required:
%       getConstants
%       getCornerNMRparameter
%       getGeometryParameter
%       getPartialSaturationMatrix
%       getSaturationFromPressureBatch
%
% See also:
%
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License

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

% make vector orientations consistent
t = t(:);
g = g(:);
x = x(:);
f = f(:);

%% waitbar option
wbopts.show = false;

%% surface relaxivity as log10 value and "second" angle
rhos = 10^X(1);
beta = X(2);

%% only works for right angular triangles
if ~strcmp(igeom.type,'ang')
    error('fcn_JointInvshape only supports geometry type ''ang''.');
end

%% check triangle (right-angular) geometry
%  The first angle is fixed. beta is the second angle and
%  the third angle follows from
%   alpha3 = alpha1 - beta
%  according to the original geometry definition.
alpha1 = igeom.angles(1);
alpha3 = alpha1 - beta;

if ~isfinite(beta) || beta <= 0 || alpha3 <= 0
    % Return a large objective value for invalid geometries.
    % This is useful when the function is called by fminsearch,
    % which does not support explicit bounds.
    F = realmax('double')^(1/4);
    if nargout > 1
        varargout{1} = [];
        varargout{2} = [];
        varargout{3} = igeom;
        varargout{4} = [];
    end
    return
end

%% get new geometry parameter "a"
%  "a" depends only on pore shape and is required to
%  transform the fixed surface relaxation time distribution
%  into a pore-size distribution:
%       r = x * a(beta) * rhos
%  Note:
%  x represents the surface-relaxation time. Bulk and
%  diffusion relaxation are therefore NOT subtracted here.
%  Tb and Td are accounted for separately in the NMR kernel.
tmp.type = igeom.type;
tmp.radius = 1;
tmp.angles = [alpha1 beta alpha3];
tmp = getGeometryParameter(tmp);

%% new PSD with updated rhos and shape parameter a
ipsddata.r = x.*tmp.a.*rhos;
ipsddata.psd = f';

%% update geometry
igeom.radius = ipsddata.r;
igeom.angles(2) = beta;
igeom.angles(3) = alpha3;
igeom = getGeometryParameter(igeom);

%% new saturation state
iSAT = getSaturationFromPressureBatch(igeom,p,ipsddata,constants,wbopts);
IPS = getPartialSaturationMatrix(iSAT,indt,SatImbDrain);

%% get amplitudes and surface-to-volume ratios for the
%  partially saturated corners
SVdata = getCornerNMRparameter(igeom,iSAT,indt,SatImbDrain);
SVdata.TT = repmat(t,[1 length(SVdata.SVF)]);

SV  = SVdata.SVF';
SVC = SVdata.SVC;
Amp = SVdata.Ampl;
TT  = SVdata.TT;
SV = SV(:);

%% consistency checks
if size(IPS,1) ~= length(t)
    error(['Number of rows in IPS does not match the number ', ...
           'of NMR data points. Check indt after gating.']);
end
if size(IPS,2) ~= length(SV)
    error(['Number of columns in IPS does not match the ', ...
           'number of RTD/PSD bins.']);
end
if length(f) ~= length(SV)
    error(['Length of RTD f does not match the number ', ...
           'of kernel columns.']);
end

%% Kernel matrices
% full saturation
Kf = zeros(length(t),length(SV));
% partial saturation
Kc = zeros(length(t),length(SV));
switch T1T2
    case 'T1'
        % for full saturation
        for i = 1:length(SV)
            Kf(:,i) = 1-T1IRfac.*exp(-t.*(rhos*SV(i)+1/Tb+1/Td));
        end

        % for partial saturation
        for i = 1:size(SVC,1)
            svc = squeeze(SVC(i,:,:));
            amp = squeeze(Amp(i,:,:));
            Kc = Kc + amp.*(1-T1IRfac.*exp(-TT.*(rhos.*svc+1/Tb+1/Td)));
        end

    case 'T2'
        % for full saturation
        for i = 1:length(SV)
            Kf(:,i) = exp(-t.*(rhos*SV(i)+1/Tb+1/Td));
        end

        %for partial saturation
        for i = 1:size(SVC,1)
            svc = squeeze(SVC(i,:,:));
            amp = squeeze(Amp(i,:,:));
            Kc = Kc + amp.*exp(-TT.*(rhos.*svc+1/Tb+1/Td));
        end
    otherwise
        error('Unknown relaxation type "%s".',T1T2);
end

%% select full or partially saturated kernel
%  Fully saturated entries use Kf.
%  Partially saturated entries use the corner kernel Kc.
K = Kf;
K(IPS~=1) = Kc(IPS~=1);
XX = K;

%% corresponding physical NMR signal
%  IMPORTANT:
%  XX and ig remain physical, unweighted quantities.
ig = XX*f;

%% physical residual
res = ig - g;

%% weighting
%  iparam.W contains the standard deviations:
%       W = diag(sigma)
%  The weighted residual therefore is
%       res_i = (ig_i - g_i)/sigma_i
%  Weighting is applied ONLY to the residual.
%  Neither XX nor ig are modified.
if isfield(iparam,'W') && ~isempty(iparam.W)
    sigma = diag(iparam.W);
    if length(sigma) ~= length(res)
        error(['Number of standard deviations does not match ', ...
               'the number of NMR data points.']);
    end
    if any(~isfinite(sigma)) || any(sigma <= 0)
        error('All standard deviations must be finite and > 0.');
    end

    res = res ./ sigma;
end

%% scalar objective function for fminsearchbnd
F = norm(res);

%% output

if nargout > 1
    % physical, unweighted fitted NMR signal
    varargout{1} = ig;
    % physical, unweighted kernel matrix
    varargout{2} = XX;
    % final geometry
    varargout{3} = igeom;
    % final pressure/saturation state
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