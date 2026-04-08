function imOut = gaussianFilter(im, params)
%GAUSSIANFILTER  Gaussian smoothing filter with struct-based API.
%
%   imOut = gaussianFilter(im)
%   imOut = gaussianFilter(im, params)
%
% DESCRIPTION
%   Applies isotropic Gaussian smoothing.  Reduces Gaussian noise effectively
%   at the cost of some edge blurring.  The degree of smoothing is controlled
%   by sigma (standard deviation of the Gaussian in pixels).
%
% PARAMETERS (fields of the params struct)
%   sigma – standard deviation of the Gaussian kernel (px) (default 1.5)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% See also: meanFilter, medianFilter, imgaussfilt

if nargin < 2, params = struct(); end
if ~isfield(params, 'sigma'), params.sigma = 1.5; end

% Cast to double: imgaussfilt builds a Gaussian kernel via fspecial, which
% requires a double sigma argument in all MATLAB versions.
sigma = double(max(1e-3, double(params.sigma)));
imOut = im2single(imgaussfilt(im2single(im), sigma, 'Padding', 'replicate'));
end
