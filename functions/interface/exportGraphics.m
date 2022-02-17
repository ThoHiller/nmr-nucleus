function varargout = exportGraphics(fig_tag,format)
%exportGraphics exports graphics from both GUIs into various formats
%
% Syntax:
%       exportGraphics
%
% Inputs:
%       fig_tag - 'MOD' or 'INV'
%       format - 'fig', 'png', 'eps' or 'tiff'
%
% Outputs:
%       varargout
%
% Example:
%       exportGraphics('MOD','eps')
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
% See also: NUCLEUSinv, NUCLEUSmod
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag',fig_tag);
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

% get GUI position
posf = get(fig,'Position');
% opening the figure
expfig = figure('Color',gui.myui.colors.panelBG);

% check which layout
switch get(gui.menu.file_export_graphics_layout_vert,'Checked')
    case 'on'
        horzvert = 'vert';
    case 'off'
        horzvert = 'horz';
end

%% switch depending on which GUI called the routine
switch fig_tag
    case 'INV'
        % check if joint inversion is activated
        isjoint = strcmp(get(gui.menu.extra_joint,'Checked'),'on');
        
        % create dummy subplots on the export figure to extract the
        % standard positions
        if isjoint
            switch horzvert
                case 'horz'
                    ax1 = subplot(1,3,1,'Parent',expfig);
                    ax2 = subplot(1,3,2,'Parent',expfig);
                    ax3 = subplot(1,3,3,'Parent',expfig);
                case 'vert'
                    ax1 = subplot(3,1,1,'Parent',expfig);
                    ax2 = subplot(3,1,2,'Parent',expfig);
                    ax3 = subplot(3,1,3,'Parent',expfig);
            end
            pos1 = get(ax1,'Position');
            pos2 = get(ax2,'Position');
            pos3 = get(ax3,'Position');
            delete(ax1);delete(ax2);delete(ax3);
        else
            switch horzvert
                case 'horz'
                    ax1 = subplot(1,2,1,'Parent',expfig);
                    ax2 = subplot(1,2,2,'Parent',expfig);
                case 'vert'
                    ax1 = subplot(2,1,1,'Parent',expfig);
                    ax2 = subplot(2,1,2,'Parent',expfig);
            end
            pos1 = get(ax1,'Position');
            pos2 = get(ax2,'Position');
            delete(ax1);delete(ax2);
        end
        
        % check which axes are visible and copy the corresponding axes to
        % the export figure and update with the standard positions
        whichsignal = get(gui.plots.SignalPanel,'Selection');
        whichdist = get(gui.plots.DistPanel,'Selection');
        
        if isjoint
            % if joint inversion is activated then the axes are laid out
            % in the same way as for NUCLEUSmod for consistency reasons
            switch horzvert
                case 'horz'
                    if whichdist == 1
                        ax1 = copyobj(gui.axes_handles.rtd,expfig);
                    elseif whichdist == 2
                        ax1 = copyobj(gui.axes_handles.psd,expfig);
                    elseif whichdist == 3
                        ax1 = copyobj(gui.axes_handles.psdj,expfig);
                    end
                    ax2 = copyobj(gui.axes_handles.cps,expfig);
                    if whichsignal == 1
                        ax3 = copyobj(gui.axes_handles.proc,expfig);
                    elseif whichsignal == 2
                        ax3 = copyobj(gui.axes_handles.raw,expfig);
                    elseif whichsignal == 3
                        ax3 = copyobj(gui.axes_handles.all,expfig);
                    end
                case 'vert'
                    if whichdist == 1
                        ax2 = copyobj(gui.axes_handles.rtd,expfig);
                    elseif whichdist == 2
                        ax2 = copyobj(gui.axes_handles.psd,expfig);
                    elseif whichdist == 3
                        ax2 = copyobj(gui.axes_handles.psdj,expfig);
                    end
                    ax3 = copyobj(gui.axes_handles.cps,expfig);
                    if whichsignal == 1
                        ax1 = copyobj(gui.axes_handles.proc,expfig);
                    elseif whichsignal == 2
                        ax1 = copyobj(gui.axes_handles.raw,expfig);
                    elseif whichsignal == 3
                        ax1 = copyobj(gui.axes_handles.all,expfig);
                    end
            end            
            set(ax1,'Position',pos1);
            set(ax2,'Position',pos2);
            set(ax3,'Position',pos3);
        else
            if whichsignal == 1
                ax1 = copyobj(gui.axes_handles.proc,expfig);
            elseif whichsignal == 2
                ax1 = copyobj(gui.axes_handles.raw,expfig);
            end
            if whichdist == 1
                ax2 = copyobj(gui.axes_handles.rtd,expfig);
            elseif whichdist == 2
                ax2 = copyobj(gui.axes_handles.psd,expfig);
            end
            set(ax1,'Position',pos1);
            set(ax2,'Position',pos2);
        end
        
        % add the legend(s) and remove the info lines (CBW etc) from the
        % distribution plots
        if isjoint
            lgh1 = legend(ax1,'show');
            lgh2 = legend(ax3,'show');
            set(lgh1,'TextColor',gui.myui.colors.panelFG);
            set(lgh2,'TextColor',gui.myui.colors.panelFG);
            h1 = findobj([ax1 ax2 ax3],'Tag','infolines');
            h2 = findobj([ax1 ax2 ax3],'Tag','TLGM');
        else
            lgh = legend(ax1,'show');
            set(lgh,'TextColor',gui.myui.colors.panelFG);
            h1 = findobj([ax1 ax2],'Tag','infolines');
            h2 = findobj([ax1 ax2],'Tag','TLGM');
        end
        if ~isempty(h1)
            delete(h1);
        end
        if ~isempty(h2)
            delete(h2);
        end
            
        % adjust the export figure height and axes size
        switch horzvert
            case 'horz'
                axis(ax1,'square');
                axis(ax2,'square');
                if isjoint
                    axis(ax3,'square');
                end
                set(expfig,'Position',[posf(1) posf(2)*1.25 posf(3) posf(4)*0.75]);
            case 'vert'
                set(expfig,'Position',[posf(1)+300 posf(2) (posf(3)-300)*0.8 posf(4)*0.8]);
        end
        
        % adjust the figure layout on A4
        figno = get(expfig,'Number');
        if isjoint
            figname = ['Figure ',num2str(figno),...
                ': joint inv ',data.invjoint.invtype,' ',...
                data.invjoint.geometry_type];
        else
            figname = ['Figure ',num2str(figno),...
                ': std inv ',data.invstd.invtype];
        end
        set(expfig,'Name',figname,'NumberTitle','off');
        switch horzvert
            case 'horz'
                set(expfig,'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','landscape');
                set(expfig,'PaperPositionMode','manual',...
                    'PaperPosition',[0.6 3.8 28.4 13.3]);
            case 'vert'
                set(expfig,'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','portrait');
                if isjoint
                    set(expfig,'PaperPositionMode','manual',...
                        'PaperPosition',[0.6 3.8 18 19.5]);
                else
                    set(expfig,'PaperPositionMode','manual',...
                        'PaperPosition',[1.5 5 18 19.5]);
                end
        end
        set(expfig,'Renderer','painter');
        % not nice but necessary (otherwise the uiputfile-dialog is hidden)
        drawnow;
        
    case 'MOD'
        % create dummy subplots on the export figure to extract the
        % standard positions
        switch horzvert
            case 'horz'
                ax1 = subplot(1,3,1,'Parent',expfig);
                ax2 = subplot(1,3,2,'Parent',expfig);
                ax3 = subplot(1,3,3,'Parent',expfig);
            case 'vert'
                ax1 = subplot(3,1,1,'Parent',expfig);
                ax2 = subplot(3,1,2,'Parent',expfig);
                ax3 = subplot(3,1,3,'Parent',expfig);
        end
        pos1 = get(ax1,'Position');
        pos2 = get(ax2,'Position');
        pos3 = get(ax3,'Position');
        delete(ax1);delete(ax2);delete(ax3);
        
        % copy the GUI axes to the export figure
        ax1 = copyobj(gui.axes_handles.geo,expfig);
        ax2 = copyobj(gui.axes_handles.cps,expfig);
        ax3 = copyobj(gui.axes_handles.nmr,expfig);
        % and update with the standard positions
        set(ax1,'Position',pos1);
        set(ax2,'Position',pos2);
        set(ax3,'Position',pos3);
        lh2 = legend(ax2,'show','Location','NorthEast');
        set(lh2,'FontSize',10,'TextColor',gui.myui.colors.panelFG);
        
        % adjust the export figure height and axes size
        switch horzvert
            case 'horz'
                axis(ax1,'square');
                axis(ax2,'square');
                axis(ax3,'square');
                ax11 = copyobj(gui.axes_handles.type,expfig);
                set(ax11,'Position',[0.27 0.625 0.08 0.08]);
                set(expfig,'Position',[posf(1) posf(2)*1.25 posf(3) posf(4)*0.75]);
            case 'vert'
                ax11 = copyobj(gui.axes_handles.type,expfig);
                set(ax11,'Position',[0.8 0.825 0.08 0.08]);
                set(expfig,'Position',[posf(1)+300 posf(2) (posf(3)-300)*0.8 posf(4)*0.8]);
        end
        
        % adjust the figure layout on A4
        figno = get(expfig,'Number');
        type = get(gui.popup_handles.geometry_type,'String');
        type = type{get(gui.popup_handles.geometry_type,'Value')};
        figname = ['Figure ',num2str(figno),': ',type];
        set(expfig,'Name',figname,'NumberTitle','off');
        switch horzvert
            case 'horz'
                set(expfig,'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','landscape');
            case 'vert'
                set(expfig,'PaperType','A4','PaperUnits','centimeters',...
                    'PaperOrientation','portrait');
                set(expfig,'PaperPositionMode','manual',...
                    'PaperPosition',[1.5 5 18 19.5]);
        end
        set(expfig,'Renderer','painter');
        % not nice but necessary (otherwise the uiputfile-dialog is hidden)
        drawnow;
end

%% export to file
switch format
    case {'png','tiff','eps'}
        
        switch format
            case 'png'
                statstr = 'PNG';
                putext = '*.png';
                put1 = 'Portable Network Graphics file';
                driver = '-dpng';
            case 'tiff'
                statstr = 'TIFF';
                putext = '*.tiff';
                put1 = 'TIFF file';
                driver = '-dtiff';
            case 'eps'
                statstr = 'EPS';
                putext = '*.eps';
                put1 = 'EPS file';
                driver = '-depsc';
        end
        
        displayStatusText(gui,['Saving ',statstr,'-file ...']);
        
        switch fig_tag
            case 'INV'
                % which NMR signal
                id = get(gui.listbox_handles.signal,'Value');
                % get the new file name
                sfilename = data.import.NMR.filesShort{id};
                ind1 = strfind(sfilename,'.');
                if isempty(ind1)
                    sfilename = [sfilename,'_INV'];
                else
                    sfilename = [sfilename(1:ind1-1),'_INV'];
                end
                [FileName,PathName,~] = uiputfile({putext,put1},...
                    ['NUCLEUSinv: Save ',statstr,' Graphics'],...
                    fullfile(data.import.path,sfilename));
            case 'MOD'
                [FileName,PathName,~] = uiputfile({putext,put1},...
                    ['NUCLEUSmod: Save ',statstr,' Graphics'],...
                    fullfile(pwd,'NUCLEUSmod_forward'));
        end
        if ~isequal(FileName,0) || ~isequal(PathName,0)
            print(expfig,fullfile(PathName,FileName),'-r300',driver);
            close(expfig);
            displayStatusText(gui,['Saving ',statstr,'-file ... done.']);
        else
            displayStatusText(gui,['Saving ',statstr,'-file ... canceled.']);
            figure(expfig);
        end
    otherwise
        % nothing to do ... fig-files are not saved automatically
end

if nargout > 0
    varargout{1} = expfig;
    if isjoint
        varargout{2} = [ax1 ax2 ax3];
    else
        varargout{2} = [ax1 ax2];
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