function det = cdt_design_details(in, design)
%CDT_DESIGN_DETAILS Full evaluation of one selected design.
%   det = cdt_design_details(in, design) returns everything shown on the
%   design-point, blade and CFturbo pages of the app:
%
%     summary   - table: quantity / value / unit
%     stations  - table of total and static states at each station
%     checks    - Aungier design checklist (PASS / MARGINAL / FAIL)
%     blade     - Aungier Eq 6-17 hub/shroud blade angle distribution
%     wrap      - CFturbo wrap angle table (5 spans)
%     impeller  - impeller-only PR, efficiency and power
%     s1, s2    - impeller inlet and exit station states
%     design    - the design struct (copy)

eos = cdt_eos(in);
g = design.impeller_geometry;

imp = impeller_new(eos, struct(), g, struct('mass_flow_tolerance', 1e-6));
in0 = new_station_state('0');
in0.total = new_fluid_state(in.p0, in.T0);
in0.mass_flow = in.mdot;
s2 = impeller_compute(imp, in0);
s1 = impeller_solve_station1(imp, in.p0, in.T0, in.mdot);
bd = aungier_blade_angle_distribution(design, s1, in.n_blade_points);
checks = cdt_translate_checks(aungier_design_checks(design, s1, s2, eos));

% Impeller-only performance (what CFturbo needs for its velocity triangles)
gam = eos.gamma;
PR_imp = s2.total.p / in.p0;
TR_imp = s2.total.T / in.T0;
eta_imp = (PR_imp^((gam - 1) / gam) - 1) / (TR_imp - 1);
P_imp_kW = in.mdot * eos.cp * (s2.total.T - in.T0) / 1e3;
det.impeller = struct('PR_tt', PR_imp, 'eta_tt', eta_imp, 'power_kW', P_imp_kW);

% Whole stage, station by station
comps = sweep_build_components(eos, design, in.impeller_type, in.diffuser_type, in.stage_type);
res = run_stage_pipeline(comps, in0);
det.stations = cdt_station_table(res, eos);
det.stage = stage_result_summary(res, eos);

% CFturbo wrap table: LE phi and TE delta-phi per span (hub LE = reference)
span = [0; 0.25; 0.5; 0.75; 1.0];
phi_LE = rad2deg(bd.shroud.theta_rad(1)) * span;
theta_TE = rad2deg(bd.hub.theta_rad(end) + (bd.shroud.theta_rad(end) - bd.hub.theta_rad(end)) * span);
det.wrap = table({'1 (Hub)'; '2'; '3 (Middle)'; '4'; '5 (Shroud)'}, phi_LE, theta_TE - phi_LE, ...
    'VariableNames', {'span', 'LE_phi_deg', 'TE_dphi_deg'});

det.s1 = s1;
det.s2 = s2;
det.blade = bd;
det.checks = checks;
det.design = design;
det.summary = cdt_summary_table(in, design, det, s1, s2);
end

function T = cdt_translate_checks(C)
% The library returns Turkish labels; translate them for the app.
names = containers.Map( ...
    {'dW/Wbar (kanat yukleme)', 'W2/W1 (cark difuzyonu)', 'W2/W1s (bilgi: shroud referansli)', ...
     'Deq (esdeger difuzyon)', 'W1s/Wth (inducer stall)', 'A_th/A* (tikanma payi)', ...
     '|kappa_m*b| (gecis egriligi)', 'b/Rc (genislik/egrilik yaricapi)', 'Cm_min/Cm_max (hub-shroud)'}, ...
    {'Blade loading dW/W', 'Impeller diffusion W2/W1', 'W2/W1s (info, shroud based)', ...
     'Equivalent diffusion Deq', 'Inducer stall W1s/Wth', 'Choke margin A_th/A*', ...
     'Turning curvature |kappa_m b|', 'Width / curvature radius b/Rc', 'Hub-shroud Cm_min/Cm_max'});
status = containers.Map({'GECTI', 'SINIRDA', 'KALDI'}, {'PASS', 'MARGINAL', 'FAIL'});
crit = C.kriter;
for k = 1:numel(crit)
    if isKey(names, crit{k}); crit{k} = names(crit{k}); end
end
st = C.durum;
for k = 1:numel(st)
    if isKey(status, st{k}); st{k} = status(st{k}); end
end
pref = strrep(C.tercih, 'ustu', 'or above');
src = regexprep(C.kaynak, '\(.*', '');
T = table(string(crit), C.deger, string(pref), string(C.kesin_sinir), string(st), string(strtrim(src)), ...
    'VariableNames', {'criterion', 'value', 'preferred', 'hard_limit', 'status', 'source'});
T.hard_limit = replace(T.hard_limit, 'on tasarim', 'preliminary');
end

function T = cdt_station_table(res, eos)
labels = res.station_order;
n = numel(labels);
[pt, Tt, p, Ts, Cm, Cu, C, M] = deal(NaN(n, 1));
for k = 1:n
    s = res.stations.(labels{k});
    pt(k) = s.total.p; Tt(k) = s.total.T;
    if ~isempty(s.static) && isfield(s.static, 'p') && s.static.p > 0
        p(k) = s.static.p; Ts(k) = s.static.T;
    end
    if ~isnan(p(k)) && ~isempty(s.vel) && isfield(s.vel, 'Cm')
        Cm(k) = s.vel.Cm; Cu(k) = s.vel.Cu; C(k) = hypot(Cm(k), Cu(k));
        if ~isnan(Ts(k)); M(k) = C(k) / eos_speed_of_sound(eos, p(k), Ts(k)); end
    end
end
T = table(string(labels(:)), pt / 1e3, Tt, p / 1e3, Ts, Cm, Cu, C, M, 'VariableNames', ...
    {'station', 'pt_kPa', 'Tt_K', 'p_kPa', 'T_K', 'Cm_m_s', 'Cu_m_s', 'C_m_s', 'Mach'});
end

function T = cdt_summary_table(in, d, det, s1, s2)
g = d.impeller_geometry;
dg = d.diffuser_geometry;
st = det.stage;
q = {
    'Mass flow',                      in.mdot,                         'kg/s'
    'Shaft speed',                    in.N_rpm,                        'rpm'
    'Tip speed U2',                   d.U2,                            'm/s'
    'Flow coefficient phi',           d.phi,                           '-'
    'Stage PR (total-total)',         st.pressure_ratio_total_to_total,'-'
    'Stage efficiency (total-total)', 100 * st.isentropic_efficiency_total_to_total, '%'
    'Impeller PR (total-total)',      det.impeller.PR_tt,              '-'
    'Impeller efficiency',            100 * det.impeller.eta_tt,       '%'
    'Shaft power',                    det.impeller.power_kW,           'kW'
    'r1 hub',                         g.r1_hub_m * 1e3,                'mm'
    'r1 shroud',                      g.r1_shroud_m * 1e3,             'mm'
    'r2',                             g.r2_m * 1e3,                    'mm'
    'b2',                             g.b2_m * 1e3,                    'mm'
    'b2 source',                      NaN,                             char(strrep(string(d.tip.b2_source), 'sureklilik', 'continuity'))
    'Blade angle beta2 (from tangential)', g.blade_angle_2_deg,        'deg'
    'Blades (main + splitter)',       g.n_blades_full + g.n_blades_splitter, '-'
    'Axial length (Eq 6-3)',          g.axial_length_z_m * 1e3,        'mm'
    'Inducer shroud W1',              s1.W1_shroud,                    'm/s'
    'Impeller exit Cm2',              s2.vel.Cm,                       'm/s'
    'Impeller exit Cu2',              s2.vel.Cu,                       'm/s'
    'Mean incidence i1',              d.tip.i1_deg,                    'deg'
    'Throat margin A_th/A* (Eq 6-15, >= 1.2)', d.tip.throat_margin,   '-'
    'Blade loading dW/W (Eq 7-60, <= 0.8)', d.tip.blade_loading_ratio, '-'
    'Diffuser exit radius r4',        dg.r4_m * 1e3,                   'mm'
    'Diffuser exit width b4',         dg.b4_m * 1e3,                   'mm'
    };
T = cell2table(q, 'VariableNames', {'quantity', 'value', 'unit'});
end
