classdef test_claheFilter < matlab.unittest.TestCase
%TEST_CLAHEFILTER  Unit tests for claheFilter.
%
%   Run with:  runtests('test_claheFilter')

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = rand(30, 30, 'single');
            out = claheFilter(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(64, 48, 'single');
            out = claheFilter(im);
            tc.verifySize(out, [64, 48]);
        end

        function testOutputInUnitRange(tc)
            im  = rand(40, 40, 'single');
            out = claheFilter(im);
            tc.verifyGreaterThanOrEqual(min(out(:)), single(-1e-6));
            tc.verifyLessThanOrEqual(max(out(:)),    single(1+1e-6));
        end

        function testContrastEnhanced(tc)
            % Low-contrast input: pixels near 0.5 with tiny spread
            rng(42);
            im  = single(0.5 + 0.01 * randn(64, 64));
            im  = max(0, min(1, im));
            p.clipLimit = 0.05;
            out = claheFilter(im, p);
            % Output should have higher variance (more contrast)
            tc.verifyGreaterThan(std(out(:)), std(im(:)));
        end

        function testClipLimitZeroNearlyIdentity(tc)
            % clipLimit = 0 → minimal redistribution → output ≈ input
            im = rand(32, 32, 'single');
            p.clipLimit = 0;
            out = claheFilter(im, p);
            % Not identical (still some tile processing) but correlation high
            r = corrcoef(im(:), out(:));
            tc.verifyGreaterThan(r(1,2), single(0.95));
        end

        function testUint8InputAccepted(tc)
            im  = uint8(randi([0 255], 40, 40));
            tc.verifyWarningFree(@() claheFilter(im));
        end

        function testNumTilesParameter(tc)
            im  = rand(64, 64, 'single');
            p4.numTiles = 4;  out4 = claheFilter(im, p4);
            p8.numTiles = 8;  out8 = claheFilter(im, p8);
            % Different tile counts produce different outputs
            tc.verifyNotEqual(out4, out8);
        end

    end
end
