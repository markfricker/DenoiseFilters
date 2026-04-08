function imOut = meanFilter(im, params)
%MEANFILTER  Box (mean) filter with struct-based API.
%
%   imOut = meanFilter(im)
%   imOut = meanFilter(im, params)
%
% DESCRIPTION
%   Applies a uniform averaging (box) filter to reduce noise by replacing
%   each pixel with the mean of its rectangular neighbourhood.  Simple and
%   fast but does not preserve edges.
%
% PARAMETERS (fields of the params struct)
%   kernelSize – odd integer side length of the square kernel (px) (default 3)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% See also: medianFilter, gaussianFilter, medfilt2, imfilter

if nargin < 2, params = struct(); end
if ~isfield(params, 'kernelSize'), params.kernelSize = 3; end

% Cast to double: fspecial('average', HSIZE) requires HSIZE to be double.
k = double(max(1, round(double(params.kernelSize))));

h     = fspecial('average', [k, k]);
imOut = im2single(imfilter(im2single(im), h, 'replicate'));
end
