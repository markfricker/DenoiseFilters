classdef test_medianFilter < matlab.unittest.TestCase
%TEST_MEDIANFILTER  Unit tests for medianFilter.
%
%   Run with:  runtests('test_medianFilter')

    methods (Test)

        function testOutputClassIsSingle(tc)
            im  = uint16(1000 * ones(20, 20));
            out = medianFilter(im);
            tc.verifyClass(out, 'single');
        end

        function testOutputSizeUnchanged(tc)
            im  = rand(55, 37, 'single');
            out = medianFilter(im);
            tc.verifySize(out, [55, 37]);
        end

        function testUniformImagePreserved(tc)
            im  = 0.4 * ones(25, 25, 'single');
            out = medianFilter(im);
            tc.verifyEqual(out, im, 'AbsTol', single(1e-5));
        end

        function testImpulseNoiseRemoved(tc)
            % Add salt-and-pepper to a flat background — median should
            % eliminate the impulses
            im       = 0.5 * ones(31, 31, 'single');
            im(5,5)  = 1.0;    % salt
            im(15,15)= 0.0;    % pepper
            out = medianFilter(im);
            tc.verifyEqual(out(5,5),   single(0.5), 'AbsTol', single(0.05));
            tc.verifyEqual(out(15,15), single(0.5), 'AbsTol', single(0.05));
        end

        function testEdgePreservationVsMean(tc)
            % Hard edge: median preserves more contrast than mean
            im          = zeros(30, 30, 'single');
            im(:, 16:30)= 1.0;
            outMed  = medianFilter(im);
            outMean = meanFilter(im);
            % Gradient of the transition in median output vs mean output
            gradMed  = abs(diff(outMed(15,:)));
            gradMean = abs(diff(outMean(15,:)));
            tc.verifyGreaterThan(max(gradMed(:)), max(gradMean(:)));
        end

        function testLargeKernelReducesVariance(tc)
            rng(42);
            im = rand(60, 60, 'single');
            p.kernelSize = 7;
            out = medianFilter(im, p);
            tc.verifyLessThan(std(out(:)), std(im(:)));
        end

    end
end
