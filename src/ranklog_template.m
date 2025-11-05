%% ranklog_template.m
% % Created by Greg Berumen Sánchez (2025)
% README
% -------
% This script generates a publication-style rank–log plot where the x-axis is
% rank (after sorting by value) and the y-axis is a quantity such as a log2
% ratio. Points are colored by category:
%   - "Upregulated"
%   - "Down-regulated"
%   - "Unchanged"
%
% HOW TO USE WITH YOUR OWN DATA
% ------------------------------
% Provide a numeric vector Y (e.g., log2 ratios). Optionally provide matching
% categories 'cats' as a string/categorical array with values from:
% {"Upregulated","Down-regulated","Unchanged"}.
%
%   Y    = <your numeric vector>;
%   cats = <optional categories with same length as Y>;
%
% If 'cats' is omitted, the script auto-assigns categories based on a fold-
% change threshold 'fc_thr' and a dummy p-vector (random). Replace that logic
% with your real significance criteria if available.
%
% EXPORT OPTIONS
% ---------------
% Set these flags below:
%   savePNG = true;  pngName = 'rank_intensity.png';  pngDPI = 300;
%   saveSVG = true;  svgName = 'rank_intensity.svg';
% Exports are transparent and vector-friendly (SVG).
%
% CITATION (optional — edit/remove to suit your repo)
% ---------------------------------------------------
% Greg Berumen Sánchez, Purvi Patel, Kristie Rose, et al.
% Proteomics in Practice: A Case Study Highlighting Tandem Mass Tag-Based MS
% for Quantitative Profiling of Extracellular Vesicles and Application to
% Irradiated Fibroblasts. Authorea. May 16, 2025.
% DOI: 10.22541/au.174740614.48163602/v1
% -------------------------------------------------------------------------

clear; clc; close all;

%% ─── USER PARAMETERS ────────────────────────────────────────────────────────
% Provide Y (required) and cats (optional). If cats is omitted, the script
% auto-categorizes using thresholds below. For convenience, a synthetic demo
% is created unless you set useDemo = false and define your own Y (and cats).
useDemo = true;

% X-axis max override (if empty, uses number of points)
xMaxOverride = [];    % e.g., 2000 or []

% Fonts and frame
fontName        = 'Verdana';
fontSizeTicks   = 21.5;
fontTickWeight  = 'bold';
fontSizeLabel   = 24;
fontLabelWeight = 'normal';
frameLineW      = 1.5;

% Marker sizes
markerSizeBG  = 20;   % Unchanged
markerSizeKey = 70;   % Up/Down (key categories)

% Colors
downColor = [0,      0.4470, 0.7410];  % Down-regulated
upColor   = [0.9290, 0.6940, 0.1250];  % Upregulated
unchColor = [0.8,    0.8,    0.8   ];  % Unchanged
grayLine  = [0.6,    0.6,    0.6   ];  % y=0 dashed

% Legend
legendFontSize    = 18;
legendMarkerScale = 1.5;

% EXPORTS
savePNG = false;  pngName = 'rank_intensity.png';  pngDPI = 300;
saveSVG = false;  svgName = 'rank_intensity.svg';

% Thresholds for auto-categorization (if cats not provided)
fc_thr = log2(1.5);   % magnitude threshold for log2-scale values
p_thr  = 0.05;        % nominal p-value cutoff (only used in demo logic)

%% ─── DATA (DEMO OR YOUR OWN) ────────────────────────────────────────────────
if useDemo
    % --- Synthetic demo data (replace with your own Y and optional cats) ---
    nDemo = 1200;
    rng(1);
    Y = 0.8*sin(linspace(0, 6*pi, nDemo))' + 0.4*randn(nDemo,1);
    % Omit 'cats' to trigger auto-categorization below
else
    % --- Your data here ---
    % Y = <your numeric vector>;
    % cats = <optional string/categorical: "Upregulated","Down-regulated","Unchanged">;
end

% Basic checks
if ~exist('Y','var') || isempty(Y) || ~isvector(Y)
    error('Y must be a non-empty numeric vector.');
end
Y = double(Y(:));

if exist('cats','var') && ~isempty(cats)
    cats = string(cats(:));
    if numel(cats) ~= numel(Y)
        error('cats must be the same length as Y.');
    end
else
    % Auto-categorize: uses thresholds and a dummy p-vector for demo
    % Replace 'p_dummy' with your real p-values/criteria if available.
    p_dummy = rand(numel(Y),1)*0.5; % uniform(0,0.5)
    cats = strings(numel(Y),1);
    cats(Y >=  fc_thr & p_dummy < p_thr) = "Upregulated";
    cats(Y <= -fc_thr & p_dummy < p_thr) = "Down-regulated";
    cats(cats=="") = "Unchanged";
end

%% ─── SORT & PREP FOR PLOT ───────────────────────────────────────────────────
[sortedY, idx] = sort(Y, 'descend');
sortedCats     = cats(idx);
n = numel(sortedY);

% X limits
xMax = n;
if ~isempty(xMaxOverride), xMax = xMaxOverride; end

% Y limits & ticks
yPad  = 0.5;
ylims = [min(sortedY)-yPad, max(sortedY)+yPad];
yTick = floor(ylims(1)):1:ceil(ylims(2));
yTick(abs(yTick) > 1e6) = []; % guard for extreme values

%% ─── DRAW PLOT ──────────────────────────────────────────────────────────────
fig = figure('Color','w','Units','inches','Position',[1 1 9.125 5.65]); % wide panel
tiledlayout(fig,1,1,'TileSpacing','compact','Padding','compact');
ax = nexttile;
set(ax,'PositionConstraint','outerposition'); % leave space for southoutside legend

set(ax, ...
    'Color','none', ...
    'Box','off', ...
    'Layer','bottom', ...  % axes beneath data so dashed line sits under
    'FontName',fontName, ...
    'FontSize',fontSizeTicks, ...
    'FontWeight',fontTickWeight, ...
    'LineWidth',frameLineW, ...
    'TickDir','out', ...
    'XAxisLocation','bottom', ...
    'YAxisLocation','left');

ax.XLim  = [0 xMax];
ax.YLim  = ylims;
ax.XTick = autospace(0, xMax); % helper below
if ~isempty(yTick), ax.YTick = yTick; end
hold(ax,'on');

% Manual top/right frame
xl = ax.XLim; yl = ax.YLim;
line(ax, xl,       [yl(2) yl(2)], 'Color','k','LineWidth',frameLineW,'HandleVisibility','off');
line(ax, [xl(2) xl(2)], yl,       'Color','k','LineWidth',frameLineW,'HandleVisibility','off');

% Dashed gray y=0 under points
yline(ax, 0, 'Color',grayLine, 'LineStyle','--', 'LineWidth',1.5, 'HandleVisibility','off');

% Layered scatter: Unchanged -> Down -> Up (so Up/Down draw on top)
idxUn = (sortedCats=="Unchanged");
idxDn = (sortedCats=="Down-regulated");
idxUp = (sortedCats=="Upregulated");

scatter(ax, find(idxUn), sortedY(idxUn), markerSizeBG, unchColor, 'filled','MarkerEdgeColor','none');
scatter(ax, find(idxDn), sortedY(idxDn), markerSizeKey, downColor, 'filled','MarkerEdgeColor','k');
scatter(ax, find(idxUp), sortedY(idxUp), markerSizeKey, upColor,   'filled','MarkerEdgeColor','k');

% Labels
xlabel(ax, 'Rank',       'FontName',fontName,'FontSize',fontSizeLabel,'FontWeight',fontLabelWeight);
ylabel(ax, 'Log_2 ratio','FontName',fontName,'FontSize',fontSizeLabel,'FontWeight',fontLabelWeight);

% Legend (horizontal, boxed) — dummy handles so we control marker size
legendMarkerSizeKey = sqrt(markerSizeKey) * legendMarkerScale;
hLeg(1) = plot(nan,nan,'o', 'MarkerFaceColor',downColor, 'MarkerEdgeColor','k', 'MarkerSize',legendMarkerSizeKey);
hLeg(2) = plot(nan,nan,'o', 'MarkerFaceColor',unchColor,'MarkerEdgeColor','k', 'MarkerSize',legendMarkerSizeKey);
hLeg(3) = plot(nan,nan,'o', 'MarkerFaceColor',upColor,   'MarkerEdgeColor','k', 'MarkerSize',legendMarkerSizeKey);

lg = legend(ax, hLeg, {'Down-regulated','Unchanged','Upregulated'}, ...
    'Orientation','horizontal', ...
    'Location','southoutside', ...
    'FontName',fontName, ...
    'FontSize',legendFontSize, ...
    'Box','on');
set(lg, 'LineWidth', frameLineW);
lg.Layout.Tile = 'south';
set(lg, 'NumColumns', 3);

hold(ax,'off');

%% ─── EXPORTS (transparent) ──────────────────────────────────────────────────
if savePNG
    set(fig,'Renderer','painters');
    set(fig,'Color','none'); set(ax,'Color','none');
    print(fig, pngName, '-dpng', sprintf('-r%d',pngDPI));
end
if saveSVG
    set(fig,'Renderer','painters');
    origFigColor  = fig.Color;   origAxesColor = ax.Color;
    origInvertHC  = fig.InvertHardcopy;
    set(fig,'Color','none','InvertHardcopy','off'); set(ax,'Color','none');
    print(fig, svgName, '-dsvg');
    set(fig,'Color',origFigColor,'InvertHardcopy',origInvertHC);
    set(ax,'Color',origAxesColor);
end

%% ─── HELPERS ────────────────────────────────────────────────────────────────
function xt = autospace(x0, x1)
%AUTOSPACE choose "nice" ticks from x0..x1 (aim ~5 ticks including 0)
    span = max(x1 - x0, 1);
    rawStep = span / 4; % ~4 intervals
    p10 = 10.^floor(log10(rawStep));
    step = p10 .* [1 2 5 10];
    step = step(find(step >= rawStep, 1, 'first'));
    if isempty(step), step = p10(end); end
    xt = x0:step:x1;
end
