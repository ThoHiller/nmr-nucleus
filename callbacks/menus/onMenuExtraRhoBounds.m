function onMenuExtraRhoBounds(src,~)
%onMenuExtraRhoBounds sets inversion bounds for the surface relaxivity
%
% Syntax:
%       onMenuExtraRhoBounds(src,~)
%
% Inputs:
%       src - handle of the calling object
%
% Outputs:
%       none
%
% Example:
%       onMenuExtraRhoBounds(src)
%
% Other m-files required:
%       changeColorTheme
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
fig = ancestor(src,'figure','toplevel');
fig_tag = get(fig,'Tag');
gui = getappdata(fig,'gui');
data = getappdata(fig,'data');

bounds = data.invjoint.rhobounds;

prompt = {'lower boundary [µm/s]:','upper boundary [µm/s]:'};
title = 'Surface relaxivity bounds';
dims = [1 50];
definput = {sprintf('%4.3f',bounds(1)),sprintf('%4.3f',bounds(2))};
answer = inputdlg(prompt,title,dims,definput);

if ~isempty(answer)
    data.invjoint.rhobounds(1) = str2double(answer{1});
    data.invjoint.rhobounds(2) = str2double(answer{2});
    setappdata(fig,'data',data);
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