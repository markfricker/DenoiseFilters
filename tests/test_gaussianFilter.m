classdef test_gaussianFilter < matlab.unittest.TestCase
%TEST_GAUSSIANFILTER  Unit tests for gaussianFilter.
%
%   Run with:  runtests('test_gaussianFilter')

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = uint8(200 * ones(20, 20));
            out = gaussianFilter(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(70, 50, 'single');
            out = gaussianFilter(im);
            tc.verifySize(out, [70, 50]);
        end

        function testUniformImagePreserved(tc)
            im  = 0.7 * ones(30, 30, 'single');
            out = gaussianFilter(im);
            tc.verifyEqual(out, im, 'AbsTol', single(1e-5));
        end

        function testSmoothsNoise(tc)
            rng(1);
            im  = 0.5 * ones(64, 64, 'single') + 0.1 * randn(64, 64, 'single');
            im  = max(min(im, 1), 0);
            p.sigma = 2.0;
            out = gaussianFilter(im, p);
            tc.verifyLessThan(std(out(:)), std(im(:)));
        end

        function testLargerSigmaMoreSmoothing(tc)
            rng(2);
            im  = rand(50, 50, 'single');
            p1.sigma = 1.0;  out1 = gaussianFilter(im, p1);
            p2.sigma = 3.0;  out2 = gaussianFilter(im, p2);
            % Larger sigma → lower variance output
            tc.verifyLessThan(std(out2(:)), std(out1(:)));
        end

        function testDefaultSigmaIs1p5(tc)
            im    = rand(30, 30, 'single');
            out1  = gaussianFilter(im);
            p.sigma = 1.5;
            out2  = gaussianFilter(im, p);
            tc.verifyEqual(out1, out2, 'AbsTol', single(1e-6));
        end

        function testTinyPositiveSigmaClampedSafely(tc)
            % Very small sigma must not error (clamp prevents sigma = 0)
            im  = rand(20, 20, 'single');
            p.sigma = 0.001;
            out = gaussianFilter(im, p);
            tc.verifySize(out, [20, 20]);
        end

    end
end
