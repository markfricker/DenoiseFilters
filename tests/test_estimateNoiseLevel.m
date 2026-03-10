classdef test_estimateNoiseLevel < matlab.unittest.TestCase
%TEST_ESTIMATENOISELEVEL  Unit tests for estimateNoiseLevel.
%
%   Run with:  runtests('test_estimateNoiseLevel')

    methods (Test)

        function testOutputIsSingleScalar(tc)
            im  = rand(50, 50, 'single');
            sig = estimateNoiseLevel(im);
            tc.verifyClass(sig, 'single');
            tc.verifySize(sig, [1, 1]);
        end

        function testOutputNonNegative(tc)
            im  = rand(50, 50, 'single');
            sig = estimateNoiseLevel(im);
            tc.verifyGreaterThanOrEqual(sig, single(0));
        end

        function testFlatImageGivesNearZero(tc)
            im  = 0.5 * ones(50, 50, 'single');
            sig = estimateNoiseLevel(im);
            % Perfectly flat image: no gradient noise
            tc.verifyLessThan(sig, single(1e-5));
        end

        function testNoisyImageLargerThanFlat(tc)
            rng(99);
            imFlat  = 0.5 * ones(100, 100, 'single');
            imNoisy = imFlat + 0.05 * randn(100, 100, 'single');
            sigFlat  = estimateNoiseLevel(imFlat);
            sigNoisy = estimateNoiseLevel(imNoisy);
            tc.verifyGreaterThan(sigNoisy, sigFlat);
        end

        function testMonotonicallyIncreasingWithNoise(tc)
            rng(7);
            base = 0.5 * ones(100, 100, 'single');
            levels = [0.01, 0.03, 0.05, 0.10];
            sigs   = zeros(1, numel(levels), 'single');
            for k = 1:numel(levels)
                im      = base + single(levels(k)) * randn(100, 100, 'single');
                sigs(k) = estimateNoiseLevel(im);
            end
            % Estimated noise should increase monotonically
            tc.verifyTrue(all(diff(sigs) > 0), ...
                'Expected monotonically increasing noise estimates.');
        end

        function testUint8InputAccepted(tc)
            im  = uint8(128 * ones(30, 30));
            tc.verifyWarningFree(@() estimateNoiseLevel(im));
        end

        function testSmallImageReturnsSafely(tc)
            % Images smaller than 4×4 return 0 without error
            im  = rand(3, 3, 'single');
            sig = estimateNoiseLevel(im);
            tc.verifyEqual(sig, single(0));
        end

    end
end
