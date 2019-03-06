function onPopupInvstdType(src,~)
%onPopupInvstdType selects the inversion method for the standard inversion
%When Expert-Mode is off than the menu and possible options change
%accordingly
%
% Syntax:
%       onPopupInvstdType
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onPopupInvstdType(src,~)
%
% Other m-files required:
%       NUCLEUSinv_updateInterface
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
data = getappdata(fig,'data');
gui = getappdata(fig,'gui');

% get the value of the popup menu
value = get(src,'Value');

% change settings depending on expert mode and value
switch data.info.ExpertMode
    case 'on'        
        switch value
            case 1
                data.invstd.invtype = 'mono';
                data.invstd.regtype = 'none';
                data.invstd.lambda = 1;
                
            case 2
                data.invstd.invtype = 'free';
                data.invstd.regtype = 'none';
                data.invstd.lambda = 1;
                
            case 3
                data.invstd.invtype = 'NNLS';
                data.invstd.regtype = 'manual';
                data.invstd.lambda = 1;
                
            case 4
                data.invstd.invtype = 'ILA';
                data.invstd.regtype = 'auto';
                data.invstd.lambda = -1;
        end
                
    case 'off'
        switch value
            case 1
                data.invstd.invtype = 'mono';
                data.invstd.regtype = 'none';
                data.invstd.lambda = 1;
                
            case 2
                data.invstd.invtype = 'free';
                data.invstd.regtype = 'none';
                data.invstd.lambda = 1;
                
            case 3
                data.invstd.invtype = 'NNLS';
                % set LIAG defaults
                if isfield(data.import,'LIAG')
                    data.invstd.regtype = 'iterchi2';
                    data.invstd.lambda = 1;
                    data.invstd.lambdaR = [1e-5 100];
                else
                    data.invstd.regtype = 'manual';
                    data.invstd.lambda = 1;
                end
                % for multi-exponential inversion log-gating is used as default
                data.process.gatetype = 'log';    
        end
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