%% mirrored_histogram_and_bland_altman_template.m
% % Created by Greg Berumen Sánchez (2025)
% README
% -------
% This script generates two plots for comparing 
% quantitative methods:
%
% 1. Mirrored histogram
%    - Compares the distributions of two methods (Method A vs Method B).
%    - Method A counts are shown on the left (negative side).
%    - Method B counts are shown on the right (positive side).
%    - The Command Window prints a simple text legend.
%
% 2. Bland–Altman plot
%    - Shows the difference (Method A – Method B) vs the average.
%    - Bias (mean difference) and limits of agreement (±1.96 SD) are drawn.
%    - Interpretation is printed to the Command Window.
%
% HOW TO USE WITH YOUR OWN DATA
% ------------------------------
% Replace the “Synthetic demo data” section with your own numeric vectors:
%
%   A = <your vector for Method A>;
%   B = <your vector for Method B>;
%
% Both A and B must be numeric vectors of the same length (paired values).
%
% EXPORT OPTIONS
% ---------------
% By default, saving is turned OFF.
% To export figures, set these flags near the top:
%
%   savePNG_hist = true;   % save histogram as PNG
%   saveSVG_hist = true;   % save histogram as SVG
%   savePNG_ba   = true;   % save Bland–Altman as PNG
%   saveSVG_ba   = true;   % save Bland–Altman as SVG
%
% All exports use transparent backgrounds and vector-friendly SVGs.
%
% CITATION
% ---------
% Cite as:
% Greg Berumen Sánchez, Purvi Patel, Kristie Rose, et al.
% Proteomics in Practice: A Case Study Highlighting Tandem Mass Tag-Based MS 
% for Quantitative Profiling of Extracellular Vesicles and Application to 
% Irradiated Fibroblasts. Authorea. May 16, 2025.
% DOI: 10.22541/au.174740614.48163602/v1
%
% (This pre-print citation will eventually be replaced with the final full citation.)
%

clear; clc; close all;

%% ─── USER PARAMETERS ────────────────────────────────────────────────────────
methodA_name = 'Method A';
methodB_name = 'Method B';
diff_caption = sprintf('Difference = %s - %s', methodA_name, methodB_name);

% Colors
colorA = [66/255, 165/255,  71/255];   % green (left bars)
colorB = [0/255,   88/255, 125/255];   % teal (right bars)

% Formatting
fontName        = 'Verdana';
fontSizeTicks   = 21.5;
tickFontWeight  = 'bold';
fontSizeLabel   = 24;
labelFontWeight = 'normal';
frameLineW      = 1.5;

% Axis auto-tuning
targetXTicks_hist = 7;
targetYTicks_hist = 6;
targetXTicks_ba   = 7;
targetYTicks_ba   = 6;

% Saving options (all OFF by default)
savePNG_hist   = false;
pngName_hist   = 'mirrored_histogram.png';
saveSVG_hist   = false;
svgName_hist   = 'mirrored_histogram.svg';

savePNG_ba     = false;
pngName_ba     = 'bland_altman.png';
saveSVG_ba     = false;
svgName_ba     = 'bland_altman.svg';

pngDPI = 300;

%% ─── SYNTHETIC DEMO DATA (replace with your own) ────────────────────────────
rng(1); % reproducibility
A = randn(500,1) * 0.5;        % Method A
B = A + randn(500,1) * 0.2;    % Method B, correlated with noise

%% ─── MIRRORED HISTOGRAM ─────────────────────────────────────────────────────
binWidth = 0.1;
allData_hist = [A; B];
edges = min(allData_hist):binWidth:max(allData_hist);

[countA, edgesUsed] = histcounts(A, edges);
[countB, ~        ] = histcounts(B, edgesUsed);
binCenters = edgesUsed(1:end-1) + binWidth/2;

fig1 = figure('Color','w');
ax1  = axes(fig1); hold(ax1,'on');

barh(ax1, binCenters, -countA, 1, 'FaceColor', colorA, 'EdgeColor', 'k');
barh(ax1, binCenters,  countB, 1, 'FaceColor', colorB, 'EdgeColor', 'k');

styleAxes(ax1, fontName, fontSizeTicks, tickFontWeight, frameLineW);

[yMin1, yMax1, yStep1] = autoLimitsTicks(min(allData_hist), max(allData_hist), targetYTicks_hist);
ax1.YLim  = [yMin1, yMax1]; ax1.YTick = yMin1:yStep1:yMax1;

maxLeft = max(countA); maxRight = max(countB);
roughStep = max(1, (maxLeft + maxRight) / max(3, targetXTicks_hist));
xStep1    = niceStep(roughStep);
xMaxL     = xStep1 * ceil(maxLeft  / xStep1);
xMaxR     = xStep1 * ceil(maxRight / xStep1);
ax1.XLim  = [-xMaxL, xMaxR]; ax1.XTick = -xMaxL:xStep1:xMaxR;
ax1.XTickLabel = arrayfun(@(v) sprintf('%d', abs(v)), ax1.XTick, 'UniformOutput', false);

plot(ax1, [0 0], ax1.YLim, 'k-', 'LineWidth', frameLineW);
drawTopRightFrame(ax1, frameLineW);

xlabel(ax1, 'Frequency', 'FontName', fontName, 'FontSize', fontSizeLabel);
ylabel(ax1, 'Log_2 fold change', 'FontName', fontName, 'FontSize', fontSizeLabel);

doExports(fig1, ax1, savePNG_hist, pngName_hist, saveSVG_hist, svgName_hist, pngDPI);

fprintf('\nMirrored histogram legend:\n');
fprintf('  Left bars  (negative side) = %s\n', methodA_name);
fprintf('  Right bars (positive side) = %s\n\n', methodB_name);

%% ─── BLAND–ALTMAN PLOT ──────────────────────────────────────────────────────
average    = (A + B) / 2;
difference =  A - B;

mean_diff  = mean(difference);
sd_diff    = std(difference);
upper_LoA  = mean_diff + 1.96 * sd_diff;
lower_LoA  = mean_diff - 1.96 * sd_diff;

fprintf('Bland–Altman interpretation:\n');
fprintf('  %s\n', diff_caption);
fprintf('  Pairs compared: %d values\n\n', numel(A));

fig2 = figure('Color','w');
ax2  = axes(fig2); hold(ax2,'on');

hPts = scatter(ax2, average, difference, 12, [0 0 1], 'filled', 'MarkerFaceAlpha', 0.6);
set(hPts, 'Clipping','off');

[xMin2, xMax2, xStep2] = autoLimitsTicks(min(average), max(average), targetXTicks_ba);
ax2.XLim  = [xMin2, xMax2]; ax2.XTick = xMin2:xStep2:xMax2;

yMinData = min([difference; lower_LoA]);
yMaxData = max([difference; upper_LoA]);
yMargin  = 0.1 * (yMaxData - yMinData);
ax2.YLim = [yMinData - yMargin, yMaxData + yMargin];

yRange = diff(ax2.YLim);
roughY = yRange / max(3, targetYTicks_ba);
yStep2 = niceStep(roughY);
ax2.YTick = round(ax2.YLim(1)/yStep2)*yStep2 : yStep2 : round(ax2.YLim(2)/yStep2)*yStep2;

ax2.XGrid = 'on'; ax2.YGrid = 'on';
ax2.GridColor = [0.7 0.7 0.7]; ax2.GridAlpha = 0.5;

plot(ax2, ax2.XLim, [mean_diff mean_diff], '-.', 'Color', [0 0 1], 'LineWidth', 2.0);
plot(ax2, ax2.XLim, [upper_LoA upper_LoA], '-.', 'Color', [1 0 0], 'LineWidth', 2.0);
plot(ax2, ax2.XLim, [lower_LoA lower_LoA], '-.', 'Color', [1 0 0], 'LineWidth', 2.0);

xR = ax2.XLim(2);
text(xR*0.985, mean_diff, sprintf('Bias: %.2f', mean_diff), ...
    'HorizontalAlignment','right', 'VerticalAlignment','bottom', ...
    'FontName', fontName, 'FontSize', 18, 'FontWeight','bold', 'Color', [0 0 1]);
text(xR*0.985, upper_LoA, sprintf('Upper LoA: %.2f', upper_LoA), ...
    'HorizontalAlignment','right', 'VerticalAlignment','bottom', ...
    'FontName', fontName, 'FontSize', 18, 'FontWeight','bold', 'Color', [1 0 0]);
text(xR*0.985, lower_LoA, sprintf('Lower LoA: %.2f', lower_LoA), ...
    'HorizontalAlignment','right', 'VerticalAlignment','top', ...
    'FontName', fontName, 'FontSize', 18, 'FontWeight','bold', 'Color', [1 0 0]);

styleAxes(ax2, fontName, fontSizeTicks, tickFontWeight, frameLineW);
drawTopRightFrame(ax2, frameLineW);

xlabel(ax2, 'Log_2 ratio average', 'FontName', fontName, 'FontSize', fontSizeLabel);
ylabel(ax2, 'Log_2 ratio difference', 'FontName', fontName, 'FontSize', fontSizeLabel);

doExports(fig2, ax2, savePNG_ba, pngName_ba, saveSVG_ba, svgName_ba, pngDPI);

%% ─── HELPERS ────────────────────────────────────────────────────────────────
function styleAxes(ax, fontName, fontSizeTicks, tickFontWeight, frameLineW)
    ax.FontName      = fontName;
    ax.FontSize      = fontSizeTicks;
    ax.FontWeight    = tickFontWeight;
    ax.LineWidth     = frameLineW;
    ax.TickDir       = 'out';
    ax.Box           = 'off';
    ax.XAxisLocation = 'bottom';
    ax.YAxisLocation = 'left';
end

function drawTopRightFrame(ax, frameLineW)
    xl = ax.XLim; yl = ax.YLim;
    line(ax, xl, [yl(2) yl(2)], 'Color','k','LineWidth',frameLineW);
    line(ax, [xl(2) xl(2)], yl, 'Color','k','LineWidth',frameLineW);
end

function doExports(fig, ax, savePNG, pngName, saveSVG, svgName, pngDPI)
    drawnow;
    if savePNG
        exportgraphics(fig, pngName, 'Resolution', pngDPI, 'BackgroundColor','none');
        fprintf('Saved PNG to "%s"\n', fullfile(pwd, pngName));
    end
    if saveSVG
        set(fig,'Renderer','painters'); set(fig,'Color','none'); set(ax,'Color','none');
        exportgraphics(fig, svgName, 'ContentType','vector', 'BackgroundColor','none');
        fprintf('Saved SVG to "%s"\n', fullfile(pwd, svgName));
    end
end

function s = niceStep(x)
    if x <= 0 || ~isfinite(x), s = 1; return; end
    k = floor(log10(x)); m = x/10^k;
    if m <= 1.5, base = 1;
    elseif m <= 3.5, base = 2;
    elseif m <= 7.5, base = 5;
    else, base = 10;
    end
    s = base * 10^k;
end

function [lo, hi, step] = autoLimitsTicks(minVal, maxVal, targetTicks)
    if ~isfinite(minVal) || ~isfinite(maxVal)
        lo=-1; hi=1; step=0.5; return;
    end
    if minVal==maxVal
        pad=max(1,abs(minVal)*0.1);
        minVal=minVal-pad; maxVal=maxVal+pad;
    end
    rough=(maxVal-minVal)/max(3,targetTicks);
    step=niceStep(rough);
    lo=floor(minVal/step)*step;
    hi=ceil(maxVal/step)*step;
end
