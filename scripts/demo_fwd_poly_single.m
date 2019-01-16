% function demo_fwd_poly_single
clear variables; clc;

%% geometry
% square pore
geom.type  = 'poly';
geom.polyN = 4; % square

% single pore
psddata.psd = 1;
psddata.r = 1e-6; % [m]

% get geometry data
geom.radius = psddata.r;
geom = getGeometryParameter(geom);

%% CPS
% pressure range
pbounds = [1e4 1e6]; % [Pa]
pressure = logspace(log10(pbounds(1)),log10(pbounds(2)),50);
% physical constants
constants = getConstants;
% no waitbar
wbopts.show = false;
% get CPS data
sat = getSaturationFromPressureBatch(geom,pressure,psddata,constants,wbopts);

%% NMR
% init
nmr.t = getNMRTimeVector(1,'ms','N',1001);
nmr.rho = 1e-6;
nmr.Tb = 2;
% get NMR data
nmr = getNMRSignal(nmr,geom.type,sat,psddata,wbopts);

%% results
figure;

subplot(131);
stem(psddata.r,psddata.psd,'ko','LineWidth',2);
set(gca,'XSCale','log')
xlabel('equiv. pore size [m]');
ylabel('amplitude [-]');
title('single pore size - square');
ylim([0 1.05]);
axis square;
grid on;

subplot(132);
semilogx(pressure,sat.Sifull,'kv-','LineWidth',1.5,'MarkerSize',8); hold on;
semilogx(pressure,sat.Sdfull,'k^-','LineWidth',1.5,'MarkerSize',8);
xlabel('pressure [Pa]');
ylabel('saturation [-]');
title('capillary pressure saturation');
ylim([-0.05 1.05]);
legend('imb','drain','Location','SouthWest')
axis square;
grid on;

[pp,tt] = meshgrid(pressure,nmr.t);
subplot(133);
pcolor(tt',pp',nmr.EiT1); shading flat;
set(gca,'XScale','log','YScale','log','Layer','top');
xlabel('time [s]');
ylabel('pressure [Pa]');
title('NMR T1 data (imbibition)');
axis square;
cb = colorbar;
set(cb,'Location','North','XColor','w');
