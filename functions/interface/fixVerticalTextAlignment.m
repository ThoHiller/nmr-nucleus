function fixVerticalTextAlignment(fig)
%fixVerticalTextAlignment fixes the vertical positioning of all text
%handles
%
% Syntax:
%       fixVerticalTextAlignment(fig)
%
% Inputs:
%       fig - GUI handle
%
% Outputs:
%       none
%
% Example:
%       fixVerticalTextAlignment(fig)
%
% Other m-files required:
%       findjobj.m
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

%% get GUI data
gui = getappdata(fig,'gui');

% loop over all text handles
fn = fieldnames(gui.text_handles);
for j1 = 1:numel(fn)
    jh = findjobj(gui.text_handles.(fn{j1}));
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
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