function pt = sweep_run_one_point(rpm, r2_m, mdot, diffuser_type, impeller_type, stage_type, ...
    p0, T0, eos, phi_min, phi_max, U2_max, splitter_length_ratio, r_min_m, r_max_m, inlet_prewhirl_angle_deg, ...
    b2_over_r2_ratio, plenum_target_C_exit_m_s, tip_clearance_m, n_blades_full_fixed, le_thickness_m)
%SWEEP_RUN_ONE_POINT design/parametric_sweep.py :: _run_one_point() portu.
%   Tek bir kombinasyon noktasini calistirir; her hatayi yakalar.
%
%   [YENI] r_min_m, r_max_m, inlet_prewhirl_angle_deg -- opsiyonel, tum
%   taramadaki her noktaya SABIT olarak uygulanan kisitlar (govde/mil
%   yaricabi, kasa yaricabi, preswirl acisi). Verilmezse eski davranisla
%   BIREBIR AYNI (kisitsiz, preswirl=0).

if nargin < 13 || isempty(splitter_length_ratio)
    splitter_length_ratio = 0.50;
end
if nargin < 14; r_min_m = []; end
if nargin < 15; r_max_m = []; end
if nargin < 16 || isempty(inlet_prewhirl_angle_deg); inlet_prewhirl_angle_deg = 0.0; end
if nargin < 17 || isempty(b2_over_r2_ratio); b2_over_r2_ratio = NaN; end  % NaN -> b2 Aungier zincirinden
if nargin < 18; plenum_target_C_exit_m_s = []; end
if nargin < 19 || isempty(tip_clearance_m); tip_clearance_m = 0.0; end
if nargin < 20; n_blades_full_fixed = []; end
if nargin < 21; le_thickness_m = []; end

pt = new_sweep_point();
pt.rpm = rpm;
pt.r2_m = r2_m;
pt.mdot = mdot;
pt.diffuser_type = diffuser_type;
pt.impeller_type = impeller_type;
pt.stage_type = stage_type;
pt.p0 = p0;
pt.T0 = T0;
pt.splitter_length_ratio = splitter_length_ratio;
pt.r_min_m = r_min_m; pt.r_max_m = r_max_m; pt.inlet_prewhirl_angle_deg = inlet_prewhirl_angle_deg;
pt.b2_over_r2_ratio = b2_over_r2_ratio;
pt.plenum_target_C_exit_m_s = plenum_target_C_exit_m_s;

prev_warn_state = [];

try
    % --- Tasarim: Chapter 6 korelasyonlari ---
    design = design_preliminary_stage(mdot, p0, T0, rpm, r2_m, eos, impeller_type, ...
        diffuser_type, stage_type, splitter_length_ratio, [], [], r_min_m, r_max_m, [], ...
        inlet_prewhirl_angle_deg, b2_over_r2_ratio, plenum_target_C_exit_m_s, tip_clearance_m, n_blades_full_fixed, le_thickness_m);

    % --- Hizli on-filtre: phi ve U2 kisitlari ---
    omega_rad = 2.0 * 3.141592653589793 * rpm / 60.0;
    U2 = omega_rad * r2_m;
    if U2 > U2_max
        pt.fail_reason = sprintf('U2=%.0f > U2_max=%.0f m/s', U2, U2_max);
        return;
    end
    phi = design.phi;
    if ~(phi_min <= phi && phi <= phi_max)
        pt.fail_reason = sprintf('phi=%.4f disinda [%g,%g]', phi, phi_min, phi_max);
        return;
    end

    % --- Performans analizi: uyari = model gecerlilik siniri ---
    components = sweep_build_components(eos, design, impeller_type, diffuser_type, stage_type);
    inlet = new_station_state('0');
    inlet.total = new_fluid_state(p0, T0);
    inlet.mass_flow = mdot;

    prev_warn_state = warning('off', 'all');
    lastwarn('');
    result = run_stage_pipeline(components, inlet);
    [wmsg, wid] = lastwarn();
    warning(prev_warn_state);

    % Uyari varsa (model_validity_flagged, B4 siniri vb.) elenir
    if ~isempty(wid) && startsWith(wid, 'centrifugal:')
        pt.fail_reason = ['model_validity_flagged: ' wmsg(1:min(80, numel(wmsg)))];
        return;
    end

    summary = stage_result_summary(result, eos);

    pr = summary.pressure_ratio_total_to_total;
    eta = summary.isentropic_efficiency_total_to_total;
    w = summary.specific_work_J_per_kg;

    % --- [YENI] Fiziksel gecerlilik kontrolu: difuzor cikis hizi giristen
    % BUYUK olamaz (difuzorun tanimi geregi hizi DUSURMESI gerekir).
    % Boğazlanma siniri civarinda fzero bazen SAHTE (fiziksel olmayan,
    % sonik tepe noktasinin OTESINDEKI) bir kok buluyor -- bu durumda
    % pipeline hata FIRLATMIYOR ama sonuc anlamsiz (C_cikis > C_giris).
    % Bu kontrol olmadan boyle sahte cozumler "basarili" olarak
    % isaretlenip taramanin en iyi adaylari arasina sizabiliyordu.
    C2_exit_impeller = hypot(result.stations.impeller.vel.Cm, result.stations.impeller.vel.Cu);
    last_label = result.station_order{end};
    C_exit = hypot(result.stations.(last_label).vel.Cm, result.stations.(last_label).vel.Cu);
    pt.C2_impeller_exit_m_s = C2_exit_impeller;
    pt.C_exit_m_s = C_exit;
    pt.diffuser_physically_valid = C_exit <= C2_exit_impeller;
    if ~pt.diffuser_physically_valid
        pt.fail_reason = sprintf(...
            ['fiziksel_olmayan_cozum: difuzor cikis hizi (%.1f m/s) impeller cikis ' ...
             'hizindan (%.1f m/s) BUYUK -- bogazlanma sinirinda sahte/gecersiz bir kok ' ...
             'bulunmus olabilir.'], C_exit, C2_exit_impeller);
        return;
    end

    pt.ok = true;
    pt.phi = phi;
    pt.U2_m_s = U2;
    pt.PR_tt = pr;
    if ~isempty(eta)
        pt.eta_tt_pct = eta * 100.0;
    else
        pt.eta_tt_pct = NaN;
    end
    if ~isempty(w) && w
        pt.specific_work_kJ_kg = w / 1000.0;
        pt.Power_kW = mdot * pt.specific_work_kJ_kg;  % [YENI]
    else
        pt.specific_work_kJ_kg = NaN;
    end
    pt.mass_flow_balance_ok = summary.mass_flow_balance_ok;

    % --- [YENI] Inducer shroud bagil Mach sayisi (M1s_rel) ---
    imp_for_M1s = impeller_new(eos, struct(), design.impeller_geometry, struct('mass_flow_tolerance', 1e-6));
    station1 = impeller_solve_station1(imp_for_M1s, p0, T0, mdot);
    T1s_static = T0 - station1.W1_shroud^2 / (2.0 * eos.cp);
    a1s = eos_speed_of_sound(eos, station1.p1, T1s_static);
    pt.M1s_rel = station1.W1_shroud / a1s;

    % --- Impeller geometrisi ---
    g = design.impeller_geometry;
    pt.r1_hub_mm = g.r1_hub_m * 1000.0;
    pt.r1_shroud_mm = g.r1_shroud_m * 1000.0;
    pt.r2_mm = g.r2_m * 1000.0;
    pt.b2_mm = g.b2_m * 1000.0;
    pt.beta1_deg = g.blade_angle_1_deg;
    pt.beta2_deg = g.blade_angle_2_deg;
    pt.n_blades_full = g.n_blades_full;
    pt.n_blades_splitter = g.n_blades_splitter;
    pt.axial_length_mm = g.blade_mean_camberline_length_m * 1000.0;  % yaklasim

    % --- Difuzor geometrisi ---
    dg = design.diffuser_geometry;
    pt.r4_mm = dg.r4_m * 1000.0;
    pt.b4_mm = dg.b4_m * 1000.0;
    if strcmp(diffuser_type, 'vaned')
        pt.r3_mm = struct_get(dg, 'r3_m_for_inlet_station', dg.r4_m) * 1000.0;
        pt.n_vanes_diffuser = struct_get(dg, 'n_vanes', 0);
        pt.beta3_diff_deg = struct_get(dg, 'blade_angle_3_deg', NaN);
        pt.beta4_diff_deg = struct_get(dg, 'blade_angle_4_deg', NaN);
    else
        pt.r3_mm = pt.r4_mm;  % vanesiz: giris = cikis yaricapi
    end

    % --- Crossover + Return channel ---
    if strcmp(stage_type, 'return_channel')
        cg = design.crossover_geometry;
        pt.r6_mm = struct_get(cg, 'r6_m', 0.0) * 1000.0;
        pt.b6_mm = struct_get(cg, 'b6_m', 0.0) * 1000.0;
        pt.R_ch_mm = struct_get(cg, 'R_ch_m', 0.0) * 1000.0;
        rcg = design.return_channel_geometry;
        pt.r7_mm = struct_get(rcg, 'r7_m', 0.0) * 1000.0;
        pt.b7_mm = struct_get(rcg, 'b7_m', 0.0) * 1000.0;
    end

    % --- Volut ---
    if strcmp(stage_type, 'voluted') && ~isempty(fieldnames(design.volute_geometry))
        vg = design.volute_geometry;
        pt.r_volute_mm = struct_get(vg, 'r6_m', 0.0) * 1000.0;
        pt.A_volute_cm2 = struct_get(vg, 'A6_m2', 0.0) * 1e4;
    end

    % --- [YENI] Dump plenum ---
    if strcmp(stage_type, 'dump_with_plenum')
        st5 = result.stations.plenum;
        pt.r5_mm = st5.geom.r * 1000.0;
        pt.b5_mm = st5.geom.b * 1000.0;
        pt.A5_cm2 = st5.geom.area * 1e4;
    end

    % --- [YENI] Genel disaridan boyut kontrolu ---
    pt.D2_mm = pt.r2_mm * 2.0;
    pt.D_overall_mm = 2.0 * max([pt.r4_mm, pt.r_volute_mm, pt.r6_mm, pt.r5_mm], [], 'omitnan');
    if ~isempty(r_max_m)
        pt.fits_casing = (pt.D_overall_mm / 2.0) <= (r_max_m * 1000.0 + 1e-6);
    end

    % --- Kayip katsayilari ---
    lc = struct_get(summary, 'total_loss_coefficients', struct());
    pt.omega_impeller = struct_get(lc, 'impeller', NaN);
    pt.omega_diffuser = struct_get(lc, 'vaneless_diffuser', struct_get(lc, 'vaned_diffuser', NaN));
    pt.omega_crossover = struct_get(lc, 'crossover_bend', NaN);
    pt.omega_return_channel = struct_get(lc, 'return_channel', NaN);
    pt.omega_volute = struct_get(lc, 'volute_2', struct_get(lc, 'volute', NaN));
    pt.omega_plenum = struct_get(lc, 'plenum', NaN);

catch exc
    if ~isempty(prev_warn_state)
        warning(prev_warn_state);
    end
    msg = exc.message;
    pt.fail_reason = msg(1:min(120, numel(msg)));
    % [YENI] design_preliminary_stage kendi asamasinda zaten bir kapasite
    % uyarisi ureттiyse (ornegin vanli difuzor boguzu icin), pipeline
    % daha sonra kriptik bir hatayla cokerse fail_reason'i o daha ACIK
    % ve ERKEN teshisle degistiriyoruz.
    if exist('design', 'var') && isfield(design, 'warnings')
        for wi = 1:numel(design.warnings)
            if contains(design.warnings{wi}, 'BOGAZLANABILIR')
                w = design.warnings{wi};
                pt.fail_reason = ['design_stage_uyardi: ' w(1:min(110, numel(w)))];
                break;
            end
        end
    end
end

end
