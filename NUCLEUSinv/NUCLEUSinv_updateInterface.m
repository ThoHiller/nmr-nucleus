function NUCLEUSinv_updateInterface
%NUCLEUSinv_updateInterface updates all GUI elements
%
% Syntax:
%       NUCLEUSinv_updateInterface
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       NUCLEUSinv_updateInterface
%
% Other m-files required:
%       none
%
% Subfunctions:
%       updateGatetype
%       updateNormalize
%       updateTimescale
%       updateInvstdTime
%       updateInvjointRadii
%       updateLambda
%       updateLambdaJoint
%       updateLorder
%       updateLorderJoint
%       updateParams
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

switch data.info.ExpertMode
    case 'on'
        %% update the processing panel
        set(gui.edit_handles.process_start,'Enable','on',...
            'String',num2str(data.process.start));
        set(gui.edit_handles.process_end,'Enable','on',...
            'String',num2str(data.process.end));
        
        gui = updateGatetype(gui,data.process.gatetype);
        gui = updateNormalize(gui,data.process.norm);
        gui = updateTimescale(gui,data.process.timescale);
        if data.invstd.porosity <= 1
            set(gui.edit_handles.invstd_porosity,'Enable','on',...
                'BackgroundColor','w',...
                'String',num2str(data.invstd.porosity));
        else
            set(gui.edit_handles.invstd_porosity,'Enable','on',...
                'BackgroundColor','r',...
                'String',num2str(data.invstd.porosity));
        end
        
        %% update standard inversion panel
        % inversion method popup
        switch data.info.optim
            case 'on'
                istring = {'Mono exp.','Several free exp. (2-5)',...
                    'Multi exp. (LSQLIN)',...
                    'Multi exp. (InvLaplace)'};
            case 'off'
                istring = {'Mono exp.','Several free exp. (2-5)',...
                    'Multi exp. (NNLS)',...
                    'Multi exp. (InvLaplace)'};
        end
        set(gui.popup_handles.invstd_InvType,'String',istring);
        switch data.invstd.invtype
            case 'mono'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',1,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','off',...
                    'Value',1,'String','none');
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','No extra options');
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,0,0,0);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,0,0);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','off',...
                    'String',num2str(data.invstd.Tbulk));
                
            case 'free'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',2,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','on',...
                    'Value',data.invstd.freeDT,...
                    'String',{'1','2','3','4','5'});
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','No. of free decay times T');
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,0,0,0);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,0,0);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','off',...
                    'String',num2str(data.invstd.Tbulk));
                
            case 'NNLS'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',3,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','on',...
                    'String',{'Manual','Iterative Chi2','Tikhonov (SVD)','TSVD (SVD)',...
                    'DSVD (SVD)','Discrep. (SVD)','L-curve'});
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','regularization options');
                
                % regularization options
                switch data.invstd.regtype
                    case 'manual'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',1);
                    case 'iterchi2'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',2);    
                    case 'gcv_tikh'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',3);
                    case 'gcv_trunc'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',4);
                    case 'gcv_damp'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',5);
                    case 'discrep'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',6);
                    case 'lcurve'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',7);
                end
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,data.invstd.lambda,...
                    data.invstd.lambdaR,data.invstd.NlambdaR);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,data.invstd.time,...
                    data.invstd.Ntime);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','on',...
                    'String',num2str(data.invstd.Tbulk));
                
            case 'ILA'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',4,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','on',...
                    'String',{'Manual','Automatic'});
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','regularization options');
                
                % regularization options
                switch data.invstd.regtype
                    case 'manual'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',1);
                    case 'auto'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',2);
                        data.invstd.lambda = -1;
                end
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,data.invstd.lambda,...
                    data.invstd.lambdaR,data.invstd.NlambdaR);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,data.invstd.time,...
                    data.invstd.Ntime);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','on',...
                    'String',num2str(data.invstd.Tbulk));
        end
        
        % updates CBW, BVI, rho and a
        gui = updateParams(gui,data.invstd.invtype,data.param);
        
        %% update joint inversion panel
        % depending if it is activated or not
        switch data.info.JointInv
            case 'on'
                % inversion method dependent
                switch data.invjoint.invtype
                    case 'free'                        
                        % inversion method popup
                        set(gui.popup_handles.invjoint_InvType,'Value',1,'Enable','on');
                        
                        % PSD limits
                        gui = updateInvjointRadii(gui,data.invjoint.invtype,...
                            data.invjoint.radii,data.invjoint.Nradii);
                        
                        % additional inversion settings
                        set(gui.popup_handles.invjoint_InvTypeOpt,'Enable','on');
                        
                        % regularization options
                        switch data.invjoint.regtype
                            case 'manual'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',1);
                            case 'lcurve'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',2);
                        end
                        
                        % smoothness constraint and lambda
                        gui = updateLorderJoint(gui,data.invjoint.invtype,...
                            data.invjoint.Lorder);
                        gui = updateLambdaJoint(gui,data.invjoint.regtype,...
                            data.invjoint.lambda,data.invjoint.lambdaR,...
                            data.invjoint.NlambdaR,data.invstd.regtype);
                        
                        % start values
                        set(gui.edit_handles.invjoint_rhostart,'Enable','on');
                        set(gui.edit_handles.invjoint_anglestart,'Enable','off');
                        
                        % geometry type dependent
                        switch data.invjoint.geometry_type
                            case 'cyl'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',1,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,'String','');
                                set(gui.edit_handles.invjoint_beta,'String','');
                                set(gui.edit_handles.invjoint_gamma,'String','');
                                
                            case 'ang'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',2,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','on');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String',num2str(data.invjoint.alpha));
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(data.invjoint.beta));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String',num2str(data.invjoint.gamma));
                                
                            case 'poly'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',3,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','on',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                polyangle = ((data.invjoint.polyN-2)/data.invjoint.polyN)*180;
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String','');
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(polyangle));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String','');
                        end
                        
                    case 'fixed'                        
                        % inversion method popup
                        set(gui.popup_handles.invjoint_InvType,'Value',2,'Enable','on');
                        
                        % PSD limits
                        gui = updateInvjointRadii(gui,data.invjoint.invtype,...
                            data.invjoint.radii,data.invjoint.Nradii);
                        
                        % additional inversion settings
                        set(gui.popup_handles.invjoint_InvTypeOpt,'Enable','off');
                        
                        % regularization options
                        switch data.invjoint.regtype
                            case 'manual'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',1);
                            case 'lcurve'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',2);
                        end
                        
                        % smoothness constraint and lambda
                        gui = updateLorderJoint(gui,data.invjoint.invtype,...
                            data.invjoint.Lorder);
                        gui = updateLambdaJoint(gui,'none',data.invjoint.lambda,...
                            data.invjoint.lambdaR,data.invjoint.NlambdaR,...
                            data.invstd.regtype);
                        
                        % start values
                        set(gui.edit_handles.invjoint_rhostart,'Enable','on');
                        set(gui.edit_handles.invjoint_anglestart,'Enable','off');
                        
                        % geometry type dependent
                        switch data.invjoint.geometry_type
                            case 'cyl'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',1,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,'String','');
                                set(gui.edit_handles.invjoint_beta,'String','');
                                set(gui.edit_handles.invjoint_gamma,'String','');
                                
                            case 'ang'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',2,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','on');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String',num2str(data.invjoint.alpha));
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(data.invjoint.beta));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String',num2str(data.invjoint.gamma));
                                
                            case 'poly'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',3,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','on',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                polyangle = ((data.invjoint.polyN-2)/data.invjoint.polyN)*180;
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String','');
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(polyangle));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String','');
                        end
                        
                    case 'shape'                        
                        % inversion method popup
                        set(gui.popup_handles.invjoint_InvType,'Value',3,'Enable','on');
                        
                        % PSD limits
                        gui = updateInvjointRadii(gui,data.invjoint.invtype,...
                            data.invjoint.radii,data.invjoint.Nradii);
                        
                        % additional inversion settings
                        set(gui.popup_handles.invjoint_InvTypeOpt,'Enable','off');
                        
                        % regularization options
                        switch data.invjoint.regtype
                            case 'manual'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',1);
                            case 'lcurve'
                                set(gui.popup_handles.invjoint_InvTypeOpt,'Value',2);
                        end
                        
                        % smoothness constraint and lambda
                        gui = updateLorderJoint(gui,data.invjoint.invtype,...
                            data.invjoint.Lorder);
                        gui = updateLambdaJoint(gui,'none',data.invjoint.lambda,...
                            data.invjoint.lambdaR,data.invjoint.NlambdaR,data.invstd.regtype);
                        
                        % start values
                        set(gui.edit_handles.invjoint_rhostart,'Enable','on');
                        set(gui.edit_handles.invjoint_anglestart,'Enable','on');
                        
                        % geometry type dependent
                        switch data.invjoint.geometry_type
                            case 'cyl'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',1,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,'String','');
                                set(gui.edit_handles.invjoint_beta,'String','');
                                set(gui.edit_handles.invjoint_gamma,'String','');
                                
                            case 'ang'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',2,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','off',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String',num2str(data.invjoint.alpha));
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(data.invjoint.beta));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String',num2str(data.invjoint.gamma));
                                
                            case 'poly'                                
                                % geometry popup
                                set(gui.popup_handles.invjoint_geometry_type,...
                                    'Value',3,'Enable','on');
                                
                                % polygon sides and corresponding angle beta
                                set(gui.popup_handles.invjoint_polyN,'Enable','on',...
                                    'Value',data.invjoint.polyN-2);
                                set(gui.edit_handles.invjoint_beta,'Enable','off');
                                
                                % angles
                                polyangle = ((data.invjoint.polyN-2)/data.invjoint.polyN)*180;
                                set(gui.edit_handles.invjoint_alpha,...
                                    'String','');
                                set(gui.edit_handles.invjoint_beta,...
                                    'String',num2str(polyangle));
                                set(gui.edit_handles.invjoint_gamma,...
                                    'String','');
                        end
                end

            case 'off'
                % inversion method popup
                set(gui.popup_handles.invjoint_InvType,'Value',1,'Enable','off');
                
                % PSD limits
                gui = updateInvjointRadii(gui,'off',0,0);
                
                % additional inversion settings
                set(gui.popup_handles.invjoint_InvTypeOpt,'Enable','off');
                
                % smoothness constraint and lambda
                gui = updateLorderJoint(gui,'off',0);
                gui = updateLambdaJoint(gui,'none',data.invjoint.lambda,...
                    data.invjoint.lambdaR,data.invjoint.NlambdaR,data.invstd.regtype);
                
                % polygon sides and angles
                set(gui.popup_handles.invjoint_polyN,'Enable','off');
                set(gui.edit_handles.invjoint_alpha,'Enable','off');
                set(gui.edit_handles.invjoint_beta,'Enable','off');
                set(gui.edit_handles.invjoint_gamma,'Enable','off');
                
                % start values
                set(gui.edit_handles.invjoint_rhostart,'Enable','off');
                set(gui.edit_handles.invjoint_anglestart,'Enable','off');
        end
        
        % this is always updated
        switch data.pressure.unit
            case 'Pa'
                set(gui.popup_handles.invjoint_pressure_units,'Value',1);
            case 'kPa'
                set(gui.popup_handles.invjoint_pressure_units,'Value',2);
            case 'MPa'
                set(gui.popup_handles.invjoint_pressure_units,'Value',3);
            case 'bar'
                set(gui.popup_handles.invjoint_pressure_units,'Value',4);
        end
        set(gui.table_handles.invjoint_table,...
            'ColumnName',{'use',['p [',data.pressure.unit,']'],'S [-]','D / I'})
        
        table = data.pressure.table;
        for i = 1:size(table,1)
            table{i,2} = table{i,2}.*data.pressure.unitfac;
        end
        set(gui.table_handles.invjoint_table,'Data',table);
        
    case 'off'
        %% update the processing panel
        set(gui.edit_handles.process_start,'Enable','on',...
            'String',num2str(data.process.start));
        set(gui.edit_handles.process_end,'Enable','on',...
            'String',num2str(data.process.end));
        
        gui = updateGatetype(gui,data.process.gatetype);        
        set(gui.radio_handles.process_normalize_on,'Enable','off','Value',0);
        set(gui.radio_handles.process_normalize_off,'Enable','off','Value',1);
        set(gui.radio_handles.process_timescale_s,'Enable','off','Value',1);
        set(gui.radio_handles.process_timescale_ms,'Enable','off','Value',0);
        
        if data.invstd.porosity <= 1
            set(gui.edit_handles.invstd_porosity,'Enable','on',...
                'BackgroundColor','w',...
                'String',num2str(data.invstd.porosity));
        else
            set(gui.edit_handles.invstd_porosity,'Enable','on',...
                'BackgroundColor','r',...
                'String',num2str(data.invstd.porosity));
        end
        
        %% update standard inversion panel
        % inversion method popup
        set(gui.popup_handles.invstd_InvType,'String',{'Mono exp.',...
            'Several free exp. (2-5)','Multi exp. (NNLS)'});
        switch data.invstd.invtype
            case 'mono'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',1,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','off',...
                    'Value',1,'String','none');
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','No extra options');
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,0,0,0);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,0,0);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','off',...
                    'String',num2str(data.invstd.Tbulk));
                
            case 'free'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',2,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','on',...
                    'Value',data.invstd.freeDT,...
                    'String',{'1','2','3','4','5'});
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','No. of free decay times T');
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,0,0,0);
                gui = updateLorder(gui,data.invstd.invtype,data.invstd.Lorder);
                gui = updateInvstdTime(gui,data.invstd.invtype,0,0);
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','off',...
                    'String',num2str(data.invstd.Tbulk));
                
            case 'NNLS'
                % inversion method popup
                set(gui.popup_handles.invstd_InvType,'Value',3,'Enable','on');
                
                % additional inversion settings
                set(gui.popup_handles.invstd_InvTypeOpt,'Enable','on',...
                    'String',{'Manual','L-curve','Iterative Chi2'});
                set(gui.text_handles.invstd_InvTypeOpt,...
                    'String','regularization options');
                
                % regularization options
                switch data.invstd.regtype
                    case 'manual'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',1);
                    case 'lcurve'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',2);
                    case 'iterchi2'
                        set(gui.popup_handles.invstd_InvTypeOpt,'Value',3);
                end
                
                % lambda, smoothness constraint and RTD limits
                gui = updateLambda(gui,data.invstd.regtype,data.invstd.lambda,...
                    data.invstd.lambdaR,data.invstd.NlambdaR);
                data.invstd.Lorder = 1;
                set(gui.radio_handles.invstd_Lorder0,'Value',0,'Enable','off');
                set(gui.radio_handles.invstd_Lorder1,'Value',1,'Enable','off');
                set(gui.radio_handles.invstd_Lorder2,'Value',0,'Enable','off');
                
                set(gui.edit_handles.invstd_time_min,'Enable','on',...
                    'String',num2str(data.invstd.time(1)));
                set(gui.edit_handles.invstd_time_max,'Enable','on',...
                    'String',num2str(data.invstd.time(2)));
                set(gui.edit_handles.invstd_Ntime,'Enable','off',...
                    'String',num2str(data.invstd.Ntime));
                
                % Tbulk
                set(gui.edit_handles.invstd_Tbulk,'Enable','on',...
                    'String',num2str(data.invstd.Tbulk));
        end
        
        %% update petro parameter panel
        
        data.param.CBWcutoff = 3;
        data.param.BVIcutoff = 33;
        data.param.rho = 10;
        data.param.a = 2;
        setappdata(fig,'data',data);
        set(gui.edit_handles.param_CBW,'Enable','off',...
            'String',num2str(data.param.CBWcutoff));
        set(gui.edit_handles.param_BVI,'Enable','off',...
            'String',num2str(data.param.BVIcutoff));
        set(gui.edit_handles.param_rho,'Enable','off',...
            'String',num2str(data.param.rho));
        set(gui.edit_handles.param_geom,'Enable','off',...
            'String',num2str(data.param.a));
        set(gui.edit_handles.param_calibVol,'Enable','on',...
            'String',num2str(data.param.calibVol));
        set(gui.edit_handles.param_calibAmp,'Enable','on',...
            'String',num2str(data.param.calibAmp));
        set(gui.edit_handles.param_sampVol,'Enable','on',...
            'String',num2str(data.param.sampVol));
end

% Matlab need some time
pause(0.001);

end

%% sub functions
function gui = updateGatetype(gui,gatetype)

set(gui.radio_handles.process_gates_log,'Enable','on');
set(gui.radio_handles.process_gates_lin,'Enable','on');
set(gui.radio_handles.process_gates_none,'Enable','on');

switch gatetype
    
    case 'log'
        
        set(gui.radio_handles.process_gates_log,'Value',1);
        set(gui.radio_handles.process_gates_lin,'Value',0);
        set(gui.radio_handles.process_gates_none,'Value',0);
        
    case 'lin'
        
        set(gui.radio_handles.process_gates_log,'Value',0);
        set(gui.radio_handles.process_gates_lin,'Value',1);
        set(gui.radio_handles.process_gates_none,'Value',0);
        
    case 'raw'
        
        set(gui.radio_handles.process_gates_log,'Value',0);
        set(gui.radio_handles.process_gates_lin,'Value',0);
        set(gui.radio_handles.process_gates_none,'Value',1);
        
end

end

function gui = updateNormalize(gui,norm)

switch norm    
    case 0        
        set(gui.radio_handles.process_normalize_on,'Enable','on','Value',0);
        set(gui.radio_handles.process_normalize_off,'Enable','on','Value',1);
        
    case 1        
        set(gui.radio_handles.process_normalize_on,'Enable','on','Value',1);
        set(gui.radio_handles.process_normalize_off,'Enable','on','Value',0);
end

end

function gui = updateTimescale(gui,timescale)

switch timescale
    
    case 's'        
        set(gui.radio_handles.process_timescale_s,'Enable','on','Value',1);
        set(gui.radio_handles.process_timescale_ms,'Enable','on','Value',0);
        set(gui.text_handles.invstd_RTDtimes,'String','RTD - min [s] | max [s] | # / dec',...
            'FontSize',10);
        set(gui.text_handles.petro_Tbulk,'String',...
            ['Tbulk [s]   |   ',char(hex2dec('03C1')),' [µm/s]   |   geom']);
        
    case 'ms'        
        set(gui.radio_handles.process_timescale_s,'Enable','on','Value',0);
        set(gui.radio_handles.process_timescale_ms,'Enable','on','Value',1);
        set(gui.text_handles.invstd_RTDtimes,'String','RTD - min [ms] | max [ms] | # / dec',...
            'FontSize',9);
        set(gui.text_handles.petro_Tbulk,'String',...
            ['Tbulk [ms]   |   ',char(hex2dec('03C1')),' [µm/s]   |   geom']);        
end

end

function gui = updateInvstdTime(gui,invtype,time,Ntime)

switch invtype
    
    case {'mono','free'}        
        set(gui.edit_handles.invstd_time_min,'Enable','off');
        set(gui.edit_handles.invstd_time_max,'Enable','off');
        set(gui.edit_handles.invstd_Ntime,'Enable','off');
        
    case {'ILA','NNLS'}        
        set(gui.edit_handles.invstd_time_min,'Enable','on','String',num2str(time(1)));
        set(gui.edit_handles.invstd_time_max,'Enable','on','String',num2str(time(2)));
        set(gui.edit_handles.invstd_Ntime,'Enable','on','String',num2str(Ntime));   
end

end

function gui = updateInvjointRadii(gui,invtype,radii,Nradii)

switch invtype    
    case {'fixed','shape','off'}        
        set(gui.edit_handles.invjoint_radii_min,'Enable','off');
        set(gui.edit_handles.invjoint_radii_max,'Enable','off');
        set(gui.edit_handles.invjoint_Nradii,'Enable','off');
        
    case {'free'}        
        set(gui.edit_handles.invjoint_radii_min,'Enable','on','String',num2str(radii(1)));
        set(gui.edit_handles.invjoint_radii_max,'Enable','on','String',num2str(radii(2)));
        set(gui.edit_handles.invjoint_Nradii,'Enable','on','String',num2str(Nradii));
end

end

function gui = updateLambda(gui,regtype,lambda,lambdaR,NlambdaR)

switch regtype    
    case 'none'        
        set(gui.edit_handles.invstd_lambda_min,'Enable','off');
        set(gui.edit_handles.invstd_lambda_max,'Enable','off');
        set(gui.edit_handles.invstd_NlambdaR,'Enable','off');
        gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
        
    case 'manual'        
        set(gui.edit_handles.invstd_lambda_min,'Enable','on','String',num2str(lambda));
        set(gui.edit_handles.invstd_lambda_max,'Enable','off');
        set(gui.edit_handles.invstd_NlambdaR,'Enable','off');
        gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
        
    case 'auto'        
        set(gui.edit_handles.invstd_lambda_min,'Enable','off','String',num2str(lambda));
        set(gui.edit_handles.invstd_lambda_max,'Enable','off');
        set(gui.edit_handles.invstd_NlambdaR,'Enable','off');
        gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
        
    case 'lcurve'        
        set(gui.edit_handles.invstd_lambda_min,'Enable','on','String',num2str(lambdaR(1)));
        set(gui.edit_handles.invstd_lambda_max,'Enable','on','String',num2str(lambdaR(2)));
        set(gui.edit_handles.invstd_NlambdaR,'Enable','on','String',num2str(NlambdaR));
        gui.plots.DistPanel.TabTitles = {'L-CURVE','RMS','PSD (joint)'};
        
    case 'iterchi2'        
        set(gui.edit_handles.invstd_lambda_min,'Enable','on','String',num2str(lambdaR(1)));
        set(gui.edit_handles.invstd_lambda_max,'Enable','on','String',num2str(lambdaR(2)));
        set(gui.edit_handles.invstd_NlambdaR,'Enable','off','String',num2str(NlambdaR));
        gui.plots.DistPanel.TabTitles = {'CHI2','RMS','PSD (joint)'};
        
    case {'gcv_tikh','gcv_trunc','gcv_damp','discrep'}        
        set(gui.edit_handles.invstd_lambda_min,'Enable','off','String',num2str(lambda));
        set(gui.edit_handles.invstd_lambda_max,'Enable','off');
        set(gui.edit_handles.invstd_NlambdaR,'Enable','off');
        gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
end

end

function gui = updateLambdaJoint(gui,regtype,lambda,lambdaR,NlambdaR,regtypestd)

switch regtype    
    case 'none'        
        switch regtypestd            
            case 'lcurve'                
                set(gui.edit_handles.invjoint_lambda_min,'Enable','off');
                set(gui.edit_handles.invjoint_lambda_max,'Enable','off');
                set(gui.edit_handles.invjoint_NlambdaR,'Enable','off');
                gui.plots.DistPanel.TabTitles = {'L-CURVE','RMS','PSD (joint)'};
                
            case 'iterchi2'                
                set(gui.edit_handles.invjoint_lambda_min,'Enable','off');
                set(gui.edit_handles.invjoint_lambda_max,'Enable','off');
                set(gui.edit_handles.invjoint_NlambdaR,'Enable','off');
                gui.plots.DistPanel.TabTitles = {'CHI2','RMS','PSD (joint)'};
                
            otherwise                
                set(gui.edit_handles.invjoint_lambda_min,'Enable','off');
                set(gui.edit_handles.invjoint_lambda_max,'Enable','off');
                set(gui.edit_handles.invjoint_NlambdaR,'Enable','off');
                gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
        end
        
    case 'manual'        
        switch regtypestd            
            case 'lcurve'                
                set(gui.edit_handles.invjoint_lambda_min,'Enable','on','String',num2str(lambda));
                set(gui.edit_handles.invjoint_lambda_max,'Enable','off');
                set(gui.edit_handles.invjoint_NlambdaR,'Enable','off');
                gui.plots.DistPanel.TabTitles = {'L-CURVE','RMS','PSD (joint)'};
                
            otherwise                
                set(gui.edit_handles.invjoint_lambda_min,'Enable','on','String',num2str(lambda));
                set(gui.edit_handles.invjoint_lambda_max,'Enable','off');
                set(gui.edit_handles.invjoint_NlambdaR,'Enable','off');
                gui.plots.DistPanel.TabTitles = {'RTD','PSD','PSD (joint)'};
        end
        
    case 'lcurve'        
        set(gui.edit_handles.invjoint_lambda_min,'Enable','on','String',num2str(lambdaR(1)));
        set(gui.edit_handles.invjoint_lambda_max,'Enable','on','String',num2str(lambdaR(2)));
        set(gui.edit_handles.invjoint_NlambdaR,'Enable','on','String',num2str(NlambdaR));
        gui.plots.DistPanel.TabTitles = {'L-CURVE','RMS','PSD (joint)'};
end

end

function gui = updateLorder(gui,invtype,Lorder)

switch invtype
    case {'mono','free'}
        set(gui.radio_handles.invstd_Lorder0,'Enable','off');
        set(gui.radio_handles.invstd_Lorder1,'Enable','off');
        set(gui.radio_handles.invstd_Lorder2,'Enable','off');
        
    case {'ILA','NNLS'}
        set(gui.radio_handles.invstd_Lorder0,'Enable','on');
        set(gui.radio_handles.invstd_Lorder1,'Enable','on');
        set(gui.radio_handles.invstd_Lorder2,'Enable','on');
        
        switch Lorder
            case 0
                set(gui.radio_handles.invstd_Lorder0,'Value',1);
                set(gui.radio_handles.invstd_Lorder1,'Value',0);
                set(gui.radio_handles.invstd_Lorder2,'Value',0);
                
            case 1
                set(gui.radio_handles.invstd_Lorder0,'Value',0);
                set(gui.radio_handles.invstd_Lorder1,'Value',1);
                set(gui.radio_handles.invstd_Lorder2,'Value',0);
                
            case 2
                set(gui.radio_handles.invstd_Lorder0,'Value',0);
                set(gui.radio_handles.invstd_Lorder1,'Value',0);
                set(gui.radio_handles.invstd_Lorder2,'Value',1);
        end
end

end

function gui = updateLorderJoint(gui,invtype,Lorder)

switch invtype
    case {'fixed','shape','off'}
        set(gui.radio_handles.invjoint_Lorder0,'Enable','off');
        set(gui.radio_handles.invjoint_Lorder1,'Enable','off');
        set(gui.radio_handles.invjoint_Lorder2,'Enable','off');
        
    case 'free'
        set(gui.radio_handles.invjoint_Lorder0,'Enable','on');
        set(gui.radio_handles.invjoint_Lorder1,'Enable','on');
        set(gui.radio_handles.invjoint_Lorder2,'Enable','on');
        
        switch Lorder
            case 0
                set(gui.radio_handles.invjoint_Lorder0,'Value',1);
                set(gui.radio_handles.invjoint_Lorder1,'Value',0);
                set(gui.radio_handles.invjoint_Lorder2,'Value',0);
                
            case 1
                set(gui.radio_handles.invjoint_Lorder0,'Value',0);
                set(gui.radio_handles.invjoint_Lorder1,'Value',1);
                set(gui.radio_handles.invjoint_Lorder2,'Value',0);
                
            case 2
                set(gui.radio_handles.invjoint_Lorder0,'Value',0);
                set(gui.radio_handles.invjoint_Lorder1,'Value',0);
                set(gui.radio_handles.invjoint_Lorder2,'Value',1);
        end
end

end

function gui = updateParams(gui,invtype,p)

switch invtype
    case {'mono','free'}
        set(gui.edit_handles.param_CBW,'Enable','off','String',num2str(p.CBWcutoff));
        set(gui.edit_handles.param_BVI,'Enable','off','String',num2str(p.BVIcutoff));
        set(gui.edit_handles.param_rho,'Enable','on','String',num2str(p.rho));
        set(gui.edit_handles.param_geom,'Enable','on','String',num2str(p.a));
        
    case {'ILA','NNLS'}
        set(gui.edit_handles.param_CBW,'Enable','on','String',num2str(p.CBWcutoff));
        set(gui.edit_handles.param_BVI,'Enable','on','String',num2str(p.BVIcutoff));
        set(gui.edit_handles.param_rho,'Enable','on','String',num2str(p.rho));
        set(gui.edit_handles.param_geom,'Enable','on','String',num2str(p.a));
        
end
set(gui.edit_handles.param_calibVol,'Enable','on','String',num2str(p.calibVol));
set(gui.edit_handles.param_calibAmp,'Enable','on','String',num2str(p.calibAmp));
set(gui.edit_handles.param_sampVol,'Enable','on','String',num2str(p.sampVol));

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