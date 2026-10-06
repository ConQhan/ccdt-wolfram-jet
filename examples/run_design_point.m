%RUN_DESIGN_POINT Same workflow as the app, without the user interface.
%   Runs a small sweep, evaluates the selected design and writes every
%   table and figure to a time-stamped folder under output/.

tool_root = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(tool_root, 'lib')));
addpath(fullfile(tool_root, 'api'));

in = cdt_default_inputs();
in.b2_mm = 5.41;            % fixed exit width (V2/V3 geometry)
in.r2_mm = 64:1:68;
in.r1_hub_mm = 8:1:12;

sw = cdt_run_sweep(in, @(k, n) fprintf('point %d / %d\n', k, n));
disp(sw.table(:, 1:12));
if isnan(sw.selected)
    error('No feasible design: relax the selection criteria.');
end
fprintf('Selected: %s\n', sw.rule);

det = cdt_design_details(in, sw.designs{sw.selected});
disp(det.summary);
disp(det.checks(:, 1:5));
disp(cdt_cfturbo_inputs(in, det));

folder = cdt_export(sw, det);
fprintf('Results written to %s\n', folder);
