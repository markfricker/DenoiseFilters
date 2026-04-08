function imOut = claheFilter(im, params)
%CLAHEFILTER  Contrast Limited Adaptive Histogram Equalisation (CLAHE).
%
%   imOut = claheFilter(im)
%   imOut = claheFilter(im, params)
%
% DESCRIPTION
%   Applies CLAHE (Zuiderveld 1994) via MATLAB's adapthisteq.  Divides the
%   image into non-overlapping tiles and performs histogram equalisation in
%   each, with a clip limit to prevent over-amplification of noise.
%   Bilinear interpolation at tile boundaries avoids blocking artefacts.
%
%   In the denoise pipeline, CLAHE is applied as a post-processing step after
%   the primary filter to improve local contrast in the denoised image.
%
% PARAMETERS (fields of the params struct)
%   numTiles  – number of tile divisions per dimension (default 8)
%               The image is divided into numTiles × numTiles tiles.
%   clipLimit – clip limit [0,1] (default 0.01)
%               Values near 0 suppress histogram redistribution (≈ no
%               equalisation); 1 = full equalisation with no clip.
%               Typical range: 0.005–0.05.
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float [0,1]).
%
% OUTPUT
%   imOut – contrast-enhanced image, single precision, same size as im.
%
% REFERENCE
%   Zuiderveld K. (1994) Contrast limited adaptive histogram equalization.
%   In: Graphics Gems IV, pp. 474-485.
%
% See also: adapthisteq

if nargin < 2, params = struct(); end
if ~isfield(params, 'numTiles'),  params.numTiles  = 8;    end
if ~isfield(params, 'clipLimit'), params.clipLimit = 0.01; end

% Cast to double: adapthisteq requires NumTiles as a double integer vector
% and ClipLimit as a double scalar.
nt    = double(max(1, round(double(params.numTiles))));
cl    = double(min(max(double(params.clipLimit), 0), 1));
imOut = im2single(adapthisteq(im2single(im), ...
    'NumTiles',     [nt, nt], ...
    'ClipLimit',    cl, ...
    'Distribution', 'uniform'));
end
