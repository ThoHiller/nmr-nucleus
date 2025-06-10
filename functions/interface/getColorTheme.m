function colors = getColorTheme(fig_tag,th)
%getColorTheme returns the colors of the selected color theme
%
% Syntax:
%       getColorTheme(th)
%
% Inputs:
%       fig_tag - tag of the calling figure ('INV' or 'MOD')
%       th - color theme ('standard', 'basic' or 'dark')
%
% Outputs:
%       colors - color definitions of the corresponding theme
%
% Example:
%       getColorTheme('INV','basic')
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

colors.theme = th;
%% switch depending on the calling figure
switch fig_tag
    case {'INV','FIXEDTIMEVIEW','PHASEVIEW','UNCERTVIEW','2DINV'}
        % chose selected theme
        switch th
            case 'standard'
                colors.BoxTitle = [0 0 0]; % black
                colors.BoxDAT = [222 184 135]./255; % burlywood
                colors.BoxINV = [189 183 107]./255; % darkkhaki
                colors.BoxPRC = [143 188 143]./255; % darkseagreen
                colors.BoxCPS = [100 149 237]./255; % cornflowerblue
                colors.BoxCBW = [216 112 147]./255; % palevioletred
                colors.TabSIG = [143 188 143]./255; % darkseagreen
                colors.TabDIST = [189 183 107]./255; % darkkhaki
                colors.listINV = [189 183 107]./255; % darkkhaki
                colors.RE = [0 114 189]./255; % blue
                colors.IM = [119 172 48]./255; % green
                colors.FIT = [217 83 25]./255; % red
                colors.editBG = [1 1 1]; % white
                colors.panelBG = [0.94 0.94 0.94]; % default grey
                colors.panelFG = [0 0 0]; % black
                colors.axisBG = [1 1 1]; % white
                colors.axisFG = [0.15 0.15 0.15]; % dark grey
                colors.axisL = [0.5 0.5 0.5]; % medium grey
                colors.tableBG = [1 1 1; 0.94 0.94 0.94]; % default white & grey
                colors.tableFG = [0 0 0]; % black
                
            case 'basic'
                colors.BoxTitle = [1 1 1]; % white
                colors.BoxDAT = [0.05 0.25 0.5]; % dark blue
                colors.BoxINV = [0.05 0.25 0.5]; % dark blue
                colors.BoxPRC = [0.05 0.25 0.5]; % dark blue
                colors.BoxCPS = [0.05 0.25 0.5]; % dark blue
                colors.BoxCBW = [0.05 0.25 0.5]; % dark blue
                colors.TabSIG = [0.05 0.25 0.5]; % dark blue
                colors.TabDIST = [0.05 0.25 0.5]; % dark blue
                colors.listINV = [0 164 0]./255; % green
                colors.RE = [0 0 255./255]; % blue
                colors.IM = [0 164 0]./255; % green
                colors.FIT = [255 0 0]./255; % red
                colors.editBG = [1 1 1]; % white
                colors.panelBG = [0.94 0.94 0.94]; % default grey
                colors.panelFG = [0 0 0]; % black
                colors.axisBG = [1 1 1]; % white
                colors.axisFG = [0.15 0.15 0.15]; % dark grey
                colors.axisL = [0.5 0.5 0.5]; % medium grey
                colors.tableBG = [1 1 1; 0.94 0.94 0.94]; % default white & grey
                colors.tableFG = [0 0 0]; % black
                
            case 'dark'
                colors.BoxTitle = [0 0 0]; % black
                colors.BoxDAT = [222 184 135]./255; % burlywood
                colors.BoxINV = [189 183 107]./255; % darkkhaki
                colors.BoxPRC = [143 188 143]./255; % darkseagreen
                colors.BoxCPS = [100 149 237]./255; % cornflowerblue
                colors.BoxCBW = [216 112 147]./255; % palevioletred
                colors.TabSIG = [143 188 143]./255; % darkseagreen
                colors.TabDIST = [189 183 107]./255; % darkkhaki
                colors.listINV = [189 183 107]./255; % darkkhaki
                colors.RE = [0 114 189]./255; % blue
                colors.IM = [119 172 48]./255; % green
                colors.FIT = [217 83 25]./255; % red
                colors.editBG = [0.1 0.1 0.1]; % very dark grey
                colors.panelBG = [0.2 0.2 0.2]; % black
                colors.panelFG = [1 1 1]; % white
                colors.axisBG = [0.1 0.1 0.1]; % very dark grey
                colors.axisFG = [1 1 1]; % white
                colors.axisL = [0.8 0.8 0.8]; % very light grey
                colors.tableBG = [0.1 0.1 0.1; 0.2 0.2 0.2]; % default white & grey
                colors.tableFG = [1 1 1]; % white
                
            case 'black'
                colors.BoxTitle = [1 1 1]; % white
                colors.BoxDAT = [0.35 0.35 0.35]; % grey
                colors.BoxINV = [0.35 0.35 0.35]; % grey
                colors.BoxPRC = [0.35 0.35 0.35]; % grey
                colors.BoxCPS = [0.35 0.35 0.35]; % grey
                colors.BoxCBW = [0.35 0.35 0.35]; % grey
                colors.TabSIG = [0.35 0.35 0.35]; % grey
                colors.TabDIST = [0.35 0.35 0.35]; % grey                
                colors.listINV = [189 183 107]./255; % darkkhaki
                colors.RE = [0 114 189]./255; % blue
                colors.IM = [119 172 48]./255; % green
                colors.FIT = [217 83 25]./255; % red
                colors.editBG = [0 0 0]; % very dark grey
                colors.panelBG = [0 0  0]; % black
                colors.panelFG = [1 1 1]; % white
                colors.axisBG = [0 0 0]; % very dark grey
                colors.axisFG = [1 1 1]; % white
                colors.axisL = [0.9 0.9 0.9]; % very light grey
                colors.tableBG = [0 0 0 ; 0.1 0.1 0.1]; % default white & grey
                colors.tableFG = [1 1 1]; % white
                
        end
        
    case {'MOD','2DMOD'}
        % chose selected theme
        switch th
            case 'standard'
                colors.BoxTitle = [0 0 0]; % black
                colors.GEO = [189 183 107]./255; % darkkhaki
                colors.NMR = [143 188 143]./255; % darkseagreen
                colors.CPS = [100 149 237]./255; % cornflowerblue
                
                colors.editBG = [1 1 1]; % white
                colors.panelBG = [0.94 0.94 0.94]; % default grey
                colors.panelFG = [0 0 0]; % black
                colors.axisBG = [1 1 1]; % white
                colors.axisFG = [0.15 0.15 0.15]; % dark grey
                colors.axisL = [0.3 0.3 0.3]; % medium grey
                colors.tableBG = [1 1 1; 0.94 0.94 0.94]; % default white & grey
                colors.tableFG = [0 0 0]; % black
                
            case 'basic'
                colors.BoxTitle = [1 1 1]; % white
                colors.GEO = [0.05 0.25 0.5]; % dark blue
                colors.NMR = [0.05 0.25 0.5]; % dark blue
                colors.CPS = [0.05 0.25 0.5]; % dark blue
                
                colors.editBG = [1 1 1]; % white
                colors.panelBG = [0.94 0.94 0.94]; % default grey
                colors.panelFG = [0 0 0]; % black
                colors.axisBG = [1 1 1]; % white
                colors.axisFG = [0.15 0.15 0.15]; % dark grey
                colors.axisL = [0.3 0.3 0.3]; % medium grey
                colors.tableBG = [1 1 1; 0.94 0.94 0.94]; % default white & grey
                colors.tableFG = [0 0 0]; % black
                
            case 'dark'
                colors.BoxTitle = [0 0 0]; % black
                colors.GEO = [189 183 107]./255; % darkkhaki
                colors.NMR = [143 188 143]./255; % darkseagreen
                colors.CPS = [100 149 237]./255; % cornflowerblue
                
                colors.editBG = [0.1 0.1 0.1]; % very dark grey
                colors.panelBG = [0.2 0.2 0.2]; % black
                colors.panelFG = [1 1 1]; % white
                colors.axisBG = [0.15 0.15 0.15]; % dark grey
                colors.axisFG = [1 1 1]; % white
                colors.axisL = [0.9 0.9 0.9]; % very light grey
                colors.tableBG = [0.1 0.1 0.1; 0.2 0.2 0.2]; % default white & grey
                colors.tableFG = [1 1 1]; % white
                
            case 'black'
                colors.BoxTitle = [1 1 1]; % white
                colors.GEO = [0.35 0.35 0.35]; % grey
                colors.NMR = [0.35 0.35 0.35]; % grey
                colors.CPS = [0.35 0.35 0.35]; % grey
                
                colors.editBG = [0 0 0]; % very dark grey
                colors.panelBG = [0 0 0]; % black
                colors.panelFG = [1 1 1]; % white
                colors.axisBG = [0 0 0]; % dark grey
                colors.axisFG = [1 1 1]; % white
                colors.axisL = [0.9 0.9 0.9]; % very light grey
                colors.tableBG = [0 0 0; 0.1 0.1 0.1]; % default white & grey
                colors.tableFG = [1 1 1]; % white
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