function [invstd,uncert] = estimateUncertainty(invtype,invstd,iparam,parameter)
%estimateUncertainty calculates pseudo uncertainty estimates for multi
%modal and LSQ inversion results
%
% Syntax:
%       estimateUncertainty(invtype,invstd,iparam,parameter)
%
% Inputs:
%       invtype - string indicating the inversion method of the optimal
%                 fit ('NNLS' or 'MUMO')
%       invstd - struct holding inversion results of the optimal fit
%       iparam - struct holding original inversion settings
%       parameter - struct that holds settings:
%                   uncertMethod : which calculation method to use for
%                                  'MUMO' the options are 'thresh' and 'ci' for
%                                  'NNLS' the options are 'RTD_var', 'Lambda',
%                                  'RMS_bound' and 'RMS_free'
%                   uncertThresh : threshold for uncertainty search range
%                   uncertChi2   : stop criteria for the chi2 deviation
%                   uncertN      : number of models to calculate
%                   uncertMax    : total number of unsuccessful attempts
%                                  after which the calculation is stopped
%
% Outputs:
%       invstd - same as input struct
%       uncert - uncertainty data
%
% Example:
%       [invstd] = estimateUncertainty('MUMO',invstd,iparam,uparam)
%
% Other m-files required:
%       createKernelMatrix
%       displayStatusText
%       fitDataLSQ
%       getFitErrors
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

%% get GUI handle and data
fig = findobj('Tag','INV');
if ~isempty(fig)
    gui = getappdata(fig,'gui');
else
    % this routine will sill call 'displayStatusText' but then the output
    % is displayed at the command line
    gui = 0;
end

% get the main parameters
uncertMethod = parameter.uncertMethod;
uncertChi2 = parameter.uncertChi2;
uncertThresh = parameter.uncertThresh;
uncertN = parameter.uncertN;
uncertMax = parameter.uncertMax;

% original data that was fitted
time = parameter.time;
signal = parameter.signal;

% kernel matrices for pure (single) E0 estimation and a second one
% that extends the original time vector to "0" -> needed for nicer plots of
% uncertainty towards shorter times
switch iparam.T1T2
    case 'T1'
        K0 = createKernelMatrix(10*time(end),invstd.T1T2me',...
            iparam.Tb,iparam.Td,'T1',iparam.T1IRfac);
        
        time0 = [time' 2*time(end) 5*time(end) 10*time(end)];
        K0f = createKernelMatrix(time0,invstd.T1T2me',...
            iparam.Tb,iparam.Td,'T1',iparam.T1IRfac);
    case 'T2'
        K0 = createKernelMatrix(0,invstd.T1T2me',iparam.Tb,...
            iparam.Td,'T2',iparam.T1IRfac);
        
        time0 = [0 1e-6 time(1)/10 time(1)/5 time(1)/3 time(1)/2 time'];
        K0f = createKernelMatrix(time0,invstd.T1T2me',iparam.Tb,...
            iparam.Td,'T2',iparam.T1IRfac);
end

% switch depending on inversion method
switch invtype
    case 'MUMO'
        % data needed from the optimal fit
        T = invstd.T;
        S = invstd.S;
        E = invstd.E;
        x = invstd.x;
        lb = invstd.lb;
        ub = invstd.ub;
        ci = invstd.ci;
        
        % kernel for the original fit needed for comparison of the uncertainty models
        K = createKernelMatrix(time,invstd.T1T2me',iparam.Tb,iparam.Td,...
            iparam.T1T2,iparam.T1IRfac);
        
        % counter
        count = 0;
        countm = 0;
        
        % initialize variables
        TDIST = zeros(uncertN,numel(invstd.T1T2me));
        SINTERP = zeros(numel(time0),uncertN);
        E0INTERP = zeros(uncertN,1);
        % calculate uncertainty models
        while count < uncertN
            switch uncertMethod
                case 'thresh'
                    % randomly vary all parameters +- thresh
                    a = 1-uncertThresh;
                    b = 1+uncertThresh;
                    rr = (b-a).*rand(1,length(ci)) + a;
                    Ti = log(T).*rr(1:3:end); % do it on log-scale
                    Si = S.*rr(2:3:end);
                    Ei = E.*rr(3:3:end);
                    
                    xi = zeros(size(x));
                    xi(1:3:end) = Ti;
                    xi(2:3:end) = Si;
                    xi(3:3:end) = Ei;
                case 'ci'
                    % randomly vary parameters within confidence interval
                    rr = 2.*rand(1,length(ci))-1;
                    xi = zeros(size(x));
                    xi(1:3:end) = log(T);
                    xi(2:3:end) = S;
                    xi(3:3:end) = E;
                    xi = xi+ci'.*rr;
            end
            
            % adjust for bounds if necessary
            xi(xi<lb) = lb(xi<lb);
            xi(xi>ub) = lb(xi>ub);
            
            % temporary values
            Ti = exp(xi(1:3:end)); % transform back to lin-scale
            Si = xi(2:3:end);
            Ei = xi(3:3:end);
            
            % create a temporary distribution with the new parameters
            TdistI = 0;
            for i = 1:numel(T)
                tmp = 1./( Si(i)*sqrt(2*pi)).*exp(-((log(invstd.T1T2me') - log(Ti(i)))/ sqrt(2)/Si(i)).^2);
                % scale to amplitude
                if sum(tmp)>0
                    tmp = (tmp/sum(tmp)) * Ei(i);
                end
                % add the tmp per mu to Tdist
                TdistI = TdistI + tmp;
            end
            % calculate temporary signal(s)
            s_interp = K*TdistI';
            s0_interp = K0f*TdistI';
            
            % get residuals and error measures
            if isfield(iparam,'W')
                % when signal gating was used the error estimates need to be adjusted
                outI = getFitErrors(signal,s_interp,iparam.noise,iparam.W);
            else
                outI = getFitErrors(signal,s_interp,iparam.noise);
            end
            
            % check if the temporary chi2 is within the desired limit
            if abs(1-outI.chi2/invstd.chi2) <= uncertChi2
                % if YES then keep it
                count = count + 1;
                % save RTD
                TDIST(count,:) = TdistI;
                % save signal
                SINTERP(:,count) = s0_interp;
                % save E0
                E0INTERP(count,1) = K0*TdistI';
                % status bar info
                infostring = ['Calculating uncertainty models: ',...
                    num2str(count),' / ',num2str(uncertN)];
                displayStatusText(gui,infostring);
                % reset max counter
                countm = 0;
            else
                % as long as we did not find a model keep counting
                if count < 1
                    countm = countm + 1;
                    infostring = ['Trying to find uncertainty model: ',...
                        num2str(countm),' / ',num2str(uncertMax)];
                    displayStatusText(gui,infostring);
                end
            end
            % after to many unsuccessful attempts STOP
            if countm > uncertMax
                infostring = ['No uncertainty model found: ',...
                    num2str(countm),' / ',num2str(uncertMax)];
                displayStatusText(gui,infostring);
                break;
            end
        end
        
        % output data
        if sum(E0INTERP) > 0
            % E0 from uncertainy calculation
            invstd.E0 = mean(E0INTERP);
            % simple E0 confidence interval
            invstd.ciE0 = 2*std(E0INTERP);
        end

        % uncertainty calculation results
        uncert.interp_t = time0(:);
        uncert.interp_E0 = E0INTERP;
        uncert.interp_f = TDIST;
        uncert.interp_s = SINTERP;
        
        % uncertainty patch for fitted signal -> mean +-2*std
        meantmp = mean(SINTERP,2);
        stdtmp = std(SINTERP,0,2);
        uncert.interp_s_min = meantmp-2*stdtmp;
        uncert.interp_s_max = meantmp+2*stdtmp;
        
        % uncertainty patch for fitted RTD -> mean +-2*std
        meantmp = mean(TDIST);
        stdtmp = std(TDIST);
        uncert.interp_f_min = meantmp-2*stdtmp;
        uncert.interp_f_max = meantmp+2*stdtmp;
        
        invstd.uncert = uncert;
        
    case 'NNLS'
        
        % 'RTD_var' | 'Lambda' | 'RMS_bound' | 'RMS_free'
        % uncertMethod = 'RMS_bound';
        
        switch uncertMethod
            case 'RTD_var'
                % find uncertainty models by varying the optimal RTD bins
                % individually
                
                % uncertN = 5;
                % uncertThresh = 0.1;
                % uncertChi2 = 0.05;
                f_final = invstd.T1T2f;
                
                % initialize variables
                % NOTE: we save 'uncertN' models for each RTD bin
                TDIST = zeros(uncertN*numel(invstd.T1T2me),numel(invstd.T1T2me));
                SINTERP = zeros(numel(time0),uncertN*numel(invstd.T1T2me));
                E0INTERP = zeros(uncertN*numel(invstd.T1T2me),1);
                % loop over all RTD bins
                for i1 = 1:numel(f_final)
                    count = 0;
                    while count < uncertN
                        % start RTD is always the optimal one
                        x0 = f_final;
                        % global bounds
                        lb = zeros(size(x0));
                        ub = max(f_final).*3.*ones(size(x0));
                        % now draw a random value for the current RTD bin
                        a = 1-uncertThresh;
                        b = 1+uncertThresh;
                        rr = (b-a).*rand(1,1) + a;
                        % adjust the initial model and bounds accordingly
                        x0(i1) = f_final(i1)*rr;
                        lb(i1) = x0(i1);
                        ub(i1) = x0(i1);
                        
                        % save bounds for the LSQ inversion
                        iparam.bounds.lb = lb;
                        iparam.bounds.ub = ub;
                        iparam.bounds.f0 = x0;
                        
                        % calculate solution
                        invtmp = fitDataLSQ(time,signal,iparam);
                        s0_interp = K0f*invtmp.T1T2f;
                        
                        % check if the temporary chi2 and model norm are
                        % within the desired limits
                        if abs(1-invtmp.chi2/invstd.chi2) <= uncertChi2 &&  ...
                                abs(1-invtmp.xn/invstd.xn) <= uncertChi2/2
                            % if YES then keep it
                            count = count + 1;
                            % save RTD
                            TDIST(i1*uncertN-(uncertN-count),:) = invtmp.T1T2f;
                            % save signal
                            SINTERP(:,i1*uncertN-(uncertN-count)) = s0_interp;
                            % save E0
                            E0INTERP(i1*uncertN-(uncertN-count),1) = invtmp.E0;
                            % status bar info
                            infostring = ['Calculating uncertainty models: ',...
                                num2str(count),' / ',num2str(uncertN),...
                                ' for RTD bin: ',num2str(i1),' / ',num2str(numel(f_final))];
                            displayStatusText(gui,infostring);
                        end
                    end
                end
                
            case 'Lambda'
                % find uncertainty models by varying the optimal
                % regularization parameter lambda
                
                % set regularization to 'manual' just in case
                iparam.regMethod = 'manual';
                
                % lambda search range
                a = log10(invstd.lambda_out/100);
                b = log10(invstd.lambda_out*10);
                
                % counter
                count = 0;
                countm = 0;
                
                % initialize variables
                TDIST = zeros(uncertN,numel(invstd.T1T2me));
                SINTERP = zeros(numel(time0),uncertN);
                E0INTERP = zeros(uncertN,1);
                % calculate uncertainty models
                while count < uncertN
                    % draw a random lambda value
                    rr = (b-a).*rand(1,1) + a;
                    iparam.lambda = 10^(rr);
                    % calculate solution
                    invtmp = fitDataLSQ(time,signal,iparam);
                    s0_interp = K0f*invtmp.T1T2f;
                    
                    % check if temporary chi2 and model norm are within the
                    % desired limits
                    if abs(1-invtmp.chi2/invstd.chi2) <= uncertChi2 &&...
                            abs(1-invtmp.xn/invstd.xn) <= uncertChi2*10
                        % if YES then keep it
                        count = count + 1;
                        % save RTD
                        TDIST(count,:) = invtmp.T1T2f;
                        % save signal
                        SINTERP(:,count) = s0_interp;
                        % save E0
                        E0INTERP(count,1) = invtmp.E0;
                        % status bar info
                        infostring = ['Calculating uncertainty models: ',...
                            num2str(count),' / ',num2str(uncertN)];
                        displayStatusText(gui,infostring);
                        % reset max counter
                        countm = 0;
                    else
%                         % update the lambda search range
%                         if invtmp.xn > invstd.xn % lambda was too small
%                             % new lower lambda search bound
%                             a = rr;
%                         end
%                         if invtmp.chi2 > invstd.chi2 % lambda was too big
%                             % new upper lambda search bound
%                             b = rr;
%                         end
                        % as long as we did not find a model keep counting
                        if count < 1
                            countm = countm + 1;
                            infostring = ['Trying to find uncertainty model: ',...
                                num2str(countm),' / ',num2str(uncertMax)];
                            displayStatusText(gui,infostring);
                        end
                    end
                    % after to many unsuccessful attempts STOP
                    if countm > uncertMax
                        infostring = ['No uncertainty model found: ',...
                            num2str(countm),' / ',num2str(uncertMax)];
                        displayStatusText(gui,infostring);
                        break;
                    end                    
                end
                
            case 'RMS_bound'
                % find uncertainty models by adding random noise (based on
                % fit RMS) on the optimal fit to create new "raw data" and
                % invert them with the original optimal inversion settings
                % select models based on chi2 and model norm bounds
                
                % set regularization to 'manual' just in case
                iparam.regMethod = 'manual';
                
                % counter
                count = 0;
                countm = 0;
                
                % initialize variables
                TDIST = zeros(uncertN,numel(invstd.T1T2me));
                SINTERP = zeros(numel(time0),uncertN);
                E0INTERP = zeros(uncertN,1);
                % calculate uncertainty models
                while count < uncertN
                    % the original fit
                    sig1 = invstd.fit_s;
                    % create some random noise based on original fit RMS
                    [signalN,~] = addNoiseToSignal(sig1,0,invstd.rms);
                    % calculate solution
                    invtmp = fitDataLSQ(time,signalN,iparam);
                    s0_interp = K0f*invtmp.T1T2f;
                    
                    % check if temporary chi2 and model norm are within the
                    % desired limits
                    if abs(1-invtmp.chi2/invstd.chi2) <= uncertChi2 &&...
                            abs(1-invtmp.xn/invstd.xn) <= uncertChi2*10
                        % if YES then keep it
                        count = count + 1;
                        % save RTD
                        TDIST(count,:) = invtmp.T1T2f;
                        % save signal
                        SINTERP(:,count) = s0_interp;
                        % save E0
                        E0INTERP(count,1) = invtmp.E0;
                        % status bar info
                        infostring = ['Calculating uncertainty models: ',...
                            num2str(count),' / ',num2str(uncertN)];
                        displayStatusText(gui,infostring);
                        % reset max counter
                        countm = 0;
                    else
                        % as long as we did not find a model keep counting
                        if count < 1
                            countm = countm + 1;
                            infostring = ['Trying to find uncertainty model: ',...
                                num2str(countm),' / ',num2str(uncertMax)];
                            displayStatusText(gui,infostring);
                        end
                    end
                    % after to many unsuccessful attempts STOP
                    if countm > uncertMax
                        infostring = ['No uncertainty model found: ',...
                            num2str(countm),' / ',num2str(uncertMax)];
                        displayStatusText(gui,infostring);
                        break;
                    end
                end
                   
            case 'RMS_free'
                % find uncertainty models by adding random noise (based on
                % fit RMS) on the optimal fit to create new "raw data" and
                % invert them with the original optimal inversion settings
                
                % set regularization to 'manual' just in case
                iparam.regMethod = 'manual';
                
                % initialize variables
                TDIST = zeros(uncertN,numel(invstd.T1T2me));
                SINTERP = zeros(numel(time0),uncertN);
                E0INTERP = zeros(uncertN,1);
                % calculate uncertainty models
                for count = 1:uncertN
                    % the original fit
                    sig1 = invstd.fit_s;
                    % create some random noise based on original fit RMS
                    [signalN,~] = addNoiseToSignal(sig1,0,invstd.rms);
                    
                    % calculate solution
                    invtmp = fitDataLSQ(time,signalN,iparam);
                    s0_interp = K0f*invtmp.T1T2f;
                    % save RTD
                    TDIST(count,:) = invtmp.T1T2f;
                    % save signal
                    SINTERP(:,count) = s0_interp;
                    % save E0
                    E0INTERP(count,1) = invtmp.E0;
                    % status bar info
                    infostring = ['Calculating uncertainty models: ',...
                        num2str(count),' / ',num2str(uncertN)];
                    displayStatusText(gui,infostring);
                end
        end
        
        % output data
        % simple E0 confidence interval
        invstd.ciE0 = 2*std(E0INTERP);
        
        % uncertainty calculation results
        uncert.interp_t = time0(:);
        uncert.interp_E0 = E0INTERP;
        uncert.interp_f = TDIST;
        uncert.interp_s = SINTERP;
        
        % uncertainty patch for fitted signal
        uncert.interp_s_min = min(SINTERP,[],2);
        uncert.interp_s_max = max(SINTERP,[],2);
        
        % uncertainty patch for fitted RTD
        uncert.interp_f_min = min(TDIST);
        uncert.interp_f_max = max(TDIST);
        
        invstd.uncert = uncert;
        
    otherwise
        % nothing to do
        uncert = [];
end

return

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2022 Thomas Hiller
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