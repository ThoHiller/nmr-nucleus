function [data,gate] = applyGatesToSignal(time,signal,varargin)
%applyGatesToSignal re-samples (gates) an NMR signal to speed up the
%inversion.
%
% The signal within each gate is averaged arithmetically. In addition to
% the gated data, the function returns the indices of the original data
% points belonging to each gate. This allows the forward kernel to be
% gated consistently with the measured signal.
%
% Syntax:
%       data = applyGatesToSignal(time,signal)
%       data = applyGatesToSignal(time,signal,'type','log')
%       [data,gate] = applyGatesToSignal(time,signal,...)
%
% Inputs:
%       time   - time vector
%       signal - NMR signal vector; complex data are allowed. If complex,
%                the real part is gated and the imaginary part is used
%                to estimate the noise within each gate.
%       varargin - PROPERTY / VALUE options:%
%                   'type'    : 'log', 'logv2' or 'lin'
%                               default: 'log'%
%                   'Ng'      : number of gates / logarithmic sampling
%                               parameter
%                               default: 100%
%                   'Ne'      : maximum number of echoes per gate
%                               default: 500%
%                   'plotit'  : 0 or 1
%                               default: 0%
%                   'special' : 'rwth' or ''
%                               default: ''
%
% Outputs:
%       data(:,1) - mean time of each gate
%       data(:,2) - arithmetic mean signal of each gate
%       data(:,3) - number of echoes in each gate
%       data(:,4) - noise std within each gate, if complex input
%       gate.indices{i} - indices of original data belonging to gate i
%       gate.N          - number of echoes per gate
%       gate.time       - mean time per gate
%       gate.type       - applied gating method
%
% Notes:
%       The arithmetic mean is used intentionally. For independent,
%       identically distributed noise with standard deviation e, the
%       standard deviation of a gated data point is
%
%               sigma_i = e / sqrt(N_i)
%
%       where N_i is the number of echoes in gate i.
%
%       The explicit gate indices can additionally be used to calculate
%       an exactly gated forward kernel:
%
%               K_gate(i,:) = mean(K_raw(indices{i},:),1)
%
% Example:
%       applyGatesToSignal(time,signal,'type','log')
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

%% default settings
type    = 'log';
Ne      = 500;
Ng      = 100;
plotit  = 0;
special = '';

%% input vectors
time = time(:);
signal = signal(:);

if length(time) ~= length(signal)
    error('time and signal must have the same number of elements.');
end
if isempty(time)
    error('time and signal must not be empty.');
end
if any(~isfinite(time))
    error('time must contain finite values only.');
end
if any(~isfinite(real(signal))) || any(~isfinite(imag(signal)))
    error('signal must contain finite values only.');
end

%% property / value input
if mod(length(varargin),2) ~= 0
    error('Optional inputs must be PROPERTY / VALUE pairs.');
end
for i = 1:2:length(varargin)
    prop  = varargin{i};
    value = varargin{i+1};
    switch lower(prop)
        case {'type','flag'}
            if ischar(value) || isstring(value)
                value = lower(char(value));
                if any(strcmp(value,{'log','logv2','lin'}))
                    type = value;
                else
                    error('''type'' must be ''log'', ''logv2'' or ''lin''.');
                end
            else
                error('''type'' must be a character vector or string.');
            end
        case {'ng','no'}
            if isnumeric(value) && isscalar(value) && ...
                    isfinite(value) && value >= 1
                Ng = round(value);
            else
                error('''Ng'' must be a positive scalar value.');
            end
        case {'nechoes','ne'}
            if isnumeric(value) && isscalar(value) && ...
                    isfinite(value) && value >= 1
                Ne = round(value);
            else
                error('''Ne'' must be a positive scalar value.');
            end
        case {'plot','plotit'}
            if isnumeric(value) && isscalar(value)
                plotit = logical(value);
            else
                error('''plotit'' must be a scalar value.');
            end
        case 'special'
            if isempty(value)
                special = '';
            elseif (ischar(value) || isstring(value)) && ...
                    strcmpi(value,'rwth')
                special = 'rwth';
            else
                error('''special'' can only be ''rwth'' or empty.');
            end
        otherwise
            warning('applyGatesToSignal:UnknownOption', ...
                'Unknown option "%s".',prop);
    end
end

%% complex signal
%  The real part is the NMR signal.
%  The imaginary part is retained for noise estimation.
iscomplex = ~isreal(signal);

if iscomplex
    Ipart = imag(signal);
    signal = real(signal);
else
    Ipart = [];
end

%% time unit
% Kept for compatibility with the original RWTH special handling.
tfak = 1;
if max(time) > 30
    tfak = 1e3;
end

%% construct gate indices
%  All three methods generate gate.indices. The actual averaging is then
%  performed in one common section below.
gate.indices = {};
switch lower(type)
    % LOG
    % Increasing number of echoes per gate:
    %       1, ..., Ne
    % followed by gates containing at most Ne echoes.
    case 'log'
        % logarithmically increasing number of echoes per gate
        index = round(logspace(0,3,Ng));

        % optional RWTH handling:
        % merge first three data points if they are below 0.001 s
        if strcmpi(special,'rwth') && length(time) >= 3
            if all(time(1:3) < 1e-3*tfak)
                index(1) = 3;
            end
        end
        % find value closest to requested maximum Ne
        [~,ind] = min(abs(index-Ne));
        M = index(ind);

        % keep increasing gates up to M
        index = index(1:ind);

        % create gates sequentially
        iStart = 1;
        iGate  = 0;
        while iStart <= length(time)
            iGate = iGate + 1;
            if iGate <= length(index)
                nThis = index(iGate);
            else
                % after reaching M, use constant gate size
                nThis = M;
            end

            iEnd = min(iStart+nThis-1,length(time));
            gate.indices{iGate,1} = (iStart:iEnd)';
            iStart = iEnd+1;
        end

    % LOGV2
    % Logarithmically spaced gate boundaries in time.
    % This retains the basic concept of the original MRSMatlab routine,
    % but explicitly creates non-overlapping index sets.
    case 'logv2'
        if length(time) < 2
            error('''logv2'' requires at least two time points.');
        end

        % The original implementation used time(2) as the logarithmic
        % offset. Retain this behavior.
        dt0 = time(2);
        if dt0 <= 0
            error(['''logv2'' requires time(2) > 0 for logarithmic ', ...
                   'gate construction.']);
        end

        % logarithmically spaced representative boundaries
        t1 = abs(logspace(log10(dt0),log10(time(end)+dt0),Ng)-dt0);

        % convert time boundaries to indices
        tInd = zeros(size(t1));
        for n = 1:length(t1)
            ind = find(time >= t1(n),1,'first');
            if isempty(ind)
                ind = length(time);
            end
            tInd(n) = ind;
        end

        % enforce valid and unique boundaries
        tInd = unique(tInd,'stable');
        tInd(tInd < 1) = [];
        tInd(tInd > length(time)) = [];

        % make sure first point is included
        if isempty(tInd) || tInd(1) ~= 1
            tInd = [1 tInd];
        end

        % use boundaries to construct non-overlapping gates
        iGate = 0;
        for n = 1:length(tInd)-1
            iStart = tInd(n);
            iEnd = tInd(n+1)-1;

            if iEnd >= iStart
                iGate = iGate+1;
                gate.indices{iGate,1} = (iStart:iEnd)';
            end
        end

        % final gate includes all remaining points
        iStart = tInd(end);
        if iStart <= length(time)
            iGate = iGate+1;
            gate.indices{iGate,1} = (iStart:length(time))';
        end

    % LIN
    % Approximately constant number Ne of echoes per gate.
    %
    % This replaces the previous time-mask implementation by explicit,
    % consecutive index ranges. This prevents empty gates and guarantees
    % that every data point belongs to exactly one gate
    case 'lin'
        % retain original interpretation:
        % Ne controls approximately how many echoes belong to one gate
        NgLin = max(1,round(length(time)/Ne));
        % distribute all data points as evenly as possible over NgLin gates
        edges = round(linspace(0,length(time),NgLin+1));

        iGate = 0;
        for n = 1:NgLin
            iStart = edges(n)+1;
            iEnd   = edges(n+1);
            if iEnd >= iStart
                iGate = iGate+1;
                gate.indices{iGate,1} = (iStart:iEnd)';
            end
        end
end

%% consistency check of gate indices
%  Every raw data point must occur exactly once.
if isempty(gate.indices)
    error('No valid gates could be generated.');
end

allInd = vertcat(gate.indices{:});
if length(allInd) ~= length(time) || ...
        any(sort(allInd) ~= (1:length(time))')
    error(['Invalid gate definition: every input data point must ', ...
           'belong to exactly one gate.']);
end

%% calculate gated data
%  IMPORTANT:
%  arithmetic averaging is used for ALL gating methods
nGates = length(gate.indices);
t = zeros(nGates,1);
signal_g = zeros(nGates,1);
Nechos   = zeros(nGates,1);

if iscomplex
    Noise = zeros(nGates,1);
end

for i = 1:nGates
    ind = gate.indices{i};
    % representative time
    t(i) = mean(time(ind));
    % arithmetic mean of NMR signal
    signal_g(i) = mean(signal(ind));
    % actual number of echoes in this gate
    Nechos(i) = length(ind);
    % local estimate from imaginary channel
    if iscomplex
        if length(ind) > 1
            Noise(i) = std(Ipart(ind));
        else
            % standard deviation cannot be estimated from one sample
            Noise(i) = NaN;
        end
    end
end

%% output data
if iscomplex
    data = zeros(nGates,4);
else
    data = zeros(nGates,3);
end
data(:,1) = t;
data(:,2) = signal_g;
data(:,3) = Nechos;
if iscomplex
    data(:,4) = Noise;
end

%% additional gate information
gate.N    = Nechos;
gate.time = t;
gate.time_raw = time;
gate.type = type;

%% plot (optional)
if plotit
    figure;
    subplot(2,1,1);
    plot(time,signal,'-');
    hold on;
    plot(t,signal_g,'ko');
    xlabel('Time');
    ylabel('Signal');
    title(['Gating: ',type]);

    subplot(2,1,2);
    semilogx(time,signal,'+-');
    hold on;
    semilogx(t,signal_g,'ko');
    xlabel('Time');
    ylabel('Signal');
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