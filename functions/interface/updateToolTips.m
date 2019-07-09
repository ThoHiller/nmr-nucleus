function updateToolTips
%updateToolTips updates tool tip entries dependent on the chosen settings
%(ExpertMode, LSQ-solver, ...)
%
% Syntax:
%       updateToolTips
%
% Inputs:
%       none
%
% Outputs:
%       none
%
% Example:
%       updateToolTips
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

%% process tool tips
switch data.info.ExpertMode
    case 'on'
        switch data.info.solver
            case 'lsqlin'
                inv_tstr = ['<HTML>Choose between different inversion (fitting) methods.<br><br>',...
                    '<u>Available options:</u><br>',...
                    '<b>Mono exp.</b> Mono-exponential fitting.<br>',...
                    '<b>Several free exp. (2-5)</b> Multi-exponential fitting with up to 5 free relaxation times.<br>',...
                    '<b>Multi exp. (LSQ)</b> Multi-exponential fitting with Optimization Toolbox.<br>',...
                    '<b>Multi exp. (ILA)</b> Multi-exponential fitting using an Inverse Laplace transform.<br><br>',...
                    'Depending on the chosen method there are additional options available.<br><br>',...
                    '<u>Default value:</u><br>',...
                    '<b>Multi exp. (LSQ)</b><br>'];
                reg_tstr = ['<HTML>Choose additional options depending on the chosen inversion (fitting) method.<br><br>',...
                    '<u>Available options:</u><br>',...
                    '<font color="red">Mono exp.:<br>',...
                    '<font color="black"><b>none</b><br>',...
                    '<font color="red">Several free exp. (2-5):<br>',...
                    '<font color="black"><b>1-5</b> choose how many free relaxation times to use.<br>',...
                    '<font color="red">Multi exp. (LSQ):<br>',...
                    '<font color="black"><b>Manual</b> Manual regularization.<br>',...
                    '<font color="black"><b>IterChi2</b> Find Chi2=1 iteratively.<br>',...
                    '<font color="black"><b>Tikhonov (GCV)</b> Tikhonov regularization (SVD-Toolbox).<br>',...
                    '<font color="black"><b>TSVD (GCV)</b> Regularization via Truncated SVD (SVD-Toolbox).<br>',...
                    '<font color="black"><b>DSVD (GCV)</b> Regularization via Damped SVD (SVD-Toolbox).<br>',...
                    '<font color="black"><b>Discrep.</b> Regularization according to discrepancy principle (SVD-Toolbox).<br>',...
                    '<font color="black"><b>L-curve</b> Perform the L-curve test to find optimal regularization parameter lambda.<br>',...
                    '<font color="red">Multi exp. (ILA):<br>',...
                    '<font color="black"><b>Manual</b> Manual regularization.<br>',...
                    '<font color="black"><b>Automatic</b> Automatic regularization.<br><br>',...
                    '<u>Default value:</u><br>',...
                    '<b>Manual</b><br>'];
            case 'lsqnonneg'
                inv_tstr = ['<HTML>Choose between different inversion (fitting) methods.<br><br>',...
                    '<u>Available options:</u><br>',...
                    '<b>Mono exp.</b> Mono-exponential fitting.<br>',...
                    '<b>Several free exp. (2-5)</b> Multi-exponential fitting with up to 5 free relaxation times.<br>',...
                    '<b>Multi exp. (LSQ)</b> Multi-exponential fitting with Non Negative Least Squares (LSQNONNEG).<br>',...
                    '<b>Multi exp. (ILA)</b> Multi-exponential fitting using an Inverse Laplace transform.<br><br>',...
                    'Depending on the chosen method there are additional options available.<br><br>',...
                    '<u>Default value:</u><br>',...
                    '<b>Multi exp. (LSQ)</b><br>'];
                reg_tstr = ['<HTML>Choose additional options depending on the chosen inversion (fitting) method.<br><br>',...
                    '<u>Available options:</u><br>',...
                    '<font color="red">Mono exp.:<br>',...
                    '<font color="black"><b>none</b><br>',...
                    '<font color="red">Several free exp. (2-5):<br>',...
                    '<font color="black"><b>1-5</b> choose how many free relaxation times to use.<br>',...
                    '<font color="red">Multi exp. (LSQ):<br>',...
                    '<font color="black"><b>Manual</b> Manual regularization.<br>',...
                    '<font color="black"><b>IterChi2</b> Find Chi2=1 iteratively.<br>',...
                    '<font color="black"><b>Tikhonov (GCV)</b> Tikhonov regularization (SVD-Toolbox).<br>',...
                    '<font color="black"><b>TSVD (GCV)</b> Regularization via Truncated SVD (SVD-Toolbox).<br>',...
                    '<font color="black"><b>DSVD (GCV)</b> Regularization via Damped SVD (SVD-Toolbox).<br>',...
                    '<font color="black"><b>Discrep.</b> Regularization according to discrepancy principle (SVD-Toolbox).<br>',...
                    '<font color="black"><b>L-curve</b> Perform the L-curve test to find optimal regularization parameter lambda.<br>',...
                    '<font color="red">Multi exp. (ILA):<br>',...
                    '<font color="black"><b>Manual</b> Manual regularization.<br>',...
                    '<font color="black"><b>Automatic</b> Automatic regularization.<br><br>',...
                    '<u>Default value:</u><br>',...
                    '<b>Manual</b><br>'];
        end        
    case 'off'
        inv_tstr = ['<HTML>Choose between different inversion (fitting) methods.<br><br>',...
            '<u>Available options:</u><br>',...
            '<b>Mono exp.</b> Mono-exponential fitting.<br>',...
            '<b>Several free exp. (2-5).</b> Multi-exponential fitting with up to 5 free relaxation times.<br>',...
            '<b>Multi exp. (LSQ)</b> Multi-exponential fitting with Non Negative Least Squares (LSQNONNEG).<br><br>',...
            'Depending on the chosen method there are additional options available.<br><br>',...
            '<u>Default value:</u><br>',...
            '<b>Multi exp. (LSQ)</b><br>'];
        reg_tstr = ['<HTML>Choose additional options depending on the chosen inversion (fitting) method.<br><br>',...
            '<u>Available options:</u><br>',...
            '<font color="red">Mono exp.:<br>',...
            '<font color="black"><b>none</b><br>',...
            '<font color="red">Several free exp. (2-5):<br>',...
            '<font color="black"><b>1-5</b> choose how many free relaxation times to use.<br>',...
            '<font color="red">Multi exp. (LSQ):<br>',...
            '<font color="black"><b>Manual</b> Manual regularization.<br>',...
            '<font color="black"><b>IterChi2</b> Find Chi2=1 iteratively.<br>',...
            '<font color="black"><b>L-curve</b> Perform the L-curve test to find optimal regularization parameter lambda.<br><br>',...
            '<u>Default value:</u><br>',...
            '<b>Manual</b><br>'];
end
% update the tool tips
set(gui.popup_handles.invstd_InvType,'UserData',struct('Tooltipstr',inv_tstr));
set(gui.popup_handles.invstd_InvTypeOpt,'UserData',struct('Tooltipstr',reg_tstr));

% update GUI data
setappdata(fig,'gui',gui);
setappdata(fig,'data',data);
% if tool tips are activated they need to be updated on-the-fly
switch data.info.ToolTips
    case 'on'
        onMenuExtraShow(gui.menu.extra_settings_tooltips_on);
    otherwise
        % nothing to do
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2019 Thomas Hiller
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