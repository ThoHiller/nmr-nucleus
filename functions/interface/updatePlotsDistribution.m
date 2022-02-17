function updatePlotsDistribution
%updatePlotsDistribution plots the RTD and PSD curves into NUCLEUSinv
%
% Syntax:
%       updatePlotsDistribution
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsDistribution
%
% Other m-files required:
%       none
%
% Subfunctions:
%       findApproxTlgmAmplitude
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
col = gui.myui.colors;

nmrproc = data.results.nmrproc;
% only continue if there is actual data to show
if isfield(data.results,'invstd')
    invstd = data.results.invstd;
    
    %% RTD
    % RTD axis
    ax = gui.axes_handles.rtd;
    clearSingleAxis(ax);
    hold(ax,'on');
    set(gui.cm_handles.axes_rtd_view,'Enable','on');
    
    % x-axis label
    switch data.process.timescale
        case 's'
            xlstring = 'relaxation time [s]';
        case 'ms'
            xlstring = 'relaxation time [ms]';
    end
    
    switch data.invstd.invtype
        case 'mono'
            switch nmrproc.T1T2
                case 'T1'
                    T = invstd.T1;
                case 'T2'
                    T = invstd.T2;
            end
            
            stem(T,invstd.E0,'o-','Color',col.FIT,'LineWidth',2,'Parent',ax);
            
            % limits
            ticks = floor(log10(min(T)))-2 :1: ceil(log10(max(T)))+2;
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'YScale','lin','YLim',[0 invstd.E0*1.05]);
            % labels
            set(get(ax,'XLabel'),'String',xlstring);
            set(get(ax,'YLabel'),'String','initial amplitude E0');
            % grid
            grid(ax,'on');
            
        case 'free'
            mymark = {'o-','+-','s-','d-','x-'};
            mycols = [0.8941 0.1020 0.1098;0.3020 0.6863 0.2902;
                0.2157 0.4941 0.7216;0.5961 0.3059 0.6392;0.6510 0.3373 0.1569];
            switch nmrproc.T1T2
                case 'T1'
                    T = invstd.T1;
                case 'T2'
                    T = invstd.T2;
            end
            
            lgdstr = cell(1,1);
            for i = 1:data.invstd.freeDT
                stem(T(i),invstd.E0(i),mymark{i},'Color',mycols(i,:),'LineWidth',2,'Parent',ax);
                lgdstr{i} = ['T',num2str(i)];
            end
            
            % limits
            ticks = floor(log10(min(T)))-2 :1: ceil(log10(max(T)))+2;
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'YScale','lin','YLim',[0 max(invstd.E0)*1.05]);
            % labels
            set(get(ax,'XLabel'),'String',xlstring);
            set(get(ax,'YLabel'),'String','individual amplitudes Ex [-]');
            % grid
            grid(ax,'on');
            
        case {'LU'}
            % scale distribution by porosity
            F = invstd.T1T2f;
            if sum(F)>0
                F = (data.invstd.porosity*100).*F./sum(F);
                ylims = [0 max(F)*1.05];
            else
                ylims = [-1 1];
            end
            if data.invstd.porosity == 1
                ylab1 = 'amplitudes [-]';
                ylab2 = 'cumulative amplitudes [-]';
            else
                ylab1 = 'water content [vol. %]';
                ylab2 = 'cumulative water content [vol. %]';
            end
            % F = data.invstd.porosity.*F./trapz(T,F);
            
            switch data.info.RTDflag
                case 'freq'
                    plot(invstd.T1T2me,F,'o-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,F,invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab1);
                    
                case 'cum'
                    plot(invstd.T1T2me,cumsum(F),'o-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,cumsum(F),invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab2);
            end
            
            % x-limits
            ticks = round(log10(min(invstd.T1T2me)) :1: log10(max(invstd.T1T2me)));
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            % x-label
            set(get(ax,'XLabel'),'String',xlstring);
            % grid
            grid(ax,'on');
            
        case {'NNLS'}
            % scale distribution by porosity
            F = invstd.T1T2f;
            if sum(F)>0
                % apply same scaling to the uncertainty patch
                if isfield(data.results.invstd,'uncert')
                    f_min = data.results.invstd.uncert.interp_f_min;
                    f_max = data.results.invstd.uncert.interp_f_max;
                    f_min = (data.invstd.porosity*100).*f_min./sum(F);
                    f_max = (data.invstd.porosity*100).*f_max./sum(F);
                end                
                F = (data.invstd.porosity*100).*F./sum(F);
                
                ylims = [0 max(F)*1.05];
            else
                ylims = [-1 1];
            end
            if data.invstd.porosity == 1
                ylab1 = 'amplitudes [-]';
                ylab2 = 'cumulative amplitudes [-]';
            else
                ylab1 = 'water content [vol. %]';
                ylab2 = 'cumulative water content [vol. %]';
            end
            % F = data.invstd.porosity.*F./trapz(T,F);
            
            switch data.info.RTDflag
                case 'freq'
                    if isfield(data.results.invstd,'uncert')
                        % plot uncertainty
                        for i = 1:size(invstd.uncert.interp_f,1)
                         plot(invstd.T1T2me,(data.invstd.porosity*100).*invstd.uncert.interp_f(i,:)./sum(invstd.T1T2f),...
                         '-','Color',[0.5 0.5 0.5],'LineWidth',1,'Parent',ax);
                         end
%                         verts = [invstd.T1T2me f_min'; flipud(invstd.T1T2me) flipud(f_max')];
%                         faces = 1:1:size(verts,1);
%                         patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
%                             'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                        % adjust y-limits
                        ylims(2) = max([ylims(2) max(f_max)*1.05]);
                    end
                    
                    plot(invstd.T1T2me,F,'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,F,invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab1);
                    
                case 'cum'
                    if isfield(data.results.invstd,'uncert')
                        verts = [invstd.T1T2me cumsum(F)-f_min'; flipud(invstd.T1T2me) flipud(cumsum(F)+f_max')];
                        faces = 1:1:size(verts,1);
                        patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                            'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                    end
                    plot(invstd.T1T2me,cumsum(F),'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,cumsum(F),invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab2);
            end
            
            % x-limits
            ticks = round(log10(min(invstd.T1T2me)) :1: log10(max(invstd.T1T2me)));
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            % x-label
            set(get(ax,'XLabel'),'String',xlstring);
            % grid
            grid(ax,'on');    
            
        case {'MUMO'}
            % single distributions for different T, sigma and amplitude
            dist = zeros(length(invstd.x)/3,numel(invstd.T1T2me));
            for i = 1:length(invstd.x)/3
                mu = invstd.T(i);
                sigma = invstd.S(i);
                amp = invstd.E(i);
                
                tmp = 1./( sigma*sqrt(2*pi)).*exp(-((log(invstd.T1T2me) - log(mu))/ sqrt(2)/sigma).^2);
                
                % scale to amplitude
                dist(i,:) = (tmp/sum(tmp)) * amp;
            end
            
            % scale distribution by porosity
            F = invstd.T1T2f;
            if sum(F)>0
                for i = 1:length(invstd.x)/3
                    dist(i,:) = (data.invstd.porosity*100).*dist(i,:)./sum(F);
                end
                % apply same scaling to the uncertainty patch
                if isfield(data.results.invstd,'uncert')
                    f_min = data.results.invstd.uncert.interp_f_min;
                    f_max = data.results.invstd.uncert.interp_f_max;
                    f_min = (data.invstd.porosity*100).*f_min./sum(F);
                    f_max = (data.invstd.porosity*100).*f_max./sum(F);
                end
                F = (data.invstd.porosity*100).*F./sum(F);
                
                ylims = [0 max(F)*1.05];
            else
                ylims = [-1 1];
            end
            if data.invstd.porosity == 1
                ylab1 = 'amplitudes [-]';
                ylab2 = 'cumulative amplitudes [-]';
            else
                ylab1 = 'water content [vol. %]';
                ylab2 = 'cumulative water content [vol. %]';
            end
            % F = data.invstd.porosity.*F./trapz(T,F);
            
            mycols = [0.2157 0.4941 0.7216;0.3020 0.6863 0.2902;
                0.5961 0.3059 0.6392;0.6510 0.3373 0.1569;0.8941 0.1020 0.1098];
            
            switch data.info.RTDflag
                case 'freq'
                    if isfield(data.results.invstd,'uncert')
                        % plot uncertainty
                        % lines
                        % for i = 1:size(invstd.TDIST,1)
                        %  plot(invstd.T1T2me,(data.invstd.porosity*100).*invstd.TDIST(i,:)./sum(invstd.T1T2f),...
                        %  '-','Color',[0.5 0.5 0.5],'LineWidth',1,'Parent',ax);
                        %  end
                        % patch
%                         TDIST = invstd.TDIST;
%                         for i = 1:size(invstd.TDIST,1)
%                             TDIST(i,:) = (data.invstd.porosity*100).*invstd.TDIST(i,:)./sum(invstd.T1T2f);
%                         end
%                         TDISTmin = min(TDIST);
%                         TDISTmax = max(TDIST);
%                         verts = [nmrproc.t(nmrproc.t>0) s_min; flipud(nmrproc.t(nmrproc.t>0)) flipud(s_max)];
%                         faces = 1:1:size(verts,1);
%                 
                        verts = [invstd.T1T2me f_min'; flipud(invstd.T1T2me) flipud(f_max')];
                        faces = 1:1:size(verts,1);
                        patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                            'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                        % adjust y-limits
                        ylims(2) = max([ylims(2) max(f_max)*1.05]);
                    end
                    
                    % plot total RTD
                    plot(invstd.T1T2me,F,'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % plot individual RTDs
                    for i = 1:length(invstd.x)/3
                        plot(invstd.T1T2me,dist(i,:),'--','Color',mycols(i,:),...
                            'LineWidth',2,'Parent',ax);
                    end
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,F,invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab1);
                    
                case 'cum'
                    if isfield(data.results.invstd,'uncert')
                        verts = [invstd.T1T2me cumsum(F)-f_min'; flipud(invstd.T1T2me) flipud(cumsum(F)+f_max')];
                        faces = 1:1:size(verts,1);
                        patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                            'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                    end
                    plot(invstd.T1T2me,cumsum(F),'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    for i = 1:length(invstd.x)/3
                        plot(invstd.T1T2me,cumsum(dist(i,:)),'--','Color',mycols(i,:),...
                            'LineWidth',2,'Parent',ax);
                    end
                    % find approx. TLGM amplitude
                    amp = findApproxTlgmAmplitude(invstd.T1T2me,cumsum(F),invstd.Tlgm);
                    stem(invstd.Tlgm,amp,'x-','Color',col.axisL,...
                        'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab2);
            end
            
            % x-limits
            ticks = round(log10(min(invstd.T1T2me)) :1: log10(max(invstd.T1T2me)));
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            % x-label
            set(get(ax,'XLabel'),'String',xlstring);
            % grid
            grid(ax,'on');
    end
    
    %% PSD
    % PSD axis
    ax = gui.axes_handles.psd;
    clearSingleAxis(ax);
    hold(ax,'on');
    set(gui.cm_handles.axes_psd_view,'Enable','on');
    
    % x-axis label
    switch data.process.timescale
        case 's'
            xlstring = 'equiv. pore size [m]';
        case 'ms'
            xlstring = 'equiv. pore size [mm]';
    end
    
    rho = data.param.rho/1e6; % surface relaxivity [m/s]
    a = data.param.a; % geometry parameter
    
    switch data.invstd.invtype
        case 'mono'
            switch nmrproc.T1T2
                case 'T1'
                    T = invstd.T1;
                case 'T2'
                    T = invstd.T2;
            end
            
            stem(T.*rho.*a,invstd.E0,'o-','Color',col.FIT,'LineWidth',2,'Parent',ax);
            
            % limits
            ticks = floor(log10(min(T.*rho.*a)))-2 :1: ceil(log10(max(T.*rho.*a)))+2;
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'YScale','lin','YLim',[0 invstd.E0*1.05]);
            % labels
            set(get(ax,'XLabel'),'String',xlstring);
            set(get(ax,'YLabel'),'String','initial amplitude E0');
            % grid
            grid(ax,'on');
            
        case 'free'
            mymark = {'o-','+-','s-','d-','x-'};
            mycols = [0.8941 0.1020 0.1098;0.3020 0.6863 0.2902;
                0.2157 0.4941 0.7216;0.5961 0.3059 0.6392;0.6510 0.3373 0.1569];
            switch nmrproc.T1T2
                case 'T1'
                    T = invstd.T1;
                case 'T2'
                    T = invstd.T2;
            end
            
            lgdstr = cell(1,1);
            for i = 1:data.invstd.freeDT
                stem(T(i).*rho.*a,invstd.E0(i),mymark{i},'Color',mycols(i,:),'LineWidth',2,'Parent',ax);
                lgdstr{i} = ['T',num2str(i)];
            end
            
            % limits
            ticks = floor(log10(min(T.*rho.*a)))-2 :1: ceil(log10(max(T.*rho.*a)))+2;
            set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'YScale','lin','YLim',[0 max(invstd.E0)*1.05]);
            % labels
            set(get(ax,'XLabel'),'String',xlstring);
            set(get(ax,'YLabel'),'String','individual amplitudes Ex [-]');
            % grid
            grid(ax,'on');
            
        case {'LU','NNLS'}
            % very basic RTD to PSD conversion
            requiv = invstd.T1T2me.*rho.*a;
            Rlgm = invstd.Tlgm.*rho.*a;
            
            switch data.info.PSDflag
                case 'freq'
                    plot(requiv,F,'o-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. RLGM amplitude
                    amp = findApproxTlgmAmplitude(requiv,F,Rlgm);
                    stem(Rlgm,amp,'x-','Color',col.axisL,'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab1);
                    
                case 'cum'
                    plot(requiv,cumsum(F),'o-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. RLGM amplitude
                    amp = findApproxTlgmAmplitude(requiv,cumsum(F),Rlgm);
                    stem(Rlgm,amp,'x-','Color',col.axisL,'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab2);
            end
            
            % x-limits
            ticks = floor(log10(min(requiv))) :1: ceil(log10(max(requiv)));
            %         set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'XScale','log','XLim',[min(requiv) max(requiv)],'XTick',10.^ticks);
            % x-label
            set(get(ax,'XLabel'),'String',xlstring);
            % grid
            grid(ax,'on');
            
        case {'MUMO'}
            % very basic RTD to PSD conversion
            requiv = invstd.T1T2me.*rho.*a;
            Rlgm = invstd.Tlgm.*rho.*a;
            
            switch data.info.PSDflag
                case 'freq'
                    if isfield(data.results.invstd,'uncert')
                        verts = [requiv f_min'; flipud(requiv) flipud(f_max')];
                        patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                            'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                        % adjust y-limits
                        ylims(2) = max([ylims(2) max(f_max)*1.05]);
                    end
                    plot(requiv,F,'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    for i = 1:length(invstd.x)/3
                        plot(requiv,dist(i,:),'--','Color',mycols(i,:),...
                            'LineWidth',2,'Parent',ax);
                    end                    
                    % find approx. RLGM amplitude
                    amp = findApproxTlgmAmplitude(requiv,F,Rlgm);
                    stem(Rlgm,amp,'x-','Color',col.axisL,'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab1);
                    
                case 'cum'
                    if isfield(data.results.invstd,'uncert')
                        verts = [requiv cumsum(F)-f_min'; flipud(requiv) flipud(cumsum(F)+f_max')];
                        patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                            'FaceAlpha',0.75,'EdgeColor','none','Parent',ax);
                    end
                    plot(requiv,cumsum(F),'-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    for i = 1:length(invstd.x)/3
                        plot(requiv,cumsum(dist(i,:)),'--','Color',mycols(i,:),...
                            'LineWidth',2,'Parent',ax);
                    end                    
                    % find approx. RLGM amplitude
                    amp = findApproxTlgmAmplitude(requiv,cumsum(F),Rlgm);
                    stem(Rlgm,amp,'x-','Color',col.axisL,'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String',ylab2);
            end
            
            % x-limits
            ticks = floor(log10(min(requiv))) :1: ceil(log10(max(requiv)));
            %         set(ax,'XScale','log','XLim',[10^(ticks(1)) 10^(ticks(end))],'XTick',10.^ticks);
            set(ax,'XScale','log','XLim',[min(requiv) max(requiv)],'XTick',10.^ticks);
            % x-label
            set(get(ax,'XLabel'),'String',xlstring);
            % grid
            grid(ax,'on');
    end
    
    % show CBW and diffusion regime lines
    updatePlotsDistributionInfo;
end

end

%%
function amp = findApproxTlgmAmplitude(t,f,TLGM)

if isnan(TLGM)
    amp = NaN;
else
    index = find(abs(t-TLGM)==min(abs(t-TLGM)));
    amp = interp1(t(index-1:index+1),f(index-1:index+1),TLGM);
end

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