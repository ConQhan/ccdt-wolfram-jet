function cdt_plot_map(axs, mp)
%CDT_PLOT_MAP Compressor map: PR and efficiency versus mass flow.
%   cdt_plot_map(axs, mp) draws the speed lines of cdt_compressor_map on
%   AXS(1) (total pressure ratio) and AXS(2) (efficiency). The PR peak of
%   every speed line (surge estimate) is joined by a dashed line; the
%   design point is marked with a star.

P = mp.points(mp.points.valid, :);
sp = unique(P.speed_pct);
cols = parula(numel(sp) + 1);
for a = 1:2
    ax = axs(a);
    cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
    for k = 1:numel(sp)
        s = P(P.speed_pct == sp(k), :);
        if a == 1; y = s.PR_tt; else; y = s.eta_tt_pct; end
        plot(ax, s.mdot, y, '-o', 'Color', cols(k, :), 'MarkerFaceColor', cols(k, :), 'MarkerSize', 4, ...
            'LineWidth', 1.4, 'DisplayName', sprintf('%g %%', sp(k)));
    end
    xlabel(ax, 'Mass flow [kg/s]');
end
L = mp.lines(~isnan(mp.lines.mdot_PR_peak), :);
plot(axs(1), L.mdot_PR_peak, L.PR_peak, 'k--', 'LineWidth', 1.2, 'DisplayName', 'PR peak (surge est.)');
d = P(P.speed_pct == 100, :);
if ~isempty(d)
    PRd = interp1(d.mdot, d.PR_tt, mp.design.mdot, 'linear', NaN);
    etad = interp1(d.mdot, d.eta_tt_pct, mp.design.mdot, 'linear', NaN);
    plot(axs(1), mp.design.mdot, PRd, 'kp', 'MarkerSize', 14, 'MarkerFaceColor', [1 0.85 0], 'DisplayName', 'design');
    plot(axs(2), mp.design.mdot, etad, 'kp', 'MarkerSize', 14, 'MarkerFaceColor', [1 0.85 0], 'HandleVisibility', 'off');
end
ylabel(axs(1), 'PR_{tt} (diffuser exit) [-]');
ylabel(axs(2), '\eta_{tt} [%]');
title(axs(1), sprintf('Speed lines (meanline) - surge margin at design %.0f %%', mp.surge_margin_pct));
title(axs(2), 'Efficiency');
legend(axs(1), 'Location', 'southeast', 'FontSize', 8);
hold(axs(1), 'off'); hold(axs(2), 'off');
end
