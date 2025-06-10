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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag','INV');
data = getappdata(fig,'data');
maingui = getappdata(fig,'gui');
colors = maingui.myui.colors;

%% proceed if there is data
if isfield(data,'results')
    if isfield(data.results,'nmrraw') && isfield(data.results,'nmrproc')
        
        % check if the figure is already open
        fig_stat = findobj('Tag','FITSTATS');
        % if not, create it
        if isempty(fig_stat)
            % draw the figure on top of NUCLEUSinv
            fig_stat = figure('Name','NUCLEUSinv - Fit Statistics',...
                'NumberTitle','off','ToolBar','none','Tag','FITSTATS');
            pos0 = get(fig,'Position');
            cent(1) = (pos0(1)+pos0(3)/2);
            cent(2) = (pos0(2)+pos0(4)/2);
            set(fig_stat,'Position',[cent(1)-pos0(3)/3 pos0(2) pos0(3)/1.5 pos0(4)]);
            
            % create the layout
            gui.main = uix.VBox('Parent',fig_stat,'BackGroundColor',colors.panelBG,'Spacing',10,'Padding',10);
            gui.row1 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % axes Im
            gui.row2 = uicontainer('Parent',gui.main,'BackGroundColor',colors.panelBG); % axes res
            gui.row3 = uix.HBox('Parent',gui.main,'BackGroundColor',colors.panelBG); % histogram + text
            set(gui.main,'Heights',[-1 -1 -1.5]);
            
            % Im and res axes
            gui.axes_handles.imag = axes('Parent',gui.row1,...
                'Color',colors.axisBG,'XColor',colors.axisFG,...
                'YColor',colors.axisFG);
            gui.axes_handles.err = axes('Parent',gui.row2,...
                'Color',colors.axisBG,'XColor',colors.axisFG,...
                'YColor',colors.axisFG);
            
            uix.Empty('Parent',gui.row3);
            gui.box1 = uicontainer('Parent',gui.row3,...
                'BackGroundColor',colors.panelBG); % histogram axes
            gui.box2 = uix.VBox('Parent',gui.row3,...
                'BackGroundColor',colors.panelBG,'Padding',10,'Spacing',5); % text
            uix.Empty('Parent',gui.row3);
            set(gui.row3,'Widths',[40 -1 300 60]);
            
            % histogram axes
            gui.axes_handles.hist = axes('Parent',gui.box1,...
                'Color',colors.axisBG,'XColor',colors.axisFG,...
                'YColor',colors.axisFG);
            
            % all text boxes
            uix.Empty('Parent',gui.box2);
            gui.row31 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            gui.row32 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            gui.row33 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            gui.row34 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            gui.row35 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            gui.row36 = uix.HBox('Parent',gui.box2,'BackGroundColor',colors.panelBG,'Spacing',10);
            uix.Empty('Parent',gui.box2);
            set(gui.box2,'Heights',[-1 -1 -1 -1 -1 -1 -1 -1]);
            
            gui.text11 = uicontrol('Parent',gui.row31,'Style','text',...
                'String','mean(Imag)',...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text12 = uicontrol('Parent',gui.row31,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            gui.text21 = uicontrol('Parent',gui.row32,'Style','text',...
                'String','mean(residual)',...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text22 = uicontrol('Parent',gui.row32,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            gui.text31 = uicontrol('Parent',gui.row33,'Style','text',...
                'String','std(Imag)',...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text32 = uicontrol('Parent',gui.row33,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            gui.text41 = uicontrol('Parent',gui.row34,'Style','text',...
                'String','std(residual)',...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text42 = uicontrol('Parent',gui.row34,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            gui.text51 = uicontrol('Parent',gui.row35,'Style','text',...
                'String',[char(hex2dec('03A7')),char(hex2dec('0B2'))],...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text52 = uicontrol('Parent',gui.row35,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            gui.text61 = uicontrol('Parent',gui.row36,'Style','text','String','RMS',...
                'FontSize',maingui.myui.fontsize+4,'HorizontalAlignment','right',...
                'BackGroundColor',colors.panelBG,'ForeGroundColor',colors.panelFG);
            gui.text62 = uicontrol('Parent',gui.row36,'Style','edit','String','',...
                'FontSize',maingui.myui.fontsize,'BackGroundColor',colors.editBG,...
                'ForeGroundColor',colors.panelFG);
            
            % Java Hack to adjust vertical alignment of text fields
            jh = findjobj(gui.text11); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            jh = findjobj(gui.text21); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            jh = findjobj(gui.text31); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            jh = findjobj(gui.text41); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            jh = findjobj(gui.text51); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            jh = findjobj(gui.text61); jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
            
            % save to GUI
            setappdata(fig_stat,'gui',gui);
        end
        % if the figure is already open load the GUI data
        gui = getappdata(fig_stat,'gui');
        
        % get axes handles
        ax1 = gui.axes_handles.imag;
        ax2 = gui.axes_handles.err;
        ax3 = gui.axes_handles.hist;
        % clear all axes
        clearAllAxes(fig_stat);
        hold(ax1,'on');
        hold(ax2,'on');
        hold(ax3,'on');
        
        %% gather the fit statistics for the current inversion
        nmrraw = data.results.nmrraw;
        nmrproc = data.results.nmrproc;
        if isfield(data.results,'invstd')
            invstd = data.results.invstd;
        end
        loglinx = get(maingui.cm_handles.axes_proc_xaxis,'Label');
        lgdstr = cell(1,1);
        lgdc = 0;
        % plot imaginary part
        if ~isreal(nmrraw.s)
            plot(nmrraw.t,imag(nmrraw.s),'Color',colors.IM,'Parent',ax1);
            xlims = get(maingui.axes_handles.raw,'XLim');
            line(xlims,[0 0],'LineStyle','--','Color',colors.axisL,'Parent',ax1);
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
            set(get(ax1,'YLabel'),'String','Imag');
            grid(ax1,'on');
            
            % draw first histogram
            min1 = mean(imag(nmrraw.s))-5*std(imag(nmrraw.s));
            max1 = mean(imag(nmrraw.s))+5*std(imag(nmrraw.s));
            bins1 = linspace(min1,max1,100);
            % the "0" is a nasty hack because Matlab does not like the old
            % "hist" function anymore
            n1 = [0 histcounts(imag(nmrraw.s),bins1)];
            n1 = n1./trapz(bins1,n1);
            stairs(bins1,n1,'Color',maingui.myui.colors.IM,'LineWidth',1.5,'Parent',ax3);
            hold(ax3,'on');
            line(xlims,[imag_mean imag_mean],'LineStyle','--','Color','g','Parent',ax1);
            line([imag_mean imag_mean],[0 max(n1)],...
                'color','g','LineStyle','--','Parent',ax3);
            
            lgdc = lgdc + 1;
            lgdstr{lgdc} = 'Imag';
            lgdc = lgdc + 1;
            lgdstr{lgdc} = 'mean(Imag)';
            
            % update the text fields
            set(gui.text12,'String',sprintf('%5.4e',imag_mean));
            set(gui.text32,'String',sprintf('%5.4e',imag_std));
        end
        
        if isfield(data.results,'invstd')
            % plot residuals
            if nmrproc.noise > 0
                plot(nmrproc.t,invstd.residual./nmrproc.e,'Color',colors.RE,'Parent',ax2);
                % get statistics
                residual = invstd.residual./nmrproc.e;
                err_mean = mean(residual);
                err_std = std(residual);
                ylabel2 = {'noise','weighted','residual'};
            else
                plot(nmrproc.t,invstd.residual,'Color',colors.RE,'Parent',ax2);
                % get statistics
                residual = invstd.residual;
                err_mean = mean(residual);
                err_std = std(residual);
                ylabel2 = 'residual';
            end
            xlims = get(maingui.axes_handles.proc,'XLim');
            line(xlims,[0 0],'LineStyle','--','Color',colors.axisL,'Parent',ax2);
            line(xlims,[err_mean err_mean],'LineStyle','--','Color','b','Parent',ax2);
            
            if nmrproc.noise > 0
                line(xlims,[-1 -1],'LineStyle','-.','LineWidth',1,'Color',colors.axisL,'Parent',ax2);
                line(xlims,[1 1],'LineStyle','-.','LineWidth',1,'Color',colors.axisL,'Parent',ax2);
                line(xlims,[err_mean-err_std err_mean-err_std],...
                    'LineStyle','--','LineWidth',1,'Color','r','Parent',ax2);
                line(xlims,[err_mean+err_std err_mean+err_std],...
                    'LineStyle','--','LineWidth',1,'Color','r','Parent',ax2);
            else
                line(xlims,[err_mean-err_std err_mean-err_std],...
                    'LineStyle','-.','LineWidth',1,'Color','k','Parent',ax2);
                line(xlims,[err_mean+err_std err_mean+err_std],...
                    'LineStyle','-.','LineWidth',1,'Color','k','Parent',ax2);
            end
            
            set(ax2,'XTickLabel',get(maingui.axes_handles.proc,'XTickLabel'));
            set(ax2,'YLim',[err_mean-3*err_std err_mean+3*err_std]);
            switch loglinx
                case 'x-axis -> lin' % log axes
                    set(ax2,'XScale','log','XLim',xlims);
                case 'x-axis -> log' % lin axes
                    set(ax2,'XScale','lin','XLim',xlims);
            end
            set(get(ax2,'XLabel'),'String','time [s]')
            set(get(ax2,'YLabel'),'String',ylabel2);
            grid(ax2,'on');
            
            % update the text fields
            set(gui.text22,'String',sprintf('%5.4e',err_mean));
            % set(gui.text42,'String',sprintf('%5.4e',err_std));
            set(gui.text42,'String',sprintf('%5.4e',std(invstd.residual)));
            if nmrproc.noise > 0
                if isfield(invstd,'chi2')
                    set(gui.text52,'String',sprintf('%5.3f',invstd.chi2));
                else
                    set(gui.text52,'String',sprintf('%5.3f',err_std));
                end
            else
                set(gui.text52,'String','');
            end
            set(gui.text62,'String',sprintf('%5.4e',invstd.rms));
            
            % draw second histogram
            min2 = mean(invstd.residual)-5*std(invstd.residual);
            max2 = mean(invstd.residual)+5*std(invstd.residual);
            bins2 = linspace(min2,max2,100);
            % the "0" is a nasty hack because Matlab does not like the old
            % "hist" function anymore
            n2 = [0 histcounts(invstd.residual,bins2)];
            n2 = n2./trapz(bins2,n2);
            stairs(bins2,n2,'LineWidth',1.5,'Color',colors.RE,'Parent',ax3);
            line([mean(invstd.residual) mean(invstd.residual)],[0 max(n2)],...
                'color','b','LineStyle','--','Parent',ax3);
            set(get(ax3,'XLabel'),'String','Imag | residual');
            set(get(ax3,'YLabel'),'String','count');
            grid(ax3,'on');
            
            lgdc = lgdc + 1;
            lgdstr{lgdc} = 'residual';
            lgdc = lgdc + 1;
            lgdstr{lgdc} = 'mean(residual)';
        end
        lgh = legend(ax3,lgdstr);
        set(lgh,'FontSize',10,'TextColor',colors.panelFG);
        
        set(ax1,'FontSize',maingui.myui.fontsize);
        set(ax2,'FontSize',maingui.myui.fontsize);
        set(ax3,'FontSize',maingui.myui.fontsize);
        
        set(get(ax1,'YLabel'),'FontSize',16);
        set(get(ax2,'YLabel'),'FontSize',16);
        
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

% License:
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