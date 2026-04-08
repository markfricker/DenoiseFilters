function imOut = nlmeansFilter(im, params)
%NLMEANSFILTER  Non-local means (NLM) filter with struct-based API.
%
%   imOut = nlmeansFilter(im)
%   imOut = nlmeansFilter(im, params)
%
% DESCRIPTION
%   Applies non-local means denoising (Buades et al. 2005) via MATLAB's
%   imnlmfilt.  Each pixel is restored by computing a weighted average over
%   all pixels whose surrounding patch is similar to the target patch.
%   Preserves repeated textures and fine structures at the cost of high
%   computational complexity.
%
%   Both SearchWindowSize and ComparisonWindowSize are enforced to odd values.
%   ComparisonWindowSize is clamped to be smaller than SearchWindowSize.
%
% PARAMETERS (fields of the params struct)
%   degreeOfSmoothing   – filtering parameter h, same units as image [0,1]
%                         (default 0.02; ≈ noise std for good denoising)
%   searchWindowSize    – search neighbourhood (px, odd int)  (default 21)
%   comparisonWindowSize – patch size (px, odd int)           (default 7)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float), intensity in [0,1].
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% REFERENCE
%   Buades A., Coll B. & Morel J.-M. (2005) A non-local algorithm for image
%   denoising. CVPR 2005, vol. 2, pp. 60-65.
%
% See also: gaussianFilter, bilateralFilter, imnlmfilt

if nargin < 2, params = struct(); end
if ~isfield(params, 'degreeOfSmoothing'),    params.degreeOfSmoothing    = 0.02; end
if ~isfield(params, 'searchWindowSize'),     params.searchWindowSize     = 21;   end
if ~isfield(params, 'comparisonWindowSize'), params.comparisonWindowSize = 7;    end

% Enforce odd sizes and cast to double: imnlmfilt passes window sizes to
% internal imfilter-based operations that require double scalar arguments.
sw = double(max(3, round(double(params.searchWindowSize))));
if mod(sw, 2) == 0, sw = sw + 1; end

cw = double(max(3, round(double(params.comparisonWindowSize))));
if mod(cw, 2) == 0, cw = cw + 1; end

% Comparison window must be strictly smaller than search window
cw = min(cw, sw - 2);
cw = max(cw, 3);

h     = double(max(1e-8, double(params.degreeOfSmoothing)));
imOut = im2single(imnlmfilt(im2single(im), ...
    'DegreeOfSmoothing',   h, ...
    'SearchWindowSize',    sw, ...
    'ComparisonWindowSize', cw));
end
