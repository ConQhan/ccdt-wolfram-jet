function res = cdt_evaluate_point(in, r2_mm, r1_hub_mm)
%CDT_EVALUATE_POINT Evaluate one (r2, r1_hub) combination of the sweep.
%   res = cdt_evaluate_point(in, r2_mm, r1_hub_mm) runs the Aungier
%   preliminary design and the 0D meanline performance chain for a single
%   geometry and applies the selection criteria in IN.
%
%   res fields:
%     ok_model     - true if the meanline solution converged and is physical
%     feasible     - ok_model and every selection criterion is met
%     reason       - text explaining why the point failed (empty if feasible)
%     row          - one-row table with the reported quantities
%     design       - design struct from design_preliminary_stage (if ok)
%     point        - sweep point struct from sweep_run_one_point

eos = cdt_eos(in);
r2 = r2_mm * 1e-3;
r1h = r1_hub_mm * 1e-3;
b2r2 = NaN;
if ~isnan(in.b2_mm); b2r2 = in.b2_mm / r2_mm; end
le = [in.le_thickness_hub_mm, in.le_thickness_shroud_mm] * 1e-3;
tc = in.tip_clearance_mm * 1e-3;
rmax = in.r_max_mm * 1e-3;

res = struct('ok_model', false, 'feasible', false, 'reason', '', 'row', [], ...
    'design', [], 'point', []);

pt = sweep_run_one_point(in.N_rpm, r2, in.mdot, in.diffuser_type, in.impeller_type, ...
    in.stage_type, in.p0, in.T0, eos, in.phi_min, in.phi_max, in.U2_max, ...
    in.splitter_ratio, r1h, rmax, 0.0, b2r2, [], tc, in.n_blades_main, le);
res.point = pt;

nan_row = @(why) cdt_row(r2_mm, r1_hub_mm, NaN(1, 9), false, why);
if ~pt.ok
    res.reason = pt.fail_reason;
    res.row = nan_row(pt.fail_reason);
    return;
end

d = design_preliminary_stage(in.mdot, in.p0, in.T0, in.N_rpm, r2, eos, in.impeller_type, ...
    in.diffuser_type, in.stage_type, in.splitter_ratio, [], [], r1h, rmax, [], 0.0, b2r2, [], ...
    tc, in.n_blades_main, le);

% Stage exit state, then the exit bend loss (zeta times exit dynamic head)
comps = sweep_build_components(eos, d, in.impeller_type, in.diffuser_type, in.stage_type);
st = new_station_state('0');
st.total = new_fluid_state(in.p0, in.T0);
st.mass_flow = in.mdot;
for k = 1:size(comps, 1)
    st = comps{k, 2}(st);
end
C4 = hypot(st.vel.Cm, st.vel.Cu);
rho4 = eos_density(eos, st.static.p, st.static.T);
PR_bend = (st.total.p - in.zeta_bend * 0.5 * rho4 * C4^2) / in.p0;

% Shaft: minimum solid diameter in torsion, margin against the hub bore
omega = 2 * pi * in.N_rpm / 60;
d_min = (16 * in.shaft_SF * (pt.Power_kW * 1e3 / omega) / (pi * in.shaft_tau_MPa * 1e6))^(1/3);
shaft_margin_pct = (2 * r1h / d_min - 1) * 100;
loading = d.tip.blade_loading_ratio;

why = {};
if PR_bend < in.PR_min; why{end+1} = sprintf('PR %.2f < %.2f', PR_bend, in.PR_min); end
if shaft_margin_pct < 0; why{end+1} = sprintf('shaft margin %.0f%%', shaft_margin_pct); end
if ~pt.fits_casing; why{end+1} = 'does not fit casing'; end
if loading >= in.blade_loading_max; why{end+1} = sprintf('blade loading %.2f', loading); end

res.ok_model = true;
res.feasible = isempty(why);
res.reason = strjoin(why, '; ');
res.design = d;
res.row = cdt_row(r2_mm, r1_hub_mm, [pt.b2_mm, pt.beta2_deg, pt.PR_tt, PR_bend, ...
    pt.eta_tt_pct, pt.Power_kW, pt.M1s_rel, loading, shaft_margin_pct], res.feasible, res.reason);
end

function T = cdt_row(r2_mm, r1h_mm, v, feasible, reason)
T = table(r2_mm, r1h_mm, v(1), v(2), v(3), v(4), v(5), v(6), v(7), v(8), v(9), ...
    feasible, string(reason), 'VariableNames', {'r2_mm', 'r1_hub_mm', 'b2_mm', ...
    'beta2_deg', 'PR_diffuser', 'PR_after_bend', 'eta_tt_pct', 'power_kW', 'M1s_rel', ...
    'blade_loading', 'shaft_margin_pct', 'feasible', 'reason'});
end
