% example script imports NUCLEUS data files and calculates Ku estimates
% based on capillary bundle model with circular or angular pore cross section

% For running it, NUCLEUS folder und subfolders must be registered in the
% MATLAB working path 
clear all;
% working directory:
%mypath = 'E:\Costabel.S\Papers\KU_triangle_model\figures\Figure2';
mypath = 'E:\Costabel.S\Projekte\Petromethoden\WRC_from_NMR\Software\NUCLEUS\example data\Documentation\T2inv_maran';

[filenames,path] = uigetfile('*.mat','pick NUCLEUS data files',mypath,'MultiSelect','on');

pressure = 10.^[1:0.01:7];

% check how many files were selected
if iscell(filenames)
    ndset = length(filenames);
else
    ndset = 1;
    file = filenames;
end

for nfile = 1:ndset
    if ndset > 1
        file = filenames{nfile};
    end
    load([path,file]);
    % check whether file comes from NUCLEUSmod
    if exist('data') == 1
        % gather info for feeding the the modified NUCLEUS functions
        geom = data.GEOM;
        psddata = data.psddata;
        wbopts.show = false;
    % check whether file comes from NUCLEUSinv...
    elseif exist('idata') == 1
            %...and contains results of joint inversion
            if isfield(idata.results,'invjoint')
                % gather info for feeding the modified NUCLEUS functions
                geom = idata.results(1).invjoint.iGEOM;
                psddata.r = geom.radius';
                psddata.psd = idata.results(1).invjoint.iF'./sum(idata.results(1).invjoint.iF);
                wbopts.show = false;
            else
                disp(['File <',file,'> does not contain joint inversion results']);
            end
    else
        disp(['File <',file,'> is not a regular NUCLEUS export']);
    end
    pSAT = getSaturationFromPressureBatch(geom,pressure,psddata,getConstants,wbopts);
%     idata.results(1).invjoint.pSAT = pSAT;
%     save([path,file(1:end-4),'_corr.mat']);
    dset(nfile).pSAT = pSAT;
    dset(nfile).file = file;
    dset(nfile).PSD = psddata;
    dset(nfile).ptype = geom.type;
end

%% plot WRC and KU data
p_fak = 1/100; %pressure in hPa or h in cm
K_fak = 100*60*60*24; % hydr. conductivity in cm/d
% porosity estimate:
poro = 0.35; % NOTE THAT K-VALUES FROM NUCLEUS COME PURELY, I.E., WITHOUT
% POROSITY AND TORTUOSITY CORRECTION!

% tolerance for Krel calculation considering possible artefacts at high
% relaxation times:
tolKrel = 0.999;

for nfile = 1:ndset
    pSAT = dset(nfile).pSAT;
    PSD = dset(nfile).PSD;
    figure;
    % Equivalent pore size distribution
    subplot(2,2,1);
    plot(PSD.r,PSD.psd);
    title(['eq. PSD of <',dset(nfile).file,'>']);
    xlabel('r_{eq} [m]');
    ylabel('\theta_{part} [a.u.]');
    set(gca,'xscale','log');
    % Water retention curve
    subplot(2,2,2);
    plot(pSAT.Sdfull,p_fak*pSAT.pressure);
    title(['WRC (',dset(nfile).ptype,') of <',dset(nfile).file,'>']);
    xlabel('S [-]');
    ylabel('h [cm]');
    set(gca,'yscale','log',...
            'xlim',[0 1]);
    % hydraulic conductivity
    subplot(2,2,3);
    plot(pSAT.Sdfull,K_fak*poro*pSAT.Kdfull,pSAT.Sdfull,K_fak*poro*pSAT.Kd_eff);
    title(['K_U (',dset(nfile).ptype,') of <',dset(nfile).file,'>']);
    xlabel('S [-]');
    ylabel('K_U [cm/d]');
    set(gca,'yscale','log',...
            'xlim',[0 1],...
            'ylim',[1e-5 1e5]);
    legend('K_U (full)','K_U (eff)','Location','SouthEast');
    % relative hydraulic conductivity
    subplot(2,2,4);
    plot(pSAT.Sdfull,pSAT.Kdfull/pSAT.Kdfull(find(pSAT.Sdfull<tolKrel,1)),...
        pSAT.Sdfull,pSAT.Kd_eff/pSAT.Kd_eff(find(pSAT.Sdfull<tolKrel,1)));
    title(['K_{rel} (',dset(nfile).ptype,') of <',dset(nfile).file,'>']);
    xlabel('S [-]');
    ylabel('K_{rel} [-]');
    set(gca,'yscale','log',...
            'xlim',[0 1],...
            'ylim',[1e-6 1]);
    legend('K_{rel} (full)','K_{rel} (eff)','Location','SouthEast');    
end
