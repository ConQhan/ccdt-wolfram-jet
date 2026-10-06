function sw = cdt_run_sweep(in, progress_fcn)
%CDT_RUN_SWEEP Parametric sweep over the r2 x r1_hub grid in IN.
%   sw = cdt_run_sweep(in) evaluates every grid point with
%   cdt_evaluate_point and selects the design point.
%   sw = cdt_run_sweep(in, progress_fcn) calls progress_fcn(k, n) after each
%   point (used by the app to update a progress bar).
%
%   sw fields:
%     table    - one row per grid point (see cdt_evaluate_point)
%     designs  - cell array of design structs, aligned with table rows
%     selected - row index of the selected design (NaN if none feasible)
%     rule     - text describing how the design was selected
%     inputs   - copy of IN

if nargin < 2; progress_fcn = []; end
[R2, R1] = ndgrid(in.r2_mm, in.r1_hub_mm);
n = numel(R2);
rows = cell(n, 1);
designs = cell(n, 1);
for k = 1:n
    res = cdt_evaluate_point(in, R2(k), R1(k));
    rows{k} = res.row;
    designs{k} = res.design;
    if ~isempty(progress_fcn); progress_fcn(k, n); end
end
T = vertcat(rows{:});

sw.table = T;
sw.designs = designs;
sw.inputs = in;
[sw.selected, sw.rule] = cdt_select_design(T, in);
end

function [idx, rule] = cdt_select_design(T, in)
idx = NaN;
if ~isempty(in.select_r2_mm) && ~isempty(in.select_r1_hub_mm)
    k = find(abs(T.r2_mm - in.select_r2_mm) < 1e-9 & abs(T.r1_hub_mm - in.select_r1_hub_mm) < 1e-9, 1);
    if ~isempty(k) && ~isnan(T.eta_tt_pct(k))
        idx = k;
        rule = sprintf('user selection (r2 = %g, r1_hub = %g mm)', in.select_r2_mm, in.select_r1_hub_mm);
        return;
    end
end
cand = find(T.feasible);
if isempty(cand)
    rule = 'no feasible point';
    return;
end
[~, j] = max(T.eta_tt_pct(cand));
idx = cand(j);
rule = 'highest efficiency among feasible points';
end
