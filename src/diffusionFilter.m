function imOut = diffusionFilter(im, params)
%DIFFUSIONFILTER  Anisotropic (Perona-Malik) diffusion filter with struct API.
%
%   imOut = diffusionFilter(im)
%   imOut = diffusionFilter(im, params)
%
% DESCRIPTION
%   Applies anisotropic diffusion (Perona & Malik 1990) via MATLAB's
%   imdiffusefilt.  Diffusion is slowed or stopped at high-gradient locations
%   (edges) and proceeds more strongly in flat, noisy regions.  The number of
%   iterations and the gradient threshold control the trade-off between
%   smoothing and edge preservation.
%
% PARAMETERS (fields of the params struct)
%   numIterations     – number of diffusion iterations      (default 10)
%   gradientThreshold – edge-stopping threshold, same scale  (default 0.05)
%                       as image intensity gradients for a [0,1] image.
%                       Gradients exceeding this value suppress diffusion.
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% REFERENCE
%   Perona P. & Malik J. (1990) Scale-space and edge detection using
%   anisotropic diffusion. IEEE T-PAMI 12(7):629-639.
%
% See also: bilateralFilter, guidedFilter, imdiffusefilt
%
% NOTE on Connectivity
%   imdiffusefilt uses 'maximal' (8-connected, default) and 'minimal'
%   (4-connected) — NOT '4-connected'/'8-connected' strings.
%   'maximal' is the MATLAB default and gives smoother, more isotropic
%   diffusion; it is used here unconditionally.

if nargin < 2, params = struct(); end
if ~isfield(params, 'numIterations'),     params.numIterations     = 10;   end
if ~isfield(params, 'gradientThreshold'), params.gradientThreshold = 0.05; end

% Cast to double: imdiffusefilt validates NumIterations as a double integer
% and GradientThreshold as a double scalar internally.
nIter = double(max(1, round(double(params.numIterations))));
gThr  = double(max(1e-8, double(params.gradientThreshold)));

imOut = im2single(imdiffusefilt(im2single(im), ...
    'NumberOfIterations', nIter, ...
    'GradientThreshold',  gThr));
end
