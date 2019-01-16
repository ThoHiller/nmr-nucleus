function onContextPlotsPSD(src,~)
%onContextPlotsPSD checks the label of the distribution axis context menu
%to allow plotting either the cumulative or discrete pore size distribution
%either from NUCLEUSmod or by shifting the relaxation time distribution
%inside NUCLEUSinv
%
% Syntax:
%       onContextPlotsPSD
%
% Inputs:
%       src - Handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onContextPlotsPSD(src,~)
%
% Other m-files required:
%       updatePlotsPSD
%       updatePlotsDistribution
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

% get the tag of the context menu
tag = get(src,'Tag'); % ('view')
% get the label of the context menu
label = get(src,'Label'); % ('cum' or 'freq')

% depending on the current label, set a check mark and unceck the other one
switch fig_tag
    case 'MOD'        
        switch tag
            case 'view'
                switch label
                    case 'freq'
                        set(src,'Checked','on');
                        set(gui.cm_handles.geo_cm_viewcum,'Checked','off');
                    case 'cum'
                        set(src,'Checked','on');
                        set(gui.cm_handles.geo_cm_viewfreq,'Checked','off');
                end
                % update the GUI data
                setappdata(fig,'gui',gui);
                % update the plot axes
                updatePlotsPSD;
            otherwise
                disp('onContextPlotsPSD: something is utterly wrong.');
        end
    case 'INV'
        switch tag
            case 'view'
                data.info.PSDflag = label;
                switch label
                    case 'freq'
                        set(src,'Checked','on');
                        set(gui.cm_handles.axes_psd_view_cum,'Checked','off');
                    case 'cum'
                        set(src,'Checked','on');
                        set(gui.cm_handles.axes_psd_view_freq,'Checked','off');
                end
                % update the GUI data
                setappdata(fig,'data',data);
                setappdata(fig,'gui',gui);
                % update the plot axes
                updatePlotsDistribution;
            otherwise
                disp('onContextPlotsPSD: something is utterly wrong.');
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