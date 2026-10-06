function mp = cdt_compressor_map(in, design, speed_frac, flow_frac, progress_fcn)
%CDT_COMPRESSOR_MAP Off-design speed lines of a fixed geometry (meanline).
%   mp = cdt_compressor_map(in, design) evaluates the stage at
%   60, 70, 80, 90 and 100 % of the design speed, for mass flows from 30 %
%   to 130 % of the design mass flow scaled with speed.
%   mp = cdt_compressor_map(in, design, speed_frac, flow_frac) sets both lists
%   (fractions of the design speed and of the speed-scaled design flow).
%   progress_fcn(k, n) is called after each speed line.
%
%   mp fields:
%     points  - table: speed_rpm, speed_pct, mdot, PR_tt, eta_tt_pct,
%               work_kJ_kg, ok, model_valid (false = loss model flags stall)
%     lines   - table per speed: smallest / largest solved mass flow (the
%               largest is the meanline choke estimate), mass flow at the PR
%               peak (surge estimate) and the best efficiency point
%     surge_margin_pct - (PR/mdot at the PR peak) / (PR/mdot at design) - 1
%     design  - design speed and mass flow
%
%   Notes: this is the meanline model on the design geometry, diffuser
%   exit conditions (no exit bend loss). The surge edge is taken at the PR
%   peak of each speed line; the choke edge is where the meanline solution
%   stops existing. Both are estimates; CFD speed lines are the reference.

if nargin < 3 || isempty(speed_frac); speed_frac = [0.6 0.7 0.8 0.9 1.0]; end
if nargin < 4 || isempty(flow_frac); flow_frac = 0.30:0.05:1.30; end
if nargin < 5; progress_fcn = []; end
eos = cdt_eos(in);

rows = {};
lines = {};
for k = 1:numel(speed_frac)
    rpm = in.N_rpm * speed_frac(k);
    d = design;
    d.impeller_geometry.rotational_speed_rpm = rpm;
    factory = @(r) sweep_build_components(eos, d, in.impeller_type, in.diffuser_type, in.stage_type);
    mdots = in.mdot * speed_frac(k) * flow_frac;
    cmap = compute_compressor_map(eos, factory, rpm, mdots, in.p0, in.T0, in.N_rpm, in.mdot, false);
    curve = cmap.speedlines(1);
    for p = curve.points
        rows(end + 1, :) = {rpm, 100 * speed_frac(k), p.mdot, p.PR_tt, p.eta_tt_pct, ...
            p.specific_work_kJ_kg, p.ok, p.ok && p.model_valid}; %#ok<AGROW>
    end
    ok = [curve.points.ok] & [curve.points.model_valid];
    m = [curve.points.mdot];
    eta = [curve.points.eta_tt_pct];
    pr = [curve.points.PR_tt];
    if any(ok)
        [~, ib] = max(eta .* ok - 1e9 * ~ok);
        [~, ip] = max(pr .* ok - 1e9 * ~ok);
        lines(end + 1, :) = {rpm, 100 * speed_frac(k), min(m(ok)), m(ip), pr(ip), max(m(ok)), m(ib), ...
            pr(ib), eta(ib)}; %#ok<AGROW>
    else
        lines(end + 1, :) = {rpm, 100 * speed_frac(k), NaN, NaN, NaN, NaN, NaN, NaN, NaN}; %#ok<AGROW>
    end
    if ~isempty(progress_fcn); progress_fcn(k, numel(speed_frac)); end
end
mp.points = cell2table(rows, 'VariableNames', {'speed_rpm', 'speed_pct', 'mdot', 'PR_tt', ...
    'eta_tt_pct', 'work_kJ_kg', 'solved', 'valid'});
mp.lines = cell2table(lines, 'VariableNames', {'speed_rpm', 'speed_pct', 'mdot_min_solved', ...
    'mdot_PR_peak', 'PR_peak', 'mdot_max_solved', 'mdot_best_eta', 'PR_best_eta', 'eta_best'});

% Surge margin estimate at design speed: surge taken at the PR peak
% (left of the peak the speed line has a positive slope and is unstable).
mp.surge_margin_pct = NaN;
k = find(abs(speed_frac - 1) < 1e-9, 1);
if ~isempty(k)
    P = mp.points(mp.points.speed_pct == 100 & mp.points.valid, :);
    if ~isempty(P)
        PRd = interp1(P.mdot, P.PR_tt, in.mdot, 'linear', NaN);
        L = mp.lines(k, :);
        mp.surge_margin_pct = 100 * ((L.PR_peak / L.mdot_PR_peak) / (PRd / in.mdot) - 1);
    end
end
mp.design = struct('N_rpm', in.N_rpm, 'mdot', in.mdot);
end
