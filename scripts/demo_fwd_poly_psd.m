% function demo_fwd_poly_psd
clear variables; clc;

%% geometry
% hexagonal pores
geom.type  = 'poly';
geom.polyN = 6;

% PSD
psddata = createPSD([1e-8 1e-4],[1e-6 0.5 1],50,1);

% get geometry data
geom.radius = psddata.r';
geom = getGeometryParameter(geom);

%% CPS
% pressure range
pbounds = getPressureRangeFromPSD(geom,psddata); % [Pa]
pressure = logspace(log10(pbounds(1)),log10(pbounds(2)),50);
% physical constants
constants = getConstants;
% no waitbar
wbopts.show = false;
% get CPS data
sat = getSaturationFromPressureBatch(geom,pressure,psddata,constants,wbopts);

%% NMR
% init
nmr.t = getNMRTimeVector(0.1,'ms','tmax',0.1);
nmr.rho = 1e-5;
nmr.Tb = 2;
nmr.Td = 1e6;
% get NMR data
nmr = getNMRSignal(nmr,geom.type,sat,psddata,wbopts);

%% just pick NMR signals at predefined saturations / pressures
SatImbDrain = 'DDDID';
SatLevels   = [1 0.95 0.8 0.5 0.2]; % saturation values
iSatLevels = getSaturationLevelData(sat,SatLevels,SatImbDrain); % indices

%% results
figure;
% color for the individual NMR signals
mycol = flipud(parula(128));
colind = getColorIndex(SatLevels,128);

subplot(131);
plot(psddata.r,psddata.psd,'k','LineWidth',2);
set(gca,'XSCale','log','XLim',[1e-8 1e-4],'XTick',[1e-8 1e-7 1e-6 1e-5 1e-4]);
xlabel('equiv. pore size [m]');
ylabel('amplitude [-]');
title('pore size distribution - hexagonal');
ylim([0 0.04]);
axis square;
grid on

subplot(132);
plot(pressure,sat.Sifull,'kv-','LineWidth',1.5,'MarkerSize',8); hold on;
plot(pressure,sat.Sdfull,'k^-','LineWidth',1.5,'MarkerSize',8);
for i = 1:length(iSatLevels)
    if strcmp(SatImbDrain(i),'D')
        plot(pressure(iSatLevels(i)),sat.Sdfull(iSatLevels(i)),'o',...
            'Color',mycol(colind(i),:),'LineWidth',2,'MarkerSize',10); hold on;
    elseif strcmp(SatImbDrain(i),'I')
        plot(pressure(iSatLevels(i)),sat.Sifull(iSatLevels(i)),'o',...
        'Color',mycol(colind(i),:),'LineWidth',2,'MarkerSize',10);
    end
end
set(gca,'XSCale','log');
xlabel('pressure [Pa]');
ylabel('saturation [-]');
title('capillary pressure saturation');
ylim([-0.05 1.05]);
legend('imb','drain','Location','SouthWest')
axis square;
grid on

subplot(133);
for i = 1:length(SatLevels)
    if strcmp(SatImbDrain(i),'D')
        plot(nmr.t,nmr.EdT2(iSatLevels(i),:),'-','Color',...
            mycol(colind(i),:),'LineWidth',2); hold on;
    elseif strcmp(SatImbDrain(i),'I')
        plot(nmr.t,nmr.EiT2(iSatLevels(i),:),'--','Color',...
            mycol(colind(i),:),'LineWidth',2); hold on;
    end
   
end
xlabel('time [s]');
ylabel('saturation [-]');
title('NMR T2 data');
axis square;
grid on;
