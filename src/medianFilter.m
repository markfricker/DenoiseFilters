function imOut = medianFilter(im, params)
%MEDIANFILTER  Median filter with struct-based API.
%
%   imOut = medianFilter(im)
%   imOut = medianFilter(im, params)
%
% DESCRIPTION
%   Applies a 2-D median filter.  Excellent at removing impulse (salt-and-
%   pepper) noise while preserving edges better than linear filters.
%
% PARAMETERS (fields of the params struct)
%   kernelSize – side length of the square median neighbourhood (px) (default 3)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% See also: meanFilter, gaussianFilter, medfilt2

if nargin < 2, params = struct(); end
if ~isfield(params, 'kernelSize'), params.kernelSize = 3; end

k     = max(1, round(params.kernelSize));
imOut = im2single(medfilt2(im2single(im), [k, k], 'symmetric'));
end
