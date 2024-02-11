function [invstd,uncert] = estimateUncertainty(invtype,invstd,iparam,parameter)
%estimateUncertainty calculates pseudo uncertainty estimates for multi
%modal and LSQ inversion results
%
% Syntax:
%       estimateUncertainty(invtype,invstd,iparam,parameter)
%
% Inputs:
%       invtype - string indicating the inversion method of the optimal
%                 fit ('LU','NNLS' or 'MUMO')
%       invstd - struct holding inversion results of the optimal fit
%       iparam - struct holding original inversion settings
%       parameter - struct that holds settings:
%                   uncert.Method : which calculation method to use for
%                                  'MUMO' the options are 'thresh' and 'ci' for
%                                  'NNLS' the options are 'RTD_var', 'Lambda',
%                                  'RMS_bound' and 'RMS_free'
%                   uncert.Thresh : threshold for uncertainty search range
%                   uncert.N      : number of models to calculate
%                   uncert.Max    : total number of unsuccessful attempts
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
    % this routine will still call 'displayStatusText' but then the output
    % is displayed at the command line
    gui = 0;
end

% get the main parameters
uncertMethod = parameter.uncert.Method;
chi2_range = parameter.uncert.chi2_range;
mnorm_range = parameter.uncert.mnorm_range;
uncertThresh = parameter.uncert.Thresh;
uncertN = parameter.uncert.N;
uncertMax = parameter.uncert.Max;

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

%% there are four different methods implemented
switch uncertMethod
    case 'RMS_free'
        %%
        % find uncertainty models by adding random noise (based on
        % fit RMS) on the optimal fit to create new "raw data" and
        % invert them with the original optimal inversion settings

        % initialize variables
        TDIST = zeros(uncertN,numel(invstd.T1T2me));
        SINTERP = zeros(numel(time0),uncertN);
        E0INTERP = zeros(uncertN,1);
        TLGMINTERP = zeros(uncertN,1);
        mnorm_all = zeros(uncertN,1);
        rnorm_all = zeros(uncertN,1);
        chi2_all = zeros(uncertN,1);
        % calculate uncertainty models
        for count = 1:uncertN
            % the original fit
            sig1 = invstd.fit_s;
            % create some random noise based on original fit RMS
            [signalN,~] = addNoiseToSignal(sig1,0,invstd.rms);

            % calculate solution
            switch invtype
                case 'LU'
                    invtmp = fitDataLUdecomp(time,signalN,iparam);
                case 'MUMO'
                    invtmp = fitDataMultiModal(time,signalN,iparam);
                case 'NNLS'
                    invtmp = fitDataLSQ(time,signalN,iparam);
            end
            % new signal
            s0_interp = K0f*invtmp.T1T2f;
            % save RTD
            TDIST(count,:) = invtmp.T1T2f;
            % save signal
            SINTERP(:,count) = s0_interp;
            % save E0
            E0INTERP(count,1) = invtmp.E0;
            % save TLGM
            TLGMINTERP(count,1) = invtmp.Tlgm;
            mnorm_all(count,1) = invtmp.xn;
            rnorm_all(count,1) = invtmp.rn;
            chi2_all(count,1) = invtmp.chi2;
            % status bar info
            infostring = ['Calculating uncertainty models: ',...
                num2str(count),' / ',num2str(uncertN)];
            displayStatusText(gui,infostring);
        end
    case 'RMS_bound'
        %%
        % find uncertainty models by adding random noise (based on
        % fit RMS) on the optimal fit to create new "raw data" and
        % invert them with the original optimal inversion settings
        % select models based on chi2 and model norm bounds

        % counter
        count = 0;
        countm = 0;

        % initialize variables
        TDIST = zeros(uncertN,numel(invstd.T1T2me));
        SINTERP = zeros(numel(time0),uncertN);
        E0INTERP = zeros(uncertN,1);
        TLGMINTERP = zeros(uncertN,1);
        mnorm_all = zeros(uncertN,1);
        rnorm_all = zeros(uncertN,1);
        chi2_all = zeros(uncertN,1);
        % calculate uncertainty models
        while count < uncertN
            % the original fit
            sig1 = invstd.fit_s;
            % create some random noise based on original fit RMS
            [signalN,~] = addNoiseToSignal(sig1,0,invstd.rms);
            % calculate solution
            switch invtype
                case 'LU'
                    invtmp = fitDataLUdecomp(time,signalN,iparam);
                case 'MUMO'
                    invtmp = fitDataMultiModal(time,signalN,iparam);
                case 'NNLS'
                    invtmp = fitDataLSQ(time,signalN,iparam);
            end
            % new signal
            s0_interp = K0f*invtmp.T1T2f;

            % check if temporary chi2 and model norm are within the
            % desired limits
            if invtmp.chi2 >= chi2_range(1) && invtmp.chi2 <= chi2_range(2) && ...
                    invtmp.xn >= mnorm_range(1) && invtmp.xn <= mnorm_range(2)
                % if YES then keep it
                count = count + 1;
                % save RTD
                TDIST(count,:) = invtmp.T1T2f;
                % save signal
                SINTERP(:,count) = s0_interp;
                % save E0
                E0INTERP(count,1) = invtmp.E0;
                % save TLGM
                TLGMINTERP(count,1) = invtmp.Tlgm;
                mnorm_all(count,1) = invtmp.xn;
                rnorm_all(count,1) = invtmp.rn;
                chi2_all(count,1) = invtmp.chi2;
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
    otherwise % 'thresh' and 'ci'
        %%
        % data needed from the optimal fit
        T = invstd.T;
        S = invstd.S;
        E = invstd.E;
        x = invstd.x;
        lb = invstd.lb;
        ub = invstd.ub;
        ci = invstd.ci;

        % kernel for the original fit needed for comparison to the
        % uncertainty models
        K = createKernelMatrix(time,invstd.T1T2me',iparam.Tb,iparam.Td,...
            iparam.T1T2,iparam.T1IRfac);

        % counter
        count = 0;
        countm = 0;

        % initialize variables
        TDIST = zeros(uncertN,numel(invstd.T1T2me));
        SINTERP = zeros(numel(time0),uncertN);
        E0INTERP = zeros(uncertN,1);
        TLGMINTERP = zeros(uncertN,1);
        mnorm_all = zeros(uncertN,1);
        rnorm_all = zeros(uncertN,1);
        chi2_all = zeros(uncertN,1);
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

            % create a temporary distribution with the new random RTD parameters
            TdistI = 0;
            for i = 1:numel(T)
                tmp = 1./( Si(i)*sqrt(2*pi)).*exp(-((log(invstd.T1T2me') -...
                    log(Ti(i)))/ sqrt(2)/Si(i)).^2);
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

            chi2 = outI.chi2;
            xn = norm(TdistI,2);
            rn = norm(outI.residual,2);

            % check if the temporary chi2 and xn are within the desired
            % limits
            if chi2 >= chi2_range(1) && chi2 <= chi2_range(2) && ...
                    xn >= mnorm_range(1) && xn <= mnorm_range(2)    
                % if YES then keep it
                count = count + 1;
                % save RTD
                TDIST(count,:) = TdistI;
                % save signal
                SINTERP(:,count) = s0_interp;
                % save E0
                E0INTERP(count,1) = K0*TdistI';
                % save TLGM
                TLGMINTERP(count,1) = getTLogMean(invstd.T1T2me,TdistI);
                mnorm_all(count,1) = xn;
                rnorm_all(count,1) = rn;
                chi2_all(count,1) = chi2;
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
end

% output data
% simple E0 confidence interval
invstd.ciE0 = 2*std(E0INTERP);

% mean E0
uncert.E0 = [mean(E0INTERP) std(E0INTERP)];
% mean TLGM
uncert.Tlgm = [mean(TLGMINTERP) std(TLGMINTERP)];

% uncertainty calculation results
uncert.interp_t = time0(:);
uncert.interp_E0 = E0INTERP;
uncert.interp_Tlgm = TLGMINTERP;
uncert.mnorm_all = mnorm_all;
uncert.rnorm_all = rnorm_all;
uncert.chi2_all = chi2_all;
uncert.interp_f = TDIST;
uncert.interp_s = SINTERP;

% uncertainty patch for fitted signal
uncert.interp_s_min = min(SINTERP,[],2);
uncert.interp_s_max = max(SINTERP,[],2);

% uncertainty patch for fitted RTD
uncert.interp_f_min = min(TDIST);
uncert.interp_f_max = max(TDIST);

% uncertainty calculation parameter
uncert.params = parameter;

% statistics of all uncertainty runs
uncert.statistics = getUncertaintyStatistics(invstd.T1T2me,TDIST,...
    [min(invstd.T1T2me) max(invstd.T1T2me)],K0);

invstd.uncert = uncert;

end
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