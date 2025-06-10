function onMenuExtraZvector(src,~)
%onMenuExtraZvector creates a z-vector (e.g. for HELIOS series data in
%the CONAN lift)
%
% Syntax:
%       onMenuExtraZvector(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraZvector(src)
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
% Author: see AUTHORS.md
% email: see AUTHORS.md
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% get GUI handle and data
fig = ancestor(src,'figure','toplevel');
data = getappdata(fig,'data');

% check if there is any data at all
if isfield(data.import,'NMR')

    % how many signals
    N = numel(data.import.NMR.data);

    % ask the user for start point and z increment
    prompt = {'Enter start point:','Enter z-increment [mm]:'};
    dlgtitle = 'Z-vector Input';
    fieldsize = [1 30; 1 30];
    definput = {'0','10'};
    answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
    
    % retrieve answer
    z_start = str2double(answer{1});
    z_inc = str2double(answer{2});
    
    % create vector
    zslice = linspace(z_start,z_start+N*z_inc-z_inc,N);
    
    % save z-slice vector in dummy BAM field for ploting
    data.import.BAM.use_z = 1;
    data.import.BAM.zslice = zslice';
    data.import.BAM.z_unit = 'mm';

    % update the GUI data
    setappdata(fig,'data',data);
else
    helpdlg('Nothing to do because there is no data loaded!',...
        'onMenuExtraZvector: Load NMR data first.');

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