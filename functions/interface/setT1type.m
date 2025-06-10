function setT1type(id,T1type)
%clearInversion removes inversion results from the internal data structure
%
% Syntax:
%       setT1type
%
% Inputs:
%       id - index of the calling NMR signal in the file list
%       T1type - string: "SR" or "IR"
%
% Outputs:
%       none
%
% Example:
%       setT1type(1,'SR')
%
% Other m-files required:
%       None
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
fig = findobj('Tag','INV');
data = getappdata(fig,'data');
INVdata = getappdata(fig,'INVdata');

if isnumeric(id)
    
    if ~isempty(INVdata) && ~isempty(INVdata{id})
        clearInversion(id);
    end

    switch T1type
        case "SR"
            data.import.NMR.data{id}.T1IRfac = 1;
            data.results.nmrproc.T1IRfac = 1;
        case "IR"
            data.import.NMR.data{id}.T1IRfac = 2;
            data.results.nmrproc.T1IRfac = 2;
    end
     
    % update GUI
    setappdata(fig,'data',data);
end

end

%------------- END OF CODE --------------

%% License:
% MIT License
%
% Copyright (c) 2025 Thomas Hiller
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