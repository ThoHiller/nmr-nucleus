function showFitStatistics
%showFitStatistics shows an extra fit statistics figure (for T2 data)
%
% Syntax:
%       showFitStatistics
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       showFitStatistics
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
maingui = getappdata(fig,'gui');

%% proceed if there is data
if isfield(data,'results')
    if isfield(data.results,'nmrraw') && isfield(data.results,'nmrproc')
        
        % check if the figure is already open
        figstat = findobj('Tag','FITSTATS');
        % if not, create it
        if isempty(figstat)
            % draw the figure on top og NUCLEUSinv
            figstat = figure('Name','NUCLEUSinv - Fit Statistics',...
                'NumberTitle','off','Tag','FITSTATS');
            pos0 = get(fig,'Position');
            pos1 = get(figstat,'Position');
            cent(1) = (pos0(1)+pos0(3)/2);
            cent(2) = (pos0(2)+pos0(4)/2);
            set(figstat,'Position',[cent(1)-pos0(3)/4 pos0(2) pos0(3)/2 pos0(4)-28]);
            
            % create the layout
            gui.main = uix.VBoxFlex('Parent',figstat,'Spacing',5);
            gui.row1 = uicontainer('Parent',gui.main); % axes
            gui.row2 = uicontainer('Parent',gui.main); % axes
            gui.row3 = uix.HBoxFlex('Parent',gui.main); % axes + text
            set(gui.main,'Heights',[-1 -1 -1.5]);
            
            gui.box1 = uicontainer('Parent',gui.row3); % axes
            gui.box2 = uix.VBox('Parent',gui.row3); % text
            set(gui.row3,'Widths',[-1 -1]);
            
            % all text boxes
            gui.row31 = uix.HBox('Parent',gui.box2);
            gui.row32 = uix.HBox('Parent',gui.box2);
            gui.row33 = uix.HBox('Parent',gui.box2);
            gui.row34 = uix.HBox('Parent',gui.box2);
            gui.row35 = uix.HBox('Parent',gui.box2);
            gui.row36 = uix.HBox('Parent',gui.box2);
            set(gui.box2,'Heights',[-1 -1 -1 -1 -1 -1]);
            
            gui.text11 = uicontrol('Parent',gui.row31,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text12 = uicontrol('Parent',gui.row31,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            gui.text21 = uicontrol('Parent',gui.row32,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text22 = uicontrol('Parent',gui.row32,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            gui.text31 = uicontrol('Parent',gui.row33,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text32 = uicontrol('Parent',gui.row33,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            gui.text41 = uicontrol('Parent',gui.row34,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text42 = uicontrol('Parent',gui.row34,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            gui.text51 = uicontrol('Parent',gui.row35,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text52 = uicontrol('Parent',gui.row35,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            gui.text61 = uicontrol('Parent',gui.row36,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','right','FontWeight','bold');
            gui.text62 = uicontrol('Parent',gui.row36,'Style','text','String','',...
                'FontSize',12,'HorizontalAlignment','left','FontWeight','bold');
            
            % all axes
            gui.axes_handles.imag = axes('Parent',gui.row1);
            gui.axes_handles.err = axes('Parent',gui.row2);
            gui.axes_handles.hist = axes('Parent',gui.box1);
            
            % save to GUI
            setappdata(figstat,'gui',gui);
        end
        % if the figure is already open load the GUI data
        gui = getappdata(figstat,'gui');
        
        % get axes handles
        ax1 = gui.axes_handles.imag;
        ax2 = gui.axes_handles.err;
        ax3 = gui.axes_handles.hist;
        % clear all axes
        clearAllAxes(figstat);
        
        %% gather the fit statistics for the current inversion
        text = cell(1,1);
        nmrraw = data.results.nmrraw;
        nmrproc = data.results.nmrproc;
        if isfield(data.results,'invstd')
            invstd = data.results.invstd;
        end
        loglinx = get(maingui.cm_handles.axes_raw_xaxis,'Label');
        
        % plot imaginary part
        if ~isreal(nmrraw.s)
            plot(nmrraw.t,imag(nmrraw.s),'LineWidth',1,'Parent',ax1);
            xlims = get(maingui.axes_handles.raw,'XLim');
            line(xlims,[0 0],'LineStyle','--','LineWidth',1,'Color','k','Parent',ax1);
            % get statistics
            imag_mean = mean(imag(nmrraw.s));
            imag_std = std(imag(nmrraw.s));
            set(ax1,'XTickLabel',get(maingui.axes_handles.raw,'XTickLabel'));
            switch loglinx
                case 'x-axis -> lin' % log axes
                    set(ax1,'XScale','log','XLim',xlims);
                case 'x-axis -> log' % lin axes
                    set(ax1,'XScale','lin','XLim',xlims);
            end
            set(get(ax1,'YLabel'),'String','imag. part [a.u.]');
            grid(ax1,'on');
            
            % draw first histogram
            min1 = mean(imag(nmrraw.s))-5*std(imag(nmrraw.s));
            max1 = mean(imag(nmrraw.s))+5*std(imag(nmrraw.s));
            bins1 = linspace(min1,max1,100);
            n1 = hist(imag(nmrraw.s),bins1);
            n1 = n1./trapz(bins1,n1);
            stairs(bins1,n1,'Parent',ax3);
            hold(ax3,'on');
            line([mean(imag(nmrraw.s)) mean(imag(nmrraw.s))],[0 max(n1)],...
                'LineWidth',1,'color','b','LineStyle','--',...
                'HandleVisibility','off','Parent',ax3);
            
            % update the text fields
            set(gui.text11,'String','mean(IMAG) = ');
            set(gui.text12,'String',sprintf('%5.4e',imag_mean));
            set(gui.text31,'String','std(IMAG) (noise) = ');
            set(gui.text32,'String',sprintf('%5.4e',imag_std));
        end
        
        if isfield(data.results,'invstd')
            % plot residuals
            if nmrproc.noise > 0
                plot(nmrproc.t,invstd.residual./nmrproc.e,'LineWidth',1,'Parent',ax2);
                % get statistics
                err_mean = mean(invstd.residual./nmrproc.e);
                err_std = std(invstd.residual./nmrproc.e);
            else
                plot(nmrproc.t,invstd.residual,'LineWidth',1,'Parent',ax2);
                % get statistics
                err_mean = mean(invstd.residual);
                err_std = std(invstd.residual);
            end
            xlims = get(maingui.axes_handles.proc,'XLim');
            line(xlims,[0 0],'LineStyle','--','LineWidth',1,'Color','k','Parent',ax2);
            
            line(xlims,[err_mean-err_std err_mean-err_std],...
                'LineStyle','-.','LineWidth',1,'Color','k','Parent',ax2);
            line(xlims,[err_mean+err_std err_mean+err_std],...
                'LineStyle','-.','LineWidth',1,'Color','k','Parent',ax2);
            set(ax2,'XTickLabel',get(maingui.axes_handles.proc,'XTickLabel'));
            set(ax2,'YLim',[err_mean-3*err_std err_mean+3*err_std]);
            switch loglinx
                case 'x-axis -> lin' % log axes
                    set(ax2,'XScale','log','XLim',xlims);
                case 'x-axis -> log' % lin axes
                    set(ax2,'XScale','lin','XLim',xlims);
            end
            set(get(ax2,'XLabel'),'String','time [s]')
            if nmrproc.noise > 0
                set(get(ax2,'YLabel'),'String',{'noise','weighted','residuals'});
            else
                set(get(ax2,'YLabel'),'String','residuals');
            end
            grid(ax2,'on');
            
            % update the text fields
            set(gui.text21,'String','mean(RES) = ');
            set(gui.text22,'String',sprintf('%5.4e',err_mean));
            if nmrproc.noise > 0
                set(gui.text41,'String','X2 = ');
            else
                set(gui.text41,'String','std(RES) = ');
            end
            set(gui.text42,'String',sprintf('%4.2f',err_std));
            
            set(gui.text51,'String','RMS = ');
            set(gui.text52,'String',sprintf('%5.4e',invstd.rms));
            
            if nmrproc.noise == 0
                if isfield(invstd,'chi2')
                    set(gui.text61,'String','X2 = ');
                    set(gui.text62,'String',sprintf('%5.4f',invstd.chi2));
                else
                    set(gui.text61,'String','X2 = ');
                    set(gui.text62,'String','N/A');
                end
            end
            
            % draw second histogram
            min2 = mean(invstd.residual)-5*std(invstd.residual);
            max2 = mean(invstd.residual)+5*std(invstd.residual);
            bins2 = linspace(min2,max2,100);
            n2 = hist(invstd.residual,bins2);
            n2 = n2./trapz(bins2,n2);
            stairs(bins2,n2,'Parent',ax3);
            line([mean(invstd.residual) mean(invstd.residual)],[0 max(n2)],...
                'LineWidth',1,'color','r','LineStyle','--',...
                'HandleVisibility','off','Parent',ax3);
            set(get(ax3,'XLabel'),'String','amplitude [a.u.]');
            set(get(ax3,'YLabel'),'String','count');
            legend(ax3,'IM','RES');
            grid(ax3,'on');
        end
    else
        helpdlg({'function: showFitStatistics',...
            'Cannot continue because no data is loaded!'},...
            'Load NMR data first.');
    end
else
    helpdlg({'function: showFitStatistics',...
        'Cannot continue because no data is loaded!'},...
        'Load NMR data first.');
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