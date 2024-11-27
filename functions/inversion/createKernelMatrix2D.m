function [K,indices] = createKernelMatrix2D(dat,T1vec,T2vec,p)
%createKernelMatrix2D creates a Kernel matrix from signals time vectors "t"
%and relaxation time vector "T1vec" and "T2vec"
%
% Syntax:
%       createKernelMatrix2D(dat,T1vec,T2vec,G0,D,te,T1IRfac)
%
% Inputs:
%       dat - struct holding signal data including time vector "t" in [s]
%       T1vec - relaxation times vector in [s]
%       T2vec - relaxation times vector in [s]
%       p - struct holding optional settings
%           G0 - gradient in [T/m]
%           D - diffusion coefficient [m²/s]
%           te - echo time in [s]
%           Tbulk - Bulk relaxation time in [s]
%           T1IRfac - 1 or 2 (Sat. or Inv. Recovery)
%           IRtype - 1 or 2 (1-2exp() or -exp())
%
% Outputs:
%       K - Kernel matrix size(length(t),length(T1vec)*length(T2vec))
%       indices - struct holding tile indices
%
% Example:
%       K = createKernelMatrix(dat,T1,T2,0,2e-9,2e-4,2)
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

%%
useTbulk = false;
if isfield(p,'Tbulk')
    useTbulk = true;
    Tbulk = p.Tbulk;
end
if isfield(p,'G0')
    G0 = p.G0;
else
    G0 = 0;
end
if isfield(p,'D')
    D = p.D;
else
    D = 2.025e-09;
end
if isfield(p,'te')
    te = p.te;
else
    te = 2e-4;
end
if isfield(p,'T1IRfac')
    T1IRfac = p.T1IRfac;
else
    T1IRfac = 2;
end
if isfield(p,'IRtype')
    IRtype = p.IRtype;
else
    IRtype = 1;
end

%% gyromagnetic ratio of hydrogen
gyro = 0.267*1e9; % [rad/(T*s)]

%% how many recovery times?
num_T1 = length(dat);

%% init data
lin_1 = zeros(1,num_T1);
lin_end = zeros(1,num_T1);
col_1 = zeros(1,numel(T1vec));
col_end = zeros(1,numel(T1vec));

% determine cumulative length of all involved t-vectors
t_dim = 0;
for nn = 1:num_T1
    lin_1(nn) = 1 + t_dim;
    t_dim = t_dim + length(dat(nn).t);
    lin_end(nn) = t_dim;
end
K = zeros(t_dim,length(T1vec)*length(T2vec));

% assemble kernel
for n = 1:numel(T1vec)
    % determine current tile:
    col_1(n) = (n-1) * length(T2vec) + 1;
    col_end(n) = n * length(T2vec);
    for nn = 1:num_T1
        % time vectors
        tr = repmat(dat(nn).t(:),[1,numel(T2vec)]);
        Tr = repmat(T2vec,[numel(dat(nn).t),1]);
        % diffusion relaxation rate:
        Tdiff_rate = (D*(gyro*G0*te)^2)/12;
        % T1 relaxation
        if IRtype == 1
            T1loss = (1-T1IRfac*exp(-dat(nn).T1/T1vec(n)));
        else
            % after Hürlimann 2001 JMR
            T1loss = -(exp(-dat(nn).T1/T1vec(n)));
        end
        % kernel
        if useTbulk
            K(lin_1(nn):lin_end(nn),col_1(n):col_end(n)) = T1loss*exp(-tr./Tr).*exp(-tr.*Tdiff_rate).*exp(-tr./Tbulk);
        else
            K(lin_1(nn):lin_end(nn),col_1(n):col_end(n)) = T1loss*exp(-tr./Tr).*exp(-tr.*Tdiff_rate);
        end        
    end
end

% struc holding tile indices
indices.lin_1 = lin_1;
indices.lin_end = lin_end;
indices.col_1 = col_1;
indices.col_end = col_end;

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2024 Thomas Hiller
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