function t = getNMRTimeVector(TE,TEunit,varargin)
%getNMRTimeVector Creates a NMR time vector depending on the given echo
%time TE
%
% Syntax:
%       getNMRTimeVector(TE,TEunit,varargin)
%
% Inputs:
%       TE - echo time
%       TEunit - unit of the input echo time TE; can be either 's', 'ms'
%                or 'µs'
%       varargin - optional PROPERTY - VALUE OPTIONS:
%           'N'    - number of sampling points
%           'tmax' - maximum time in 's'
%                    NOTE: it only makes sense to choose either 'N' or
%                   'tmax' as input
%           'RWTH' - 'on' or 'off' -> will treat the echo time spacing
%                     according to the RWTH lab if set to 'on'
%
% Outputs:
%       t - time vector in [s]
%
% Example:
%       t = getNMRTimeVector(1,'ms');
%       t = getNMRTimeVector(1,'ms','N',10000);
%       t = getNMRTimeVector(231,'µs','N',16000,'RWTH','on');
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

%% default values
N = 1000;
touse = 'N';
dorwth = 'off';

%% check input parameter
if mod(nargin,2)~=0
    disp('getNMRTimeVector: Check you input Property/Value!');
else
    for i = 1:(nargin-2)/2
        prop  = varargin{2*i-1};
        value = varargin{2*i};
        if strcmpi(prop,'RWTH')
            if ischar(value) && (strcmpi(value,'on') || strcmpi(value,'off'))
                dorwth = value;
            else
                disp('getNMRTimeVector: ''RWTH'' must be either ''on'' or ''off''');
            end
        end
        if strcmpi(prop,'N')
            if ~ischar(value)
                N = value;
                touse = 'N';
            else
                disp('getNMRTimeVector: ''N'' must be a scalar value.');
            end
        end
        if strcmpi(prop,'tmax')
            if ~ischar(value) 
                tmax = value;
                touse = 'tmax';
            else
                disp('getNMRTimeVector: ''tmax'' must be a scalar value.');
            end
        end        
    end
end

%% conversion of the echo time TE into [s]
switch TEunit
    case 's'
        Tfak = 1;
    case 'ms'
        Tfak = 1e3;
    case 'µs'
        Tfak = 1e6;
end
TE = TE / Tfak;

%% generate the time vector
switch touse
    % use a given No of sampling points N
    case 'N'
        t = zeros(N,1);
        switch dorwth
            case 'on'
                t(2) = TE/2;
            case 'off'
                t(2) = TE;
        end
        t(3:end) = t(2) + cumsum(TE.*ones(N-2,1));
    
    % use a maximum time tmax
    case 'tmax'
        t = 0:TE:tmax+TE;
        switch dorwth
            case 'on'
                 t = [0 TE/2 TE/2+t(2:end)];
            case 'off'
                 t = [0 TE TE+t(2:end)];
        end       
        dt = abs(t-tmax);
        ind = find(dt==min(dt),1,'last');
        t = t(1:ind)';
end

%% make it a row vector
t = t(:)';

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