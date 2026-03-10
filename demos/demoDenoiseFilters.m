%DEMODENOISEFILTERS  Demonstration of all DenoiseFilters methods.
%
% PURPOSE
%   Applies every available denoising filter to a synthetic confocal-like
%   fibre image and to the MATLAB built-in 'cameraman' image.  Produces:
%     1. An overview figure comparing all methods side-by-side.
%     2. Individual per-method figures suitable for inclusion in a manual.
%     3. A quantitative table (PSNR and SSIM) printed to the command window.
%
% USAGE
%   demoDenoiseFilters               % display figures, no saving
%   demoDenoiseFilters('save', true) % also save PNG files to demos/output/
%   demoDenoiseFilters('noiseLevel', 0.05, 'save', true)
%
% PARAMETERS (name-value pairs)
%   'noiseLevel'  – std of additive Gaussian noise [0,1]   (default 0.04)
%   'save'        – logical, save PNG figures to demos/output/ (default false)
%   'outputDir'   – directory to save figures (default: demos/output/)
%   'imageType'   – 'fibre'|'cameraman'|'both'             (default 'both')
%
% REQUIREMENTS
%   Image Processing Toolbox  (imbilatfilt, imguidedfilter, imdiffusefilt,
%                               imnlmfilt, adapthisteq, ssim, psnr)
%   DenoiseFilters_sandbox/src/ on the MATLAB path.

function demoDenoiseFilters(varargin)

% ---- parse inputs -------------------------------------------------------
p = inputParser;
addParameter(p, 'noiseLevel', 0.04,    @(x) isnumeric(x) && x >= 0 && x <= 1);
addParameter(p, 'save',       false,   @islogical);
addParameter(p, 'outputDir',  '',      @ischar);
addParameter(p, 'imageType',  'both',  @(x) ismember(x, {'fibre','cameraman','both'}));
parse(p, varargin{:});
opt = p.Results;

if isempty(opt.outputDir)
    here = fileparts(mfilename('fullpath'));
    opt.outputDir = fullfile(here, 'output');
end

if opt.save && ~isfolder(opt.outputDir)
    mkdir(opt.outputDir);
end

rng(42);

% =========================================================================
%  Build test images
% =========================================================================
if ismember(opt.imageType, {'fibre','both'})
    imFibre = makeSyntheticFibreImage(256);
    runDemo(imFibre, 'synthetic_fibre', opt);
end

if ismember(opt.imageType, {'cameraman','both'})
    imCam = im2single(imread('cameraman.tif'));
    runDemo(imCam, 'cameraman', opt);
end

end  % end demoDenoiseFilters

% =========================================================================
%  Core demo runner for one image
% =========================================================================
function runDemo(imClean, label, opt)

noiseLevel = opt.noiseLevel;
imNoisy    = max(0, min(1, imClean + single(noiseLevel) * randn(size(imClean), 'single')));

fprintf('\n=== Demo: %s  (noise \sigma = %.3f) ===\n', label, noiseLevel);

% ---- define all filter configurations ----------------------------------
configs = defineFilterConfigs(noiseLevel);

% ---- apply all filters --------------------------------------------------
nMethods = numel(configs);
results  = cell(nMethods, 1);
for k = 1:nMethods
    cfg       = configs{k};
    switch cfg.func
        case 'none'
            results{k} = imNoisy;
        case 'meanFilter'
            results{k} = meanFilter(imNoisy, cfg.params);
        case 'medianFilter'
            results{k} = medianFilter(imNoisy, cfg.params);
        case 'gaussianFilter'
            results{k} = gaussianFilter(imNoisy, cfg.params);
        case 'bilateralFilter'
            results{k} = bilateralFilter(imNoisy, cfg.params);
        case 'guidedFilter'
            results{k} = guidedFilter(imNoisy, cfg.params);
        case 'diffusionFilter'
            results{k} = diffusionFilter(imNoisy, cfg.params);
        case 'nlmeansFilter'
            results{k} = nlmeansFilter(imNoisy, cfg.params);
        case 'orientedGaussSmooth'
            results{k} = orientedGaussSmooth(imNoisy, cfg.params);
    end
end

% ---- quantitative table -------------------------------------------------
fprintf('  %-22s  %6s  %6s\n', 'Method', 'PSNR', 'SSIM');
fprintf('  %-22s  %6s  %6s\n', repmat('-',22,1), '------', '------');
for k = 1:nMethods
    psnrVal = psnr(results{k}, imClean);
    ssimVal = ssim(results{k}, imClean);
    fprintf('  %-22s  %6.2f  %6.4f\n', configs{k}.name, psnrVal, ssimVal);
end
fprintf('\n');

% ---- overview figure (all methods) -------------------------------------
plotOverview(imClean, imNoisy, results, configs, label, opt);

% ---- individual method figures (for manual) ----------------------------
plotPerMethod(imClean, imNoisy, results, configs, label, opt);

% ---- CLAHE post-processing figure --------------------------------------
plotCLAHE(imNoisy, results, configs, label, opt);

end

% =========================================================================
%  Overview figure: grid of all methods
% =========================================================================
function plotOverview(imClean, imNoisy, results, configs, label, opt)

nMethods = numel(configs);
nTotal   = nMethods + 2;   % + original + noisy
nCols    = 5;
nRows    = ceil(nTotal / nCols);

fh = figure('Name', sprintf('Denoise overview — %s', label), ...
    'Color', 'w', 'Units', 'pixels', 'Position', [50 50 1400 280*nRows]);

imAll   = [{imClean}, {imNoisy}, results(:)'];
titles  = [{'Original'}, {'Noisy'}, cellfun(@(c) c.name, configs, 'UniformOutput', false)];

for k = 1:numel(imAll)
    ax = subplot(nRows, nCols, k, 'Parent', fh);
    imshow(imAll{k}, [], 'Parent', ax);
    title(ax, titles{k}, 'FontSize', 8, 'Interpreter', 'none');
end

sgtitle(sprintf('Denoising Methods — %s  (\\sigma_{noise} = %.3f)', label, opt.noiseLevel), ...
    'FontSize', 10, 'Interpreter', 'tex');

if opt.save
    exportgraphics(fh, fullfile(opt.outputDir, sprintf('%s_overview.png', label)), ...
        'Resolution', 150);
    fprintf('  Saved overview figure.\n');
end
end

% =========================================================================
%  Per-method figure: clean / noisy / filtered + zoom + profile
% =========================================================================
function plotPerMethod(imClean, imNoisy, results, configs, label, opt)

[nY, nX] = size(imClean);
ry       = round(nY/2); % row for horizontal profile
rx       = round(nX/2); % column for vertical profile

for k = 1:numel(configs)
    imFilt = results{k};
    psnrV  = psnr(imFilt, imClean);
    ssimV  = ssim(imFilt, imClean);

    fh = figure('Name', sprintf('%s — %s', configs{k}.name, label), ...
        'Color', 'w', 'Units', 'pixels', 'Position', [100 100 1100 420]);

    % Panel 1: Clean
    ax1 = subplot(2, 4, 1);
    imshow(imClean, [], 'Parent', ax1);  title(ax1, 'Original', 'FontSize', 9);

    % Panel 2: Noisy
    ax2 = subplot(2, 4, 2);
    imshow(imNoisy, [], 'Parent', ax2);  title(ax2, 'Noisy', 'FontSize', 9);

    % Panel 3: Filtered
    ax3 = subplot(2, 4, 3);
    imshow(imFilt, [], 'Parent', ax3);
    title(ax3, sprintf('%s\nPSNR=%.1f  SSIM=%.3f', configs{k}.name, psnrV, ssimV), ...
        'FontSize', 8, 'Interpreter', 'none');

    % Panel 4: Difference (noise residual)
    ax4 = subplot(2, 4, 4);
    diffIm = imFilt - imClean + 0.5;
    imshow(diffIm, [0 1], 'Parent', ax4);
    title(ax4, 'Residual (filtered − clean + 0.5)', 'FontSize', 8);

    % Panel 5: Zoomed clean
    r1 = max(1, round(nY/2-20)); r2 = min(nY, r1+40);
    c1 = max(1, round(nX/4));    c2 = min(nX, c1+60);
    ax5 = subplot(2, 4, 5);
    imshow(imClean(r1:r2, c1:c2), [], 'Parent', ax5);
    title(ax5, 'Zoom: clean', 'FontSize', 8);

    % Panel 6: Zoomed filtered
    ax6 = subplot(2, 4, 6);
    imshow(imFilt(r1:r2, c1:c2), [], 'Parent', ax6);
    title(ax6, 'Zoom: filtered', 'FontSize', 8);

    % Panel 7: Horizontal intensity profile
    ax7 = subplot(2, 4, 7);
    x   = 1:nX;
    plot(ax7, x, imClean(ry,:), 'k-',  'LineWidth', 1.2, 'DisplayName', 'Clean');  hold(ax7,'on');
    plot(ax7, x, imNoisy(ry,:), 'Color',[0.7 0.7 0.7], 'LineWidth', 0.8, 'DisplayName', 'Noisy');
    plot(ax7, x, imFilt(ry,:),  'r-',  'LineWidth', 1.2, 'DisplayName', 'Filtered');
    legend(ax7, 'FontSize', 7, 'Location', 'best');
    xlabel(ax7, 'Column (px)');  ylabel(ax7, 'Intensity');
    title(ax7, sprintf('Profile: row %d', ry), 'FontSize', 8);
    grid(ax7, 'on');

    % Panel 8: Parameter summary text
    ax8 = subplot(2, 4, 8);
    axis(ax8, 'off');
    paramStr = struct2dispStr(configs{k}.params);
    text(ax8, 0.05, 0.9, configs{k}.name, 'FontWeight', 'bold', 'FontSize', 10, ...
        'VerticalAlignment', 'top', 'Interpreter', 'none');
    text(ax8, 0.05, 0.72, paramStr, 'FontSize', 8, 'VerticalAlignment', 'top', ...
        'FontName', 'Courier', 'Interpreter', 'none');
    text(ax8, 0.05, 0.15, sprintf('PSNR:  %.2f dB\nSSIM:  %.4f', psnrV, ssimV), ...
        'FontSize', 9, 'VerticalAlignment', 'top');

    if opt.save
        safeName = strrep(configs{k}.name, ' ', '_');
        safeName = regexprep(safeName, '[^A-Za-z0-9_]', '');
        exportgraphics(fh, fullfile(opt.outputDir, ...
            sprintf('%s_%s.png', label, safeName)), 'Resolution', 150);
    end
    drawnow;
end
end

% =========================================================================
%  CLAHE post-processing figure
% =========================================================================
function plotCLAHE(imNoisy, results, configs, label, opt)

% Apply CLAHE after a selected filter (bilateral) for demonstration
kBilat = find(strcmp(cellfun(@(c) c.func, configs, 'UniformOutput', false), 'bilateralFilter'), 1);
if isempty(kBilat), return; end

imBilat    = results{kBilat};
pClahe.numTiles  = 8;
pClahe.clipLimit = 0.02;
imClahe    = claheFilter(imBilat, pClahe);

fh = figure('Name', sprintf('CLAHE post-processing — %s', label), ...
    'Color', 'w', 'Units', 'pixels', 'Position', [150 150 900 300]);

subplot(1,3,1); imshow(imNoisy,  [], 'Parent', gca); title('Noisy input',    'FontSize',9);
subplot(1,3,2); imshow(imBilat,  [], 'Parent', gca); title('Bilateral',      'FontSize',9);
subplot(1,3,3); imshow(imClahe,  [], 'Parent', gca); title('Bilateral+CLAHE','FontSize',9);
sgtitle(sprintf('CLAHE post-processing effect — %s', label), 'FontSize', 10);

if opt.save
    exportgraphics(fh, fullfile(opt.outputDir, sprintf('%s_clahe_demo.png', label)), ...
        'Resolution', 150);
end
drawnow;
end

% =========================================================================
%  Define filter configurations
% =========================================================================
function configs = defineFilterConfigs(noiseLevel)

configs = {};

% pass-through (noisy input)
configs{end+1} = struct('name', 'none', 'func', 'none', 'params', struct());

% mean
configs{end+1} = struct('name', 'mean (k=3)',  'func', 'meanFilter', ...
    'params', struct('kernelSize', 3));
configs{end+1} = struct('name', 'mean (k=5)',  'func', 'meanFilter', ...
    'params', struct('kernelSize', 5));

% median
configs{end+1} = struct('name', 'median (k=3)', 'func', 'medianFilter', ...
    'params', struct('kernelSize', 3));
configs{end+1} = struct('name', 'median (k=5)', 'func', 'medianFilter', ...
    'params', struct('kernelSize', 5));

% gaussian
sig = max(0.5, min(5, noiseLevel * 50));
configs{end+1} = struct('name', sprintf('gaussian (\\sigma=%.1f)', sig), ...
    'func', 'gaussianFilter', 'params', struct('sigma', sig));

% bilateral
rSig = min(max(noiseLevel * 2.5, 0.02), 0.3);
configs{end+1} = struct('name', sprintf('bilateral (sp=3, r=%.3f)', rSig), ...
    'func', 'bilateralFilter', ...
    'params', struct('spatialSigma', 3, 'rangeSigma', rSig));

% guided
configs{end+1} = struct('name', 'guided (nbhd=5, \epsilon=0.01)', ...
    'func', 'guidedFilter', ...
    'params', struct('neighborhoodSize', 5, 'smoothing', 0.01));

% diffusion
configs{end+1} = struct('name', 'diffusion (iter=15, thr=0.05)', ...
    'func', 'diffusionFilter', ...
    'params', struct('numIterations', 15, 'gradientThreshold', 0.05));

% nlmeans
h = min(max(noiseLevel * 1.5, 0.005), 0.2);
configs{end+1} = struct('name', sprintf('nlmeans (h=%.3f)', h), ...
    'func', 'nlmeansFilter', ...
    'params', struct('degreeOfSmoothing', h, 'searchWindowSize', 21, ...
    'comparisonWindowSize', 7));

% orientedGauss
configs{end+1} = struct('name', 'orientedGauss (\sigma_A=4, \sigma_C=1.5)', ...
    'func', 'orientedGaussSmooth', ...
    'params', struct('sigmaAlong', 4, 'sigmaAcross', 1.5, 'orientations', 8, ...
    'sigmaGrad', 1.5, 'sigmaInt', 5));

end

% =========================================================================
%  Generate synthetic confocal-like fibre image
% =========================================================================
function im = makeSyntheticFibreImage(sz)
%MAKESYNTHETICFIBREIMAGE  Synthesise a fibre/tubule test image.
%
% Generates a set of curved, crossed fibres on a noisy background —
% similar to the ER network appearance in confocal fluorescence images.

[X, Y] = meshgrid(linspace(0, 4*pi, sz), linspace(0, 4*pi, sz));

% Horizontal wavy fibres
im = zeros(sz, 'single');
for n = 0:4
    offset = (n / 4) * 4 * pi;
    wave   = 0.3 * sin(X + 0.7 * n);
    fibre  = exp(-((Y - offset - wave).^2) / (2 * 1.2^2));
    im     = im + fibre * (0.6 + 0.4 * rand(1));
end

% Diagonal fibres (45°)
for n = 0:3
    offset = (n / 4) * sz;
    fibre  = exp(-(((X - Y) / sqrt(2) - offset).^2) / (2 * 1.5^2));
    im     = im + fibre * 0.5;
end

% Background fluorescence
im = im + 0.05;

% Normalise to [0,1]
im = single(mat2gray(im));
end

% =========================================================================
%  Utility: struct to display string
% =========================================================================
function s = struct2dispStr(params)
fields = fieldnames(params);
if isempty(fields)
    s = '(no parameters)';
    return
end
lines = cell(numel(fields), 1);
for k = 1:numel(fields)
    v = params.(fields{k});
    if isscalar(v) && isnumeric(v)
        lines{k} = sprintf('%-18s = %g', fields{k}, v);
    else
        lines{k} = sprintf('%-18s = [...]', fields{k});
    end
end
s = strjoin(lines, newline);
end
