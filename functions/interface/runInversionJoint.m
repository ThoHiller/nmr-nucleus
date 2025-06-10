function runInversionJoint
%runInversionJoint controls the joint inversion process to infer a pore size
%distribution (PSD) from NMR and CPS data
%
% Syntax:
%       runInversionJoint
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       runInversionJoint
%
% Other m-files required:
%       checkIfInversionExists
%       clearSingleAxis
%       displayStatusText
%       fcn_JointInvfixed
%       fcn_JointInvfree
%       fcn_JointInvshape
%       getChi2
%       getLambdaFromRMS
%       getConstants
%       getCornerNMRparameter
%       getGeometryParameter
%       getPartialSaturationMatrix	
%       getSaturationFromPressureBatch
%       onPushRun
%       onPushShowHide
%       onPushStop
%       removeInversionFields	
%       updateInfo
%       updatePlotsJointInversion	
%       updatePlotsLcurve	

%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

% check if there is any inversion results at all
foundINV = checkIfInversionExists(INVdata);

%% if yes continue
if foundINV    
    % check which signals have been inverted before
    % (E0 is needed for Sat-normalization)
    nINV = size(INVdata,1);
    E0 = zeros(nINV,1);
    c = 0;
    for i = 1:nINV
        if isstruct(INVdata{i})
            c = c + 1;
            E0(i,1) = sum(INVdata{i}.results.invstd.E0);
            invlevels(c) = i; %#ok<*AGROW>
            invtype{c} = INVdata{i}.invstd.invtype;
            gatetype{c} = INVdata{i}.results.nmrproc.gatetype;
        end
    end    
    % for "fixed" and "shape" inversion a RTD is needed
    InvtypeIsOK = false;
    switch data.invjoint.invtype
        case {'fixed','shape'}
            switch invtype{1}
                case {'LU','NNLS'}
                    InvtypeIsOK = true;
                otherwise
                    % nothing to do
            end
        otherwise
            InvtypeIsOK = true;
    end
    % check if the gatetype is for all signals the same
    GatetypeIsOK = false;
    if numel(unique(gatetype)) == 1
        GatetypeIsOK = true;
    end
    
    % the pressure / saturation data
    table = data.pressure.table;
    uselevel = cell2mat(table(:,1));
    tablelevels = 1:size(table,1);
    tablelevels = tablelevels(uselevel);
    
    % get the union of inverted signals and check marks in the CPS table
    [isin,levels] = ismember(invlevels,tablelevels);
    levels = tablelevels(levels(isin));
    
    % at least the first one should be there and the inversion type should
    % be okay
    if any(levels==1) && InvtypeIsOK && GatetypeIsOK
        % the pressure / saturation data
        table = data.pressure.table;
        p0 = cell2mat(table(:,2));
        S0 = cell2mat(table(:,3));
        SatImbDrain = cell2mat(table(:,4))';
        % used for inversion
        p = p0(levels);
        S = S0(levels);
        SatImbDrain = SatImbDrain(levels);
        
        % the NMR signals used for inversion
        for i = 1:numel(levels)
            idata.nmr{levels(i)}.name = data.import.NMR.filesShort{levels(i)};
            idata.nmr{levels(i)}.t0 = INVdata{levels(i)}.results.nmrproc.t;
            idata.nmr{levels(i)}.g0 = S(i).*...
                (INVdata{levels(i)}.results.nmrproc.s./E0(levels(i)));
            idata.nmr{levels(i)}.t = INVdata{levels(i)}.results.nmrproc.t;
            idata.nmr{levels(i)}.g = S(i).*...
                (INVdata{levels(i)}.results.nmrproc.s./E0(levels(i)));
            idata.nmr{levels(i)}.N = INVdata{levels(i)}.results.nmrproc.N;
            idata.nmr{levels(i)}.noise = S(i).*...
                (INVdata{levels(i)}.results.nmrproc.noise./E0(levels(i)));
            idata.nmr{levels(i)}.e = idata.nmr{levels(i)}.noise./...
                sqrt(idata.nmr{levels(i)}.N);
            
            % switch depending on inversion method
            switch data.invjoint.invtype
                case 'free'
                    % T1 or T2 data?
                    if levels(i) == 1
                        T1T2flag = INVdata{levels(i)}.results.nmrproc.T1T2;
                        T1IRfac = INVdata{levels(i)}.results.nmrproc.T1IRfac;
                    end
                case {'fixed','shape'}
                    if levels(i) == 1
                        % full saturation RTD
                        fullsat.T = INVdata{levels(i)}.results.invstd.T1T2me;
                        fullsat.F = S(i).*...
                            (INVdata{levels(i)}.results.invstd.T1T2f./...
                            sum(INVdata{levels(i)}.results.invstd.T1T2f));
                        % T1 or T2 data?
                        T1T2flag = INVdata{levels(i)}.results.nmrproc.T1T2;
                        T1IRfac = INVdata{levels(i)}.results.nmrproc.T1IRfac;
                    end
            end
        end
        
        % stack all NMR signals into one long vector
        c = 0;
        indt = zeros(size(levels));
        for i = 1:numel(levels)
            c = c + 1;
            if c == 1
                t = idata.nmr{levels(i)}.t';
                g = idata.nmr{levels(i)}.g';
                e = idata.nmr{levels(i)}.e';
                N = idata.nmr{levels(i)}.N';
            else
                t = [t idata.nmr{levels(i)}.t'];
                g = [g idata.nmr{levels(i)}.g'];
                e = [e idata.nmr{levels(i)}.e'];
                N = [N idata.nmr{levels(i)}.N'];
            end
            indt(c) = length(idata.nmr{levels(i)}.t);
        end
        
        % create the error weighing matrix
        if strcmp(unique(gatetype),'log') || strcmp(unique(gatetype),'lin')
            W = diag(e);
            useW = true;
        else
            useW = false;
        end
        
        % inversion output on the command line
        switch data.info.InvInfo
            case 'on'
                info = 'iter';
            case 'off'
                info = 'off';
        end
        
        % switch depending on inversion method
        switch data.invjoint.invtype            
            case 'free'
                % radii distribution 
                r_start = log10(data.invjoint.radii(1));
                r_end = log10(data.invjoint.radii(2));
                r = logspace(r_start,r_end,(r_end-r_start)*data.invjoint.Nradii);
                
                % inversion geometry
                igeom.type = data.invjoint.geometry_type;
                igeom.angles = [data.invjoint.alpha data.invjoint.beta data.invjoint.gamma];
                igeom.polyN = data.invjoint.polyN;
                igeom.radius = r';
                igeom = getGeometryParameter(igeom);
                
                % saturation for the inversion model
                ipsddata.r = igeom.radius';
                ipsddata.psd = ones(size(ipsddata.r));
                % wait-bar option
                wbopts.show = false;
                wbopts.tag = 'INV';
                iSAT = getSaturationFromPressureBatch(igeom,p,ipsddata,getConstants,wbopts);
                IPS = getPartialSaturationMatrix(iSAT,indt,SatImbDrain);
                % get the amplitudes and surface to volume ratios for all shapes
                SVdata = getCornerNMRparameter(igeom,iSAT,indt,SatImbDrain);
                SVdata.TT = repmat(t',[1 length(SVdata.SVF)]);
                
                % derivative matrix
                L = get_l(length(ipsddata.r),data.invjoint.Lorder);
                
                % switch depending on regularization method
                switch data.invjoint.regtype                    
                    case 'lcurve'
                        % clear axes
                        clearSingleAxis(gui.axes_handles.all);
                        clearSingleAxis(gui.axes_handles.rtd);
                        clearSingleAxis(gui.axes_handles.psd);
                        clearSingleAxis(gui.axes_handles.psdj);
                        clearSingleAxis(gui.axes_handles.cps);
                        
                        % make the RUN button a STOP button
                        % set "UserData" to 1 to catch a STOP button event
                        set(gui.push_handles.invjoint_run,'String','STOP',...
                            'BackGroundColor','r','UserData',1,'Callback',@onPushStop);
                        
                        % no command line output during l-curve calculation
                        info = 'off';
                        
                        % lambda range and initialization of output variables
                        lambda_range = logspace(log10(data.invjoint.lambdaR(1)),...
                            log10(data.invjoint.lambdaR(2)),data.invjoint.NlambdaR);
                        RMS = zeros(size(lambda_range));
                        XN = zeros(size(lambda_range));
                        RN = zeros(size(lambda_range));
                        
                        % status bar information
                        infostring = 'L-Curve calculation ... ';
                        displayStatusText(gui,infostring);
                        
                        % wait-bar option
                        wbopts.show = true;
                        wbopts.tag = 'INV';
                        if wbopts.show
                            hwb = waitbar(0,'processing ...','Name','L-Curve calculation','Visible','off');
                            steps = length(lambda_range);
                            fig = findobj('Tag',wbopts.tag);
                            if ~isempty(fig)
                                posf = get(fig,'Position');
                                set(hwb,'Units','Pixel')
                                posw = get(hwb,'Position');
                                set(hwb,'Position',[posf(1)+posf(3)/2-posw(3)/2 posf(2)+posf(4)/2-posw(4)/2 posw(3:4)]);
                            end
                            set(hwb,'Visible','on');
                        end
                        
                        % the L-curve calculation
                        for i = 1:length(lambda_range)
                            % check if the STOP button was pressed
                            % if "UserData" is 1 STOP was not pressed -> continue
                            if get(gui.push_handles.invjoint_run,'UserData') == 1
                                
                                iparam.t = t;
                                iparam.g = g;
                                if useW
                                    iparam.W = W;
                                end
                                iparam.Tb = data.invstd.Tbulk;
                                iparam.Td = data.invstd.Tdiff;
                                iparam.T1T2 = T1T2flag;
                                iparam.T1IRfac = T1IRfac;
                                iparam.L = L;
                                iparam.lambda = lambda_range(i);
                                iparam.igeom = igeom;
                                iparam.IPS = IPS;
                                iparam.SVdata = SVdata;
                                iparam.SatImbDrain = SatImbDrain;
                                
                                % start values and bounds
                                rhostart = log10(data.invjoint.rhostart/1e6);
                                rhobounds = log10(data.invjoint.rhobounds/1e6);
                                x0 = [zeros(size(igeom.radius))' rhostart];
                                lb = [zeros(size(igeom.radius))' rhobounds(1)];
                                ub = [ones(size(igeom.radius))' rhobounds(2)];
                                
                                options = optimset('Display',info,'TolFun',1e-12,'TolX',1e-12,...
                                    'Jacobian','on','DerivativeCheck','off','FinDiffType','central',...
                                    'Algorithm','levenberg-marquardt',...
                                    'MaxIter',1000);
                                
                                [X,~,~,~] = lsqnonlin(@(X)fcn_JointInvfree(X,iparam),x0,lb,ub,options);
                                [~,~,ig,~] = fcn_JointInvfree(X,iparam);
                                
                                if useW
                                    % normalize the fit because the signal was error
                                    % weighted for the inversion
                                    ig = iparam.W * ig;
                                end
                        
                                residual = ig - g';
                                iF = X(1:length(X)-1);
                                
                                % output data
                                % get RMS and X^2
                                if useW
                                    % weighted RMS error
                                    % residual is weighted with the amount of echoes N per time gate
                                    % NOTE: if "N per gate" is too large, the RMS estimation breaks down
                                    RMS(i) = sqrt (sum(N'.*(residual).^2) / length(residual));
                                    % X2 estimate
                                    CHI2(i) = getChi2(g',ig,e');
                                else
                                    % RMS error
                                    RMS(i) = sqrt( sum(residual.^2) / length(residual) );
                                    % X2 estimate
                                    CHI2(i) = getChi2(g',ig,e');
                                end
                                % error norm and model norm
                                RN(i) = norm(residual,2);
                                XN(i) = norm(L*iF',2);
                                % wait-bar update
                                if wbopts.show
                                    waitbar(i / steps,hwb,['processing ...',num2str(i),' / ',num2str(steps),' lambda steps']);
                                end
                            end
                        end                        
                        % delete the wait-bar
                        if wbopts.show
                            delete(hwb);
                        end
                        
                        % check if the STOP button was pressed
                        % if "UserData" is 1 STOP was not pressed -> save data
                        if get(gui.push_handles.invjoint_run,'UserData') == 1
                            lc.lambda = lambda_range;
                            lc.RMS = RMS;
                            lc.RN = RN;
                            lc.XN = XN;
                            % get optimal lambda
                            lc.index = getLambdaFromLCurve(RN,XN,0);
                            data.results.lcurve = lc;
                            % update GUI data
                            setappdata(fig,'data',data);
                            % update L-curve plots
                            updatePlotsLcurve;
                            % status bar information
                            displayStatusText(gui,[infostring,' done']);
                            % set focus on results
                            set(gui.plots.DistPanel,'Selection',1);
                        else
                            % status bar information
                            displayStatusText(gui,[infostring,' was canceled']);
                            % remove temporary data fields
                            data = removeInversionFields(data);
                        end
                        
                    case 'manual'
                        % disable the RUN button to indicate a running inversion
                        set(gui.push_handles.invjoint_run,'String','RUNNING ...',...
                            'Enable','inactive');

                        % inversion parameter
                        iparam.t = t;
                        iparam.g = g;
                        if useW
                            iparam.W = W;
                        end
                        iparam.Tb = data.invstd.Tbulk;
                        iparam.Td = data.invstd.Tdiff;
                        iparam.T1T2 = T1T2flag;
                        iparam.T1IRfac = T1IRfac;
                        iparam.L = L;
                        iparam.lambda = data.invjoint.lambda;
                        iparam.igeom = igeom;
                        iparam.IPS = IPS;
                        iparam.SVdata = SVdata;
                        iparam.SatImbDrain = SatImbDrain;
                        
                        % start values and bounds
                        rhostart = log10(data.invjoint.rhostart/1e6);
                        rhobounds = log10(data.invjoint.rhobounds/1e6);
                        x0 = [zeros(size(igeom.radius))' rhostart];
                        lb = [zeros(size(igeom.radius))' rhobounds(1)];
                        ub = [ones(size(igeom.radius))' rhobounds(2)];
                        
                        % status bar information
                        infostring = 'Joint Inversion (free) using ''lsqnonlin'' ... ';
                        displayStatusText(gui,infostring);
                        
                        % optimization settings
                        options = optimset('Display',info,'TolFun',1e-12,'TolX',1e-12,...
                            'Jacobian','on','DerivativeCheck','off','FinDiffType','central',...
                            'Algorithm','levenberg-marquardt',...
                            'MaxIter',1000);
                        [X,~,~,exitflag] = lsqnonlin(@(X)fcn_JointInvfree(X,iparam),x0,lb,ub,options);
                        
                        % status bar information
                        displayStatusText(gui,[infostring,'done']);
                        % get the final fit
                        [~,~,ig,KK] = fcn_JointInvfree(X,iparam);
                        
                        if useW
                            % normalize the fit because the signal was error
                            % weighted for the inversion
                            ig = iparam.W * ig;
                        end
                
                        % the inverted surface relaxivity and PSD
                        iF = X(1:length(X)-1);
                        irho = 10^X(length(X));
                        % inversion output
                        data.results.invjoint.p0 = p0;
                        data.results.invjoint.S0 = S0;
                        data.results.invjoint.levels = levels;
                        data.results.invjoint.T1T2 = T1T2flag;
                        data.results.invjoint.T1IRfac = T1IRfac;
                        data.results.invjoint.x0 = x0;
                        data.results.invjoint.lb = lb;
                        data.results.invjoint.ub = ub;
                        data.results.invjoint.iparam = iparam;
                        data.results.invjoint.iGEOM = igeom;
                        data.results.invjoint.iSAT = iSAT;
                        data.results.invjoint.iF = iF';
                        data.results.invjoint.irho = irho;
                        data.results.invjoint.ig = ig;
                        data.results.invjoint.XX = KK;
                        data.results.invjoint.errnorm = norm((ig - g')).^2;
                        data.results.invjoint.residual = ig - g';
                        data.results.invjoint.exitflag = exitflag;
                        
                        % get RMS and X^2
                        residual = data.results.invjoint.residual;
                        if useW
                            % weighted RMS error
                            % residual is weighted with the amount of echoes N per time gate
                            % NOTE: if "N per gate" is too large, the RMS estimation breaks down
                            data.results.invjoint.rms = sqrt (sum(N'.*(residual).^2) / length(residual));
                            % X2 estimate
                            data.results.invjoint.chi2 = getChi2(g',ig,e');
                        else
                            % RMS error
                            data.results.invjoint.rms = sqrt( sum(residual.^2) / length(residual) );
                            % X2 estimate
                            data.results.invjoint.chi2 = getChi2(g',ig,e');
                        end
                                                
                        % predict CPS curves for the final model
                        infostring = 'calculate CPS curve ... ';
                        displayStatusText(gui,infostring);
                        ppsddata.r = igeom.radius';
                        ppsddata.psd = data.results.invjoint.iF'./sum(data.results.invjoint.iF);
                        if min(p) == 0
                            p_tmp = logspace(floor(log10(min(p(p>0)))-2),ceil(log10(max(p)))+2,150);
                        else
                            p_tmp = logspace(floor(log10(min(p)/2)),ceil(log10(max(p)))+2,150);
                        end
                        % waitbar option
                        wbopts.show = true;
                        wbopts.tag = 'INV';
                        pSAT = getSaturationFromPressureBatch(igeom,p_tmp,ppsddata,getConstants,wbopts);
                        % save
                        data.results.invjoint.pSAT = pSAT;
                        displayStatusText(gui,[infostring,'done']); 
                end
                
            case 'fixed' % only invert for rho
                % disable the RUN button to indicate a running inversion
                set(gui.push_handles.invjoint_run,'String','RUNNING ...',...
                    'Enable','inactive');
                
                % inversion geometry
                igeom.type = data.invjoint.geometry_type;
                igeom.angles = [data.invjoint.alpha data.invjoint.beta data.invjoint.gamma];
                igeom.polyN = data.invjoint.polyN;
                igeom.radius = data.param.rho.*data.param.a.*fullsat.T; % first guess
                igeom = getGeometryParameter(igeom);
                
                iparam.t = t;
                iparam.g = g;
                if useW
                    iparam.W = W;
                end
                iparam.indt = indt;
                iparam.Tb = data.invstd.Tbulk;
                iparam.Td = data.invstd.Tdiff;
                iparam.T1T2 = T1T2flag;
                iparam.T1IRfac = T1IRfac;
                iparam.SatImbDrain = SatImbDrain;
                iparam.p = p;
                iparam.igeom = igeom;
                iparam.x = fullsat.T';
                iparam.f = fullsat.F';
                
                % start values and bounds
                x0 = log10(data.invjoint.rhostart/1e6);
                rhobounds = log10(data.invjoint.rhobounds/1e6);
                lb = rhobounds(1);
                ub = rhobounds(2);
                
                infostring = 'Joint Inversion (fixed) using ''fminsearchbnd'' ... ';
                displayStatusText(gui,infostring);
                
                options = optimset('Display',info,'TolFun',1e-12,'TolX',1e-12,...
                    'MaxFunEvals',300,'MaxIter',300);
                X = fminsearchbnd(@(X) fcn_JointInvfixed(X,iparam),x0,lb,ub,options);
                
                [errnorm,ig,XX,iGEOM,iSAT] = fcn_JointInvfixed(X,iparam);
                
                displayStatusText(gui,[infostring,'done']);
                
                if useW
                    % normalize the fit because the signal was error
                    % weighted for the inversion
                    ig = iparam.W * ig;
                end                
                
                % inverted surface relaxivity
                irho = 10^X(1);
                % output data
                data.results.invjoint.p0 = p0;
                data.results.invjoint.S0 = S0;
                data.results.invjoint.levels = levels;
                data.results.invjoint.T1T2 = T1T2flag;
                data.results.invjoint.T1IRfac = T1IRfac;
                data.results.invjoint.x0 = x0;
                data.results.invjoint.lb = lb;
                data.results.invjoint.ub = ub;
                data.results.invjoint.iparam = iparam;
                data.results.invjoint.iGEOM = iGEOM;
                data.results.invjoint.iSAT = iSAT;
                data.results.invjoint.iF = fullsat.F;
                data.results.invjoint.irho = irho;
                data.results.invjoint.ig = ig;
                data.results.invjoint.XX = XX;
                data.results.invjoint.errnorm = errnorm;
                data.results.invjoint.residual = ig-g';
                
                % get RMS and X^2
                residual = data.results.invjoint.residual;
                if useW
                    % weighted RMS error
                    % residual is weighted with the amount of echoes N per time gate
                    % NOTE: if "N per gate" is too large, the RMS estimation breaks down
                    data.results.invjoint.rms = sqrt (sum(N'.*(residual).^2) / length(residual));
                    % X2 estimate
                    data.results.invjoint.chi2 = getChi2(g',ig,e');
                else
                    % RMS error
                    data.results.invjoint.rms = sqrt( sum(residual.^2) / length(residual) );
                    % X2 estimate
                    data.results.invjoint.chi2 = getChi2(g',ig,e');
                end
                
                % predict CPS curves from final model
                infostring = 'calculate CPS curve ... ';
                displayStatusText(gui,infostring);
                ppsddata.r = iGEOM.radius';
                ppsddata.psd = data.results.invjoint.iF'./sum(data.results.invjoint.iF);
                if min(p) == 0
                    p_tmp = logspace(floor(log10(min(p(p>0)))-2),ceil(log10(max(p)))+2,200);
                else
                    p_tmp = logspace(floor(log10(min(p)/2)),ceil(log10(max(p)))+2,200);
                end
                % waitbar option
                wbopts.show = true;
                wbopts.tag = 'INV';
                pSAT = getSaturationFromPressureBatch(iGEOM,p_tmp,ppsddata,getConstants,wbopts);
                
                data.results.invjoint.pSAT = pSAT;
                displayStatusText(gui,[infostring,'done']);
                
            case 'shape' % invert for rho and right angular shape
                % disable the RUN button to indicate a running inversion
                set(gui.push_handles.invjoint_run,'String','RUNNING ...',...
                    'Enable','inactive');
                
                % inversion geometry
                igeom.type = data.invjoint.geometry_type;
                igeom.angles = [data.invjoint.alpha data.invjoint.beta data.invjoint.gamma];
                igeom.polyN = data.invjoint.polyN;
                igeom.radius = data.param.rho.*data.param.a.*fullsat.T; % first guess
                igeom = getGeometryParameter(igeom);
                
                iparam.t = t;
                iparam.g = g;
                if useW
                    iparam.W = W;
                end
                iparam.indt = indt;
                iparam.Tb = data.invstd.Tbulk;
                iparam.Td = data.invstd.Tdiff;
                iparam.T1T2 = T1T2flag;
                iparam.T1IRfac = T1IRfac;
                iparam.SatImbDrain = SatImbDrain;
                iparam.p = p;
                iparam.igeom = igeom;
                iparam.x = fullsat.T';
                iparam.f = fullsat.F';
                
                % scale fit parameter between [0 1]
                % x0 = [(log10(1e-6)+7)/3 data.invjoint.beta/45];
                % lb = [(log10(1e-7)+7)/3 0.1/45];
                % ub = [(log10(1e-4)+7)/3 45/45];
                % old way
                x0 = [log10(data.invjoint.rhostart/1e6) data.invjoint.anglestart];
                rhobounds = log10(data.invjoint.rhobounds/1e6);
                lb = [rhobounds(1) 0.1];
                ub = [rhobounds(2) 45];
                
                infostring = 'Joint Inversion (shape) using ''fminsearchbnd'' ... ';
                displayStatusText(gui,infostring);
                options = optimset('Display','iter','TolFun',1e-12,'TolX',1e-12,'MaxIter',500);
                options.Algorithm = 'levenberg-marquardt';
                options.MaxFunEvals = 500;
                options.DiffMinChange = 1;
                
                options = optimset('Display',info,'TolFun',1e-9,'TolX',1e-9,...
                    'MaxFunEvals',300,'MaxIter',300);
                X = fminsearchbnd(@(X) fcn_JointInvshape(X,iparam),x0,lb,ub,options);
                
                [errnorm,ig,XX,iGEOM,iSAT] = fcn_JointInvshape(X,iparam);
                
                displayStatusText(gui,[infostring,'done']);
                
                if useW
                    % normalize the fit because the signal was error
                    % weighted for the inversion
                    ig = iparam.W * ig;
                end
                
                irho = 10^X(1);
                ibeta = X(2);
                
                data.results.invjoint.p0 = p0;
                data.results.invjoint.S0 = S0;
                data.results.invjoint.levels = levels;
                data.results.invjoint.T1T2 = T1T2flag;
                data.results.invjoint.T1IRfac = T1IRfac;
                data.results.invjoint.x0 = x0;
                data.results.invjoint.lb = lb;
                data.results.invjoint.ub = ub;
                data.results.invjoint.iparam = iparam;
                data.results.invjoint.iGEOM = iGEOM;
                data.results.invjoint.iSAT = iSAT;
                data.results.invjoint.iF = fullsat.F;
                data.results.invjoint.irho = irho;
                data.results.invjoint.ibeta = ibeta;
                data.results.invjoint.ig = ig;
                data.results.invjoint.XX = XX;
                data.results.invjoint.errnorm = errnorm;
                data.results.invjoint.residual = ig-g';
                
                % get RMS and X^2
                residual = data.results.invjoint.residual;
                if useW
                    % weighted RMS error
                    % residual is weighted with the amount of echoes N per time gate
                    % NOTE: if "N per gate" is too large, the RMS estimation breaks down                   
                    data.results.invjoint.rms = sqrt (sum(N'.*(residual).^2) / length(residual));
                    % X2 estimate
                    data.results.invjoint.chi2 = getChi2(g',ig,e');
                else
                    % RMS error
                    data.results.invjoint.rms = sqrt( sum(residual.^2) / length(residual) );
                    % X2 estimate
                    data.results.invjoint.chi2 = getChi2(g',ig,e');
                end
                
                % predict CPS curves from final model
                infostring = 'calculate CPS curve ... ';
                displayStatusText(gui,infostring);
                ppsddata.r = iGEOM.radius';
                ppsddata.psd = data.results.invjoint.iF'./sum(data.results.invjoint.iF);
                if min(p) == 0
                    p_tmp = logspace(floor(log10(min(p(p>0)))-2),ceil(log10(max(p)))+2,150);
                else
                    p_tmp = logspace(floor(log10(min(p)/2)),ceil(log10(max(p)))+2,150);
                end
                % wait-bar option
                wbopts.show = true;
                wbopts.tag = 'INV';
                pSAT = getSaturationFromPressureBatch(iGEOM,p_tmp,ppsddata,getConstants,wbopts);
                
                data.results.invjoint.pSAT = pSAT;
                displayStatusText(gui,[infostring,'done']);
        end
        
        % if the regularization method was not L-curve then post process the
        % NMR data fits
        if ~strcmp(data.invjoint.regtype,'lcurve')
            % get the individual NMR fits
            for i = 1:1:numel(levels)
                idata.nmr{levels(i)}.fit_t = idata.nmr{levels(i)}.t;
                if i == 1
                    idata.nmr{levels(i)}.fit_g = ig(1:indt(1));
                else
                    idata.nmr{levels(i)}.fit_g = ig(sum(indt(1:i-1))+1:sum(indt(1:i-1))+indt(i));
                end
                residual = idata.nmr{levels(i)}.fit_g - idata.nmr{levels(i)}.g;
                
                % get RMS and X^2
                if useW
                    % weighted RMS error
                    % residual is weighted with the amount of echoes N per time gate
                    % NOTE: if "N per gate" is too large, the RMS estimation breaks down
                    N = idata.nmr{levels(i)}.N;
                    rms = sqrt (sum(N.*(residual).^2) / length(residual));
                    % X2 estimate
                    chi2 = getChi2(idata.nmr{levels(i)}.g,...
                        idata.nmr{levels(i)}.fit_g,...
                        idata.nmr{levels(i)}.e);
                else
                    % RMS error
                    rms = sqrt( sum(residual.^2) / length(residual) );
                    % X2 estimate
                    chi2 = getChi2(idata.nmr{levels(i)}.g,...
                        idata.nmr{levels(i)}.fit_g,...
                        idata.nmr{levels(i)}.noise);
                end

                idata.nmr{levels(i)}.residual = residual;
                idata.nmr{levels(i)}.rms = rms;
                idata.nmr{levels(i)}.chi2 = chi2;
            end
            % save the GUI data
            data.results.invjoint.idata = idata;
            setappdata(fig,'data',data);
            
            % save the "INVdata"
            for i = 1:1:numel(levels)
                INVdata{levels(i)}.invjoint = data.invjoint;
                INVdata{levels(i)}.pressure = data.pressure;
                INVdata{levels(i)}.results.invjoint = data.results.invjoint;
            end
            setappdata(fig,'INVdata',INVdata);
            % update the plots
            updatePlotsJointInversion;
            % update the INFO fields
            updateInfo(gui.plots.SignalPanel);            
            % set focus on results
            set(gui.plots.SignalPanel,'Selection',3);
            set(gui.plots.DistPanel,'Selection',3);
            % open INFO field
            set(gui.push_handles.info,'String','<');
            onPushShowHide(gui.push_handles.info);
            % activate the ConductView GUI
            set(gui.menu.extra_conduct,'Enable','on');
        end     
    else        
        if ~InvtypeIsOK
            helpdlg({'function: runInversionJoint','Perform standard multi-exponential inversion first.',...
            'For ''fixed'' and ''shape'' you need a RTD!'},'No RTD');
        end
        if ~GatetypeIsOK
            helpdlg({'function: runInversionJoint','Check your ''signal gating'' settings.',...
            'All signals need to have the same gating.'},'Wrong gating');
        end
    end
else
    helpdlg({'function: runInversionJoint','Perform standard inversion first.',...
        'For ''fixed'' and ''shape'' you need a RTD!'},'No Data');
end

%% at the end, no matter what reset the RUN button
set(gui.push_handles.invjoint_run,'String','<HTML><u>R</u>UN',...
    'BackgroundColor','g','Enable','on','Callback',@onPushRun);
setappdata(fig,'gui',gui);

end

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