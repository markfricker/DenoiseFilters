classdef test_autoDenoiseParams < matlab.unittest.TestCase
%TEST_AUTODENOSEPARAMS  Unit tests for autoDenoiseParams.
%
%   Run with:  runtests('test_autoDenoiseParams')

    properties (Constant)
        % Flat image with known noise
        noiseSigma = 0.03;
    end

    methods (TestMethodSetup)
        function makeNoisyImage(tc)
            rng(55);
            tc.TestData.im = max(0, min(1, ...
                0.5 * ones(100, 100, 'single') + ...
                single(tc.noiseSigma) * randn(100, 100, 'single')));
        end
    end

    properties
        TestData
    end

    methods (Test)

        function testGaussianSigmaPositive(tc)
            p = autoDenoiseParams(tc.TestData.im, 'gaussian');
            tc.verifyGreaterThan(p.sigma, single(0));
        end

        function testGaussianSigmaInRange(tc)
            p = autoDenoiseParams(tc.TestData.im, 'gaussian');
            tc.verifyGreaterThanOrEqual(p.sigma, single(0.5));
            tc.verifyLessThanOrEqual(p.sigma,    single(5));
        end

        function testBilateralFieldsPresent(tc)
            p = autoDenoiseParams(tc.TestData.im, 'bilateral');
            tc.verifyField(p, 'spatialSigma');
            tc.verifyField(p, 'rangeSigma');
        end

        function testBilateralRangeSigmaScalesWithNoise(tc)
            rng(56);
            imLow  = 0.5*ones(100,100,'single') + 0.01*randn(100,100,'single');
            imHigh = 0.5*ones(100,100,'single') + 0.08*randn(100,100,'single');
            pLow  = autoDenoiseParams(imLow,  'bilateral');
            pHigh = autoDenoiseParams(imHigh, 'bilateral');
            % Higher noise → larger range sigma
            tc.verifyGreaterThan(pHigh.rangeSigma, pLow.rangeSigma);
        end

        function testNlmeansHScalesWithNoise(tc)
            rng(57);
            imLow  = 0.5*ones(100,100,'single') + 0.01*randn(100,100,'single');
            imHigh = 0.5*ones(100,100,'single') + 0.08*randn(100,100,'single');
            pLow  = autoDenoiseParams(imLow,  'nlmeans');
            pHigh = autoDenoiseParams(imHigh, 'nlmeans');
            tc.verifyGreaterThan(pHigh.degreeOfSmoothing, pLow.degreeOfSmoothing);
        end

        function testCurrentParamsCarriedForward(tc)
            current.foo = 42;
            p = autoDenoiseParams(tc.TestData.im, 'gaussian', current);
            tc.verifyEqual(p.foo, 42);
        end

        function testUnknownMethodIssuesWarning(tc)
            tc.verifyWarning( ...
                @() autoDenoiseParams(tc.TestData.im, 'unknownMethod'), ...
                'autoDenoiseParams:noAuto');
        end

        function testUnknownMethodReturnsCurrentParams(tc)
            current.bar = 99;
            [~, p] = evalc('autoDenoiseParams(tc.TestData.im, ''unknown'', current)');
            tc.verifyEqual(p.bar, 99);
        end

    end
end
