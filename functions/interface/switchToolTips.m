function switchToolTips(gui,onoff) %#ok<INUSL>
%switchToolTips switches GUI tooltips either "on" or "off"
%
% Syntax:
%       gui = switchToolTips(gui,onoff)
%
% Inputs:
%       gui - figure gui elements structure
%       onoff - 'on' or 'off'
%
% Outputs:
%       gui
%
% Example:
%       gui = switchToolTips(gui,'on')
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

%% list of handles that have tooltips
h = {'popup_handles','edit_handles','push_handles',...
    'listbox_handles','radio_handles'};

%% process all handles
switch lower(onoff)
    case 'on'
        for i = 1:numel(h)
            eval(['fnames = fieldnames(gui.',h{i},');']);
            for j = 1:numel(fnames)
                eval(['ud = get(gui.',h{i},'.',fnames{j},...
                    ',''UserData'');']);
                if isfield(ud,'Tooltipstr')
                    tstr = ud.Tooltipstr;
                    eval(['set(gui.',h{i},'.',fnames{j},...
                        ',''ToolTipString'',tstr);']);
                end
            end
        end
        
    case 'off'
        for i = 1:numel(h)
            eval(['fnames = fieldnames(gui.',h{i},');']);
            for j = 1:numel(fnames)
                eval(['ud = get(gui.',h{i},'.',fnames{j},...
                    ',''UserData'');']);
                if isfield(ud,'Tooltipstr')
                    tstr = ud.Tooltipstr;
                    eval(['set(gui.',h{i},'.',fnames{j},...
                        ',''ToolTipString'','''');']);
                end
            end
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