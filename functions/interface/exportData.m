function exportData(fig_tag,format)
%exportData exports data from both GUIs into various formats
%
% Syntax:
%       exportData(fig_tag,format)
%
% Inputs:
%       fig_tag - 'MOD' or 'INV'
%       format - 'matS', 'matA', 'excelS' or 'LIAG'
%
% Outputs:
%       none
%
% Example:
%       exportData('INV','matS')
%
% Other m-files required:
%       clearSingleAxis
%
% Subfunctions:
%       checkINV
%       checkMOD
%       exportINV_EXCEL
%       exportINV_CSV
%       exportMOD_EXCEL
%       findApproxTlgmAmplitude
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = findobj('Tag',fig_tag);
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

switch fig_tag
    case 'INV'
        % get inversion data
        INVdata = getappdata(fig,'INVdata');
        
        % which NMR signal
        id = get(gui.listbox_handles.signal,'Value');
        
        % different export formats
        switch format
            
            case 'LIAGcsvT2' % raw data
                % check if there is any data at all
                if isfield(data.import,'NMR')
                    
                    % display info text
                    displayStatusText(gui,...
                        'Exporting LIAG csv T2 raw data ...');
                    % which NMR signal
                    id = get(gui.listbox_handles.signal,'Value');
                    % export path
                    spath = data.import.path;
                    % export file names
                    fname = data.import.NMR.data{id}.datfile;
                    fname_org = [fname,'.org'];
                    % ask the user if the imag part should be set to zero
                    quest = 'Set imaginary part to ZERO?';
                    title = 'Saving T2 data';
                    answer = questdlg(quest,title,'Yes');
                    
                    switch answer
                        case {'Yes','No'}
                            % first copy original file to backup file
                            sourcef = fullfile(spath,fname);
                            destf = fullfile(spath,fname_org);
                            [status,~,~] = copyfile(sourcef,destf);
                            % if the backup was successful save the data
                            if status == 1
                                t = data.import.NMR.data{id}.time;
                                s = data.import.NMR.data{id}.signal;
                                
                                switch answer
                                    case 'Yes'
                                        out = [t real(s) zeros(size(t))];
                                    case 'No'
                                        out = [t real(s) imag(s)];
                                end
                                dlmwrite(sourcef,out,'precision','%.6f');
                                
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting LIAG csv T2 raw data ... done');
                            else
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting LIAG csv T2 raw data ... canceled');
                            end
                        otherwise
                            % display info text
                            displayStatusText(gui,...
                                'Exporting LIAG csv T2 raw data ... canceled');
                    end
                end
                
            otherwise % inv data
                % check if data can be exported
                doexport_inv = checkINV(INVdata,id);
                
                if doexport_inv
                    % get the new file name
                    sfilename = data.import.NMR.filesShort{id};
                    ind1 = strfind(sfilename,'.');
                    if isempty(ind1)
                        sfilename = [sfilename,'_INV'];
                    else
                        sfilename = [sfilename(1:ind1-1),'_INV'];
                    end
                    
                    % different export formats
                    switch format
                        case 'excelS'
                            % get the file name
                            [sfile,spath] = uiputfile('*.xlsx',...
                                'Save inversion to Excel-file',...
                                fullfile(data.import.path,[sfilename,'.xlsx']));
                            
                            % if user didn't cancel
                            if sum([sfile spath]) > 0
                                exportINV_EXCEL(gui,INVdata,id,sfile,spath);
                            end
                            
                        case 'matS'
                            % get the file name
                            [sfile,spath] = uiputfile('*.mat',...
                                'Save inversion to mat-file',...
                                fullfile(data.import.path,[sfilename,'.mat']));
                            
                            % if user didn't cancel
                            if sum([sfile spath]) > 0
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion data to mat-file ...');
                                % gather all data
                                idata.NMRdata = data.import.NMR.data{id};
                                idata.results = INVdata{id}.results;
                                idata.NUCLEUSinv_GUI = INVdata{id};
                                idata.NUCLEUSinv_GUI = rmfield(idata.NUCLEUSinv_GUI,'results');
                                
                                % save to file
                                save(fullfile(spath,sfile),'idata');
                                
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion data to mat-file ... done');
                            else
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion data to mat-file ... canceled');
                            end
                            
                        case 'matA'
                            % get the file name
                            [sfile,spath] = uiputfile('*.mat',...
                                'Save inversion to mat-file',...
                                fullfile(data.import.path,'inversion_set.mat'));
                            % if user didn't cancel
                            if sum([sfile spath]) > 0
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion set to mat-file ...');
                                idata = struct;
                                for id = 1:size(INVdata,1)
                                    if isstruct(INVdata{id})
                                        results = INVdata{id}.results;
                                        results = rmfield(results,'nmrraw');
                                        results.nmraw = data.import.NMR.data{id};
                                        idata.results(id) = results;
                                    end
                                end
                                idata.NUCLEUSinv_GUI = INVdata{1};
                                idata.NUCLEUSinv_GUI = rmfield(idata.NUCLEUSinv_GUI,'results');
                                
                                % save to file
                                save(fullfile(spath,sfile),'idata');
                                
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion set to mat-file ... done');
                            else
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting inversion set to mat-file ... canceled');
                            end
                            
                        case 'LIAG'
                            
                            if isfield(data.import,'LIAG')
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting LIAG archive data ...');
                                % find id of sample
                                id = 1;
                                spath = data.import.LIAG.workpaths{id};
                                sfilename = ['INV_',data.import.NMR.filesShort{id}];
                                
                                % session output
                                silent.sname = fullfile(spath,[sfilename,'_session.mat']);
                                exportINV('session',silent);
                                
                                % csv output
                                csvname = fullfile(spath,[sfilename,'.csv']);
                                exportINV_CSV(INVdata{id},csvname);
                                
                                % png graphics
                                pngname = fullfile(spath,[sfilename,'.png']);
                                [f,ax] = exportGraphics('INV','fig');
                                
                                figure(f);
                                por = INVdata{id}.invstd.porosity;
                                tname = [sfilename(5:end),' (water content: ',...
                                    sprintf('%2.1f',por*100),' vol. %)'];
                                set(get(ax(1),'Title'),'String',tname,'Interpreter','none');
                                
                                % get the cut-offs
                                switch INVdata{id}.process.timescale
                                    case 's'
                                        CBW = INVdata{id}.param.CBWcutoff/1000;
                                        BVI = INVdata{id}.param.BVIcutoff/1000;
                                    case 'ms'
                                        CBW = INVdata{id}.param.CBWcutoff;
                                        BVI = INVdata{id}.param.BVIcutoff;
                                end
                                % ylim of relaxation time axis
                                yy = get(ax(2),'YLim');
                                lgdstr = cell(1,1);
                                switch INVdata{id}.invstd.invtype
                                    case {'ILA','NNLS'}
                                        TLGM = INVdata{id}.results.invstd.Tlgm;
                                        T = INVdata{id}.results.invstd.T1T2me;
                                        F = INVdata{id}.results.invstd.T1T2f;
                                        F = 100.*por.*F./sum(F);
                                        amp = findApproxTlgmAmplitude(T,F,TLGM);
                                        stem(TLGM,amp,...
                                            'x-','Color',[0.3 0.3 0.3],'LineWidth',2,...
                                            'Tag','TLGM','Parent',ax(2));
                                        lgdstr{1} = 'RTD';
                                        lgdstr{2} = 'TLGM';
                                        
                                        CBWa = abs(sum(F(T<=CBW))/sum(F));
                                        BVIa = abs(sum(F(T>CBW & T<=BVI))/sum(F));
                                        BVMa = abs(sum(F(T>BVI))/sum(F));
                                        % tname2 = ['CBW: ',sprintf('%2.1f',por*100*CBWa),...
                                        % ' | BVI: ',sprintf('%2.1f',por*100*BVIa),...
                                        % ' | BVM: ',sprintf('%2.1f',por*100*BVMa),...
                                        % ' vol. % | TLGM: ',sprintf('%4.3f',TLGM),' [s]'];
                                        tname2 = ['CBW / BVI / BVM: ',sprintf('%2.1f',por*100*CBWa),...
                                            ' / ',sprintf('%2.1f',por*100*BVIa),...
                                            ' / ',sprintf('%2.1f',por*100*BVMa),...
                                            ' vol. % | TLGM: ',sprintf('%5.4f',TLGM),' [s]'];
                                        
                                    case {'mono','free'}
                                        F = INVdata{id}.results.invstd.E0(:);
                                        switch INVdata{id}.results.nmrproc.T1T2
                                            case 'T1'
                                                T = INVdata{id}.results.invstd.T1(:);
                                            case 'T2'
                                                T = INVdata{id}.results.invstd.T2(:);
                                        end
                                        F = 100.*por.*F./sum(F);
                                        CBWa = abs(sum(F(T<=CBW))/sum(F));
                                        BVIa = abs(sum(F(T>CBW & T<=BVI))/sum(F));
                                        BVMa = abs(sum(F(T>BVI))/sum(F));
                                        tname2 = ['CBW / BVI / BVM: ',sprintf('%2.1f',por*100*CBWa),...
                                            ' / ',sprintf('%2.1f',por*100*BVIa),...
                                            ' / ',sprintf('%2.1f',por*100*BVMa),...
                                            ' vol. %'];
                                        for i = 1:numel(T)
                                            lgdstr{i} = ['Tx',num2str(i)];
                                        end
                                end
                                % print cut-off lines
                                line([CBW CBW],[yy(1) yy(2)],'Color',[0.3 0.3 0.3],'LineStyle','--',...
                                    'LineWidth',1,'Parent',ax(2),'Tag','infolines');
                                line([BVI BVI],[yy(1) yy(2)],'Color',[0.3 0.3 0.3],'LineStyle','--',...
                                    'LineWidth',1,'Parent',ax(2),'Tag','infolines');
                                legend(ax(2),[lgdstr,'cutoffs']);
                                set(get(ax(2),'Title'),'String',tname2,'Interpreter','none');
                                
                                set(f,'PaperType','A4','PaperUnits','centimeters',...
                                    'PaperOrientation','portrait');
                                set(f,'PaperPositionMode','manual',...
                                    'PaperPosition',[0.6 6.2 19.7 17.2]);
                                set(f,'Renderer','painter');
                                print(f,pngname,'-r300','-dpng');
                                close(f);
                                
                                % display info text
                                displayStatusText(gui,...
                                    'Exporting LIAG archive data ... done');
                                
                            else
                                helpdlg({'function: exportData',...
                                    'This routine works only on LIAG specific project data.'},...
                                    'No LIAG data');
                            end
                    end
                end
        end
    case 'MOD'
        % check if data can be exported
        doexport_mod = checkMOD(data);
        if doexport_mod
            % different export formats
            switch format
                case 'mat'
                    % gather all relevant data
                    out = data.results;
                    if isfield(out.NMR.raw,'Tb')
                        out.NMR.raw = rmfield(out.NMR.raw,'Tb');
                    end
                    if isfield(out.NMR.raw,'rho')
                        out.NMR.raw = rmfield(out.NMR.raw,'rho');
                    end
                    out.NMRMOD_GUI.geometry = data.geometry;
                    out.NMRMOD_GUI.pressure = data.pressure;
                    out.NMRMOD_GUI.nmr = data.nmr;
                    out.NMRMOD_GUI.myui = gui.myui;
                    
                    displayStatusText(gui,'Saving to MAT-file ...');
                    [FileName,PathName,~] = uiputfile({'*.mat','Matlab file'},'NUCLEUSmod: Save Data',fullfile(pwd,'NUCLEUSmod_forward.mat'));
                    
                    if ~isequal(FileName,0) || ~isequal(PathName,0)
                        clear data
                        data = out; %#ok<NASGU>
                        save(fullfile(PathName,FileName),'data');
                        displayStatusText(gui,'Saving to MAT-file ... done.');
                    else
                        displayStatusText(gui,'Saving to MAT-file ... canceled.');
                    end
                    
                case 'xls'
                    indd = data.pressure.DrainLevels;
                    indi = data.pressure.ImbLevels;
                    results = data.results;
                    
                    displayStatusText(gui,'Saving to XLS-file ...');
                    [FileName,PathName,~] = uiputfile({'*.xls','XLS file'},'NUCLEUSmod: Save Data',fullfile(pwd,'NUCLEUSmod_forward.xls'));
                    
                    if ~isequal(FileName,0) || ~isequal(PathName,0)
                        exportMOD_EXCEL;
                        displayStatusText(gui,'Saving to XLS-file ... done.');
                    else
                        displayStatusText(gui,'Saving to XLS-file ... canceled.');
                    end
                    
                otherwise
                    helpdlg({'exportData:','Not yet implemented.'},'NUCLEUSmod info:');
                    
            end
        end
end

end

%%
function exportINV_EXCEL(gui,INVdata,id,sfile,spath)
unit = INVdata{id}.process.timescale;

% gather all data
% raw data
tmp1(:,1) = INVdata{id}.results.nmrraw.t(:);
header1{1} = ['time [',unit,']'];
if isreal(INVdata{id}.results.nmrraw.s(:))
    header1{2} = 'amplitude [a.u.]';
    tmp1(:,2) = INVdata{id}.results.nmrraw.s(:);
    
    b1 = {'raw data',''};
    b1(2,:) = header1;
    b1(3:2+size(tmp1,1),:) = [num2cell(tmp1(:,1)),num2cell(tmp1(:,2))];
else
    header1{2} = 'real [a.u.]';
    header1{3} = 'imag [a.u.]';
    tmp1(:,2) = real(INVdata{id}.results.nmrraw.s(:));
    tmp1(:,3) = imag(INVdata{id}.results.nmrraw.s(:));
    
    b1 = {'raw data','',''};
    b1(2,:) = header1;
    b1(3:2+size(tmp1,1),:) = [num2cell(tmp1(:,1)),num2cell(tmp1(:,2)),...
        num2cell(tmp1(:,3))];
end

% proc data
tmp2(:,1) = INVdata{id}.results.nmrproc.t(:);
tmp2(:,2) = INVdata{id}.results.nmrproc.s(:);
header2{1} = ['time [',unit,']'];
header2{2} = 'amplitude [a.u.]';

b2 = {'proc data',''};
b2(2,:) = header2;
b2(3:2+size(tmp2,1),:) = [num2cell(tmp2(:,1)),num2cell(tmp2(:,2))];

% fit data (incl. residuals)
tmp3(:,1) = INVdata{id}.results.invstd.fit_t(:);
tmp3(:,2) = INVdata{id}.results.invstd.fit_s(:);
tmp3(:,3) = INVdata{id}.results.invstd.residual(:);
header3{1} = ['time [',unit,']'];
header3{2} = 'amplitude [a.u.]';
header3{3} = 'residual [-]';

b3 = {'fit data','',''};
b3(2,:) = header3;
b3(3:2+size(tmp3,1),:) = [num2cell(tmp3(:,1)),num2cell(tmp3(:,2)),...
    num2cell(tmp3(:,3))];

% relaxation times
switch INVdata{id}.invstd.invtype
    case {'mono','free'}
        switch INVdata{id}.results.nmrproc.T1T2
            case 'T1'
                tmp4 = [INVdata{id}.results.invstd.T1(:)...
                    INVdata{id}.results.invstd.E0(:)];
                header4 = {['T1 [',unit,']'],'amplitude [a.u.]'};
            case 'T2'
                tmp4 = [INVdata{id}.results.invstd.T2(:)...
                    INVdata{id}.results.invstd.E0(:)];
                header4 = {['T2 [',unit,']'],'amplitude [a.u.]'};
        end
        
    case {'ILA','NNLS'}
        tmp4 = [INVdata{id}.results.invstd.T1T2me(:)...
            INVdata{id}.results.invstd.T1T2f(:)];
        header4 = {['relaxation times [',unit,']'],'amplitudes [a.u.]'};
        
    otherwise
        disp('Something is utterly wrong.')
end

b4 = {'relaxation times',''};
b4(2,:) = header4;
b4(3:2+size(tmp4,1),:) = [num2cell(tmp4(:,1)),num2cell(tmp4(:,2))];

% glue together the output matrix
out(1:size(b1,1),1:size(b1,2)) = b1;
yi = size(b1,2)+2;
out(1:size(b2,1),yi:yi-1+size(b2,2)) = b2;
yi = yi + size(b2,2)+1;
out(1:size(b3,1),yi:yi-1+size(b3,2)) = b3;
yi = yi + size(b3,2)+1;
out(1:size(b4,1),yi:yi-1+size(b4,2)) = b4;

% display info text
displayStatusText(gui,...
    'Exporting inversion data to Excel-file ...');
% save to file
xlswrite(fullfile(spath,sfile),out,'NMRdata','A1');

% remove the first standard excel sheet
[~,sheets] = xlsfinfo(fullfile(spath,sfile));
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile(spath,sfile));
objExcel.ActiveWorkbook.Worksheets.Item(sheets{1}).Delete;
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;
% display info text
displayStatusText(gui,...
    'Exporting inversion data to Excel-file ... done');
end

%%
function exportINV_CSV(INVdata,sfile)
unit = INVdata.process.timescale;

% gather all data
% proc data
tmp2(:,1) = INVdata.results.nmrproc.t(:);
tmp2(:,2) = INVdata.results.nmrproc.s(:);
header2{1} = ['time [',unit,']'];
header2{2} = 'signal [a.u.]';

% fit data (incl. residuals)
tmp3(:,1) = INVdata.results.invstd.fit_t(:);
tmp3(:,2) = INVdata.results.invstd.fit_s(:);
tmp3(:,3) = INVdata.results.invstd.residual(:);
header3{1} = ['time [',unit,']'];
header3{2} = 'fit [a.u.]';
header3{3} = 'residual [-]';

% relaxation times
switch INVdata.invstd.invtype
    case {'ILA','NNLS'}
        por = INVdata.invstd.porosity;
        F = INVdata.results.invstd.T1T2f(:);
        F = 100*por.*F./sum(F);
        tmp4 = [INVdata.results.invstd.T1T2me(:)...
            INVdata.results.invstd.T1T2f(:) F];
        header4 = {['relaxation times [',unit,']'],'frequency [-]',...
            ' water content [vol. %]'};
        
    case {'mono','free'}
        por = INVdata.invstd.porosity;
        F = 100*por.*INVdata.results.invstd.E0./sum(INVdata.results.invstd.E0);
        switch INVdata.results.nmrproc.T1T2
            case 'T1'
                tmp4 = [INVdata.results.invstd.T1(:)...
                    INVdata.results.invstd.E0(:) F(:)];
                header4 = {['relaxation time(s) T1 [',unit,']'],...
                    'amplitude [a.u.]',' water content [vol. %]'};
            case 'T2'
                tmp4 = [INVdata.results.invstd.T2(:)...
                    INVdata.results.invstd.E0(:) F(:)];
                header4 = {['relaxation time(s) T2 [',unit,']'],...
                    'amplitude [a.u.]',' water content [vol. %]'};
        end
        
    otherwise
        % Nothing to do
end

% glue together headers
cHeader = [header2 header3 header4];
% insert commas
commaHeader = [cHeader;repmat({','},1,numel(cHeader))];
commaHeader = commaHeader(:)';
% cHeader as string with commas
textHeader = cell2mat(commaHeader(1:numel(commaHeader)-1));

maxrows = max([size(tmp2,1) size(tmp3,1) size(tmp4,1)]);
% glue together data
if size(tmp2,1) < maxrows
    tmp2(end+1:maxrows,:) = NaN;
end
if size(tmp3,1) < maxrows
    tmp3(end+1:maxrows,:) = NaN;
end
if size(tmp4,1) < maxrows
    tmp4(end+1:maxrows,:) = NaN;
end
out(1:maxrows,1:size(tmp2,2)) = tmp2;
yi = size(tmp2,2)+1;
out(1:maxrows,yi:yi-1+size(tmp3,2)) = tmp3;
yi = yi + size(tmp3,2);
out(1:maxrows,yi:yi-1+size(tmp4,2)) = tmp4;

% save to file
%write header to file
fid = fopen(sfile,'w');
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite(sfile,out,'-append','precision','%.5f');

end

%%
function exportMOD_EXCEL()
xlswrite(fullfile(PathName,FileName),{'pressure [Pa]','saturation (drain)','saturation (imb)'},'CPS','A1');
xlswrite(fullfile(PathName,FileName),[results.SAT.pressure(:) results.SAT.Sdfull(:) results.SAT.Sifull(:)],'CPS','A2');

out = zeros(numel(results.NMR.t),numel(indd)+1);
out(:,1) = results.NMR.t(:);
header = cell(1,1);
header{1} = 'time [s]';
for i = 1:numel(indd)
    out(:,i+1) = results.NMR.EdT1(indd(i),:)';
    header{i+1} = ['S',num2str(i)];
end
xlswrite(fullfile(PathName,FileName),header,'NMR_T1_drain','A1');
xlswrite(fullfile(PathName,FileName),out,'NMR_T1_drain','A2');
out = zeros(numel(results.NMR.t),numel(indd)+1);
out(:,1) = results.NMR.t(:);
header = cell(1,1);
header{1} = 'time [s]';
for i = 1:numel(indd)
    out(:,i+1) = results.NMR.EdT2(indd(i),:)';
    header{i+1} = ['S',num2str(i)];
end
xlswrite(fullfile(PathName,FileName),header,'NMR_T2_drain','A1');
xlswrite(fullfile(PathName,FileName),out,'NMR_T2_drain','A2');

out = zeros(numel(results.NMR.t),numel(indi)+1);
out(:,1) = results.NMR.t(:);
header = cell(1,1);
header{1} = 'time [s]';
for i = 1:numel(indi)
    out(:,i+1) = results.NMR.EiT1(indi(i),:)';
    header{i+1} = ['S',num2str(i)];
end
xlswrite(fullfile(PathName,FileName),header,'NMR_T1_imb','A1');
xlswrite(fullfile(PathName,FileName),out,'NMR_T1_imb','A2');

out = zeros(numel(results.NMR.t),numel(indi)+1);
out(:,1) = results.NMR.t(:);
header = cell(1,1);
header{1} = 'time [s]';
for i = 1:numel(indi)
    out(:,i+1) = results.NMR.EiT2(indi(i),:)';
    header{i+1} = ['S',num2str(i)];
end
xlswrite(fullfile(PathName,FileName),header,'NMR_T2_imb','A1');
xlswrite(fullfile(PathName,FileName),out,'NMR_T2_imb','A2');

% remove the first standard excel sheet
[~,sheets] = xlsfinfo(fullfile(PathName,FileName));
objExcel = actxserver('Excel.Application');
objExcel.Workbooks.Open(fullfile(PathName,FileName));
objExcel.ActiveWorkbook.Worksheets.Item(sheets{1}).Delete;
objExcel.ActiveWorkbook.Save;
objExcel.ActiveWorkbook.Close;
objExcel.Quit;
objExcel.delete;
end

%%
function doexport = checkINV(INVdata,id)

doexport = false;
if ~isempty(INVdata) && ~isempty(id)
    if isstruct(INVdata{id})
        doexport = true;
    else
        helpdlg({'exportData:','No inversion data to save'},...
            'Nothing to save');
    end
else
    helpdlg({'exportData:','No inversion data to save'},...
        'Nothing to save');
end

end

%%
function doexport = checkMOD(data)

doexport = false;
if isfield(data,'results')
    if isfield(data.results,'NMR')
        doexport = true;
    else
        helpdlg({'exportData:',...
            'No data to save. Generate some data first.'},'NUCLEUSmod info:');
    end
else
    helpdlg({'exportData:',...
        'No data to save. Generate some data first.'},'NUCLEUSmod info:');
end

end

%%
function amp = findApproxTlgmAmplitude(t,f,TLGM)
index = find(abs(t-TLGM)==min(abs(t-TLGM)));
amp = interp1(t(index-1:index+1),f(index-1:index+1),TLGM);
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