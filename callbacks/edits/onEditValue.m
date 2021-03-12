function onEditValue(src,~)
%onEditValue updates all edit field values, checks for wrong inputs and
%restores a default value if necessary
%
% Syntax:
%       onEditValue
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onEditValue(src)
%
% Other m-files required:
%       calculateGeometry
%       calibratePorosity
%       clearSingleAxis
%       NUCLEUSinv_updateInterface
%       NUCLEUSmod_updateInterface
%       removeCalculationFields
%       removeInversionFields
%       processNMRDataControl
%       updateInfo
%       updateNMRsignals
%       updatePlotsDistribution
%       updatePlotsNMR
%       updatePlotsSignal
%
% Subfunctions:
%       createDataString
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
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

%% the generic part works for both GUIS
% get the value of the field
value = str2double(get(src,'String'));
% get the user data of the field
userdata = get(src,'UserData');

% check if the value is numeric
% if not reset to defaults stored in user data
defaults = userdata.defaults;
if isnan(value)
    set(src,'String',num2str(defaults(1)));
    value = str2double(get(src,'String'));
end

% get the tag
tag = get(src,'Tag');
out = createDataString(tag);

% update the corresponding data field
updstr = [out.updstr,'(',num2str(defaults(2)),',',...
    num2str(defaults(3)),')','=value;'];
eval(updstr);
% update the data inside the GUI
setappdata(fig,'data',data);

% switch depending on what figure called
switch fig_tag
    case 'INV'
        % id of the chosen NMR signal
        id = get(gui.listbox_handles.signal,'Value');
        
        % switch depending on the parent panel
        switch out.panel
            case 'process'
                % remove temporary data fields
                data = removeInversionFields(data);
                setappdata(fig,'data',data);
                % process the current selected signal
                id = get(gui.listbox_handles.signal,'Value');
                switch out.field
                    case {'Nechoes'}
                        if value == 0
                            data.process.Nechoes = 1;
                            set(src,'String',num2str(data.process.Nechoes));
                            setappdata(fig,'data',data);
                        end
                    case 'end'
                        % check if the first sample is really smaller than
                        % the last one; if not reset everything
                        first = str2double(get(gui.edit_handles.process_start,'String'));
                        last = value;
                        maxL = length(data.import.NMR.data{id}.signal);
                        if last == 0 || last <= first || last > maxL
                            data.process.end = maxL;
                            set(src,'String',num2str(data.process.end));
                            setappdata(fig,'data',data);
                        end
                end
                % process the current selected signal
                processNMRDataControl(fig,id);
                updatePlotsSignal;
                updateInfo(src);
                % clear axes
                clearSingleAxis(gui.axes_handles.rtd);
                clearSingleAxis(gui.axes_handles.psd);
                % set focus on data
                set(gui.plots.SignalPanel,'Selection',1);
            case 'param'
                switch out.field
                    case {'rho','a','CBWcutoff','BVIcutoff'}
                        if isstruct(INVdata{id})
                            eval(['INVdata{',num2str(id),'}.',...
                                out.panel,'.',out.field,'=value;']);
                            setappdata(fig,'INVdata',INVdata);
                        end
                        updatePlotsDistribution;
                        updateInfo(gui.plots.SignalPanel);
                    case 'calibAmp'
                        data.calib.amp = data.param.calibAmp;
                        setappdata(fig,'data',data);
                    case 'calibVol'
                        data.calib.vol = data.param.calibVol;
                        setappdata(fig,'data',data);
                    case 'sampVol'
                        calibratePorosity;
                end
            case 'invstd'
                switch out.field
                    case 'lambdaR'
                        data.invstd.lambda = data.invstd.lambdaR(1);
                        setappdata(fig,'data',data);
                    case 'Tbulk'
                        if data.invstd.Tbulk <=0
                            data.invstd.Tbulk = 2;
                            setappdata(fig,'data',data);
                            set(src,'String',num2str(data.invstd.Tbulk));
                        end
                    case 'porosity'
                        if data.invstd.porosity < 0 || data.invstd.porosity > 1
                            data.invstd.porosity = 1;
                            setappdata(fig,'data',data);
                            set(src,'String',num2str(data.invstd.porosity));
                        end
                        updatePlotsDistribution;
                end
            case 'invjoint'
                switch out.field
                    case 'lambdaR'
                        data.invjoint.lambda = data.invjoint.lambdaR(1);
                        setappdata(fig,'data',data);
                    case 'beta'
                        if value < 0.1
                            value = 1;
                        elseif value > 89.9
                            value = 89;
                        end
                        eval(updstr);
                        data.invjoint.gamma = data.invjoint.alpha - data.invjoint.beta;
                        setappdata(fig,'data',data);
                        NUCLEUSinv_updateInterface;
                    case 'rhostart'
                    case 'anglestart'
                        if value < 0.1
                            value = 1;
                        elseif value > 89.9
                            value = 89;
                        end
                        eval(updstr);
                        data.invjoint.beta = value;
                        data.invjoint.gamma = data.invjoint.alpha - data.invjoint.beta;
                        setappdata(fig,'data',data);
                        NUCLEUSinv_updateInterface;
                end
        end % switch out.panel
        setappdata(fig,'gui',gui);
    case 'MOD'
        % switch depending on the parent panel
        switch out.panel
            case 'geometry'
                switch out.field
                    case 'beta'
                        if value < 0.5
                            value = 1;
                        elseif value > 89.5
                            value = 89;
                        end
                        eval(updstr);
                        setappdata(fig,'data',data);
                    otherwise
                        % nothing to do
                end
                data = removeCalculationFields(data,'cps');
                data = removeCalculationFields(data,'nmr');
                clearSingleAxis(gui.axes_handles.cps);
                clearSingleAxis(gui.axes_handles.nmr);
                setappdata(fig,'data',data);
                calculateGeometry;
                
            case 'pressure'
                switch out.field
                    case 'range'
                        updstr = [out.updstr,'(',num2str(defaults(2)),...
                            ',',num2str(defaults(3)),')',...
                            '=value/data.pressure.unitfac;'];
                        eval(updstr);
                end
                data = removeCalculationFields(data,'cps');
                data = removeCalculationFields(data,'nmr');
                clearSingleAxis(gui.axes_handles.cps);
                clearSingleAxis(gui.axes_handles.nmr);
                setappdata(fig,'data',data);
                NUCLEUSmod_updateInterface;
                
            case 'nmr'
                switch out.field
                    case 'noise'
                        if isfield(data.results,'NMR')
                            updateNMRsignals;
                            updatePlotsNMR;
                        end
                    case 'porosity'
                        if data.nmr.porosity <= 0 || data.nmr.porosity > 1
                            data.nmr.porosity = 1;
                            set(src,'String',num2str(data.nmr.porosity));
                            setappdata(fig,'data',data);
                        end
                        if isfield(data.results,'NMR')
                            updateNMRsignals;
                            updatePlotsNMR;
                        end
                    otherwise
                        data = removeCalculationFields(data,'nmr');
                        clearSingleAxis(gui.axes_handles.nmr);
                        setappdata(fig,'data',data);
                        NUCLEUSmod_updateInterface;
                end
        end
    otherwise
        helpdlg({'function: onEditValue','Something is utterly wrong.'},...
            'wrong fig tag');
end

end

function out = createDataString(tag)
ind = strfind(tag,'_');
out.panel = tag(1:ind(1)-1);
out.field = tag(ind(1)+1:end);
tag(ind) = '.';
out.updstr = ['data.',tag];
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