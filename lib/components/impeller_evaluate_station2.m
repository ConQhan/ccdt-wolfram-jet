function [station2, loss_result, mdot_calc] = impeller_evaluate_station2(imp, Cm2, station1, pt0, Tt0, mdot_target)
%IMPELLER_EVALUATE_STATION2 components/impeller.py :: Impeller._evaluate_station2() portu.

g = imp.geometry;
eos = imp.eos;
r2 = g.r2_m;
b2 = g.b2_m;
A2 = 2.0 * pi * r2 * b2;
U2 = imp.omega_rad_s * r2;
phi2 = Cm2 / U2;
beta2_blade = deg2rad(g.blade_angle_2_deg);
z_eff = imp.z_eff;
L_B = g.blade_mean_camberline_length_m;
d_H = g.mean_hydraulic_diameter_m;
tip_clearance = struct_get(g, 'tip_clearance_m', 0.0);

W1 = station1.W1_mean;
r1_mean = station1.r1_mean;

% [YENI -- preswirl] Eq (4-5)'teki U1*Cu1 terimi icin GERCEK degerler --
% Cu1_mean=0 (varsayilan, preswirl yok) ise eski davranisla BIREBIR AYNI
% (U1*Cu1=0, U2 degeri onemsiz kalirdi -- eskiden "1.0" hardcode edilmis
% olmasinin sebebi buydu).
U1_mean = imp.omega_rad_s * r1_mean;
Cu1_mean = struct_get(station1, 'Cu1_mean', 0.0);

r1_shroud = struct_get(g, 'r1_shroud_m', []);
[sigma, sigma_radius_ratio_corrected] = slip_factor_with_radius_ratio_correction(...
    beta2_blade, z_eff, r1_shroud, r2, pi/2.0);

lam_guess = 1.0;
I_B_guess = blade_work_input_coefficient(sigma, lam_guess, phi2, beta2_blade, U1_mean, Cu1_mean, U2);
Cu2_guess = I_B_guess * U2;
Wu2_guess = U2 - Cu2_guess;
W2_guess = hypot(Cm2, Wu2_guess);

delta_W_guess = compute_delta_w(U2, I_B_guess, z_eff, L_B, r2); %#ok<NASGU>
[Deq_guess, W_max_guess] = equivalent_diffusion_factor(W1, W2_guess, delta_W_guess); %#ok<NASGU,ASGLU>

rho1 = station1.rho1;
Wth_for_sf = W1;
cf_guess = impeller_compute_cf(imp, W1, W2_guess, Wth_for_sf, rho1, d_H);
omega_sf_guess = skin_friction_loss(cf_guess, W1, W2_guess, Wth_for_sf, L_B, d_H);

A_th = station1.A_th;
beta_th = station1.beta_th;
AR = tip_area_ratio(A_th, beta_th, A2, beta2_blade);

delta_h_euler_guess = U2 * Cu2_guess;
cp = eos.cp;
Tt2_ideal_guess = Tt0 + delta_h_euler_guess / cp;
gamma = eos.gamma;
pt2_ideal_guess = pt0 * (Tt2_ideal_guess / Tt0)^(gamma / (gamma - 1.0));
C2_guess = hypot(Cm2, Cu2_guess);
static2_guess = eos_static_from_total(eos, pt2_ideal_guess, Tt2_ideal_guess, C2_guess);
rho2_guess = static2_guess.rho;

pt1_rel = station1.pt1_rel;
p1 = station1.p1;
pv1 = pt1_rel - p1;
pv2 = pt2_ideal_guess - static2_guess.p;

B2 = tip_area_blockage(omega_sf_guess, pv1, pv2, W1, d_H, W2_guess, b2, L_B, AR, rho1, rho2_guess, tip_clearance);
B2_raw = B2;
B2 = max(0.0, min(B2, 0.5));
B2_clamped = (B2_raw < 0.0) || (B2_raw > 0.5);
lam = 1.0 / (1.0 - B2);

I_B = blade_work_input_coefficient(sigma, lam, phi2, beta2_blade, U1_mean, Cu1_mean, U2);
Cu2 = I_B * U2;
Wu2 = U2 - Cu2;
W2 = hypot(Cm2, Wu2);

% --- delta_W, Deq (Eq 4-41/4-42) -- I_L ve I_R icin de gerekli ---
delta_W_value = compute_delta_w(U2, I_B, z_eff, L_B, r2);
[Deq, W_max] = equivalent_diffusion_factor(W1, W2, delta_W_value); %#ok<ASGLU>

% --- Clearance gap leakage (Eq 4-17/18/19) ---
delta_p_CL = clearance_gap_pressure_difference(mdot_target, r1_mean, r2, 0.0, Cu2, z_eff, L_B, station1.b1, b2);
U_CL = clearance_gap_leakage_velocity(delta_p_CL, rho2_guess);
m_dot_CL = clearance_gap_leakage_mass_flow(rho2_guess, z_eff, tip_clearance, L_B, U_CL);

s_disk = struct_get(g, 'disk_axial_clearance_m', 0.001);
I_DF = estimate_disk_friction_work_coefficient(rho2_guess, imp.omega_rad_s, r2, imp.mu, s_disk, U2, mdot_target);

% --- Sizinti isi: acik cark Eq 4-40, kapali cark Eq 4-39 + Eq 6-7 ---
% [DUZELTME -- H4] Kapali carkta goz contasi sizintisi eskiden hic
% hesaplanmiyordu (I_L=0). Egli modeli (Eq 4-33..4-38) conta geometrisi
% gerektirdiginden, Aungier'in on tasarim korelasyonu Eq 6-7 kullaniliyor.
if strcmp(struct_get(g, 'impeller_type', 'open'), 'covered')
    m_dot_L = eye_seal_leakage_fraction(imp_phi(imp, pt0, Tt0, mdot_target, r2, U2)) * mdot_target;
    I_L = leakage_work_coefficient_covered_impeller(m_dot_L, I_B, mdot_target);
else
    I_L = leakage_work_coefficient_open_impeller(m_dot_CL, U_CL, U2, mdot_target);
end

% --- Eq 4-43: recirculation work ---
I_R = recirculation_work_coefficient(Deq, Wu2, Cm2, beta2_blade, 1e-3, 2.0);
I_R_clamped = I_R >= 2.0 - 1e-9;

% --- Eq 4-1: I = I_B + I_DF + I_L + I_R ---
I_total = I_B + I_DF + I_L + I_R;

omega_bl = blade_loading_loss(delta_W_value, W1);

rho_ref_final = 0.5 * (rho1 + rho2_guess);
cf_final = impeller_compute_cf(imp, W1, W2, Wth_for_sf, rho_ref_final, d_H);
omega_sf = skin_friction_loss(cf_final, W1, W2, Wth_for_sf, L_B, d_H);

% [DUZELTME -- H11] Eq 5-35: kappa_bar = (alphaC2 - alphaC1)/L. Eskiden egrilik
% sabit 0 veriliyordu -> hub-shroud yukleme kaybi hic hesaba girmiyordu.
% Eksenel giris -> radyal cikis: alphaC2 - alphaC1 = pi/2; L = ortalama
% meridyonel uzunluk (design_preliminary_stage, Eq 6-17 geometrisi). Geometri
% bu alani tasimiyorsa eksenel uzunluk + radyal fark ile duz-cizgi tahmini.
L_mer = struct_get(g, 'meridional_length_m', []);
if isempty(L_mer)
    Lz = struct_get(g, 'axial_length_z_m', []);
    if isempty(Lz)
        L_mer = Inf;  % meridyonel bilgi yok: egrilik kaybi hesaplanamaz
    else
        L_mer = hypot(r2 - r1_mean, Lz);
    end
end
kappa_m_bar = (pi / 2.0) / L_mer;
omega_hs = hub_shroud_loading_loss(kappa_m_bar, station1.b1, b2, W1, W2);

omega_dd = distortion_loss(lam, Cm2, W1);

omega_mix = wake_mixing_loss(Deq, W2, Wu2, Cm2, A2, r2, b2, W1);

omega_cl = clearance_loss(m_dot_CL, delta_p_CL, mdot_target, rho1, W1);

loss_result = new_impeller_loss_result();
loss_result.shock_and_incidence = station1.omega_inc;
loss_result.entrance_diffusion = station1.omega_dif;
loss_result.choking = station1.omega_choke;
loss_result.skin_friction = omega_sf;
loss_result.blade_loading = omega_bl;
loss_result.hub_shroud_loading = omega_hs;
loss_result.distortion = omega_dd;
loss_result.mixing = omega_mix;
loss_result.clearance = omega_cl;

% --- [DUZELTME -- H3] Cikis toplam kosullari ---
% Eskiden pt2_ideal, I_total (parazitik is DAHIL) uzerinden izantropik
% hesaplaniyordu ve kayip (bagil cerceve dinamik basinciyla) mutlak pt'den
% fc=1 ile dusuluyordu. Sonuc: parazitik is (disk surtunmesi, sizinti,
% resirkulasyon) basinc URETIYORDU -- acik carkta bosluk arttikca verimin
% artmasinin koku buydu. Aungier'e gore:
%   1) Bagil cercevede ideal cikis: rothalpi korunumu (Eq 5-22/5-23).
%   2) Kayiplar bagil cercevede, entropi-tutarli fc ile (Eq 5-24/5-25).
%      Ideal gazda rho_t*T_t = p_t/R, dolayisiyla fc = pt2'/pt1'; Eq 5-24
%      bu fc ile kapali formda cozulur.
%   3) Mutlak toplam basinc: kanat isinin (I_B) izantropik basinci x ayni
%      entropi orani. Parazitik is basinc uretmez (Bolum 1 SS4).
%   4) Mutlak toplam sicaklik: TUM is (Eq 4-1, Eq 5-43) -- parazitik is
%      yalnizca isi olarak girer.
sum_omega = impeller_loss_result_total_omega(loss_result);
Tt1_rel = station1.Tt1_rel;
Tt2_rel = Tt1_rel + (U2^2 - U1_mean^2) / (2.0 * cp);
pt2_rel_ideal = pt1_rel * (Tt2_rel / Tt1_rel)^(gamma / (gamma - 1.0));
pt2_rel = pt2_rel_ideal / (1.0 + (pt1_rel - p1) * sum_omega / pt1_rel);
entropy_pressure_ratio = pt2_rel / pt2_rel_ideal;

Tt2_blade = Tt0 + I_B * U2^2 / cp;
pt2_actual = pt0 * (Tt2_blade / Tt0)^(gamma / (gamma - 1.0)) * entropy_pressure_ratio;
Tt2_actual = Tt0 + I_total * U2^2 / cp;

C2 = hypot(Cm2, Cu2);
static2 = eos_static_from_total(eos, pt2_actual, Tt2_actual, C2);
% [DUZELTME -- H10] Aungier (Bolum 5 SS3.4): yakinsama kriteri
% mdot = rho2*phi2*U2*A2 -- Cm2 GEOMETRIK alan uzerinden ortalama hizdir,
% blokaj yalnizca lambda uzerinden is denklemine (Eq 4-3/4-5) girer.
% Eskiden burada ayrica (1-B2) carpani vardi -> blokaj iki kez sayiliyordu.
mdot_calc = static2.rho * Cm2 * A2;

station2 = new_station_state('2');
station2.geom = new_geometry();
station2.geom.r = r2; station2.geom.b = b2; station2.geom.n_blades = g.n_blades_full;
station2.vel = new_velocity_triangle();
station2.vel.Cm = Cm2; station2.vel.Cu = Cu2; station2.vel.U = U2; station2.vel.C = C2; station2.vel.W = W2;
station2.total = new_fluid_state(pt2_actual, Tt2_actual);
station2.static = new_fluid_state(static2.p, static2.T, static2.rho, [], [], static2.a);
station2.mass_flow = mdot_calc;
station2.angular_momentum = r2 * Cu2;

station2.model_validity_flagged = (B2_clamped || I_R_clamped || sigma_radius_ratio_corrected);

% Belgeleme/tasarim kontrolleri icin ara buyuklukler (hesaba etkisi yok)
station2.work = struct('I_B', I_B, 'I_DF', I_DF, 'I_L', I_L, 'I_R', I_R, 'I_total', I_total, ...
    'sigma', sigma, 'lambda', lam, 'B2', B2, 'delta_W', delta_W_value, 'Deq', Deq, ...
    'W1', W1, 'W2', W2, 'sum_omega', sum_omega, 'fc', pt2_rel / pt1_rel, ...
    'entropy_pressure_ratio', entropy_pressure_ratio);

end


function phi = imp_phi(imp, pt0, Tt0, mdot, r2, U2)
% Eq 1-1: kademe akis katsayisi (Eq 6-7 sizinti korelasyonu icin)
phi = mdot / (eos_density(imp.eos, pt0, Tt0) * pi * r2^2 * U2);
end
