function cdt_plot_blade(axs, det)
%CDT_PLOT_BLADE Blade angle and wrap angle distributions (Aungier Eq 6-17).
%   cdt_plot_blade(axs, det) draws on AXS(1) the hub and shroud blade angle
%   (from tangential) versus normalised meridional length, and on AXS(2)
%   the wrap angle theta. DET comes from cdt_design_details.

bd = det.blade;
c_hub = [0.10 0.30 0.80];
c_sh = [0.10 0.55 0.20];

ax = axs(1);
cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
plot(ax, bd.hub.zeta, bd.hub.beta_deg, '-', 'Color', c_hub, 'LineWidth', 1.8, 'DisplayName', 'Hub');
plot(ax, bd.shroud.zeta, bd.shroud.beta_deg, '-', 'Color', c_sh, 'LineWidth', 1.8, 'DisplayName', 'Shroud');
xlabel(ax, 'm / L  (0 = LE, 1 = TE)');
ylabel(ax, '\beta_B [deg, from tangential]');
title(ax, sprintf('Blade angle (K = %.2f, rake LE/TE = %+.1f / %+.1f deg)', ...
    bd.K, bd.rake_LE_deg, bd.rake_TE_deg));
legend(ax, 'Location', 'best');
hold(ax, 'off');

ax = axs(2);
cla(ax); hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');
plot(ax, bd.hub.zeta, rad2deg(bd.hub.theta_rad), '-', 'Color', c_hub, 'LineWidth', 1.8, 'DisplayName', 'Hub');
plot(ax, bd.shroud.zeta, rad2deg(bd.shroud.theta_rad), '-', 'Color', c_sh, 'LineWidth', 1.8, 'DisplayName', 'Shroud');
xlabel(ax, 'm / L  (0 = LE, 1 = TE)');
ylabel(ax, '\theta [deg]');
title(ax, sprintf('Wrap angle (hub %.1f, shroud %.1f deg)', bd.wrap_hub_deg, bd.wrap_shroud_deg));
legend(ax, 'Location', 'best');
hold(ax, 'off');
end
