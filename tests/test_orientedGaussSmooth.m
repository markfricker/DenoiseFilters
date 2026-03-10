classdef test_orientedGaussSmooth < matlab.unittest.TestCase
%TEST_ORIENTEDGAUSSSMOOTH  Unit tests for orientedGaussSmooth.
%
%   Run with:  runtests('test_orientedGaussSmooth')

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = rand(30, 30, 'single');
            out = orientedGaussSmooth(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(60, 40, 'single');
            out = orientedGaussSmooth(im);
            tc.verifySize(out, [60, 40]);
        end

        function testDefaultParamsReturnFiniteValues(tc)
            im  = rand(50, 50, 'single');
            out = orientedGaussSmooth(im);
            tc.verifyTrue(all(isfinite(out(:))), 'Output contains non-finite values.');
        end

        function testUniformImagePreserved(tc)
            % In a flat region (C = 0 everywhere) the filter blends
            % isotropically and a uniform image must remain uniform.
            im  = 0.6 * ones(40, 40, 'single');
            out = orientedGaussSmooth(im);
            tc.verifyEqual(out, im, 'AbsTol', single(1e-4));
        end

        function testSmoothsNoise(tc)
            rng(3);
            im  = 0.5 * ones(80, 80, 'single') + 0.05 * randn(80, 80, 'single');
            im  = max(0, min(1, im));
            out = orientedGaussSmooth(im);
            tc.verifyLessThan(std(out(:)), std(im(:)));
        end

        function testSigmaAlongMustBePositive(tc)
            im    = rand(20, 20, 'single');
            p     = struct('sigmaAlong', -1, 'sigmaAcross', 1.5);
            tc.verifyError(@() orientedGaussSmooth(im, p), 'MATLAB:error');
        end

        function testWarningWhenAlongLessThanAcross(tc)
            im = rand(30, 30, 'single');
            p  = struct('sigmaAlong', 1.0, 'sigmaAcross', 2.0, 'orientations', 4);
            tc.verifyWarning(@() orientedGaussSmooth(im, p), ...
                'orientedGaussSmooth:sigmaOrder');
        end

        function testFibrePreservation(tc)
            % Synthetic horizontal fibre image: smoothing along fibres should
            % preserve cross-fibre contrast better than isotropic Gaussian.
            im = single(repmat(sin(linspace(0, 2*pi, 60)).^2, 60, 1));
            im = im + 0.02 * randn(size(im), 'single');

            % Along = horizontal (theta~0), sigmaAlong large, sigmaAcross small
            p.sigmaAlong   = 5;
            p.sigmaAcross  = 1;
            p.orientations = 8;
            p.sigmaGrad    = 1.5;
            p.sigmaInt     = 3;

            outOG    = orientedGaussSmooth(im, p);
            outIso.sigma = 2;   outGauss = gaussianFilter(im, outIso);

            % Variance across columns (cross-fibre) should be higher for OG
            varOG    = var(outOG(:));
            varGauss = var(outGauss(:));
            tc.verifyGreaterThan(varOG, varGauss * 0.9, ...
                'orientedGauss should preserve more cross-fibre contrast than isotropic Gaussian.');
        end

        function test3DInputThrowsError(tc)
            im = rand(20, 20, 3, 'single');
            tc.verifyError(@() orientedGaussSmooth(im), 'MATLAB:error');
        end

    end
end
