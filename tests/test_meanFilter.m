classdef test_meanFilter < matlab.unittest.TestCase
%TEST_MEANFILTER  Unit tests for meanFilter.
%
%   Run with:  runtests('test_meanFilter')

    properties (TestParameter)
        kernelSize = {1, 3, 5, 7}
    end

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = uint8(128 * ones(20, 20));
            out = meanFilter(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(64, 48, 'single');
            out = meanFilter(im);
            tc.verifySize(out, [64, 48]);
        end

        function testUniformImagePreserved(tc)
            % A uniform image is unchanged by a box filter
            im  = 0.6 * ones(30, 30, 'single');
            out = meanFilter(im);
            tc.verifyEqual(out, im, 'AbsTol', single(1e-5));
        end

        function testSmoothsImpulse(tc)
            im     = zeros(21, 21, 'single');
            im(11,11) = 1.0;
            out    = meanFilter(im);
            % Central spike should be spread — centre value must decrease
            tc.verifyLessThan(out(11,11), single(1.0));
        end

        function testOutputRangeWithinInput(tc)
            im  = rand(50, 50, 'single');
            out = meanFilter(im);
            tc.verifyGreaterThanOrEqual(min(out(:)), min(im(:)) - single(1e-6));
            tc.verifyLessThanOrEqual(max(out(:)),    max(im(:)) + single(1e-6));
        end

        function testKernelSizeParameterized(tc, kernelSize)
            im = rand(40, 40, 'single');
            p.kernelSize = kernelSize;
            out = meanFilter(im, p);
            tc.verifySize(out, [40, 40]);
            tc.verifyClass(out, 'single');
        end

        function testDefaultMatchesKernel3(tc)
            im     = rand(30, 30, 'single');
            out1   = meanFilter(im);
            p.kernelSize = 3;
            out2   = meanFilter(im, p);
            tc.verifyEqual(out1, out2, 'AbsTol', single(1e-6));
        end

    end
end
