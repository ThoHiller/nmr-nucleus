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
fig_tag = get(fig,'Tag');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');
gui = getappdata(fig,'gui');

%% proceed if there is data
[foundINV,~] = checkIfInversionExists(INVdata);

if foundINV
    
    % find the first INVdata set
    for id = 1:size(INVdata,1)
        if isstruct(INVdata{id})
            break;
        end
    end    
    
    Ninv = size(INVdata,1);
    % allocate memory
    xval = zeros(Ninv,1);
    E0 = zeros(Ninv,1);
    E0er = zeros(Ninv,1);
    SNR = zeros(Ninv,1);
    switch data.invstd.invtype
        case 'mono'
            T = zeros(Ninv,1);
            Ter = zeros(Ninv,1);
        case 'free'
            T = zeros(Ninv,data.invstd.freeDT);
        otherwise
            T = zeros(Ninv,1);
            Tspec = zeros(Ninv,length(INVdata{id}.results.invstd.T1T2f));
    end
    
    % collect data for amplitude, relaxation time, SNR etc.
    c = 0;
    for id = 1:size(INVdata,1)
        if isstruct(INVdata{id})
            c = c + 1;
            if c == 1
                timescale = INVdata{id}.process.timescale;
            end
            xval(id,1) = data.import.NMR.data{id}.datenum;
            E0(id,1) = sum(INVdata{id}.results.invstd.E0) * INVdata{id}.results.nmrproc.normfac;
            SNR(id,1) = sum(INVdata{id}.results.invstd.E0) / INVdata{id}.results.nmrproc.noise;
            switch data.invstd.invtype
                case {'mono','free'}
                    E0er(id,1) = sum(INVdata{id}.results.invstd.ci(1:2:end)) *...
                        INVdata{id}.results.nmrproc.normfac;
                    
                    switch INVdata{id}.results.nmrproc.T1T2
                        case 'T1'
                            ll = length(INVdata{id}.results.invstd.T1);
                            T(id,1:ll) = INVdata{id}.results.invstd.T1;
                        case 'T2'
                            ll = length(INVdata{id}.results.invstd.T2);
                            T(id,1:ll) = INVdata{id}.results.invstd.T2;
                    end
                    
                otherwise
                    T(id,1) = INVdata{id}.results.invstd.Tlgm;
                    Tspec(id,:) = INVdata{id}.results.invstd.T1T2f';
                    if c == 1
                        Tt = INVdata{id}.results.invstd.T1T2me;
                    end
            end
            
            switch data.invstd.invtype
                case {'mono'}
                    Ter(id,1) = INVdata{id}.results.invstd.ci(2);
                otherwise
                    % nothing to do
            end
        else
            E0(id,:) = NaN;
            switch data.invstd.invtype
                case {'mono','free'}
                     E0er(id,:) = NaN;
                otherwise
                    T(id,:) = NaN;
                    Tspec(id,:) = NaN;
            end
            switch data.invstd.invtype
                case {'mono'}
                    Ter(id,:) = NaN;
            end
            SNR(id,1) = NaN;            
        end
    end
    
    if isfield(data.import,'BAM')
        if data.import.BAM.use_z
            xval = data.import.BAM.zslice;
            xlabelstr = 'position [m]';
        else
            xlabelstr = 'date' ;
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
            
            hold(ax1,'on');
            switch data.invstd.invtype
                case {'mono','free'}
                    errorbar(xval,E0,E0er,'o','Parent',ax1);
                otherwise
                    plot(xval,E0,'o','Parent',ax1);
            end
            grid(ax1,'on');
            set(get(ax1,'YLabel'),'String','E0');
            
            hold(ax2,'on');
            switch data.invstd.invtype
                case 'mono'
                    errorbar(xval,T,Ter,'ko','Parent',ax2);
                    set(get(ax2,'YLabel'),'String',['T [',timescale,']']);
                case 'free'
                    for i = 1:size(T,2)
                        semilogy(xval,T(:,i),'ko','Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String',['T_x [',timescale,']']);
                    set(ax2,'YScale','log');
                otherwise
                    for i = 1:size(T,2)
                        semilogy(xval,T(:,i),'ko','Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String',['TLGM [',timescale,']']);
            end
            grid(ax2,'on');
            
            hold(ax3,'on');
            plot(xval,SNR,'o','Parent',ax3);
            grid on;
            xlabel(xlabelstr);
            set(get(ax3,'YLabel'),'String','signal-to-noise ratio');
            
            linkaxes([ax1 ax2 ax3], 'x');
            
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
                case {'ILA','NNLS'}
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
                        [xx,yy] = meshgrid(Tt',[xval; xval(end)+dx]);
                        f  = figure;
                        ax = axes('Parent',f);
                        hold(ax,'on')
                        surf(xx,yy,zeros(size(xx)),Tspec./max(Tspec(:)),'Parent',ax);
                        shading(ax,'flat');
                        xticks = log10(min(Tt)):1:log10(max(Tt));
                        set(ax,'XScale','log','XLim',[10^xticks(1) 10^xticks(end)],...
                            'XTick',10.^xticks,'Layer','top','Box','on');                        
                        set(ax,'YLim',[min(yy(:)) max(yy(:))],'YDir','normal')
                        cmap = jet; cmap = flipud(cmap);
                        colormap(ax,cmap);
                        xlabel(['relaxation time [',timescale,']']);
                        ylabel('position [m]');
                        cb = colorbar;
                        set(get(cb,'YLabel'),'String','norm. amplitude');
                        
                        % context menu to flip y-axis direction
                        axes_cm = uicontextmenu(f);
                        gui.cm_handles.axes_proc_xaxis = uimenu(axes_cm,...
                            'Label','flip y-axis','Tag','flip','Enable','on',...
                            'Callback',@onContextFlip);
                        set(ax,'UIContextMenu',axes_cm);
                        
                    end
                otherwise
                    helpdlg({'function: showExtraGraphics',...
                        'Cannot plot RTDs because the inversion was not multi exponential'},...
                        'Invert NMR data first.');
            end
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

direction = get(ax,'Ydir');
switch direction
    case 'normal'
        set(ax,'Ydir','reverse')
    case 'reverse'
        set(ax,'Ydir','normal')
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