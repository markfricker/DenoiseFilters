function params = autoDenoiseParams(im, method, currentParams)
%AUTODENOSEPARAMS  Estimate good denoising parameters from image noise level.
%
%   params = autoDenoiseParams(im, method)
%   params = autoDenoiseParams(im, method, currentParams)
%
% DESCRIPTION
%   Estimates the noise standard deviation from the image and sets appropriate
%   denoising parameters for the requested method.  Fields not updated by this
%   function are copied from currentParams (or left absent if currentParams is
%   not supplied).
%
%   Supported methods with auto-estimation:
%     'gaussian'  – sets sigma (px) ≈ clamp(noiseSigma × 50, 0.5, 5)
%     'bilateral' – sets rangeSigma ≈ clamp(noiseSigma × 2.5, 0.02, 0.30)
%                   spatialSigma is set to 3 (structure scale, not noise-driven)
%     'nlmeans'   – sets degreeOfSmoothing ≈ clamp(noiseSigma × 1.5, 0.005, 0.20)
%
%   For other methods a warning is issued and currentParams is returned
%   unchanged.
%
% INPUTS
%   im           – 2-D grayscale image (uint8, uint16, or float [0,1]).
%   method       – string, denoise method name.
%   currentParams – (optional) struct of current parameter values to carry
%                   forward for fields not updated here.
%
% OUTPUT
%   params – parameter struct with updated fields for the method.
%
% See also: estimateNoiseLevel, gaussianFilter, bilateralFilter, nlmeansFilter

if nargin < 3 || isempty(currentParams), currentParams = struct(); end

params = currentParams;

noiseSigma = double(estimateNoiseLevel(im));
noiseSigma = max(noiseSigma, 1e-6);      % prevent degenerate zero case

switch method

    case 'gaussian'
        % Spatial sigma (pixels): heuristic — noise amplitude → spatial scale
        % noiseSigma 0.01 → sigma ~0.5 px; 0.05 → sigma ~2.5 px
        params.sigma = single(min(max(noiseSigma * 50, 0.5), 5));

    case 'bilateral'
        % Range sigma in same [0,1] units as image intensity
        params.spatialSigma = single(3);
        params.rangeSigma   = single(min(max(noiseSigma * 2.5, 0.02), 0.30));

    case 'nlmeans'
        % h parameter in same [0,1] units as image intensity
        params.degreeOfSmoothing = single(min(max(noiseSigma * 1.5, 0.005), 0.20));

    otherwise
        warning('autoDenoiseParams:noAuto', ...
            'No automatic parameter estimation for method ''%s''.', method);
end
end
