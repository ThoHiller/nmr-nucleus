function data = removeCalculationFields(data,type)
%removeCalculationFields deletes corresponding fields from NUCLEUSmod
%data struct
%
% Syntax:
%       data = removeCalculationFields(data,type)
%
% Inputs:
%       data - GUI data struct
%       type - switch to decide what should be removed ('cps' or 'nmr')
%
% Outputs:
%       data
%
% Example:
%       data = removeCalculationFields(data,type)
%
% Other m-files required:
%       clearSingleAxis
%
% Subfunctions:
%       none
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv, NUCLEUSmod
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% switch depending on type
switch type
    case 'cps'
        % if results exists delete all available data
        if isfield(data,'results')
            if isfield(data.results,'SAT')
                data.results = rmfield(data.results,'SAT');
            end
            if isfield(data.results,'constants')
                data.results = rmfield(data.results,'constants');
            end
        end
        
    case 'nmr'
        % if results exists delete all available data
        if isfield(data,'results')
            if isfield(data.results,'NMR')
                data.results = rmfield(data.results,'NMR');
            end
        end
end

return

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