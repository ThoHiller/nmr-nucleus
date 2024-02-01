function updatePlotsSignal
%updatePlotsSignal plots the raw and processed NMR signals in NUCLEUSinv
%
% Syntax:
%       updatePlotsSignal
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updatePlotsSignal
%
% Other m-files required:
%       beautifyAxes
%       clearSingleAxis
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
col = gui.myui.colors;

% check if joint inversion is activated
isjoint = strcmp(get(gui.menu.extra_joint,'Checked'),'on');

% proceed if there is data
if isfield(data,'results') && isfield(data.results,'nmrraw') &&...
        isfield(data.results,'nmrproc')
    % get NMR data
    nmrraw = data.results.nmrraw;
    nmrproc = data.results.nmrproc;
    if isfield(data.results,'invstd')
        invstd = data.results.invstd;
    end
    %% RAW data axis
    ax = gui.axes_handles.raw;
    axI = gui.axes_handles.imag;
    clearSingleAxis(ax);
    clearSingleAxis(axI);
    hold(ax,'on');
    hold(axI,'on');
    
    % data
    if isreal(nmrraw.s)
        plot(nmrraw.t,real(nmrraw.s),'Color',col.RE,'Parent',ax);
    else
        plot(nmrraw.t,real(nmrraw.s),'Color',col.RE,'Parent',ax);
        plot(nmrraw.t,imag(nmrraw.s),'Color',col.IM,'LineWidth',1,'Parent',axI);
    end
    
    % limits & ticks
    loglinx = get(gui.cm_handles.axes_raw_xaxis,'Label');
    switch loglinx
        case 'x-axis -> lin' % log axes
            ticks = floor(min(log10(nmrraw.t(nmrraw.t>0)))):1:ceil(log10(nmrraw.t(end)));
            set(ax,'XScale','log','XLim',[10^(ticks(1)) nmrraw.t(end)],...
                'XTick',10.^ticks);
        case 'x-axis -> log' % lin axes
            set(ax,'XScale','lin','XLim',[nmrproc.echotime nmrraw.t(end)],...
                'XTickMode','auto');
    end
    logliny = get(gui.cm_handles.axes_raw_yaxis,'Label');
    switch nmrproc.T1T2
        case 'T1'
            switch logliny
                case 'y-axis -> lin' % log axes
                    ticks = floor(min(log10(nmrraw.s(nmrraw.s>0))))-1:1:ceil(log10(nmrraw.s(end)));
                    set(ax,'YScale','log','YLim',[10^(ticks(1)) 10^(ticks(end))],....
                        'YTick',10.^ticks);
                case 'y-axis -> log' % lin axes
                    set(ax,'YScale','lin','YLim',[-0.05 max(real(nmrraw.s))*1.05],...
                        'YTickMode','auto');
            end
        case 'T2'
            ymin = min([min(real(nmrraw.s)) min(imag(nmrraw.s))]);
            ymax = max(real(nmrraw.s));
            if  isfield(data.results,'invstd')
                ymax = max([ymax max(data.results.invstd.fit_s)]);
            end
            switch logliny
                case 'y-axis -> lin' % log axes
                    ticks = floor(log10(ymin))-1 :1: ceil(log10(ymax));
                    set(ax,'YScale','log','YLim',[10^(ticks(1)) ymax*1.05],...
                        'YTick',10.^ticks);
                case 'y-axis -> log' % lin axes
                    set(ax,'YScale','lin','YLim',[ymin ymax*1.05],...
                        'YTickMode','auto');
            end
    end
    
    % labels
    if strcmp(data.process.timescale,'s')
        set(get(ax,'XLabel'),'String','time [s]');
    else
        set(get(ax,'XLabel'),'String','time [ms]');
    end
    if strcmp(nmrproc.T1T2,'T2') && ~isreal(nmrraw.s)
        set(get(ax,'YLabel'),'String','\Reeal');
    else
        set(get(ax,'YLabel'),'String','amplitude [a.u.]');
    end
    
    % imag part
    if ~isreal(nmrraw.s)
        xlims = get(ax,'XLim');
        line(xlims,[0 0],'LineStyle','--','LineWidth',1,'Color','k','Parent',axI);
        imag_mean = mean(imag(nmrraw.s));
        imag_std = std(imag(nmrraw.s));
        yticks = [imag_mean-imag_std*2 0 imag_mean+imag_std*2];
        ylim = [imag_mean-imag_std*3 imag_mean+imag_std*3];
        set(axI,'XTickLabel','','YLim',ylim,'YTick',yticks,'YTickLabelMode','auto');
        switch loglinx
            case 'x-axis -> lin' % log axes
                set(axI,'XScale','log','XLim',xlims);
            case 'x-axis -> log' % lin axes
                set(axI,'XScale','lin','XLim',xlims);
        end
        set(get(axI,'YLabel'),'String','\Immag');
    end
    
    % grid
    grid(ax,'on');
    
    %% PROC data axis
    ax = gui.axes_handles.proc;
    axE = gui.axes_handles.err;
    clearSingleAxis(ax);
    clearSingleAxis(axE);
    hold(ax,'on');
    hold(axE,'on');
    
    % data
    switch data.invstd.invtype
        case {'LU','NNLS','MUMO'}            
            if isfield(data.results,'invstd')
                if isfield(data.results.invstd,'uncert')
                    uncert = data.results.invstd.uncert;
                    t = uncert.interp_t;
                    SDIST = uncert.interp_s;
                    switch data.info.RTDuncert
                        case 'lines'
                            plot(t,SDIST(:,1),'-','Color',[0.5 0.5 0.5],...
                                'LineWidth',1,...
                                'DisplayName','uncert models','Parent',ax);
                            plot(t,SDIST(:,2:end),'-','Color',[0.5 0.5 0.5],...
                                'LineWidth',1,'HandleVisibility','off',...
                                'Tag','infolines','Parent',ax);
                        case 'patch'
                            % uncertainty patch created from min max of uncertainty
                            % data
                            s_min = data.results.invstd.uncert.interp_s_min;
                            s_max = data.results.invstd.uncert.interp_s_max;
                            t = data.results.invstd.uncert.interp_t;
                            verts = [t(t>0) s_min(t>0); flipud(t(t>0)) flipud(s_max(t>0))];
                            faces = 1:1:size(verts,1);
                            patch('Faces',faces,'Vertices',verts,'FaceColor',[0.64 0.64 0.64],...
                                'FaceAlpha',0.75,'EdgeColor','none',...
                                'DisplayName','uncert','Parent',ax);
                    end

                end
                if nmrproc.isgated
                    plot(data.results.nmrraw.t,data.results.nmrraw.s,'o',...
                        'Color',[0.64 0.64 0.64],'LineWidth',0.75,...
                        'DisplayName','signal_{raw}','Parent',ax);
                    plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',0.75,...
                        'DisplayName','signal_{gated}','Parent',ax);
                else
                    plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',0.75,...
                        'DisplayName','signal','Parent',ax);
                end                
                plot(invstd.fit_t,invstd.fit_s,'Color',col.FIT,'LineWidth',2,...
                    'DisplayName','fit','Parent',ax);
                if nmrproc.noise > 0
                    plot(nmrproc.t,invstd.residual./nmrproc.e,'Color',col.IM,...
                        'LineWidth',1,'Parent',axE);
                else
                    plot(nmrproc.t,invstd.residual,'Color',col.IM,...
                        'LineWidth',1,'Parent',axE);
                end
            else
                if nmrproc.isgated
                    plot(data.results.nmrraw.t,data.results.nmrraw.s,'o',...
                        'Color',[0.64 0.64 0.64],'LineWidth',0.75,...
                        'DisplayName','signal_{raw}','Parent',ax);
                    plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',0.75,...
                        'DisplayName','signal_{gated}','Parent',ax);
                else
                    plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',0.75,...
                        'DisplayName','signal','Parent',ax);
                end                
            end

        otherwise % mono & free
            if nmrproc.isgated
                plot(data.results.nmrraw.t,data.results.nmrraw.s,'o',...
                    'Color',[0.64 0.64 0.64],'LineWidth',0.75,...
                    'DisplayName','signal_{raw}','Parent',ax);
                plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',1,...
                    'DisplayName','signal_{gated}','Parent',ax);
            else
                plot(nmrproc.t,nmrproc.s,'o','Color',col.RE,'LineWidth',1,...
                    'DisplayName','signal','Parent',ax);
            end
            if isfield(data.results,'invstd')
                plot(invstd.fit_t,invstd.fit_s,'Color',col.FIT,'LineWidth',2,...
                    'DisplayName','fit','Parent',ax);
                if nmrproc.noise > 0
                    plot(nmrproc.t,invstd.residual./nmrproc.e,'Color',col.IM,...
                        'LineWidth',1,'Parent',axE);
                else
                    plot(nmrproc.t,invstd.residual,'Color',col.IM,...
                        'LineWidth',1,'Parent',axE);
                end        
            end
    end
    
    % limits & ticks
    xlimraw = get(gui.axes_handles.raw,'XLim');
    loglinx = get(gui.cm_handles.axes_proc_xaxis,'Label');
    switch loglinx
        case 'x-axis -> lin' % log axes
            ticks = floor(min(log10(nmrproc.t(nmrproc.t>0)))):1:ceil(log10(nmrproc.t(end)));
            set(ax,'XScale','log','XLim',xlimraw,'XTick',10.^ticks);
        case 'x-axis -> log' % lin axes
            set(ax,'XScale','lin','XLim',xlimraw,'XTickMode','auto');
    end
    xlims = xlimraw;
    switch nmrproc.T1T2
        case 'T1'
            if isfield(data.results,'invstd') && isfield(data.results.invstd,'uncert')
                xlims(2) = max([xlimraw(2) max(data.results.invstd.uncert.interp_t)/2]);
            end
            set(ax,'XLim',xlims);
            set(gui.axes_handles.raw,'XLim',xlims);
            set(gui.axes_handles.imag,'XLim',xlims);            
        case 'T2' 
    end
    logliny = get(gui.cm_handles.axes_proc_yaxis,'Label');
    switch nmrproc.T1T2
        case 'T1'
            ymin = min(real(nmrproc.s));
            ymax = max(real(nmrproc.s));
            if isfield(data.results,'invstd')
                ymin = min([ymin min(invstd.residual)]);
                ymax = max([ymax max(data.results.invstd.fit_s)]);
                if isfield(data.results.invstd,'uncert')
                    ymax = max([ymax max(data.results.invstd.uncert.interp_s(:))]);
                end
            end
            if ymin>0
                ymin = ymin*0.8;
            else
                ymin = ymin*1.2;
            end
            switch logliny
                case 'y-axis -> lin' % log axes
                    ticks = floor(min(log10(nmrproc.s(nmrproc.s>0))))-1:1:ceil(log10(nmrproc.s(end)));
                    set(ax,'YScale','log','YLim',[10^(ticks(1)) 10^(ticks(end))],...
                        'YTick',10.^ticks);
                case 'y-axis -> log' % lin axes
                    set(ax,'YScale','lin','YLim',[ymin ymax*1.05],...
                        'YTickMode','auto');
            end
        case 'T2'
            ymin = min([min(real(nmrraw.s)) min(imag(nmrraw.s))]);
            ymax = max(real(nmrraw.s));
            if isfield(data.results,'invstd')
                ymin = min([ymin min(invstd.residual)]);
                ymax = max([ymax max(data.results.invstd.fit_s)]);
                if isfield(data.results.invstd,'uncert')
                    ymax = max([ymax max(data.results.invstd.uncert.interp_s(:))]);
                end
            end
            switch logliny
                case 'y-axis -> lin' % log axes
                    ticks = floor(log10(ymin))-1 :1: ceil(log10(ymax));
                    set(ax,'YScale','log','YLim',[10^(ticks(1)) ymax*1.1],...
                        'YTick',10.^ticks);
                case 'y-axis -> log' % lin axes
                    set(ax,'YScale','lin','YLim',[ymin ymax*1.1],...
                        'YTickMode','auto');
            end
    end
    if isfield(data.results,'invstd')
        ylims = get(ax,'YLim');
        set(gui.axes_handles.raw,'YLim',ylims);
    end
    
    % labels
    if strcmp(data.process.timescale,'s')
        set(get(ax,'XLabel'),'String','time [s]');
    else
        set(get(ax,'XLabel'),'String','time [ms]');
    end
    set(get(ax,'YLabel'),'String','amplitude [a.u.]');
    
    % legend
    if isfield(data.results,'invstd')
        switch nmrproc.T1T2
            case 'T1'
                lgh = legend(ax,'Location','NorthWest',...
                    'Tag','fitlegend','FontSize',10);
            case 'T2'
                lgh = legend(ax,'Location','NorthEast',...
                    'Tag','fitlegend','FontSize',10);
        end
        set(lgh,'TextColor',gui.myui.colors.panelFG);
    end
    
    % grid
    grid(ax,'on');
    
    %% residual plot
    if isfield(data.results,'invstd')
        col = gui.myui.colors.axisL;
        xlims = get(ax,'XLim');
        line(xlims,[0 0],'LineStyle','--','LineWidth',1,'Color',col,'Parent',axE);
        if nmrproc.noise > 0
            err_mean = mean(invstd.residual./nmrproc.e);
            err_std = std(invstd.residual./nmrproc.e);
            line(xlims,[err_mean-err_std err_mean-err_std],...
                'LineStyle','--','LineWidth',1,'Color','r','Parent',axE);
            line(xlims,[err_mean+err_std err_mean+err_std],...
                'LineStyle','--','LineWidth',1,'Color','r','Parent',axE);
            line(xlims,[-1 -1],'LineStyle','-.','LineWidth',1,...
                'Color',col,'Parent',axE);
            line(xlims,[1 1],'LineStyle','-.','LineWidth',1,...
                'Color',col,'Parent',axE);
            set(axE,'XTickLabel','');
            set(axE,'YLim',[-2 2]);
            set(axE,'YTick',[-1 0 1],'YTickLabelMode','auto');
            set(get(axE,'YLabel'),'String',{'noise';'weighted';'residuals'},...
                'FontWeight','normal');
        else
            err_mean = mean(invstd.residual);
            err_std = std(invstd.residual);
            line(xlims,[err_mean-1*err_std err_mean-1*err_std],...
                'LineStyle','-.','LineWidth',1,'Color',col,'Parent',axE);
            line(xlims,[err_mean+1*err_std err_mean+1*err_std],...
                'LineStyle','-.','LineWidth',1,'Color',col,'Parent',axE);
            set(axE,'XTickLabel','');
            set(axE,'YLim',[err_mean-3*err_std err_mean+3*err_std]);
            set(axE,'YTick',[err_mean-3*err_std 0 err_mean+3*err_std],...
                'YTickLabelMode','auto')
            set(get(axE,'YLabel'),'String','residuals',...
                'FontWeight','normal');
        end
        
        switch loglinx
            case 'x-axis -> lin' % log axes
                set(axE,'XScale','log','XLim',xlims);
            case 'x-axis -> log' % lin axes
                set(axE,'XScale','lin','XLim',xlims);
        end
    end
    % finalize
    beautifyAxes(fig);
end

%% if joint inversion is activated all NMR signals are plotted into the
% "ALL (joint)" panel - this is just a rough overview if no joint inversion
% result is yet availabe
if isjoint && ~isfield(data.results,'invjoint') && ...
        ~strcmp(data.invstd.regtype,'lcurve')
    
    ax = gui.axes_handles.all;
    clearSingleAxis(ax);
    
    INVdata = getappdata(fig,'INVdata');
    
    nINV = size(INVdata,1);
    E0 = zeros(nINV,1);
    c = 0;
    invlevels = 0;
    for i = 1:nINV
        if isstruct(INVdata{i})
            c = c + 1;
            invlevels(c) = i; %#ok<AGROW>
            E0(i,1) = sum(INVdata{i}.results.invstd.E0);
        end
    end
    
    % the pressure / saturation data
    table = data.pressure.table;
    
    if size(table,1) == 1 & invlevels ~= 0 %#ok<AND2>
        % apparently no CPS data was loaded but joint inversion is
        % activated ... so just plot the data
        if invlevels == 0
            levels = [];
        else
            levels = invlevels;
            S = E0(invlevels)./max(E0(invlevels));
        end
    else
        uselevel = cell2mat(table(:,1));
        tablelevels = 1:size(table,1);
        tablelevels = tablelevels(uselevel);
        S = cell2mat(table(:,3));
        %         if numel(S)~=nINV
        %             % S()
        %         end
        [isin,levels] = ismember(invlevels,tablelevels);
        levels = tablelevels(levels(isin));
    end

    if ~isempty(levels) && levels(1) > 0 && c > 0
        hold(ax,'on');
        
        mycol = flipud(parula(128));
        for i = 1:numel(levels)
            t = INVdata{levels(i)}.results.invstd.fit_t;
            s = INVdata{levels(i)}.results.invstd.fit_s;
            s = S(levels(i)).*(s./sum(INVdata{levels(i)}.results.invstd.E0));
            if i == 1
                xlims = [min(t) max(t)];
                ylims = [min(s) max(s)];
            else
                xlims = [min([xlims(1) min(t)]) max([xlims(2) max(t)])];
                ylims = [min([ylims(1) min(s)]) max([ylims(2) max(s)])];
            end
            colind = getColorIndex(S(levels(i)),128);
            plot(t,s,'LineStyle','-','Color',mycol(colind,:),'Parent',ax);
        end
        set(ax,'YLim',ylims);
        
        loglinx = get(gui.cm_handles.axes_all_xaxis,'Label');
        switch loglinx
            case 'x-axis -> lin' % log axes
                ticks = floor(min(log10(nmrproc.t(nmrproc.t>0)))):1:ceil(log10(nmrproc.t(end)));
                set(ax,'XScale','log','XLim',xlims,'XTick',10.^ticks);
            case 'x-axis -> log' % lin axes
                set(ax,'XScale','lin','XLim',xlims,'XTickMode','auto');
        end
        logliny = get(gui.cm_handles.axes_all_yaxis,'Label');
        switch logliny
            case 'y-axis -> lin' % log axes
                set(ax,'YScale','log');
            case 'y-axis -> log' % lin axes
                set(ax,'YScale','lin');
        end
    end
end

% update GUI data
setappdata(fig,'data',data);
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