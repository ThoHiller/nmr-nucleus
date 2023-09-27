function onPopupInvstdTypeOptional(src,~)
%onPopupInvstdTypeOptional select regularization option for the standard
%inversion only if the inversion method is "NNLS" or "LU"; for the
%standard inversion with a X free number of exponents the popup menu allows
%to select the number of free exponents
%
% Syntax:
%       onPopupInvstdTypeOptional
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupInvstdTypeOptional(src,~)
%
% Other m-files required:
%       clearSingleAxis
%       NUCLEUSinv_updateInterface
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
fig  = findobj('Tag','INV');
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

% get value of the popup menu
value = get(src,'Value');
% get the inversion method
invtype = data.invstd.invtype;

% change settings accordingly
switch invtype
    case 'free'
        % # free relaxation times = value (1 to 5)
        data.invstd.freeDT = value;

        % if the FixedTimeView window is open update it
        if ~isempty(findobj('Tag','FIXEDTIMEVIEW'))
            % update GUI data
            setappdata(fig,'data',data);
            FixedTimeView(gui.menu.extra_fixedtime);
            data = getappdata(fig,'data');
        end
        
    case 'NNLS'
        switch data.info.ExpertMode
            case 'on'
                switch value % different regularization options/methods
                    case 1 % manual
                        data.invstd.regtype = 'manual';
                        data.invstd.lambda = 1;
                        % if there is an optimal lambda from the L-curve
                        % use it
                        if isfield(data,'results') && ...
                                isfield(data.results,'lcurve')
                                index = data.results.lcurve.index;
                                data.invstd.lambda = data.results.lcurve.lambda(index);
                        end
                        
                    case 2 % gcv_tikh
                        data.invstd.regtype = 'gcv_tikh';
                        data.invstd.lambda = 1;
                        
                    case 3 % gcv_trunc
                        data.invstd.regtype = 'gcv_trunc';
                        data.invstd.lambda = 1;
                        
                    case 4 % gcv_damp
                        data.invstd.regtype = 'gcv_damp';
                        data.invstd.lambda = 1;
                        
                    case 5 % discrep. principle
                        if data.results.nmrproc.noise == 0
                            helpdlg('Discrepancy Principle does not work with noise = 0','Change Regularization Method');
                            data.invstd.regtype = 'manual';
                            data.invstd.lambda = 1;
                        else
                            data.invstd.regtype = 'discrep';
                            data.invstd.lambda = 1;
                        end
                        
                    case 6 % l-curve
                        data.invstd.regtype  = 'lcurve';
                        lambdaFAK = 1;
                        if strcmp(data.process.gatetype,'log') || strcmp(data.process.gatetype,'lin')
                            lambdaFAK = 100;
                        end
                        data.invstd.lambdaR = data.invstd.lambdaRinit./lambdaFAK;
                        clearSingleAxis(gui.axes_handles.rtd);
                        clearSingleAxis(gui.axes_handles.psd);
                end
                
            case 'off'
                switch value % different regularization options/methods
                    case 1 % manual
                        data.invstd.regtype = 'manual';
                        lambdaFAK = 1;
                        if strcmp(data.process.gatetype,'log') || strcmp(data.process.gatetype,'lin')
                            lambdaFAK = 100;
                        end
                        data.invstd.lambda = 1/lambdaFAK;
                        % if there is an optimal lambda from the L-curve
                        % use it
                        if isfield(data,'results') && ...
                                isfield(data.results,'lcurve')
                                index = data.results.lcurve.index;
                                data.invstd.lambda = data.results.lcurve.lambda(index);
                        end                    
                    case 2 % l-curve
                        data.invstd.regtype  = 'lcurve';
                        lambdaFAK = 1;
                        if strcmp(data.process.gatetype,'log') || strcmp(data.process.gatetype,'lin')
                            lambdaFAK = 100;
                        end
                        data.invstd.lambdaR = data.invstd.lambdaRinit./lambdaFAK;
                        clearSingleAxis(gui.axes_handles.rtd);
                        clearSingleAxis(gui.axes_handles.psd);
                end
        end
        
    case 'LU'
        switch value % different regularization options/methods
            case 1 % manual
                data.invstd.regtype  = 'manual';
                data.invstd.lambda = 1;
                
            case 2 % automatic
                data.invstd.regtype  = 'auto';
                data.invstd.lambda = -1;
        end
        
    case 'MUMO'
        % # free distributions = value (1 to 4)
        data.invstd.freeDT = value;
end

% update GUI data
setappdata(fig,'data',data);
% update interface
NUCLEUSinv_updateInterface;

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