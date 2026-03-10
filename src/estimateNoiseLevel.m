function sigma = estimateNoiseLevel(im)
%ESTIMATENOISELEVEL  Estimate Gaussian noise standard deviation.
%
%   sigma = estimateNoiseLevel(im)
%
% DESCRIPTION
%   Uses the Immerkær (1996) Laplacian-based method to estimate the standard
%   deviation of additive Gaussian noise in a 2-D image.  The method is fast,
%   parameter-free, and robust to moderate spatial structure at low-to-
%   moderate SNR.
%
%   The estimate is returned on the same normalised [0,1] intensity scale as
%   the input image, so it can be used directly as:
%     • bilateral rangeSigma: rangeSigma = 2–3 × sigma
%     • non-local means h:    h           = 1–2 × sigma
%     • Gaussian sigma_px:    sigma_px    = max(0.5, sigma * 50)  (heuristic)
%
% INPUT
%   im – 2-D grayscale image (uint8, uint16, or float).
%        Must contain at least 4 × 4 pixels.
%
% OUTPUT
%   sigma – estimated noise standard deviation (single, ≥ 0), normalised
%           to the [0,1] intensity range.
%
% REFERENCE
%   Immerkær J. (1996) Fast noise variance estimation.
%   CVIU 64(2):300–302.
%
% See also: autoDenoiseParams

im = im2single(im);
[M, N] = size(im);
if M < 4 || N < 4
    sigma = single(0);
    return
end

% 3×3 Laplacian kernel (Immerkær 1996, eq. 3)
W = [1, -2, 1; -2, 4, -2; 1, -2, 1];

sigma = single( ...
    sqrt(pi/2) / (6 * double(M-2) * double(N-2)) * ...
    sum(abs(conv2(double(im), W, 'valid')), 'all') ...
    );
sigma = max(sigma, single(0));
end
