function [s_rot,alpha] = rotateT2phase(s)
%rotateT2phase rotateT2phase rotates the complex NMR T2 signal so that the imaginary
%part is zero.
%
% Syntax:
%       [s_rot,alpha] = rotateT2phase(signal)
%
% Inputs:
%       s - NMR signal vector (has to be complex!)
%
% Outputs:
%       s_rot - rotated NMR signal vector (complex)
%       alpha - rotation phase angle in [rad] (optional)
%
% Example:
%       [signal_rot,~] = rotateT2phase(signal)
%
% Other m-files required:
%       none
%
% Subfunctions:
%       fun1 - minimization function
%
% MAT-files required:
%       none
%
% See also: NUCLEUSinv
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% only proceed if signal is complex
if ~isreal(s)
    % fminsearch options
    options = optimset('MaxFunEvals',100,'MaxIter',100,'TolFun',1e-6,'TolX',1e-6);
    % let fminsearch minimize fun1
    [alpha,~,~,~] = fminsearch(@(alpha) fun1(alpha,s,'zero'),pi/18,options);
    
    % s_rot is the rotated signal
    s_rot = s .* exp(1i*alpha);
    
    % if the real part is negative multiply everything by -1
    % NOTE: maybe this is fishy!!!
    if real(s_rot(1)) < 0
        s_rot = -1.*s_rot;
    end
else
    % do nothing
    s_rot = s;
    disp('Cannot ROTATE signal because it is not complex! rotateT2phase: Data is not complex.');
end

return

% minimization function
function sse = fun1(alpha,s,method)
% Inputs:
%       alpha - rotation phase angle in [rad]
%       s - NMR signal vector (has to be complex!)
%       method - "zero" or "minsd"
%
% Outputs:
%       sse - sum of squared residuals ("zero") or standard deviation ("minsd")

s = s(:);
switch method
    case 'zero'
        % make a vector of zeros
        t0 = zeros(size(s,1),1);
        t0 = t0(:);
        % s1 is the rotated signal
        s_rot = s .* exp(1i*alpha);        
        % check if the imaginary part is as close as possible to zero
        residual = t0-imag(s_rot);
        % sse = sum(residual.^2);
%         end1 = min([20000 numel(residual)]);
        end1 = numel(residual);
        % sum of squared residuals should be minimized
        sse = sum(residual(1:end1).^2);
    case 'minsd'
        % s_rot is the rotated signal
        s_rot = s .* exp(1i*alpha);
        % standard deviation of the imaginary part should be minimized
        sse = std(imag(s_rot));
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