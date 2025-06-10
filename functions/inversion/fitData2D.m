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
s_vec = zeros(Nsignals*Nechos,1);
for n = 1:numel(data)
    if n == 1
        s_vec(1:Nechos,1) = data(n).s;
    else
        s_vec((n-1)*Nechos+1:n*Nechos,1) = data(n).s;
    end
end
% prepare error vector when gated
if parameter.useLogGates
    e_vec = zeros(Nsignals*Nechos,1);
    for n = 1:numel(data)
        if n == 1
            e_vec(1:Nechos,1) = data(n).e;
        else
            e_vec((n-1)*Nechos+1:n*Nechos,1) = data(n).e;
        end
    end
end

% create the Kernel matrix for inversion
p.G0 = G0;
p.D = D;
p.te = te;
p.T1IRfac = T1IRfac;
p.IRtype = IRtype;
[K,indices] = createKernelMatrix2D(data,T1vec,T2vec,p);

% weight the data and kernel in case of gateing
if parameter.useLogGates
    if parameter.noise == 0
        W = diag(ones(size(e_vec)));
    else
        W = diag(1./e_vec);
    end
    dat_vec = W*s_vec;
    K = W*K;
else
    dat_vec = s_vec;
end

% scale everything between [0,1]
maxS = max(dat_vec);
dat_vec = dat_vec./maxS;
K = K./maxS;

% regularization
order = parameter.orderT1;
lambda = [parameter.lamT2 parameter.lamT1];
regMethod = parameter.regMethod;

% this is essentially what happens next:
% 1. get a smoothness constraint matrix
% 2. scale them by lambda
% 3. extent kernel matrix K accordingly
%
% L = [lambda(T2)*LT2;lambda(T1)*LT1];
% Kreg = [K;L];

% get smoothness constrain matrices
[LT2,LT1,dat_inp] = getSmoothness2D(order,T2vec,T1vec,indices,dat_vec);

% extend K and apply regularization
% 'manual' | 'gcv_tikh' | 'gcv_trunc' | 'gcv_damp' | 'discrep'
[KK,lambda_out] = applyRegularization2D(K,dat_vec,LT2,LT1,lambda,...
    regMethod,order,parameter.noise./maxS);

% solve LSE
t1 = toc;
switch parameter.solver
    case 'lsqlin'
        % only the Optimization toolbox allows using bounds
        x0 = zeros(size(KK,2),1);
        lb = zeros(size(KK,2),1);
        ub = maxS.*ones(size(KK,2),1);
        
        % force certain RTs to 0 (switch in EXTRA menu)
        if strcmp(parameter.EchoFlag,'on')
            T1cut = data(1).T1(1)/5;
            T2cut = parameter.te/5;
            if T1cut < T2cut
                T1cut = T2cut;
            end            
            ub = maxS.*ones(numel(T2vec),numel(T1vec));
            ub(:,T1vec<T1cut,:) = 0;
            ub(T2vec<T2cut,:) = 0;
            ub = reshape(ub,[numel(T1vec)*numel(T2vec) 1]);
        end

        options = optimoptions('lsqlin');
        options.Display = parameter.info;
        % activate and use these options only when you know what you are doing
        % options.OptimalityTolerance = 1e-16;
        % options.StepTolerance = 1e-16;
        % options.MaxIterations = 1000;
        [f_vec,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqlin(KK,dat_inp,[],[],[],[],...
            lb,ub,x0,options);

    case 'lsqnonneg'
        % native Matlab built-in LSQ-solver
        options = optimset('lsqnonneg');
        options.Display = parameter.info;
        [f_vec,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = lsqnonneg(KK,dat_inp,options);
end
t2 = toc;
OUTPUT.solver_time = t2-t1;
% disp(OUTPUT.solver_time);

% get the fit (rescale the f distribution)
g_fit = KK*(f_vec.*maxS);
% cut off the regularization part
s_fit = g_fit(1:length(s_vec),1);

% get errors
if parameter.useLogGates
    % remove the error weights from the fit
    e = diag(W);
    einv = 1./e;
    Winv = diag(einv);
    s_fit = Winv * s_fit;

    % get global fit errors
    out_global = getFitErrors(s_vec,s_fit,noise,Winv);
    % get local fit errors (for every T2 signal)
    for n = 1:numel(data)
        data(n).s_fit = s_fit((n-1)*Nechos+1:n*Nechos);
        W1 = diag(data(n).e);
        out = getFitErrors(data(n).s,data(n).s_fit,data(n).noise,W1);
        data(n).resnorm = out.resnorm;
        data(n).residual = out.residual;
        data(n).chi2 = out.chi2;
        data(n).rms = out.rms;
    end
else
    % get global fit errors
    out_global = getFitErrors(s_vec,s_fit,noise);
    % get local fit errors (for every T2 signal)
    for n = 1:numel(data)
        data(n).s_fit = s_fit((n-1)*Nechos+1:n*Nechos);
        out = getFitErrors(data(n).s,data(n).s_fit,data(n).noise);
        data(n).resnorm = out.resnorm;
        data(n).residual = out.residual;
        data(n).chi2 = out.chi2;
        data(n).rms = out.rms;
    end
end

% L-curve parameter
% model norm |L*x|_2
xn = norm([LT2;LT1]*f_vec,2);
% residual norm |A*x-b|_2
rn = norm(out_global.residual,2);

% create the Kernel matrix for E0
dat0.t = 0; % shortest T2 echo time [s]
dat0.T1 = 10000; % longest T1 time [s]
[K0,~] = createKernelMatrix2D(dat0,T1vec,T2vec,p);
E0 = K0*f_vec;

% remap the result vector ina  2D matrix
f_2Dmap = zeros(size(MOD'));
for n = 1:length(T1vec)
    f_2Dmap(n,:) = f_vec(indices.col_1(n):indices.col_end(n));
end

% get TLGM and TMAX of the map
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
fitdata.chi2 = out_global.chi2;
fitdata.xn = xn;
fitdata.rn = rn;
fitdata.lambda_out = lambda_out;
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