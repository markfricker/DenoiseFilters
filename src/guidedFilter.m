function imOut = guidedFilter(im, params)
%GUIDEDFILTER  Self-guided filter with struct-based API.
%
%   imOut = guidedFilter(im)
%   imOut = guidedFilter(im, params)
%
% DESCRIPTION
%   Applies the guided image filter in self-guided mode (the input image
%   serves as its own guide).  Produces edge-preserving smoothing with O(N)
%   complexity.  Stronger edges are preserved while flat regions are smoothed.
%
%   Wraps MATLAB's imguidedfilter.  The neighbourhoodSize is enforced to be
%   an odd integer.
%
% PARAMETERS (fields of the params struct)
%   neighborhoodSize – size of the local window (px, odd integer) (default 5)
%   smoothing        – regularisation ε ∈ (0,1]                  (default 0.01)
%                      Small values → stronger edge preservation.
%                      Typical range: 1e-4 to 0.1.
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% See also: bilateralFilter, diffusionFilter, imguidedfilter

if nargin < 2, params = struct(); end
if ~isfield(params, 'neighborhoodSize'), params.neighborhoodSize = 5;    end
if ~isfield(params, 'smoothing'),        params.smoothing        = 0.01;  end

% Enforce odd neighbourhood size
ns = max(1, round(params.neighborhoodSize));
if mod(ns, 2) == 0, ns = ns + 1; end

eps   = max(1e-8, params.smoothing);
im_s  = im2single(im);
imOut = im2single(imguidedfilter(im_s, im_s, ...
    'NeighborhoodSize',  ns, ...
    'DegreeOfSmoothing', eps));
end
