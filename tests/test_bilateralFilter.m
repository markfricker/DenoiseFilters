classdef test_bilateralFilter < matlab.unittest.TestCase
%TEST_BILATERALFILTER  Unit tests for bilateralFilter.
%
%   Run with:  runtests('test_bilateralFilter')

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = rand(20, 20, 'single');
            out = bilateralFilter(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(45, 60, 'single');
            out = bilateralFilter(im);
            tc.verifySize(out, [45, 60]);
        end

        function testUniformImagePreserved(tc)
            im  = 0.5 * ones(25, 25, 'single');
            out = bilateralFilter(im);
            tc.verifyEqual(out, im, 'AbsTol', single(1e-4));
        end

        function testEdgePreservedWithSmallRangeSigma(tc)
            % Hard step edge — small range sigma should preserve it
            im            = zeros(40, 40, 'single');
            im(:, 21:40)  = 1.0;
            p.spatialSigma = 5;
            p.rangeSigma   = 0.01;
            out = bilateralFilter(im, p);
            % Edge gradient should remain large
            gradOut = abs(diff(out(20,:)));
            tc.verifyGreaterThan(max(gradOut(:)), single(0.5));
        end

        function testLargeRangeSigmaApproachesGaussian(tc)
            % Very large range sigma → almost isotropic → more blurring
            rng(10);
            im = rand(40, 40, 'single');
            p1.spatialSigma = 3; p1.rangeSigma = 0.001;
            p2.spatialSigma = 3; p2.rangeSigma = 0.9;
            out1 = bilateralFilter(im, p1);
            out2 = bilateralFilter(im, p2);
            % Large range sigma → more smoothing → less variance
            tc.verifyLessThan(std(out2(:)), std(out1(:)));
        end

        function testOutputRangeClipped(tc)
            im  = rand(30, 30, 'single');
            out = bilateralFilter(im);
            tc.verifyGreaterThanOrEqual(min(out(:)), single(-1e-5));
            tc.verifyLessThanOrEqual(max(out(:)),    single(1+1e-5));
        end

    end
end
