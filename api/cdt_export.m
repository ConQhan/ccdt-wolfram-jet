function folder = cdt_export(sw, det, out_root, extra)
%CDT_EXPORT Write sweep, design, blade and CFturbo results to a folder.
%   folder = cdt_export(sw, det) writes CSV tables and PNG figures to a new
%   time-stamped folder under <tool>/output and returns its path.
%   folder = cdt_export(sw, det, out_root) uses OUT_ROOT instead.
%   DET may be empty (only the sweep is written).
%   folder = cdt_export(sw, det, out_root, extra) also writes the optional
%   results in EXTRA: extra.cfturbo = struct('comps', .., 'chk', ..),
%   extra.stator = cdt_stator_sizing output, extra.map = cdt_compressor_map output.

if nargin < 3 || isempty(out_root)
    out_root = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'output');
end
folder = fullfile(out_root, ['run_' char(datetime('now', 'Format', 'yyyyMMdd_HHmmss'))]);
mkdir(folder);

if nargin < 2; det = []; end
if nargin < 4; extra = struct(); end
if ~isempty(sw)
    in = sw.inputs;
    save(fullfile(folder, 'inputs.mat'), 'in');
    writetable(sw.table, fullfile(folder, 'sweep.csv'));
    f = figure('Visible', 'off', 'Position', [100 100 1100 750]);
    tl = tiledlayout(f, 2, 2);
    axs = gobjects(1, 4);
    for k = 1:4; axs(k) = nexttile(tl); end
    cdt_plot_sweep(axs, sw);
    exportgraphics(f, fullfile(folder, 'sweep.png'), 'Resolution', 200);
    close(f);
end

cdt_export_extra(folder, extra, det);
if isempty(det) || isempty(sw); return; end
in = sw.inputs;
writetable(det.summary, fullfile(folder, 'design_summary.csv'));
writetable(det.stations, fullfile(folder, 'stations.csv'));
writetable(det.checks, fullfile(folder, 'aungier_checks.csv'));
writetable(det.blade.span_table, fullfile(folder, 'blade_spans.csv'));
writetable(det.wrap, fullfile(folder, 'cfturbo_wrap.csv'));
writetable(cdt_cfturbo_inputs(in, det), fullfile(folder, 'cfturbo_inputs.csv'));

f = figure('Visible', 'off', 'Position', [100 100 1100 420]);
tl = tiledlayout(f, 1, 2);
cdt_plot_blade([nexttile(tl), nexttile(tl)], det);
exportgraphics(f, fullfile(folder, 'blade_angles.png'), 'Resolution', 200);
close(f);

geo = cdt_meridional_geometry(det);
modes = {'dimensions', 'symbols'};
for k = 1:2
    f = figure('Visible', 'off', 'Position', [100 100 900 800]);
    cdt_plot_meridional(axes(f), geo, modes{k});
    exportgraphics(f, fullfile(folder, ['meridional_' modes{k} '.png']), 'Resolution', 200);
    close(f);
end
end

function cdt_export_extra(folder, extra, det)
if isfield(extra, 'cfturbo') && ~isempty(extra.cfturbo)
    chk = extra.cfturbo.chk;
    writetable(chk.components, fullfile(folder, 'cfturbo_export_components.csv'));
    if ~isempty(chk.interfaces); writetable(chk.interfaces, fullfile(folder, 'cfturbo_export_interfaces.csv')); end
    if ~isempty(chk.compare); writetable(chk.compare, fullfile(folder, 'cfturbo_vs_matlab.csv')); end
    writelines(chk.warnings, fullfile(folder, 'cfturbo_export_warnings.txt'));
    f = figure('Visible', 'off', 'Position', [100 100 1000 900]);
    cdt_plot_cfturbo_meridional(axes(f), extra.cfturbo.comps, det);
    exportgraphics(f, fullfile(folder, 'cfturbo_export_meridional.png'), 'Resolution', 200);
    close(f);
end
if isfield(extra, 'stator') && ~isempty(extra.stator)
    writetable(extra.stator.table, fullfile(folder, 'stator_sizing.csv'));
    writetable(struct2table(extra.stator.station3), fullfile(folder, 'stator_vaneless_gap.csv'));
end
if isfield(extra, 'map') && ~isempty(extra.map)
    writetable(extra.map.points, fullfile(folder, 'map_points.csv'));
    writetable(extra.map.lines, fullfile(folder, 'map_speedlines.csv'));
    f = figure('Visible', 'off', 'Position', [100 100 1100 450]);
    tl = tiledlayout(f, 1, 2);
    cdt_plot_map([nexttile(tl), nexttile(tl)], extra.map);
    exportgraphics(f, fullfile(folder, 'map.png'), 'Resolution', 200);
    close(f);
end
end
