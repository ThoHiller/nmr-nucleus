function showExtraGraphics(method)
%showExtraGraphics shows additional figures for long time NMR lab
%measurements
%
% Syntax:
%       showExtraGraphics
%
% Inputs:
%       method
%
% Outputs:
%       none
%
% Example:
%       showExtraGraphics('amp')
%
% Other m-files required:
%       none
%
% Subfunctions:
%       none
%fitDataLUdecomp
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
% fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');
gui = getappdata(fig,'gui');
col = gui.myui.colors;

% color for individual realaxation time(s) (modes)
mycols = [0.2157 0.4941 0.7216;0.3020 0.6863 0.2902;
          0.5961 0.3059 0.6392;0.6510 0.3373 0.1569;
          0.8941 0.1020 0.1098];

%% proceed if there is data
[foundINV,~] = checkIfInversionExists(INVdata);

if foundINV
    try
    % find the first INVdata set
    for id = 1:size(INVdata,1)
        if isstruct(INVdata{id})
            break;
        end
    end
    
    Ninv = size(INVdata,1);
    % allocate memory
    xval = nan(Ninv,1);
    SNR = nan(Ninv,1);
    E0 = nan(Ninv,1);
    E0_er = nan(Ninv,1);
    E0_init = nan(Ninv,1);
    T = nan(Ninv,1);
    T_er = nan(Ninv,1);
    T_init = nan(Ninv,1);    
    switch data.invstd.invtype
        case 'free'
            Ex = nan(Ninv,data.invstd.freeDT);
            Ex_er = nan(Ninv,data.invstd.freeDT);
            Tx = nan(Ninv,data.invstd.freeDT);
            Tx_er = nan(Ninv,data.invstd.freeDT);
        case 'MUMO'
            Ex = nan(Ninv,data.invstd.freeDT);
            Ex_er = nan(Ninv,data.invstd.freeDT);
            Tx = nan(Ninv,data.invstd.freeDT);
            Tx_er = nan(Ninv,data.invstd.freeDT);
            Tspec = nan(Ninv,length(INVdata{id}.results.invstd.T1T2f));
        case {'LU','NNLS'}
            Ex = nan(1,1);
            Ex_er = nan(1,1);
            Tx = nan(1,1);
            Tx_er = nan(1,1);
            Tspec = nan(Ninv,length(INVdata{id}.results.invstd.T1T2f));
    end
    
    % collect data for amplitude, relaxation time, SNR etc.
    c = 0;
    for id = 1:size(INVdata,1)
        if isstruct(INVdata{id})
            % check for uncertainty data
            hasUncert = false;
            if isfield(INVdata{id}.results.invstd,'uncert')
                hasUncert = true;
                % uncertainty data
                uncert = INVdata{id}.results.invstd.uncert;
            end

            % check for time scale
            c = c + 1;
            if c == 1
                timescale = INVdata{id}.process.timescale;
            end

            % get time stamp
            xval(id,1) = data.import.NMR.data{id}.datenum;

            % 1.) get E0 and T data
            E0(id,1) = sum(INVdata{id}.results.invstd.E0) * INVdata{id}.results.nmrproc.normfac;
            % get E0 error bounds
            switch data.invstd.invtype
                case 'mono'
                    % E0 error
                    E0_er(id,1) = sum(INVdata{id}.results.invstd.ci(1:2:end)) *...
                        INVdata{id}.results.nmrproc.normfac;
                    
                    % T
                    switch INVdata{id}.results.nmrproc.T1T2
                        case 'T1'
                            T(id,1) = INVdata{id}.results.invstd.T1;
                        case 'T2'
                            T(id,1) = INVdata{id}.results.invstd.T2;
                    end
                    % T error
                    T_er(id,1) = INVdata{id}.results.invstd.ci(2);

                case 'free'
                    % total E0 error
                    E0_er(id,1) = sum(INVdata{id}.results.invstd.ci(1:2:end)) *...
                        INVdata{id}.results.nmrproc.normfac;
                    % individual Ex amplitudes
                    Ex(id,:) = INVdata{id}.results.invstd.E0;
                    Ex_er(id,:) = INVdata{id}.results.invstd.ci(1:2:end) *...
                        INVdata{id}.results.nmrproc.normfac;
                    % individual Tx relaxation times
                    switch INVdata{id}.results.nmrproc.T1T2
                        case 'T1'
                            Tx(id,:) = INVdata{id}.results.invstd.T1;
                        case 'T2'
                            Tx(id,:) = INVdata{id}.results.invstd.T2;
                    end
                    Tx_er(id,:) = INVdata{id}.results.invstd.ci(2:2:end);
                    
                case 'MUMO'
                    % total E0 error
                    E0_er(id,1) = sum(INVdata{id}.results.invstd.ci(3:3:end)) *...
                        INVdata{id}.results.nmrproc.normfac;
                    % individual Ex amplitudes
                    Ex(id,:) = INVdata{id}.results.invstd.E;
                    Ex_er(id,:) = INVdata{id}.results.invstd.ci(3:3:end) *...
                        INVdata{id}.results.nmrproc.normfac;
                    % TLGM
                    T(id,1) = INVdata{id}.results.invstd.Tlgm;
                    % individual Tx relaxation times
                    Tx(id,:) = INVdata{id}.results.invstd.T;
                    Tx_er(id,:) = INVdata{id}.results.invstd.ci(1:3:end);
                    % RTDs
                    Tspec(id,:) = INVdata{id}.results.invstd.T1T2f';
                    if c == 1
                        Tt = INVdata{id}.results.invstd.T1T2me;
                    end

                otherwise
                    T(id,1) = INVdata{id}.results.invstd.Tlgm;
                    Tspec(id,:) = INVdata{id}.results.invstd.T1T2f';
                    if c == 1
                        Tt = INVdata{id}.results.invstd.T1T2me;
                    end
            end            
            
            % if there is uncertainty data we use these instead
            if hasUncert
                E0_init(id,:) = E0(id,1);
                T_init(id,:) = T(id,1);
                E0(id,:) = uncert.statistics.E0(1);
                E0_er(id,:) = 2*uncert.statistics.E0(2);
                T(id,:) = uncert.statistics.Tlgm(1);
                T_er(id,:) = 2*uncert.statistics.Tlgm(2);                
            end

            % 2.) signal-to-noise-ratio SNR
            SNR(id,1) = sum(E0(id)) / INVdata{id}.results.nmrproc.noise;
        end
    end
    
    if isfield(data.import,'BAM')
        if data.import.BAM.use_z
            xval = data.import.BAM.zslice;
            xlabelstr = 'position';
            ylabelstr = 'position [µm]';
        else
            xlabelstr = 'date' ;
        end
    elseif isfield(data.import,'IBAC')
        if data.import.IBAC.use_z
            xval = data.import.IBAC.zslice;
            xlabelstr = 'position';
            ylabelstr = 'position [µm]';
        else
            xlabelstr = 'date' ;
        end
    elseif isfield(data.import,'LIAGCORE')
        xval = data.import.LIAGCORE.zslice;
        if data.import.LIAGCORE.use_z
            xlabelstr = 'position [mm]';
            ylabelstr = 'position [mm]';
        else
            xlabelstr = 'level';
            ylabelstr = 'level';
        end
    else
        xlabelstr = 'date' ;
    end
    
    % plot it
    switch method
        case 'amp'
            f = figure;
            ax1 = subplot(311,'Parent',f);
            ax2 = subplot(312,'Parent',f);
            ax3 = subplot(313,'Parent',f);
            
            % E0 amplitudes
            hold(ax1,'on');
            switch data.invstd.invtype
                case 'mono'
                    errorbar(xval,E0,E0_er,'o','Color',col.FIT,'Parent',ax1,...
                        'DisplayName','E0');
                case 'free'
                    errorbar(xval,E0,E0_er,'o','Color',col.FIT,'Parent',ax1,...
                        'LineWidth',1.5,'DisplayName','E0');
                    for i = 1:size(Ex,2)
                        errorbar(xval,Ex(:,i),E0_er(:,1),'o','Color',mycols(i,:),...
                            'DisplayName',['Ex',num2str(i)],'Parent',ax1);
                    end
                case 'MUMO'
                    if hasUncert
                        errorbar(xval,E0_init,[],'o','Color',col.FIT,...
                            'DisplayName','E0(init)','Parent',ax1);
                        errorbar(xval,E0,E0_er,'ko','DisplayName','E0(uncert)',...
                            'LineWidth',1.5,'Parent',ax1);
                    else
                        plot(xval,E0,'o','Color',col.FIT,'Parent',ax1,...
                            'DisplayName','E0');
                    end
                    for i = 1:size(Ex,2)
                        errorbar(xval,Ex(:,i),Ex_er(:,1),'o','Color',mycols(i,:),...
                            'DisplayName',['Ex',num2str(i)],'Parent',ax1);
                    end
                otherwise
                    if hasUncert
                        errorbar(xval,E0_init,[],'o','Color',col.FIT,'DisplayName','E0(init)',...
                            'Parent',ax1);
                        errorbar(xval,E0,E0_er,'ko','DisplayName','E0(uncert)',...
                            'LineWidth',1.5,'Parent',ax1);
                    else
                        plot(xval,E0,'o','Color',col.FIT,'DisplayName','E0',...
                            'Parent',ax1);
                    end
            end
            ylims = [min([0 min(E0)*0.9 min(Ex)*0.9]) max(E0)*1.1];
            grid(ax1,'on');
            set(get(ax1,'YLabel'),'String','E0');
            set(ax1,'YLim',ylims);
            legend(ax1,'Location','SouthWest');

            % T relaxation times
            hold(ax2,'on');
            switch data.invstd.invtype
                case 'mono'
                    errorbar(xval,T,T_er,'o','Color',col.FIT,'DisplayName','T0','Parent',ax2);
                    set(get(ax2,'YLabel'),'String',['T [',timescale,']']);
                case 'free'
                    for i = 1:size(Tx,2)
                        errorbar(xval,Tx(:,i),Tx_er(:,i),'o','Color',mycols(i,:),...
                            'DisplayName',['Tx',num2str(i)],'Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String',['T_x [',timescale,']']);
                    set(ax2,'YScale','log');
                case 'MUMO'
                    if hasUncert
                        errorbar(xval,T_init,[],'o','Color',col.FIT,...
                            'DisplayName','Tlgm(init)','Parent',ax2);
                        errorbar(xval,T,T_er,'ko','LineWidth',1.5,...
                        'DisplayName','Tlgm(uncert)','Parent',ax2);
                    else
                        plot(xval,T,'o','Color',col.FIT,...
                            'DisplayName','Tlgm','Parent',ax2);
                    end
                    for i = 1:size(Tx,2)
                        errorbar(xval,Tx(:,i),Tx_er(:,i),'o','Color',mycols(i,:),...
                            'DisplayName',['Tx',num2str(i)],'Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String',['T_x [',timescale,']']);
                    set(ax2,'YScale','log');
                otherwise
                    if hasUncert
                        errorbar(xval,T_init,[],'o','Color',col.FIT,...
                            'DisplayName','Tlgm(init)','Parent',ax2);
                        errorbar(xval,T,T_er,'ko','DisplayName','Tlgm(uncert)',...
                            'LineWidth',1.5,'Parent',ax2);
                    else
                        for i = 1:size(T,2)
                            plot(xval,T(:,i),'o','Color',col.FIT,...
                                'DisplayName','Tlgm','Parent',ax2);
                        end
                    end
                    set(get(ax2,'YLabel'),'String',['TLGM [',timescale,']']);
            end
            ylims = [min([0 min(T)*0.9 min(Tx)*0.9]) max([max(T) max(Tx)])*1.1];
            grid(ax2,'on');
            set(ax2,'YLim',ylims);
            legend(ax2,'Location','SouthWest');

            % signal-to-noise-ratio SNR
            hold(ax3,'on');
            plot(xval,SNR,'o','Color',col.FIT,'LineWidth',1.5,'Parent',ax3);
            grid on;
            xlabel(xlabelstr);
            set(get(ax3,'YLabel'),'String','signal-to-noise ratio');
            
            % link axes for combined zooming and panning
            linkaxes([ax1 ax2 ax3], 'x');
            
            % make nice date ticks
            if strcmp(xlabelstr,'date')
                isfile = which('dynamicDateTicks');
                if ~isempty(isfile)
                    dynamicDateTicks([ax1 ax2 ax3],'link','dd.mm. HH:MM');
                else
                    datetick(ax1,'x','dd.mm. HH:MM','keepticks');
                    datetick(ax2,'x','dd.mm. HH:MM','keepticks');
                    datetick(ax3,'x','dd.mm. HH:MM','keepticks');
                end
            end
            
        case 'ampvst'
            f = figure;
            ax1 = axes('Parent',f);
            
            plot(E0,T,'ko','Parent',ax1),
            set(get(ax1,'XLabel'),'String','E0');
            set(get(ax1,'YLabel'),'String',['T [',timescale,']']);
            
        case 'rtd'
            switch data.invstd.invtype
                case {'LU','NNLS','MUMO'}
                    if strcmp(xlabelstr,'date')
                        mycol = jet(size(Tspec,1));
                        [time,ix] = sort(xval);
                        Tspec = Tspec(ix,:);
                        f  = figure;
                        ax = axes('Parent',f);
                        hold(ax,'on')
                        for i = 1:size(Tspec,1)
                            plot3(time(i)*ones(size(Tt)),Tt,Tspec(i,:),...
                                'Color',mycol(i,:),'Parent',ax);
                        end
                        grid on; box on;
                        xlabel('date');
                        ylabel(['relaxation time [',timescale,']']);
                        zlabel('amplitude [-]');
                        
                        set(ax,'YScale','log');
                        isfile = which('dynamicDateTicks');
                        if ~isempty(isfile)
                            dynamicDateTicks(ax,'dd.mm. HH:MM');
                        else
                            datetick(ax,'x','dd.mm. HH:MM','keepticks');
                        end
                        view([90 0]);
                    else
                        dx = xval(2)-xval(1);
                        [xx,yy] = meshgrid(Tt',[xval-dx/2; xval(end)+dx/2]);
                        f  = figure;
                        ax = axes('Parent',f);
                        hold(ax,'on')
                        
                        % remove the backgound file
                        Tspec(isnan(Tspec)) = [];
                        xi = numel(Tspec)/numel(Tt);
                        Tspec = reshape(Tspec,[xi numel(Tt)]);
                        
                        surf(xx,yy,zeros(size(xx)),Tspec./max(Tspec(:)),'Parent',ax);
                        shading(ax,'flat');
                        xticks = log10(min(Tt)):1:log10(max(Tt));
                        set(ax,'XScale','log','XLim',[10^xticks(1) 10^xticks(end)],...
                            'XTick',10.^xticks,'Layer','top','Box','on');                        
                        set(ax,'YLim',[min(yy(:)) max(yy(:))],'YDir','normal')
                        cmap = jet; cmap = flipud(cmap);
                        colormap(ax,cmap);
                        xlabel(['relaxation time [',timescale,']']);
                        ylabel(ylabelstr);
                        cb = colorbar;
                        set(get(cb,'YLabel'),'String','norm. amplitude');
                        
                        % context menu to flip y-axis direction
                        axes_cm = uicontextmenu(f);
                        gui.cm_handles.axes_proc_xaxis = uimenu(axes_cm,...
                            'Label','flip y-axis','Tag','flip','Enable','on',...
                            'Callback',@onContextFlip);
                        gui.cm_handles.axes_proc_xaxis2 = uimenu(axes_cm,...
                            'Label','color scale log/lin','Tag','loglin','Enable','on',...
                            'Callback',@onContextFlip);
                        set(ax,'UIContextMenu',axes_cm);
                        
                    end
                otherwise
                    helpdlg({'function: showExtraGraphics',...
                        'Cannot plot RTDs because the inversion was not multi exponential'},...
                        'Invert NMR data first.');
            end
    end
    
    catch ME
        % show error message in case import fails
        errmsg = {ME.message;[ME.stack(1).name,' Line: ',num2str(ME.stack(1).line)];...
            'Cannot show figure.'};
        errordlg(errmsg,'showExtraGraphics: Error!');
    end
else
    helpdlg({'function: showExtraGraphics',...
        'Cannot continue because there need to be at least two NMR measurements.'},...
        'Not enough data to show');
end

end

function onContextFlip(src,~)
f = ancestor(src,'Figure','toplevel');
ax = findobj(f,'Type','Axes');
tag = get(src,'Tag');

switch tag
    case 'loglin'
        isscale = get(ax,'ColorScale');
        switch isscale
            case 'log'
                set(ax,'ColorScale','lin','CLim',[0 1]);
            case 'linear'
                set(ax,'ColorScale','log','CLim',[0.01 1]);
        end
    case 'flip'
        direction = get(ax,'Ydir');
        switch direction
            case 'normal'
                set(ax,'Ydir','reverse')
            case 'reverse'
                set(ax,'Ydir','normal')
        end
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