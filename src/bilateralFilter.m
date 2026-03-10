function imOut = bilateralFilter(im, params)
%BILATERALFILTER  Bilateral filter with struct-based API.
%
%   imOut = bilateralFilter(im)
%   imOut = bilateralFilter(im, params)
%
% DESCRIPTION
%   Applies a bilateral filter: a spatially weighted average where pixels with
%   similar intensity to the centre pixel receive higher weight.  Preserves
%   edges and step-discontinuities while smoothing flat regions.
%
%   Wraps MATLAB's imbilatfilt.  The intensity-domain sigma (rangeSigma) is
%   squared internally to produce the DegreeOfSmoothing variance parameter
%   expected by imbilatfilt.
%
% PARAMETERS (fields of the params struct)
%   spatialSigma – spatial Gaussian sigma (px)      (default 3)
%   rangeSigma   – intensity range sigma [0,1]      (default 0.1)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float), intensity in [0,1].
%
% OUTPUT
%   imOut – filtered image, single precision, same size as im.
%
% See also: guidedFilter, diffusionFilter, imbilatfilt

if nargin < 2, params = struct(); end
if ~isfield(params, 'spatialSigma'), params.spatialSigma = 3;   end
if ~isfield(params, 'rangeSigma'),   params.rangeSigma   = 0.1; end

dos   = max(1e-8, params.rangeSigma)^2;   % variance for imbilatfilt
imOut = im2single(imbilatfilt(im2single(im), dos, params.spatialSigma, ...
    'Padding', 'replicate'));
end
