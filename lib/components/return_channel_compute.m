function station7 = return_channel_compute(eos, geometry, inlet_station)
%RETURN_CHANNEL_COMPUTE components/return_channel.py :: ReturnChannel.compute() portu.
%   Eq. (5-89) -> (5-98)'i zincirleyen return channel analizi. Impeller/
%   vaned diffuser ile AYNI mimari desen: throat kontraksiyon/tikanma,
%   ayrik kayip terimleri, dis donguide Cm7 uzerinde fzero.

g = geometry;

r6 = inlet_station.geom.r;
b6 = inlet_station.geom.b;
Cm6 = inlet_station.vel.Cm;
Cu6 = inlet_station.vel.Cu;
p6 = inlet_station.static.p;
T6 = inlet_station.static.T;
mdot_target = inlet_station.mass_flow;

C6 = hypot(Cm6, Cu6);
alpha6 = atan2(Cm6, Cu6);
pt6_state = eos_total_from_static(eos, p6, T6, C6);
pt6 = pt6_state.p; Tt6 = pt6_state.T;
A6 = 2.0 * pi * r6 * b6;

r7 = g.r7_m;
b7 = g.b7_m;
r7_shroud = struct_get(g, 'r7_shroud_m', r7 + 0.5 * b7);
r7_hub = struct_get(g, 'r7_hub_m', r7 - 0.5 * b7);
beta6 = deg2rad(g.blade_angle_6_deg);
beta7 = deg2rad(struct_get(g, 'blade_angle_7_deg', 90.0));
beta_mid = deg2rad(struct_get(g, 'blade_angle_mid_deg', 0.5 * (g.blade_angle_6_deg + struct_get(g, 'blade_angle_7_deg', 90.0))));
z = g.n_vanes;
A_th = g.throat_area_m2;
L_B = g.blade_mean_camberline_length_m;
d_H = g.mean_hydraulic_diameter_m;
cf_override = struct_get(g, 'skin_friction_cf', []);
mu = struct_get(g, 'mu_Pa_s', 1.8e-5);
roughness_m = struct_get(g, 'roughness_m', 1.0e-6);
rho6 = eos_density(eos, p6, T6);
tb7 = struct_get(g, 'vane_trailing_edge_thickness_m', 0.0008);

kappa_m = struct_get(g, 'kappa_m_crossover', 0.0);
rb_max_stall_free = struct_get(g, 'rb_max_stall_free_m2', r6 * b6);
alpha_C6 = deg2rad(struct_get(g, 'alpha_C6_deg', 90.0));
alpha_C7 = deg2rad(struct_get(g, 'alpha_C7_deg', 90.0));

% --- Giris blokaji (Eq 5-89/5-90, buyuk olan kullanilir) ---
B6_stall = inlet_blockage_stall(rb_max_stall_free, r6, b6);
B6_curv = inlet_blockage_curvature(kappa_m, b6);
B6 = max(B6_stall, B6_curv);

% --- Throat: kontraksiyon, tikanma, throat hizi ---
C_th = solve_meridional_velocity(mdot_target, A_th, 0.0, 0.0, pt6, Tt6, eos);
Cr = throat_contraction_ratio(A6, beta6, A_th);
A_star = sonic_area(mdot_target, pt6, Tt6, eos.gamma, eos.R);
omega_CH = choking_loss(Cr, A_th, A_star);

% --- Hucum kaybi (Eq 5-91/5-92) -- Cm7'den BAGIMSIZ, bir kez ---
alpha_th = geometric_throat_flow_angle(A_th, A6);
alpha_star = minimum_loss_incidence_angle(B6, alpha_th);
omega_inc = return_channel_incidence_loss(Cm6, C6, alpha_star);

% --- Cikis akis acisi (Eq 5-100->104) -- bir kez ---
[a_over_c, sigma, theta] = return_channel_camber_and_solidity(beta6, beta7, beta_mid, r6, r7, z);
delta_star_deg = deviation_angle_minimum_loss(a_over_c, sigma, rad2deg(theta), rad2deg(beta6));
d_delta_di = deviation_sensitivity(rad2deg(beta6), sigma);
alpha7_deg = discharge_flow_angle(rad2deg(beta7), delta_star_deg, d_delta_di, rad2deg(beta6), rad2deg(alpha6));

if ~(alpha7_deg >= 5.0 && alpha7_deg <= 85.0)
    error('centrifugal:return_channel_compute', ...
        ['ReturnChannel: hesaplanan cikis akis acisi alpha7=%.2f derece fiziksel ' ...
         'olarak makul [5,85] derece araliginin disinda. Ara degerler: a/c=%.4f, ' ...
         'sigma=%.4f, theta=%.2f derece, delta*=%.2f derece.'], ...
        alpha7_deg, a_over_c, sigma, rad2deg(theta), delta_star_deg);
end

tan_alpha7 = tan(deg2rad(alpha7_deg));

B_M7 = z * tb7 / (2.0 * pi * r7);  % [BASITLESTIRME] vane metal blokaji
A7 = 2.0 * pi * r7 * b7 * (1.0 - B_M7);

omega_fixed = omega_inc + omega_CH;

last_Cu7 = []; last_C7 = []; last_pt7 = []; last_Tt7 = []; last_static7 = []; last_sum_omega = []; last_mdot_calc = [];

    function r = residual(Cm7)
        Cu7_ = Cm7 / tan_alpha7;
        C7_ = hypot(Cm7, Cu7_);

        C_bar = mean_velocity_for_friction(C6, C7_, C_th);
        if ~isempty(cf_override)
            cf = cf_override;
        else
            Re_d = reynolds_number(rho6, C_bar, d_H, mu);
            cf = skin_friction_coefficient(Re_d, roughness_m, d_H);
        end
        omega_SF = return_channel_skin_friction_loss(cf, C_bar, C6, L_B, d_H, Cm6, Cm7, alpha_C6, alpha_C7);

        delta_C = average_blade_to_blade_velocity_difference(r6, Cu6, r7, Cu7_, z, L_B);
        omega_BL = return_channel_blade_loading_loss(delta_C, C6);

        C_max = max_vane_surface_velocity(C6, C7_, delta_C);
        C_sep = return_channel_wake_separation_velocity(C_max, C7_);
        [Cm_wake, Cm_mix] = return_channel_wake_mixing_velocities(C_sep, Cu7_, Cm7, A7, r7_shroud, r7_hub, b7);
        omega_mix = vaned_diffuser_wake_mixing_loss(Cm_wake, Cm_mix, C6);

        sum_omega_ = omega_fixed + omega_SF + omega_BL + omega_mix;
        pt7_ = vaned_diffuser_assemble_discharge_total_pressure(pt6, p6, sum_omega_);
        Tt7_ = Tt6;

        static7_ = eos_static_from_total(eos, pt7_, Tt7_, C7_);
        rho7_ = static7_.rho;
        mdot_calc_ = rho7_ * Cm7 * A7;

        last_Cu7 = Cu7_; last_C7 = C7_; last_pt7 = pt7_; last_Tt7 = Tt7_;
        last_static7 = static7_; last_sum_omega = sum_omega_; last_mdot_calc = mdot_calc_;

        r = mdot_calc_ - mdot_target;
    end

Cm7_lo = 0.05 * Cm6;
Cm7_hi = 3.0 * Cm6;
n_scan = 60;
scan_points = Cm7_lo + (Cm7_hi - Cm7_lo) * (0:n_scan) / n_scan;
scan_values = nan(1, n_scan + 1);
for i = 1:(n_scan + 1)
    try
        scan_values(i) = residual(scan_points(i));
    catch
        scan_values(i) = NaN;
    end
end

all_brackets = zeros(0, 2);
for i = 1:n_scan
    a = scan_values(i); b = scan_values(i+1);
    if isnan(a) || isnan(b)
        continue
    end
    if a * b <= 0
        all_brackets(end+1, :) = [scan_points(i), scan_points(i+1)]; %#ok<AGROW>
    end
end

if isempty(all_brackets)
    valid_values = scan_values(~isnan(scan_values));
    if ~isempty(valid_values)
        max_mdot = max(valid_values) + mdot_target;
    else
        max_mdot = NaN;
    end
    error('centrifugal:return_channel_compute', ...
        ['ReturnChannel dis dongu: [%.4g, %.4g] m/s taramasinda isaret degisimi ' ...
         'bulunamadi (ulasilabilen max ~%.4g kg/s, hedef %.4g kg/s).'], Cm7_lo, Cm7_hi, max_mdot, mdot_target);
end

opts = optimset('TolX', 1e-6);
candidates = zeros(1, size(all_brackets, 1));
for i = 1:size(all_brackets, 1)
    candidates(i) = fzero(@residual, all_brackets(i, :), opts);
end
Cm7_solution = max(candidates);
residual(Cm7_solution);

Cu7 = last_Cu7;
C7 = last_C7;

station7 = new_station_state('7');
station7.geom = new_geometry();
station7.geom.r = r7; station7.geom.b = b7; station7.geom.area = A7;
station7.geom.blockage = B_M7; station7.geom.n_blades = z;

station7.vel = new_velocity_triangle();
station7.vel.Cm = Cm7_solution; station7.vel.Cu = Cu7; station7.vel.C = C7; station7.vel.alpha = deg2rad(alpha7_deg);

station7.total = new_fluid_state(last_pt7, last_Tt7);
station7.static = new_fluid_state(last_static7.p, last_static7.T, last_static7.rho, [], [], last_static7.a);

station7.mass_flow = last_mdot_calc;
station7.angular_momentum = r7 * Cu7;
station7.loss_total_pressure = last_sum_omega;

end
