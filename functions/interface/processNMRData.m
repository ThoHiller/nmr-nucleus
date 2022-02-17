function [nmrraw,nmrproc] = processNMRData(nmrraw,nmrproc)
%processNMRData processes the NMR raw data
%
% Syntax:
%       [nmrraw,nmrproc] = processNMRData(nmrraw,nmrproc)
%
% Inputs:
%       nmrraw - NMR raw data struct
%       nmrproc - NMR processed data struct
%
% Outputs:
%       nmrraw
%       nmrproc
%
% Example:
%       [nmrraw,nmrproc] = processNMRData(nmrraw,nmrproc)
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% raw signal
% get some info
nmrproc.echotime = nmrraw.t(2)-nmrraw.t(1);
nmrproc.dead = nmrproc.echotime/2;

% crop the signal
nmrraw.t = nmrraw.t(nmrproc.start:nmrproc.end);
nmrraw.s = nmrraw.s(nmrproc.start:nmrproc.end);

% make data a column vector
nmrraw.t = nmrraw.t(:);
nmrraw.s = nmrraw.s(:);

% adjust the time scale
nmrraw.t = nmrraw.t .* nmrproc.timefac;
nmrproc.echotime = nmrproc.echotime * nmrproc.timefac;
nmrproc.dead  = nmrproc.dead * nmrproc.timefac;

% normalize data
if nmrproc.norm == 1
    nmrproc.normfac = max(real(nmrraw.s));
    % nmrproc.normfak = real(nmrraw.signal(1));
    if ~isreal(nmrraw.s)
        nmrraw.s = complex(real(nmrraw.s)./nmrproc.normfac,...
            imag(nmrraw.s)./nmrproc.normfac);
    else
        nmrraw.s = nmrraw.s./nmrproc.normfac;
    end
else
    nmrproc.normfac = 1;
end

%% processed signal 
t = nmrraw.t;
if isreal(nmrraw.s)
    s = nmrraw.s;
    % check if noise was calculated / estimated during import
    % and normalize if necessary
    if isfield(nmrraw,'noise')
        noise = nmrraw.noise./nmrproc.normfac;
    else
        noise = 0;
    end
else
    s = real(nmrraw.s);
    % because the imag-part of the signal is rotated to "0", the noise is
    % simply its "std"
%     noise = std(imag(nmrraw.s));
    % due to possible "weird" noise structures at early echo times this
    % is more rigorous -> only last half of the signal is used:
    range = floor(numel(s)/2):numel(s);
    noise = std(imag(nmrraw.s(range)));    
end

% gating
switch nmrproc.gatetype
    case {'log','lin'}
        tmp = applyGatesToSignal(t,s,'type',nmrproc.gatetype,...
            'Ng',min([numel(s) 300]),'Ne',nmrproc.Nechoes);
        t = tmp(:,1);
        s = tmp(:,2);
        N = tmp(:,3);
    case 'raw'
        N = ones(size(t));
    otherwise
end

% output data
nmrproc.t = t;
nmrproc.s = s;
nmrproc.N = N;
nmrproc.noise = noise;

% if there is noise information and gating was performed
% calculate noise per gate and weight matrix W
if noise ~= 0 && ~strcmp(nmrproc.gatetype,'raw')
        e = noise ./ sqrt(N);
        W = diag(e);
        nmrproc.e = e;
        nmrproc.W = W;
else
    e = noise*ones(size(s));
    nmrproc.e = e;
    if isfield(nmrproc,'W')
        nmrproc = rmfield(nmrproc,'W');
    end
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