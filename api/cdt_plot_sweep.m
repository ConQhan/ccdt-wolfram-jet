function cdt_plot_sweep(axs, sw)
%CDT_PLOT_SWEEP Plot sweep results on four axes.
%   cdt_plot_sweep(axs, sw) draws PR after bend, efficiency, power and
%   inducer relative Mach number versus r2, one line per r1_hub value.
%   Filled markers: feasible points; hollow markers: points that fail a
%   selection criterion. The selected design is marked with a star.
%   AXS is a 1x4 array of axes or uiaxes.

T = sw.table;
in = sw.inputs;
fields = {'PR_after_bend', 'eta_tt_pct', 'power_kW', 'M1s_rel'};
labels = {'PR after bend [-]', '\eta_{tt} [%]', 'Power [kW]', 'M_{1s,rel} [-]'};
h = unique(T.r1_hub_mm);
cols = lines(numel(h));

for p = 1:4
    ax = axs(p);
    cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    for k = 1:numel(h)
        s = T(T.r1_hub_mm == h(k), :);
        y = s.(fields{p});
        plot(ax, s.r2_mm, y, '-', 'Color', cols(k, :), 'LineWidth', 1.2, ...
            'DisplayName', sprintf('r_{1h} = %g mm', h(k)));
        f = s.feasible;
        plot(ax, s.r2_mm(f), y(f), 'o', 'Color', cols(k, :), 'MarkerFaceColor', cols(k, :), ...
            'MarkerSize', 5, 'HandleVisibility', 'off');
        plot(ax, s.r2_mm(~f), y(~f), 'o', 'Color', cols(k, :), 'MarkerSize', 5, ...
            'HandleVisibility', 'off');
    end
    if ~isnan(sw.selected)
        plot(ax, T.r2_mm(sw.selected), T.(fields{p})(sw.selected), 'kp', 'MarkerSize', 14, ...
            'MarkerFaceColor', [1 0.85 0], 'HandleVisibility', 'off');
    end
    if p == 1
        yline(ax, in.PR_min, 'r--', 'PR_{min}', 'HandleVisibility', 'off');
        legend(ax, 'Location', 'best', 'FontSize', 8);
    end
    xlabel(ax, 'r_2 [mm]');
    ylabel(ax, labels{p});
    hold(ax, 'off');
end
end
