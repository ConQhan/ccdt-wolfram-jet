function station1 = impeller_solve_station1(imp, pt0, Tt0, mdot_target)
%IMPELLER_SOLVE_STATION1 components/impeller.py :: Impeller._solve_station1() portu.

g = imp.geometry;
r1_hub = g.r1_hub_m; r1_shroud = g.r1_shroud_m;
r1_mean = 0.5 * (r1_hub + r1_shroud);
b1 = r1_shroud - r1_hub;
A1 = pi * (r1_shroud^2 - r1_hub^2);
beta1_blade = deg2rad(g.blade_angle_1_deg);
z_eff = imp.z_eff;
tb1 = g.blade_leading_edge_thickness_m;
kappa_m1 = struct_get(g, 'inlet_meridional_curvature_per_m', 0.0);

% *** [YENI -- preswirl] *** inlet_prewhirl_angle_deg=0 (varsayilan) ise
% Cu1_hub=Cu1_mean=Cu1_shroud=0 ve asagidaki HER SEY eski davranisla
% BIREBIR AYNI kalir (forced_vortex_prewhirl.m, K=0/r1_shroud=0 doner).
%
% Cu1'in kendisi Cm1_mean'e (continuity cozumune) bagli oldugundan,
% impeller_evaluate_station2.m'deki "_guess -> final" desenini izleyen
% iki-gecisli bir yaklasim kullanilir: once Cu1=0 varsayimiyla bir ilk
% Cm1_mean tahmini alinir, bu tahminden Cu1 dagilimi turetilir, sonra
% GERCEK Cu1_mean ile Cm1_mean TEK kez yeniden cozulur (tam sabit-nokta
% yakinsamasina gidilmez -- kodun geri kalaninda zaten kurulu olan
% guess/final rigor seviyesiyle tutarli).
prewhirl_deg = struct_get(g, 'inlet_prewhirl_angle_deg', 0.0);

Cm1_mean_guess = solve_meridional_velocity(mdot_target, A1, 0.0, 0.0, pt0, Tt0, imp.eos);
[~, Cm1_shroud_guess] = entrance_velocity_curvature_correction(Cm1_mean_guess, kappa_m1, b1);
[~, Cu1_mean, ~] = forced_vortex_prewhirl(prewhirl_deg, Cm1_shroud_guess, r1_hub, r1_mean, r1_shroud);

Cm1_mean = solve_meridional_velocity(mdot_target, A1, 0.0, Cu1_mean, pt0, Tt0, imp.eos);

[Cm1_hub, Cm1_shroud] = entrance_velocity_curvature_correction(Cm1_mean, kappa_m1, b1);
[Cu1_hub, Cu1_mean, Cu1_shroud] = forced_vortex_prewhirl(prewhirl_deg, Cm1_shroud, r1_hub, r1_mean, r1_shroud);

% [DUZELTME -- H12] Eq 5-27 hub/ortalama/shroud yuzeylerinde YEREL kanat acisiyla
% hesaplanir; eskiden uc yuzeyde de ortalama aci kullaniliyordu (hub ve shroud'da
% yapay olarak buyuk hucum kaybi). Blokaj terimindeki kanat sayisi z_FB: splitter
% kanatlar hucum kenarinda yok. Alanlar yoksa eski davranis (ortalama aci, z_eff).
beta1_blade_hub = deg2rad(struct_get(g, 'blade_angle_1_hub_deg', g.blade_angle_1_deg));
beta1_blade_shroud = deg2rad(struct_get(g, 'blade_angle_1_shroud_deg', g.blade_angle_1_deg));
if isfield(g, 'blade_angle_1_hub_deg')
    z_LE = g.n_blades_full;
else
    z_LE = z_eff;
end
[W1_hub, omega_inc_hub] = local_surface(imp, Cm1_hub, r1_hub, Cu1_hub, beta1_blade_hub, z_LE, tb1);
[W1_mean, omega_inc_mean] = local_surface(imp, Cm1_mean, r1_mean, Cu1_mean, beta1_blade, z_LE, tb1);
[W1_shroud, omega_inc_shroud] = local_surface(imp, Cm1_shroud, r1_shroud, Cu1_shroud, beta1_blade_shroud, z_LE, tb1);

omega_inc_weighted = weighted_incidence_and_shock_loss(omega_inc_hub, omega_inc_mean, omega_inc_shroud);

velocity1_mean = hypot(Cm1_mean, Cu1_mean);
static1 = eos_static_from_total(imp.eos, pt0, Tt0, velocity1_mean);
rho1 = static1.rho;
pt1_rel_state = eos_total_from_static(imp.eos, static1.p, static1.T, W1_mean);
pt1_rel = pt1_rel_state.p; Tt1_rel = pt1_rel_state.T;

% *** TEORIK TEMEL (Eq 3-5/3-6/3-7, rothalpy korunumu) ***
% Throat'ta da bu AYNI (pt1_rel, Tt1_rel) degerlerinin kullanilmasi
% keyfi bir basitlestirme DEGIL -- bkz core/rothalpy.py.

A_th = struct_get(g, 'throat_area_m2', []);
if isempty(A_th)
    % [VARSAYILAN] Throat alani verilmemisse, A1*sin(beta1)'in %95'i.
    A_th = 0.95 * A1 * sin(beta1_blade);
end
beta_th = deg2rad(struct_get(g, 'throat_blade_angle_deg', g.blade_angle_1_deg));

Wth = solve_meridional_velocity(mdot_target, A_th, 0.0, 0.0, pt1_rel, Tt1_rel, imp.eos);

Cr = throat_contraction_ratio(A1, beta1_blade, A_th);
A_star = sonic_area(mdot_target, pt1_rel, Tt1_rel, imp.eos.gamma, imp.eos.R);
omega_choke = choking_loss(Cr, A_th, A_star); %#ok<NASGU>

omega_dif = entrance_diffusion_loss_with_stall_limit(W1_shroud, Wth, W1_mean, omega_inc_weighted);

station1.r1_mean = r1_mean; station1.A1 = A1; station1.b1 = b1;
station1.Cm1_mean = Cm1_mean; station1.W1_mean = W1_mean; station1.W1_shroud = W1_shroud;
station1.Cu1_mean = Cu1_mean;  % [YENI -- preswirl -- Eq 4-5'te U1*Cu1 terimi icin]
station1.omega_inc = omega_inc_weighted; station1.omega_dif = omega_dif; station1.omega_choke = choking_loss(Cr, A_th, A_star);
station1.p1 = static1.p; station1.rho1 = rho1; station1.pt1_rel = pt1_rel; station1.Tt1_rel = Tt1_rel;
station1.beta_th = beta_th; station1.A_th = A_th;
station1.Wth = Wth; station1.A_star = A_star;  % tasarim kontrolleri icin (Eq 5-29, Eq 6-15)

end


function [W1_x, omega_inc_x] = local_surface(imp, Cm1_x, r1_x, Cu1, beta1_blade, z_eff, tb1)
U1_x = imp.omega_rad_s * r1_x;
Wu1_x = U1_x - Cu1;
W1_x = hypot(Cm1_x, Wu1_x);
omega_inc_x = incidence_loss(Cm1_x, W1_x, beta1_blade, z_eff, tb1, r1_x);
end
