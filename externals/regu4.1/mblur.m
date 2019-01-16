function T = mblur(N,bandw,xy);
%MBLUR  Create a block Toeplitz matrix that models motion deblurring.
%
% function T = mblur(N,bandw,xy);
%
% The matrix T an N*N-by-N*N symmetric, block Toeplitz matrix that models
% blurring of an N-by-N image by a linear motion blur along the x- or y-axis.
% It is stored in sparse matrix format.
%
% The bandwidth, specified by the integer bandw, detemines the "length"
% of the deblurring, in the sense that bandw is the half-bandwidth of
% the matrix.  Hence, the total "length" of the deblurring is 2*bandw-1.
% If bandw is not specified, bandw = 3 is used.
%
% The direction of the motion blurring is determined by the third
% argument being either 'x' og 'y'.  The default is 'y',

% Per Christian Hansen, IMM, 09/03/97.

% Initialization.
if (nargin < 2), bandw = 3; end
bandw = min(bandw,N);
if (nargin < 3), xy = 'y'; end

% Construct T via Kronecker product.
T = spdiags(ones(N,2*bandw-1),[-bandw+1:bandw-1],N,N)/(2*bandw-1);
if (xy=='x')
  T = kron(T,speye(N));
elseif (xy=='y')
  T = kron(speye(N),T);
else
  error('Illegal third argument')
end
