function T = oblur(N,bandw);
%OBLUR  Create a block Toeplitz matrix that models our-of-focus deblurring.
%
% function T = oblur(N,bandw);
%
% The matrix T an N*N-by-N*N symmetric, block Toeplitz matrix that models
% out-of-foucs blurring of an N-by-N image, stored in sparse matrix format.
%
% The bandwidth, specified by the integer bandw, detemines the "size"
% of the deblurring, in the sense that bandw is the half-bandwidth of
% the matrix.  If bandw is not specified, bandw = 3 is used.

% Per Christian Hansen, IMM, 09/03/97.

% Initialization.
if (nargin < 2), bandw = 3; end
bandw = min(bandw,N);

% Construct T via Kronecker product.
T = spdiags(ones(N,2*bandw-1),[-bandw+1:bandw-1],N,N)/(2*bandw-1);
T = kron(T,T);
