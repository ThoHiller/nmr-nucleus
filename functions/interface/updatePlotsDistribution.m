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
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
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
            mycols = [22 140 75;22 87 140;140 22 87;140 75 22;64 64 64]./255;
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
            
        case {'LU','NNLS'}
            % scale distribution by porosity
            F = invstd.T1T2f;
            if sum(F)>0
                F = (data.invstd.porosity*100).*F./sum(F);
                ylims = [0 max(F)*1.05];
            else
                ylims = [-1 1];
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
                    set(get(ax,'YLabel'),'String','water content [vol. %]');
                    
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
                    set(get(ax,'YLabel'),'String','cumulative water content [vol. %]');                    
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
            mycols = [22 140 75;22 87 140;140 22 87;140 75 22;64 64 64]./255;
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
                    stem(Rlgm,amp,'x-','Color',[0.3 0.3 0.3],'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',ylims);
                    % y-label
                    set(get(ax,'YLabel'),'String','water content [vol. %]');
                    
                case 'cum'
                    plot(requiv,cumsum(F),'o-','Color',col.FIT,...
                        'LineWidth',2,'Parent',ax);
                    % find approx. RLGM amplitude
                    amp = findApproxTlgmAmplitude(requiv,cumsum(F),Rlgm);
                    stem(Rlgm,amp,'x-','Color',[0.3 0.3 0.3],'LineWidth',2,'Tag','TLGM','Parent',ax);
                    
                    % y-limits
                    set(ax,'YScale','lin','YLim',[0 sum(F)*1.05]);
                    % y-label
                    set(get(ax,'YLabel'),'String','cumulative water content [vol. %]');
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