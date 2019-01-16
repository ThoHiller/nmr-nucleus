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
[foundINV,Ninv] = checkIfInversionExists(INVdata);

if foundINV && Ninv > 10
    
    % allocate memory
    date = zeros(Ninv,1);
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
            Tspec = zeros(Ninv,length(data.results.invstd.T1T2f));
    end
    
    % collect data for amplitude, relaxation time, SNR etc.
    c = 0;
    for id = 1:size(INVdata,1)
        if isstruct(INVdata{id})
            c = c + 1;
            date(c,1) = data.import.NMR.data{id}.datenum;
            E0(c,1) = sum(INVdata{id}.results.invstd.E0) * INVdata{id}.results.nmrproc.normfac;
            SNR(c,1) = sum(INVdata{id}.results.invstd.E0) / INVdata{id}.results.nmrproc.noise;
            switch data.invstd.invtype
                case {'mono','free'}
                    E0er(c,1) = sum(INVdata{id}.results.invstd.ci(1:2:end)) *...
                        INVdata{id}.results.nmrproc.normfac;
                    
                    switch INVdata{id}.results.nmrproc.T1T2
                        case 'T1'
                            ll = length(INVdata{id}.results.invstd.T1);
                            T(c,1:ll) = INVdata{id}.results.invstd.T1;
                        case 'T2'
                            ll = length(INVdata{id}.results.invstd.T2);
                            T(c,1:ll) = INVdata{id}.results.invstd.T2;
                    end
                    
                otherwise
                    T(c,1) = INVdata{id}.results.invstd.Tlgm;
                    Tspec(c,:) = INVdata{id}.results.invstd.T1T2f';
                    if c == 1
                        Tt = INVdata{id}.results.invstd.T1T2me;
                    end
            end
            
            switch data.invstd.invtype
                case {'mono'}
                    Ter(c,1) = INVdata{id}.results.invstd.ci(2);
                otherwise
                    % nothing to do
            end
        end
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
                    errorbar(date,E0,E0er,'o','Parent',ax1);
                otherwise
                    plot(date,E0,'o','Parent',ax1);
            end
            grid(ax1,'on');
            set(get(ax1,'YLabel'),'String','E0');
            
            hold(ax2,'on');
            switch data.invstd.invtype
                case 'mono'
                    errorbar(date,T,Ter,'ko','Parent',ax2);
                    set(get(ax2,'YLabel'),'String','T');
                case 'free'
                    for i = 1:size(T,2)
                        semilogy(date,T(:,i),'ko','Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String','T_x');
                    set(ax2,'YScale','log');
                otherwise
                    for i = 1:size(T,2)
                        semilogy(date,T(:,i),'ko','Parent',ax2);
                    end
                    set(get(ax2,'YLabel'),'String','TLGM');
            end
            grid(ax2,'on');
            
            hold(ax3,'on');
            plot(date,SNR,'o','Parent',ax3);
            grid on;
            xlabel('date');
            set(get(ax3,'YLabel'),'String','signal-to-noise ratio');
            
            linkaxes([ax1 ax2 ax3], 'x');
            isfile = which('dynamicDateTicks');
            if ~isempty(isfile)
                dynamicDateTicks([ax1 ax2 ax3],'link','dd.mm. HH:MM');
            else
                datetick(ax1,'x','dd.mm. HH:MM','keepticks');
                datetick(ax2,'x','dd.mm. HH:MM','keepticks');
                datetick(ax3,'x','dd.mm. HH:MM','keepticks');
            end
            
        case 'rtd'
            switch data.invstd.invtype
                case {'ILA','NNLS'}
                    mycol = jet(size(Tspec,1));
                    [time,ix] = sort(date);
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
                    ylabel('relaxation time [s]');
                    zlabel('amplitude [-]');
                    
                    set(ax,'YScale','log');
                    isfile = which('dynamicDateTicks');
                    if ~isempty(isfile)
                        dynamicDateTicks(ax,'dd.mm. HH:MM');
                    else
                        datetick(ax,'x','dd.mm. HH:MM','keepticks');
                    end
                    view([90 0]);
                otherwise
                    helpdlg({'function: showExtraGraphics',...
                        'Cannot plot RTDs because the inversion was not multi exponential'},...
                        'Invert NMR data first.');
            end
    end
else
    helpdlg({'function: showExtraGraphics',...
        'Cannot continue because there is no sufficient data.',...
        'This option does only make sense for long term measurements.'},...
        'No data to show');
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