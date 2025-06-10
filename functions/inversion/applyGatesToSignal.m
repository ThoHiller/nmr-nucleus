function data = applyGatesToSignal(time,signal,varargin)
%applyGatesToSignal re-samples (gates) a NMR signal to speedup the
%inversion
%
% Syntax:
%       applyGatesToSignal(time,signal,varargin)
%
% Inputs:
%       time - time vector
%       signal - NMR signal vector (no complex data allowed!)
%       varargin - PROPERTY - VALUE OPTIONS:
%                    'type' - 'log', 'logv2' or 'lin' (default is 'log')
%                      'Ng' - No. of gates (default is 100)
%                      'Ne' - max. No. of echoes per gate (default is 50)
%                  'plotit' - '0' or '1' (default is 0)
%                 'special' - 'rwth' or '' (default is '')
% Outputs:
%       data(:,1) - re-sampled time t
%       data(:,2) - re-sampled signal
%       data(:,3) - No. of echoes per gate
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
type = 'log';
Ne = 500;
Ng = 100;
plotit = 0;
special = '';

%% input argument checking
if nargin > 2
    lv = length(varargin);
    if mod(lv,2)~=0
        disp('applyGatesToSignal: Check you input Property/Value!');
        disp('applyGatesToSignal: Using defaults.');
    else
        for i = 1:lv/2
            prop = varargin{2*i-1};
            value = varargin{2*i};
            if strcmpi(prop,'type') || strcmpi(prop,'flag')
                if ischar(value) && (strcmpi(value,'log') ||...
                        strcmpi(value,'logv2') || strcmpi(value,'lin'))
                    type = value;
                else
                    disp('applyGatesToSignal: ''type'' must be either ''log'', ''logv2'' or ''lin''');
                    disp('applyGatesToSignal: Using default: log.');
                end
            end
            if strcmpi(prop,'Ng')|| strcmpi(prop,'No')
                if isnumeric(value)
                    Ng = value;
                else
                    disp('applyGatesToSignal: ''Ng'' must be a scalar value.');
                    disp('applyGatesToSignal: Using default: 100.');
                end
            end
            if strcmpi(prop,'Nechoes')|| strcmpi(prop,'Ne')
                if isnumeric(value)
                    Ne = value;
                else
                    disp('applyGatesToSignal: ''Nechoes'' must be a scalar value.');
                    disp('applyGatesToSignal: Using default: 50.');
                end
            end
            if strcmpi(prop,'plot')|| strcmpi(prop,'plotit')
                if isnumeric(value)
                    plotit = value;
                else
                    disp('applyGatesToSignal: ''plotit'' must be a scalar value.');
                    disp('applyGatesToSignal: Using default: 0.');
                end
            end
            if strcmpi(prop,'special')
                if ischar(value) && strcmpi(value,'rwth')
                    special = value;
                else
                    disp('applyGatesToSignal: ''special'' can only be ''rwth''.');
                    disp('applyGatesToSignal: Using default: none');
                end
            end
        end
    end
end

%% complex signal -> noise per gate
isimag = false;
if ~isreal(signal)
    isimag = true;
    Ipart = imag(signal);
    signal = real(signal);
end

%% shift correction from MMP:
VbaseCorr = abs(10*min(signal)); % necessary for log to be real
signal = signal + VbaseCorr;  % shift signal into positive

%% get time range 'ms' or 's'
tfak = 1;
if max(time) > 30
    tfak = 1e3;
end

%% applying the gates
switch type
    case 'log'
        % get a log-spaced vector with numbers of echoes per gate
        index = round(logspace(0,3,Ng));
        
        if strcmp(special,'rwth')
            % merge the first 3 data points if they are below 0.001 s
            if all(time(1:3)<1e-3*tfak)
                index(1) = 3;
            end
        end
        % the maximal No of echoes per time gates is set to M=50
        % this stabilizes / improves the RMS estimation
%         if numel(time) < 20000
%             M = 50;
%         else
%             M = 150;
%         end
        M = Ne;
        % find the first one where the number of echoes is M
        ind = find(abs(index-M)==min(abs(index-M)),1,'first');
        % maybe M is not exactly within index due to rounding issues
        % then take the closest one
        M = index(ind);
        i1 = find(index==M,1,'last');
        % sum up all gates up to M
        s1 = cumsum(index(1:i1));
        % how many gates with M echoes we need to add to get the whole
        % signal
        N = ceil((length(time)-s1(end))/M);
        % make a new index vector
        index = [index(1:i1) M*ones(1,N)];
        % sum up all gates
        ci = cumsum(index);
        % find the last one we need to re-sample the whole signal
        indc = find(ci>=length(time),1,'first');
        
        t = zeros(indc,1);
        signal_g = zeros(indc,1);
        Nechos = zeros(indc,1);
        Noise = zeros(indc,1);
        % now loop over all gates
        for i = 1:indc
            if i == 1                
                t(i) = mean(time(1:ci(i)));
                signal_g(i) = exp(mean(log(signal(1:ci(i)))));
                Nechos(i) = index(i);
                if isimag
                    if numel(1:ci(i)) == 1
                        Noise(i) = Ipart(1:ci(i));
                    else
                        Noise(i) = std(Ipart(1:ci(i)));
                    end
                end
            elseif i > 1 && i < indc
                t(i) = mean(time(ci(i-1)+1:ci(i)));
                signal_g(i) = exp(mean(log(signal(ci(i-1)+1:ci(i)))));
                Nechos(i) = index(i);
                if isimag
                    if numel(ci(i-1)+1:ci(i)) == 1
                        Noise(i) = Ipart(ci(i-1)+1:ci(i));
                    else
                        Noise(i) = std(Ipart(ci(i-1)+1:ci(i)));
                    end
                    
                end
            end
            if i == indc
                t(i) = mean(time(ci(i-1):end));
                signal_g(i) = exp(mean(log(signal(ci(i-1):end))));
                Nechos(i) = length(time)-ci(i-1)+1;
                if isimag                    
                    Noise(i) = std(Ipart(ci(i-1):end));
                end
            end
        end

    case 'logv2'
        % gateing routine from MRSMatlab by MMP
        
        % new log spaced time vector
        t1 = abs(logspace(log10(time(2)),log10(time(end)+time(2)),Ng) - time(2));

        % get indices
        tInd = ones(1,length(t1));
        for n=2:length(t1)-1
            tInd(n) = find(t1(n)<=time,1);
        end
        if ~isempty(find(t1(end)<=time,1)) % avoid crash
            tInd(end) = find(t1(end)<=time,1);
        else
            tInd(end) = length(t1);
        end
        
        % find unique indecies
        tInd = unique(tInd);
        tInd = cumsum([0 sort(diff(tInd))])+1;
        
        % prepare output data
        signal_g = zeros(1,length(tInd)-1);
        t = zeros(1,length(tInd)-1);
        Nechos = zeros(1,length(tInd)-1);

        % calculate mean within a gate in logspace
        for n=2:length(tInd)
            signal_g(n-1) = exp(mean(log(signal(tInd(n-1):tInd(n)-1))));
            t(n-1) = mean(time(tInd(n-1):tInd(n)-1));
            Nechos(n-1) = length(time(tInd(n-1):tInd(n)-1));
        end
        
    case 'lin'
        
        % if more echoes per gate are desired, than the number of gates
        % gives: update the number of gates ;-)
%         if numel(time)/Ng > Ne
            Ng = round(numel(time)/Ne);            
%         end
        
        % get a lin-spaced time vector
        timeg = linspace(time(2),time(end),Ng);
        t = zeros(Ng,1);
        signal_g = zeros(Ng,1);
        signal_std = zeros(Ng,1);
        Nechos = zeros(Ng,1);
        for i = 1:Ng
            if i == 1
                signal_g(i,1)= mean( signal(time<=timeg(i)) );
                signal_std(i,1) = std( signal(time<=timeg(i)) );
                Nechos(i,1) = length( signal(time<=timeg(i)) );
                t(i,1) = 0 + timeg(1)/2;
            else
                signal_g(i,1) = mean( signal(time<=timeg(i) & time>timeg(i-1)) );
                signal_std(i,1) = std( signal(time<=timeg(i) & time>timeg(i-1)) );
                Nechos(i,1) = length( signal(time<=timeg(i) & time>timeg(i-1)) );
                t(i,1) = timeg(i-1) + (timeg(i)-timeg(i-1))/2;
            end
        end
end

% shift correction from MMP:
signal = signal - VbaseCorr; % subtract shift
signal_g = signal_g - VbaseCorr; % subtract shift

% output struct
data(:,1) = t;
data(:,2) = signal_g;
data(:,3) = Nechos;
if isimag
 data(:,4) = Noise;
end

% if plotit is set to 1
if plotit == 1
    figure;
    subplot(211)
    plot(time,signal); hold on
    if strcmp(type,'lin')
        errorbar(t,signal_g,signal_std,'ko');
    else
        plot(t,signal_g,'ko');
    end    
    subplot(212);
    semilogx(time,signal,'+-'); hold on
    semilogx(t,signal_g,'ko');
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