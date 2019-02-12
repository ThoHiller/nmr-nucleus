function x = getStudentInvCDF(p,dof)
%getStudentInvCDF calculates the inverse of Student's t CDF using the
%degrees of freedom in 'dof' for the corresponding probabilities in 'p'.
%The code is adapted from the 'tinv' routine of the Mathwoks 'Statistical
%Toolbox' and 'Numerical Recipes 3rd ed.' It is only working up to
%dof=1000 and only accepts scalar values.
%
% Syntax:
%       getStudentInvCDF(p,dof)
%
% Inputs:
%       p   - probability (scalar value)
%       dof - degrees of freedom (scalar value)
%
% Outputs:
%       x - inverse of Student's t CDF (scalar value)
%
% Example:
%       [x] = getStudentInvCDF(p,dof)
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
% See also:
% Author: Thomas Hiller
% email: thomas.hiller[at]leibniz-liag.de
% License: MIT License (at end)

%------------- BEGIN CODE --------------

%% check inputs and calculate x
if numel(p)>1 || numel(dof) > 1
    error('Check that ''p'' and ''dof'' are scalar values.');
end
if (p <= 0 || p >= 1) || (dof < 1 || dof > 1000)
    error('Check that ''p'' ]0,1[ and ''dof'' [1,1000] are within the bounds.');    
else    
    % For DOF < 1000 use betaincinv
    if dof > 1
        q = p - .5;        
        % for z close to 1, compute 1-z directly to avoid roundoff
        % see help betaincinv
        if (abs(q) < .25)            
            oneminusz = betaincinv(2.*abs(q),0.5,dof/2,'lower');
            z = 1 - oneminusz;
        else
            z = betaincinv(2.*abs(q),dof/2,0.5,'upper');
            oneminusz = 1 - z;
        end
        x = sign(q) .* sqrt(dof .* (oneminusz./z));
    else
        % DOF = 1 Cauchy distribution
        x = tan(pi * (p - 0.5));        
    end    
end

return

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