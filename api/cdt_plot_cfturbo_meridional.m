function cdt_plot_cfturbo_meridional(ax, comps, det)
%CDT_PLOT_CFTURBO_MERIDIONAL Meridional view of a CFturbo export.
%   cdt_plot_cfturbo_meridional(ax, comps) draws every component read by
%   cdt_read_cfturbo_export: hub/shroud walls, the blade region of every
%   blade row (hub and tip profile edges) and the component interfaces.
%   cdt_plot_cfturbo_meridional(ax, comps, det) overlays the MATLAB impeller
%   design (dashed), shifted so that both hub leading edges coincide.

cols = [0.80 0.88 1.00; 0.82 0.95 0.82; 1.00 0.89 0.76; 0.93 0.85 1.00];
cla(ax); hold(ax, 'on'); axis(ax, 'equal'); box(ax, 'on'); grid(ax, 'on');
chk = cdt_cfturbo_check(comps);

for k = 1:numel(comps)
    c = comps(k);
    fill(ax, [c.hub(:, 2); flipud(c.shroud(:, 2))], [c.hub(:, 1); flipud(c.shroud(:, 1))], ...
        cols(1 + mod(k - 1, size(cols, 1)), :), 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(ax, c.hub(:, 2), c.hub(:, 1), '-', 'Color', [0.10 0.30 0.80], 'LineWidth', 1.8, 'HandleVisibility', 'off');
    plot(ax, c.shroud(:, 2), c.shroud(:, 1), '-', 'Color', [0.10 0.55 0.20], 'LineWidth', 1.8, 'HandleVisibility', 'off');
    plot(ax, [c.hub(1, 2) c.shroud(1, 2)], [c.hub(1, 1) c.shroud(1, 1)], ':', 'Color', [0.3 0.3 0.3], 'HandleVisibility', 'off');
    plot(ax, [c.hub(end, 2) c.shroud(end, 2)], [c.hub(end, 1) c.shroud(end, 1)], ':', 'Color', [0.3 0.3 0.3], 'HandleVisibility', 'off');
    % blade meridional projection: every profile, and the LE/TE lines
    for b = 1:numel(c.blades)
        for p = 1:numel(c.blades{b})
            P = c.blades{b}{p};
            plot(ax, P(:, 3), hypot(P(:, 1), P(:, 2)), '-', 'Color', [0.45 0.45 0.45 0.35], 'HandleVisibility', 'off');
        end
    end
    rows = chk.components(chk.components.component == string(c.name), :);
    for j = 1:height(rows)
        ls = '-'; if rows.blade(j) == "splitter"; ls = '--'; end
        plot(ax, [rows.LE_hub_z(j) rows.LE_tip_z(j)], [rows.LE_hub_r(j) rows.LE_tip_r(j)], ['k' ls], 'LineWidth', 1.6, 'HandleVisibility', 'off');
        plot(ax, [rows.TE_hub_z(j) rows.TE_tip_z(j)], [rows.TE_hub_r(j) rows.TE_tip_r(j)], ['k' ls], 'LineWidth', 1.6, 'HandleVisibility', 'off');
    end
    [~, i] = max(c.hub(:, 1) + c.hub(:, 2));
    text(ax, mean([c.hub(round(end / 2), 2), c.shroud(round(end / 2), 2)]), ...
        mean([c.hub(round(end / 2), 1), c.shroud(round(end / 2), 1)]), sprintf('  %s (%d)', c.name, c.n_blades), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Interpreter', 'none'); %#ok<NASGU>
end

if nargin > 2 && ~isempty(det)
    bd = det.blade;
    dz = chk.components.LE_hub_z(1) - bd.hub.z(1) * 1e3;
    plot(ax, bd.hub.z * 1e3 + dz, bd.hub.r * 1e3, 'r--', 'LineWidth', 1.4, 'DisplayName', 'MATLAB design');
    plot(ax, bd.shroud.z * 1e3 + dz, bd.shroud.r * 1e3, 'r--', 'LineWidth', 1.4, 'HandleVisibility', 'off');
    legend(ax, 'Location', 'northwest');
end
plot(ax, xlim(ax), [0 0], '-.', 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
xlabel(ax, 'z (axial) [mm]');
ylabel(ax, 'r (radial) [mm]');
title(ax, 'CFturbo export - meridional view (dotted: component interfaces)');
hold(ax, 'off');
end
