function cdt_plot_meridional(ax, geo, mode)
%CDT_PLOT_MERIDIONAL Meridional section of the stage.
%   cdt_plot_meridional(ax, geo, mode) draws the outline in GEO (from
%   cdt_meridional_geometry) on axes AX.
%     mode = 'dimensions' : main dimensions written as numbers [mm]
%     mode = 'symbols'    : coloured components and dimension symbols only
%                           (presentation version, no numbers)

if nargin < 3; mode = 'dimensions'; end
show_numbers = strcmp(mode, 'dimensions');

c_hub = [0.10 0.30 0.80];
c_sh = [0.10 0.55 0.20];
c_dim = [0.70 0.05 0.05];
c_imp = [0.80 0.88 1.00];
c_dif = [0.82 0.95 0.82];
fs = 10;

cla(ax); hold(ax, 'on'); axis(ax, 'equal'); box(ax, 'on');

% Component regions: impeller up to r2, vaneless diffuser beyond
ih = find(geo.hub_r >= geo.r2 - 1e-9, 1);
is = find(geo.shroud_r >= geo.r2 - 1e-9, 1);
fill(ax, [geo.hub_z(1:ih); flipud(geo.shroud_z(1:is))], ...
    [geo.hub_r(1:ih); flipud(geo.shroud_r(1:is))], c_imp, 'EdgeColor', 'none');
fill(ax, [geo.hub_z(ih:end); flipud(geo.shroud_z(is:end))], ...
    [geo.hub_r(ih:end); flipud(geo.shroud_r(is:end))], c_dif, 'EdgeColor', 'none');

plot(ax, geo.hub_z, geo.hub_r, '-', 'Color', c_hub, 'LineWidth', 2);
plot(ax, geo.shroud_z, geo.shroud_r, '-', 'Color', c_sh, 'LineWidth', 2);
seg(ax, geo.LE_hub, geo.LE_shroud, 'k-', 1.6);
seg(ax, geo.TE_hub, geo.TE_shroud, 'k-', 1.6);
seg(ax, geo.splitter_hub, geo.splitter_shroud, 'k--', 1.2);

zmin = min([geo.hub_z; geo.shroud_z]);
zmax = max([geo.hub_z; geo.shroud_z]);
span = zmax - zmin;
plot(ax, [zmin - 0.25 * span, zmax + 0.1 * span], [0 0], '-.', 'Color', [0.4 0.4 0.4]);

% Dimension lines: radii on the left (inlet) and right (exit), lengths below
r1h = geo.LE_hub(1); r1s = geo.LE_shroud(1);
xL = zmin - 0.08 * span;
xR = zmax + 0.06 * span;
lab = @(sym, val) pick(show_numbers, sprintf('%s = %.2f', sym, val), sym);
dimV(ax, xL - 0.10 * span, 0, r1s, lab('r_{1s}', r1s), fs, c_dim, 'left');
dimV(ax, xL, 0, r1h, lab('r_{1h}', r1h), fs, c_dim, 'left');
dimV(ax, xR, 0, geo.r2, lab('r_2', geo.r2), fs, c_dim, 'right');
dimV(ax, xR + 0.10 * span, 0, geo.r4, lab('r_4', geo.r4), fs, c_dim, 'right');
LB = geo.TE_hub(2) - geo.LE_hub(2);
dimH(ax, -0.07 * geo.r4, geo.LE_hub(2), geo.TE_hub(2), lab('L_B', LB), fs, c_dim);
text(ax, geo.TE_shroud(2) - 0.02 * span, geo.r2 + 0.03 * geo.r4, lab('b_2', geo.b2), ...
    'Color', c_dim, 'FontSize', fs, 'FontWeight', 'bold', 'HorizontalAlignment', 'right');

% Component labels at the centre of each region
jh = round(0.55 * ih); js = round(0.55 * is);
zi = 0.5 * (geo.hub_z(jh) + geo.shroud_z(js));
ri = 0.5 * (geo.hub_r(jh) + geo.shroud_r(js));
text(ax, zi, ri, 'impeller', 'FontSize', fs, 'HorizontalAlignment', 'center', 'FontAngle', 'italic');
text(ax, geo.TE_shroud(2) - 0.03 * span, 0.5 * (geo.r2 + geo.r4), 'vaneless diffuser', ...
    'FontSize', fs, 'HorizontalAlignment', 'right', 'FontAngle', 'italic');

xlabel(ax, 'z (axial) [mm]');
ylabel(ax, 'r (radial) [mm]');
if show_numbers
    title(ax, sprintf('Meridional section [mm] - %s', geo.source));
else
    title(ax, sprintf('Meridional section - %s', geo.source));
end
xlim(ax, [zmin - 0.45 * span, zmax + 0.45 * span]);
ylim(ax, [-0.15 * geo.r4, 1.12 * geo.r4]);
grid(ax, 'on');
if ~show_numbers
    % presentation version: no axes, only the drawing and its symbols
    set(ax, 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
    grid(ax, 'off');
end
hold(ax, 'off');
end

function out = pick(c, a, b)
if c; out = a; else; out = b; end
end

function seg(ax, p1, p2, style, lw)
plot(ax, [p1(2) p2(2)], [p1(1) p2(1)], style, 'LineWidth', lw);
end

function dimV(ax, x, y1, y2, s, fs, c, side)
plot(ax, [x x], [y1 y2], '-', 'Color', c, 'LineWidth', 1);
plot(ax, x, y2, 'v', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 4);
plot(ax, x, y1, '^', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 4);
if strcmp(side, 'left'); ha = 'right'; else; ha = 'left'; end
text(ax, x, y2, s, 'Color', c, 'FontSize', fs, 'VerticalAlignment', 'bottom', ...
    'HorizontalAlignment', ha, 'BackgroundColor', 'w', 'Margin', 0.5);
end

function dimH(ax, y, x1, x2, s, fs, c)
plot(ax, [x1 x2], [y y], '-', 'Color', c, 'LineWidth', 1);
plot(ax, x1, y, '<', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 4);
plot(ax, x2, y, '>', 'Color', c, 'MarkerFaceColor', c, 'MarkerSize', 4);
text(ax, (x1 + x2) / 2, y, s, 'Color', c, 'FontSize', fs, 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'top');
end
