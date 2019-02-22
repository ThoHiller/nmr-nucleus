function updateInfo(src,~) %#ok<INUSD>
%updateInfo updates the information shown in all information list boxes
%
% Syntax:
%       updateInfo(src)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       updateInfo(src,~)
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
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% because at startup the Callbacks are triggered even though not all
% elements are yet drawn, they are not shown as default
showit = false;

%% find out what panel is shown in order to update the corresponding box
if isfield(gui,'plots') && isfield(gui,'listbox_handles')
    whichsignal = get(gui.plots.SignalPanel,'Selection');
    whichdist = get(gui.plots.DistPanel,'Selection');
    
    % font size of subscripts
    subfs = floor(get(gui.listbox_handles.info_dist,'FontSize') / 3);
    
    % show info switch
    showit = true;
end

% if we can show it ...
if showit
    %% signal panel info
    info{1,1} = ' ';
    switch whichsignal
        case 1 % PROC
            if isfield(data,'results')
                nmrproc = data.results.nmrproc;
                switch nmrproc.T1T2
                    case 'T1'
                        info{end+1,1} = ['<HTML><BODY>Sampl. = ',sprintf('%d',length(nmrproc.t)),...
                            ' (',data.process.gatetype,')','</BODY></HTML>'];
                    case 'T2'
                        switch data.process.gatetype
                            case 'raw'
                                info{end+1,1} = ['<HTML><BODY>Echos &nbsp= ',...
                                    sprintf('%d',length(nmrproc.t)),...
                                    ' (',data.process.gatetype,')','</BODY></HTML>'];
                            otherwise
                                info{end+1,1} = ['<HTML><BODY>Gates &nbsp= ',...
                                    sprintf('%d',length(nmrproc.t)),...
                                    ' (',data.process.gatetype,')','</BODY></HTML>'];
                        end
                end
                
                switch data.process.norm
                    case 0
                        if max(nmrproc.s) < 1e-3
                            info{end+1,1} = ['<HTML><BODY>A_max &nbsp= ',...
                                sprintf('%5.4e',max(nmrproc.s)),...
                                '</BODY></HTML>'];
                        else
                            info{end+1,1} = ['<HTML><BODY>A_max &nbsp= ',...
                                sprintf('%5.4f',max(nmrproc.s)),...
                                '</BODY></HTML>'];
                        end
                    case 1
                        if max(nmrproc.s) < 1e-3
                            info{end+1,1} = ['<HTML><BODY>Normfac = ',...
                                sprintf('%5.4e',max(data.process.normfac)),...
                                '</BODY></HTML>'];
                        else
                            info{end+1,1} = ['<HTML><BODY>Normfac = ',...
                                sprintf('%5.4f',max(data.process.normfac)),...
                                '</BODY></HTML>'];
                        end
                        
                end
                info{end+1,1} = ['<HTML><BODY>noise &nbsp= ',sprintf('%5.4f',nmrproc.noise),'</BODY></HTML>'];
                info{end+1,1} = ' ';
                
                % possible inversion results/statistics
                if isfield(data.results,'invstd')
                    invstd = data.results.invstd;
                    invtype = data.invstd.invtype;
                    
                    switch invtype
                        case 'mono'
                            ciE0 = sum(full(invstd.ci(1:2:end)));
                            switch nmrproc.T1T2
                                case 'T1'
                                    info{end+1,1} = ['<HTML><BODY>E<sub>&infin</sub> = ',...
                                        sprintf('%5.4f',sum(invstd.E0)),...
                                        ' &#8723 (',sprintf('%5.4f',ciE0),')','</BODY></HTML>'];
                                case 'T2'
                                    info{end+1,1} = ['<HTML><BODY>E<sub><font size="',num2str(subfs),'">0</sub> = ',...
                                        sprintf('%5.4f',sum(invstd.E0)),...
                                        ' &#8723 (',sprintf('%5.4f',ciE0),')','</BODY></HTML>'];
                            end
                            info{end+1,1} = ' ';
                            if isfield(invstd,'chi2')
                                if ~isnan(invstd.chi2)
                                    str = ['&Chi<sup><font size="',num2str(subfs),'">2</sup> = ',sprintf('%4.2f',invstd.chi2)];
                                    info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                                end
                            end
                            str = ['RMS = ',sprintf('%5.4f',invstd.rms),' (',sprintf('%4.2f',invstd.rms*100./sum(invstd.E0)),'%)'];
                            info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                            if strcmp(nmrproc.T1T2,'T2') && nmrproc.noise ~= 0
                                info{end+1,1} = ['<HTML><BODY>S/N = ',sprintf('%4d',floor(sum(invstd.E0)/nmrproc.noise)),'</BODY></HTML>'];
                            end
                            
                        case 'free'
                            ciE0s = sum(full(invstd.ci(1:2:end)));
                            E0 = invstd.E0;
                            switch nmrproc.T1T2
                                case 'T1'
                                    info{end+1,1} = ['<HTML><BODY>E<sub>&infin</sub> = ',...
                                        sprintf('%5.4f',sum(E0)),...
                                        ' &#8723 (',sprintf('%5.4f',ciE0s),')','</BODY></HTML>'];
                                case 'T2'
                                    info{end+1,1} = ['<HTML><BODY>E<sub><font size="',num2str(subfs),'">0</sub> = ',...
                                        sprintf('%5.4f',sum(E0)),...
                                        ' &#8723 (',sprintf('%5.4f',ciE0s),')','</BODY></HTML>'];
                            end
                            info{end+1,1} = ' ';
                            if isfield(invstd,'chi2')
                                if ~isnan(invstd.chi2)
                                    str = ['&Chi<sup><font size="',num2str(subfs),'">2</sup> = ',sprintf('%4.2f',invstd.chi2)];
                                    info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                                end
                            end
                            str = ['RMS = ',sprintf('%5.4f',invstd.rms),' (',sprintf('%4.2f',invstd.rms*100./sum(invstd.E0)),'%)'];
                            info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                            
                            if strcmp(nmrproc.T1T2,'T2') && nmrproc.noise ~= 0
                                info{end+1,1} = ['<HTML><BODY>S/N = ',sprintf('%4d',floor(sum(invstd.E0)/nmrproc.noise)),'</BODY></HTML>'];
                            end
                            
                        case {'ILA','NNLS'}
                            switch nmrproc.T1T2
                                case 'T1'
                                    info{end+1,1} = ['<HTML><BODY>E<sub>&infin</sub> = ',...
                                        sprintf('%5.4f',sum(invstd.E0)),'</BODY></HTML>'];
                                case 'T2'
                                    info{end+1,1} = ['<HTML><BODY>E<sub><font size="',num2str(subfs),'">0</sub> = ',...
                                        sprintf('%5.4f',sum(invstd.E0)),'</BODY></HTML>'];
                            end
                            info{end+1,1} = ' ';
                            if isfield(invstd,'chi2')
                                if ~isnan(invstd.chi2)
                                    str = ['&Chi<sup><font size="',num2str(subfs),'">2</sup> = ',sprintf('%4.2f',invstd.chi2)];
                                    info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                                end
                            end
                            str = ['RMS = ',sprintf('%5.4f',invstd.rms),' (',sprintf('%4.2f',invstd.rms*100./sum(invstd.E0)),'%)'];
                            info{end+1,1} = ['<HTML><BODY>',str,'</BODY></HTML>'];
                            
                            if strcmp(nmrproc.T1T2,'T2') && nmrproc.noise ~= 0
                                info{end+1,1} = ['<HTML><BODY>S/N = ',sprintf('%4d',floor(sum(invstd.E0)/nmrproc.noise)),'</BODY></HTML>'];
                            end
                            
                            info{end+1,1} = ['<HTML><BODY>&lambda = ',sprintf('%6.5f',invstd.lambda_out),'</BODY></HTML>'];
                            info{end+1,1} = ' ';
                    end
                end
            end
            
        case 2 % RAW
            if isfield(data,'results')
                % add filename & date information
                id = get(gui.listbox_handles.signal,'Value');
                info{end+1,1} = data.import.NMR.filesShort{id};
                info{end+1,1} = data.import.NMR.data{id}.date;
                info{end+1,1} = ' ';
                info{end+1,1} = ['<HTML><BODY>t_min &nbsp= ',...
                    sprintf('%5.4e',data.results.nmrraw.t(1)),'</BODY></HTML>'];
                info{end+1,1} = ['<HTML><BODY>t_max &nbsp= ',...
                    sprintf('%5.4e',data.results.nmrraw.t(end)),'</BODY></HTML>'];
                switch data.results.nmrproc.T1T2
                    case 'T1'
                        info{end+1,1} = ' ';
                        info{end+1,1} = ['<HTML><BODY>Sampl. = ',...
                            sprintf('%d',length(data.results.nmrproc.t)),...
                            '</BODY></HTML>'];
                    case 'T2'
                        info{end+1,1} = ['<HTML><BODY>t_echo = ',...
                            sprintf('%5.4e',data.results.nmrproc.echotime),'</BODY></HTML>'];
                        info{end+1,1} = ['<HTML><BODY>t_dead = ',...
                            sprintf('%5.4e',data.results.nmrproc.dead),'</BODY></HTML>'];
                        info{end+1,1} = ' ';
                        info{end+1,1} = ['<HTML><BODY>Echos &nbsp= ',...
                            sprintf('%d',length(data.results.nmrraw.t)),...
                            '</BODY></HTML>'];
                end
                if max(data.results.nmrproc.s) < 1e-3
                    info{end+1,1} = ['<HTML><BODY>A_max &nbsp= ',...
                        sprintf('%5.4e',max(data.results.nmrproc.s)),...
                        '</BODY></HTML>'];
                else
                    info{end+1,1} = ['<HTML><BODY>A_max &nbsp= ',...
                        sprintf('%5.4f',max(data.results.nmrproc.s)),...
                        '</BODY></HTML>'];
                end
                info{end+1,1} = ' ';
            end
            
        case 3 % ALL
            if isfield(data,'results')
                if isfield(data.results,'invjoint')
                    invjoint = data.results.invjoint;
                    nmr = invjoint.idata.nmr;
                    levels = invjoint.levels;
                    
                    % global fit error
                    info{end+1,1} = ['ErrNorm: ',sprintf('%5.4f',invjoint.errnorm)];
                    info{end+1,1} = ['RMS: ',sprintf('%5.4f',invjoint.rms)];
                    info{end+1,1} = ['<HTML><BODY>&Chi<sup><font size="',num2str(subfs),'">2</sup>: ',...
                        sprintf('%5.4f',invjoint.chi2),'</BODY></HTML>'];
                    info{end+1,1}  = ' ';
                    info{end+1,1}  = '-----';
                    info{end+1,1}  = ' ';
                    
                    for i = 1:numel(levels)
                        info{end+1,1} = nmr{levels(i)}.name;
                        info{end+1,1} = ['RMS: ',sprintf('%5.4f',nmr{levels(i)}.rms)];
                        info{end+1,1} = ['<HTML><BODY>&Chi<sup><font size="',num2str(subfs),'">2</sup>: ',...
                            sprintf('%5.4f',nmr{levels(i)}.chi2),'</BODY></HTML>'];
                        info{end+1,1} = ' ';
                    end
                end
            end
    end
    % and update the text box
    set(gui.listbox_handles.info_signal,'String',info,'Value',[],'Max',2,'Min',0);
    
    %% RTD panel info
    clear info;
    info{1,1} = ' ';
    switch whichdist
        case 1 % RTD
            if isfield(data,'results')
                if isfield(data.results,'invstd')
                    nmrproc = data.results.nmrproc;
                    invstd = data.results.invstd;
                    invtype = data.invstd.invtype;
                    
                    switch invtype
                        case 'mono'
                            info{end+1,1} = invtype;
                            info{end+1,1} = ' ';
                            ciT = sum(full(invstd.ci(2:2:end)));
                            
                            switch nmrproc.T1T2
                                case 'T1'
                                    info{end+1,1} = ['<HTML><BODY>T<sub><font size="',num2str(subfs),'">1</sub> = ',...
                                        sprintf('%5.4f',invstd.T1),...
                                        ' &#8723 (',sprintf('%5.4f',ciT),')','</BODY></HTML>'];
                                case 'T2'
                                    info{end+1,1} = ['<HTML><BODY>T<sub><font size="',num2str(subfs),'">2</sub> = ',...
                                        sprintf('%5.4f',invstd.T2),...
                                        ' &#8723 (',sprintf('%5.4f',ciT),')','</BODY></HTML>'];
                            end
                            info{end+1,1} = ' ';
                            
                        case 'free'
                            str = [invtype,' ',num2str(data.invstd.freeDT)];
                            info{end+1,1} = str;
                            info{end+1,1} = ' ';
                            
                            E0 = invstd.E0;
                            ciE0 = full(invstd.ci(1:2:end));
                            ciT = full(invstd.ci(2:2:end));
                            
                            switch nmrproc.T1T2
                                case 'T1'
                                    T = invstd.T1;
                                case 'T2'
                                    T = invstd.T2;
                            end
                            
                            for i = 1:length(T)
                                info{end+1,1} = ['<HTML><BODY>T(',num2str(i),') = ',sprintf('%5.4f',T(i)),...
                                    ' &#8723 (',sprintf('%5.4f',ciT(i)),')','</BODY></HTML>']; %#ok<*AGROW>
                                info{end+1,1} = ['<HTML><BODY>E(',num2str(i),') = ',sprintf('%5.4f',E0(i)),...
                                    ' &#8723 (',sprintf('%5.4f',ciE0(i)),')','</BODY></HTML>'];
                            end
                            info{end+1,1} = ' ';
                            
                        case {'ILA','NNLS'}
                            % info is a cell array
                            str = [invtype,' ',data.invstd.regtype,' ',num2str(data.invstd.Lorder)];
                            info{end+1,1} = str;
                            info{end+1,1} = ' ';
                            
                            % TLGM
                            info{end+1,1} = ['<HTML><BODY>TLGM</sub> = ',sprintf('%5.4f',invstd.Tlgm),'</BODY></HTML>'];
                            info{end+1,1} = ' ';
                            
                            % clay-bound water CBW < tcut ms
                            % irreducible water / capillary water BVI ccut - tcut ms
                            % movable water BVM > tcut ms
                            switch data.process.timescale
                                case 's'
                                    ccut = data.param.CBWcutoff/1000;
                                    tcut = data.param.BVIcutoff/1000;
                                case 'ms'
                                    ccut = data.param.CBWcutoff;
                                    tcut = data.param.BVIcutoff;
                            end
                            por = data.invstd.porosity;
                            CBW = abs(sum(invstd.T1T2f(invstd.T1T2me<=ccut))/sum(invstd.T1T2f));
                            BVI = abs(sum(invstd.T1T2f(invstd.T1T2me>ccut & invstd.T1T2me<=tcut))/sum(invstd.T1T2f));
                            BVM = abs(sum(invstd.T1T2f(invstd.T1T2me>tcut))/sum(invstd.T1T2f));
                            info{end+1,1} = ['CBW(',sprintf('%2d',data.param.CBWcutoff),...
                                ') = ',sprintf('%5.2f',por*CBW*100),' [vol. %]'];
                            
                            info{end+1,1} = ['BVI(',sprintf('%2d',data.param.BVIcutoff),...
                                ') = ',sprintf('%5.2f',por*BVI*100),' [vol. %]'];
                            info{end+1,1} = ['BVM     = ',sprintf('%5.2f',por*BVM*100),' [vol. %]'];
                            
                    end
                end
            end
            
        case 2 % PSD
            info{end+1,1} = 'PSD';
            info{end+1,1} = ' ';
            
        case 3 % PSDJ
            if isfield(data,'results')
                if isfield(data.results,'invjoint')
                    invjoint = data.results.invjoint;
                    
                    info{end+1,1} = ['Inversion type: ',data.invjoint.invtype];
                    info{end+1,1} = ' ';
                    switch data.invjoint.geometry_type
                        case 'cyl'
                            info{end+1,1} = ['Shape: ',data.invjoint.geometry_type];
                            info{end+1,1} = ['Geom.: ',sprintf('%4.2f',invjoint.iGEOM.a)];
                        case 'ang'
                            info{end+1,1} = ['Shape: ',data.invjoint.geometry_type,' ',...
                                num2str(invjoint.iGEOM.angles(1)),' ',...
                                num2str(invjoint.iGEOM.angles(2)),' ',...
                                num2str(invjoint.iGEOM.angles(3))];
                            info{end+1,1} = ['Geom.: ',sprintf('%4.2f',invjoint.iGEOM.a)];
                        case 'poly'
                            info{end+1,1} = ['Shape: ',data.invjoint.geometry_type,...
                                ' ',num2str(data.invjoint.polyN),' sides'];
                            info{end+1,1} = ['Geom.: ',sprintf('%4.2f',invjoint.iGEOM.a)];
                    end
                    info{end+1,1} = ' ';
                    info{end+1,1} = ['rho (INV): ',sprintf('%5.3f',invjoint.irho*1e6),' [µm/s]'];
                    if isfield(data.import,'NMRMOD')
                        info{end+1,1} = ['rho (MOD): ',...
                            sprintf('%5.3f',data.import.NMRMOD.nmr.rho*1e6),' [µm/s]'];
                    end
                end
            end
    end
    % and update the text box
    set(gui.listbox_handles.info_dist,'String',info,'Value',[],'Max',2,'Min',0);
    
    %% CPS panel info
    % check if the CPS panel is maximized
    isminimized = get(gui.plots.CPSPanel,'Minimized');
    if ~isminimized
        clear info;
        info{1,1} = ' ';
        if isfield(data,'results')
            if isfield(data.results,'invjoint')
                invjoint = data.results.invjoint;
                nmr = invjoint.idata.nmr;
                levels = invjoint.levels;
                
                for i = 1:numel(levels)
                    info{end+1,1} = nmr{levels(i)}.name;
                    info{end+1,1} = ['press. : ',...
                        sprintf('%5.4f',invjoint.p0(levels(i))*data.pressure.unitfac),...
                        ' [',data.pressure.unit,']'];
                    switch invjoint.T1T2
                        case 'T1'
                            info{end+1,1} = ['sat. (INV) : ',...
                                sprintf('%4.2f',invjoint.idata.nmr{levels(i)}.fit_g(end))];
                        case 'T2'
                            info{end+1,1} = ['sat. (INV) : ',...
                                sprintf('%4.2f',invjoint.idata.nmr{levels(i)}.fit_g(1))];
                    end
                    info{end+1,1} = ['sat. (MOD) : ',...
                        sprintf('%4.2f',invjoint.S0(levels(i)))];
                    info{end+1,1} = ' ';
                end
            end
        end
        set(gui.listbox_handles.info_cps,'String',info,'Value',[],'Max',2,'Min',0);
    end
    
    % update GUI data
    setappdata(fig,'data',data);
    setappdata(fig,'gui',gui);
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