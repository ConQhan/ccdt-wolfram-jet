function station4 = vaned_diffuser_compute(eos, geometry, inlet_station)
%VANED_DIFFUSER_COMPUTE components/vaned_diffuser.py :: VanedDiffuser.compute() portu.
%   Eq. (5-62) -> (5-88)'i zincirleyen vanli difuzor analizi. Impeller ile
%   AYNI mimari desen: throat'ta kontraksiyon/tikanma, sonra ayrik kayip
%   terimlerinin toplanmasi, sonra DIS donguide Cm4 uzerinde fzero.

g = geometry;

r3 = inlet_station.geom.r;
b3 = inlet_station.geom.b;
Cm3 = inlet_station.vel.Cm;
Cu3 = inlet_station.vel.Cu;
p3 = inlet_station.static.p;
T3 = inlet_station.static.T;
mdot_target = inlet_station.mass_flow;

C3 = hypot(Cm3, Cu3);
alpha3 = atan2(Cm3, Cu3);
a3 = eos_speed_of_sound(eos, p3, T3);
M3 = C3 / a3;

pt3_state = eos_total_from_static(eos, p3, T3, C3);
pt3 = pt3_state.p; Tt3 = pt3_state.T;

rho3 = eos_density(eos, p3, T3);
mu = struct_get(g, 'mu_Pa_s', 1.8e-5);
roughness_m = struct_get(g, 'roughness_m', 1.0e-6);

A3 = 2.0 * pi * r3 * b3;

r4 = g.r4_m;
b4 = g.b4_m;
beta3 = deg2rad(g.blade_angle_3_deg);
beta4 = deg2rad(g.blade_angle_4_deg);
beta_mid = deg2rad(struct_get(g, 'blade_angle_mid_deg', 0.5 * (g.blade_angle_3_deg + g.blade_angle_4_deg)));
z = g.n_vanes;
A_th = g.throat_area_m2;
h_th = g.throat_width_m;
tb3 = struct_get(g, 'vane_leading_edge_thickness_m', 0.0008);
tb4 = struct_get(g, 'vane_trailing_edge_thickness_m', 0.0008);
L_B = g.blade_mean_camberline_length_m;
d_H = g.mean_hydraulic_diameter_m;

% --- Throat: kontraksiyon, tikanma, throat hizi (impeller ile AYNI desen) ---
C_th = solve_meridional_velocity(mdot_target, A_th, 0.0, 0.0, pt3, Tt3, eos);
Cr = throat_contraction_ratio(A3, beta3, A_th);
A_star = sonic_area(mdot_target, pt3, Tt3, eos.gamma, eos.R);
omega_CH = choking_loss(Cr, A_th, A_star);

% --- Hucum kaybi zinciri -- Cm4'ten BAGIMSIZ, bir kez ---
alpha_th = geometric_throat_flow_angle(A_th, A3);
C3_star = optimum_incidence_velocity(Cm3, beta3, alpha_th);
omega_i0 = minimum_incidence_loss(C3, C3_star, C_th, z, tb3, r3);

K0 = unguided_K0(M3, beta3);
alpha3s = solve_stall_inlet_flow_angle(r3, h_th, alpha_th, K0, 0.39);
C3s = Cm3 / sin(alpha3s);
omega_i = off_design_incidence_loss(C3, C3_star, C3s, C_th);

% --- Cikis akis acisi (Eq 5-85->5-88) -- Cm4'ten BAGIMSIZ, bir kez ---
[a_over_c, sigma, theta] = camber_and_solidity(beta3, beta4, beta_mid, r3, r4, z);
delta_star_deg = deviation_angle_minimum_loss(a_over_c, sigma, rad2deg(theta), rad2deg(beta4));
d_delta_di = deviation_sensitivity(rad2deg(beta3), sigma);
alpha4_deg = discharge_flow_angle(rad2deg(beta4), delta_star_deg, d_delta_di, rad2deg(beta3), rad2deg(alpha3));

if ~(alpha4_deg >= 5.0 && alpha4_deg <= 85.0)
    error('centrifugal:vaned_diffuser_compute', ...
        ['VanedDiffuser: hesaplanan cikis akis acisi alpha4=%.2f derece fiziksel ' ...
         'olarak makul [5,85] derece araliginin disinda -- Cu4=Cm4/tan(alpha4) iliskisi ' ...
         'bu durumda kararsiz/anlamsiz sonuc uretir. Ara degerler: a/c=%.4f, sigma=%.4f, ' ...
         'theta=%.2f derece, delta*=%.2f derece. Bu genellikle yetersiz kanat sayisi ' ...
         '(n_vanes) veya yetersiz radyal uzanim (r4/r3 orani) ile iliskilidir.'], ...
        alpha4_deg, a_over_c, sigma, rad2deg(theta), delta_star_deg);
end

alpha4 = deg2rad(alpha4_deg);
tan_alpha4 = tan(alpha4);

% --- Geometrik (Cm4'ten bagimsiz) yardimci buyukluker ---
w3 = blade_to_blade_width(r3, beta3, z);
w4 = blade_to_blade_width(r4, beta4, z);
two_theta_C = equivalent_divergence_angle(w3, w4, b3, b4, tb3, tb4, L_B);
two_theta_C_deg = rad2deg(two_theta_C);

A4 = 2.0 * pi * r4 * b4;

omega_fixed = omega_i0 + omega_i + omega_CH;

last_Cu4 = []; last_C4 = []; last_pt4 = []; last_Tt4 = []; last_static4 = [];
last_B4 = []; last_flagged = []; last_sum_omega = []; last_mdot_calc = [];

    function r = residual(Cm4)
        Cu4_ = Cm4 / tan_alpha4;
        C4_ = hypot(Cm4, Cu4_);

        cf_override = struct_get(g, 'skin_friction_cf', []);
        if ~isempty(cf_override)
            cf = cf_override;
        else
            C_bar_sq = mean_square_velocity_with_throat_floor(C3, C4_, C_th);
            Re_d = reynolds_number(rho3, sqrt(C_bar_sq), d_H, mu);
            cf = skin_friction_coefficient(Re_d, roughness_m, d_H);
        end
        omega_SF = vaned_diffuser_skin_friction_loss(cf, C3, C4_, C_th, L_B, d_H);

        delta_C = average_blade_to_blade_velocity_difference(r3, Cu3, r4, Cu4_, z, L_B);
        L = blade_loading_parameter(delta_C, C3, C4_);
        B4_raw = discharge_area_blockage(Cm3, beta4, Cm4, beta3, two_theta_C_deg, L, L_B, w4);
        B4_ = min(max(B4_raw, 0.0), 0.5);
        B4_clamped_ = (B4_raw < 0.0) || (B4_raw > 0.5);

        [C_theta, ~] = correction_coefficients(two_theta_C_deg, L);
        C_sep = wake_separation_velocity(C3, C_theta, C4_);
        [Cm_wake, Cm_mix] = wake_mixing_velocities(C_sep, Cu4_, Cm4, A4, r4, b4);
        omega_mix = vaned_diffuser_wake_mixing_loss(Cm_wake, Cm_mix, C3);

        sum_omega_ = omega_fixed + omega_SF + omega_mix;
        pt4_ = vaned_diffuser_assemble_discharge_total_pressure(pt3, p3, sum_omega_);
        Tt4_ = Tt3;

        static4_ = eos_static_from_total(eos, pt4_, Tt4_, C4_);
        rho4_ = static4_.rho;
        mdot_calc_ = rho4_ * Cm4 * A4 * (1.0 - B4_);

        last_Cu4 = Cu4_; last_C4 = C4_; last_pt4 = pt4_; last_Tt4 = Tt4_;
        last_static4 = static4_; last_B4 = B4_; last_flagged = B4_clamped_;
        last_sum_omega = sum_omega_; last_mdot_calc = mdot_calc_;

        r = mdot_calc_ - mdot_target;
    end

Cm4_lo = 0.05 * Cm3;
Cm4_hi = 3.0 * Cm3;
n_scan = 60;
scan_points = Cm4_lo + (Cm4_hi - Cm4_lo) * (0:n_scan) / n_scan;
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
    error('centrifugal:vaned_diffuser_compute', ...
        ['VanedDiffuser dis dongu: [%.4g, %.4g] m/s taramasinda isaret degisimi ' ...
         'bulunamadi (ulasilabilen max ~%.4g kg/s, hedef %.4g kg/s).'], Cm4_lo, Cm4_hi, max_mdot, mdot_target);
end

opts = optimset('TolX', 1e-6);
clean_solutions = [];
for i = 1:size(all_brackets, 1)
    Cm4_candidate = fzero(@residual, all_brackets(i, :), opts);
    if ~last_flagged
        clean_solutions(end+1) = Cm4_candidate; %#ok<AGROW>
    end
end

if ~isempty(clean_solutions)
    Cm4_solution = max(clean_solutions);
else
    Cm4_solution = fzero(@residual, all_brackets(1, :), opts);
    warning('centrifugal:vaned_diffuser_compute', ...
        ['VanedDiffuser cozumu bulundu ama TUM kok adaylarinda B4 guvenlik sinirina ' ...
         'carpildi -- sonuc model gecerlilik sinirlari disinda olabilir. Sonuclari ' ...
         'dikkatli yorumlayin.']);
end

residual(Cm4_solution);

Cu4 = last_Cu4;
C4 = last_C4;

station4 = new_station_state('4');
station4.geom = new_geometry();
station4.geom.r = r4; station4.geom.b = b4; station4.geom.area = A4;
station4.geom.blockage = last_B4; station4.geom.n_blades = z;

station4.vel = new_velocity_triangle();
station4.vel.Cm = Cm4_solution; station4.vel.Cu = Cu4; station4.vel.C = C4; station4.vel.alpha = alpha4;

station4.total = new_fluid_state(last_pt4, last_Tt4);
station4.static = new_fluid_state(last_static4.p, last_static4.T, last_static4.rho, [], [], last_static4.a);

station4.mass_flow = last_mdot_calc;
station4.angular_momentum = r4 * Cu4;
station4.loss_total_pressure = last_sum_omega;

end
