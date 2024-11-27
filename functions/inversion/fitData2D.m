function fitdata = fitData2D(data,parameter)
%fitData2D is a control routine that fits 2D NMR data;
%if the Optimization Toolbox is available the user can select LSQLIN,
%otherwise the default built-in LSQNONNEG is used;
%
% Syntax:
%       fitData2D(data,parameter)
%
% Inputs:
%       data - struct that holds the NMR signal data
%       parameter - struct that holds settings:
%
% Outputs:
%       fitdata - struct that holds the inversion results:
%
% Example:
%       [fitdata] = fitData2D(data,parameter)
%
% Other m-files required:
%       Optimization Toolbox from Mathworks (optional)
%       applyRegularization2D
%       createKernelMatrix2D
%       getFitErrors
%       getTLogMean2D
%       lsqnonneg
%       lsqlin (optional)
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

% get the input parameters
% flag = parameter.T1T2;           % T1/T2 switch
T1IRfac = parameter.T1IRfac;       % T1 Sat/Inv Recovery factor
IRtype = parameter.IRtype;         % T1 IR kernel type
% Tb = parameter.Tb;               % bulk relaxation time
% Td = parameter.Td;               % diffusion relaxation time

noise = parameter.noise;
% get system properties
D = parameter.D;
G0 = parameter.G0;
te = parameter.te;

% create model space from relaxation time T vectors
T1min = parameter.T1min;
T1max = parameter.T1max;
T1N = parameter.T1N;
T2min = parameter.T2min;
T2max = parameter.T2max;
T2N = parameter.T2N;

T1vec = logspace(log10(T1min),log10(T1max),T1N);
T2vec = logspace(log10(T2min),log10(T2max),T2N);
MOD = zeros(numel(T2vec),numel(T1vec));

% prepare data vector
Nsignals = numel(data);
Nechos = numel(data(1).t);
dat_vec = zeros(Nsignals*Nechos,1);
for n = 1:numel(data)
    if n == 1
        dat_vec(1:Nechos,1) = data(n).s;
    else
        dat_vec((n-1)*Nechos+1:n*Nechos,1) = data(n).s;
    end
end

% create the Kernel matrix for inversion
p.G0 = G0;
p.D = D;
p.te = te;
p.T1IRfac = T1IRfac;
p.IRtype = IRtype;
[K,indices] = createKernelMatrix2D(data,T1vec,T2vec,p);

% regularization
order = parameter.orderT1;
lambda = [parameter.lamT1 parameter.lamT2];

[KK,dat_inp,LT,LD] = applyRegularization2D(K,order,T2vec,T1vec,indices,dat_vec,lambda);

switch parameter.solver
    case 'lsqlin'
        x0 = zeros(size(KK,2),1);
        lb = zeros(size(KK,2),1);
        ub = ones(size(KK,2),1);

        options = optimoptions('lsqlin');
        options.Display = parameter.info;
        % options.OptimalityTolerance = 1e-16;
        % options.StepTolerance = 1e-16;
        % options.MaxIterations = 2000;
        [f_vec,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqlin(KK,dat_inp,[],[],[],[],...
            lb,ub,x0,options);

    case 'lsqnonneg'
        options = optimset('lsqnonneg');
        options.Display = parameter.info;
        [f_vec,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqnonneg(KK,dat_inp,options);
end

% global model response (fit)
s_fit = K * f_vec;
% global fit errors
out_global = getFitErrors(dat_vec,s_fit,noise);
% local fit errors
for n = 1:numel(data)
    data(n).s_fit = s_fit((n-1)*Nechos+1:n*Nechos);
    out = getFitErrors(data(n).s,data(n).s_fit,data(n).noise);
    data(n).resnorm = out.resnorm;
    data(n).residual = out.residual;
    data(n).chi2 = out.chi2;
    data(n).rms = out.rms;
end

% L-curve parameter
% model norm |L*x|_2
xn = norm([LT;LD]*f_vec,2);
% residual norm |A*x-b|_2
rn = norm(out_global.residual,2);

% create the Kernel matrix for E0
dat0.t=0;
dat0.T1=10000;
[K0,~] = createKernelMatrix2D(dat0,T1vec,T2vec,p);
E0 = K0*f_vec;

% sort the result
f_2Dmap = zeros(size(MOD'));
for n = 1:length(T1vec)
    f_2Dmap(n,:) = f_vec(indices.col_1(n):indices.col_end(n));
end

% get TLGM and TMAX
[TLGM,TMAX] = getTLogMean2D(T1vec,T2vec,f_2Dmap);

% output struct
fitdata.data = data;
fitdata.T1vec = T1vec;
fitdata.T2vec = T2vec;
fitdata.indices = indices;
fitdata.f_vec = f_vec;
fitdata.f_2Dmap = f_2Dmap;
fitdata.E0 = E0;
fitdata.T1tlgm = TLGM(1);
fitdata.T2tlgm = TLGM(2);
fitdata.T1tmax = TMAX(1);
fitdata.T2tmax = TMAX(2);
fitdata.error_global = out_global;
fitdata.xn = xn;
fitdata.rn = rn;
fitdata.solver_out.RESNORM = RESNORM;
fitdata.solver_out.RESIDUAL = RESIDUAL;
fitdata.solver_out.EXITFLAG = EXITFLAG;
fitdata.solver_out.OUTPUT = OUTPUT;
fitdata.param = parameter;
% fitdata.K = K;

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