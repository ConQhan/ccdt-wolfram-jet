function outlet_station = igv_compute(eos, geometry, inlet_station)
%IGV_COMPUTE components/igv.py :: [YENI -- IGV (preswirl) bileseni, Eq 5-9-5-21 zinciri].
%   Inlet Guide Vane analiz bileseni: verilen bir hedef cikis akis acisina
%   (target_alpha_0_deg) ulasmak icin gereken kanat metal acisini cozer
%   (igv_solve_exit_metal_angle_deg.m), sonra Howell sapma acisi + eslenik
%   difuzyon faktoru + toplam kayip zincirini (Eq 5-15-5-21) uygulayarak
%   toplam basinc dususunu hesaplar.
%
%   *** TASARIM NOKTASI VARSAYIMI *** -- hucum acisi i = i* (minimum-kayip
%   acisi) alinir, yani IGV TAM TASARIM NOKTASINDA calisir kabul edilir
%   (X=0, Eq 5-21'deki kayip katsayisi minimumda). Off-design IGV kaybi bu
%   fonksiyonun kapsami DISINDA -- off-design haritasi ayri ele alinmali.
%
%   *** GEOMETRIK BASITLESTIRMELER (acikca [KOPRU_TAHMINI]) ***
%   - beta_{-1}=90 (TEGET'TEN olculur -- bu kod tabanindaki beta1_deg/
%     beta2_deg ile AYNI konvansiyon; 90 derece = eksenel yaklasim,
%     on-donusu yok -- 0 DEGIL, DIKKAT)
%   - A_{-1}=A_0 (IGV eksenel olarak ince, giris/cikis alani esit)
%   - Cm_0=Cm_{-1} (yogunluk degisimi ihmal, ince kanat sirasi boyunca
%     meridyenel hiz sabit -- durgun bilesen oldugu icin Eq(5-24)'teki fc
%     entropi-tutarlilik duzeltmesine de gerek yok, bkz.
%     vaned_diffuser_assemble_discharge_total_pressure.m)
%   - Gamma=0 (kaynak metinde tanimlanmamis kanat yukleme sabiti)
%
%   geometry alanlari: target_alpha_0_deg, A_m1_m2 (=A_0_m2), sigma,
%   beta_m1_deg (opsiyonel, varsayilan 0), Gamma (opsiyonel, varsayilan 0)
%   inlet_station: '-1' -- IGV girisi, on-donusu YOK (Cu=0) varsayilir.
%   Cikti: outlet_station ('0' -- impeller gozu girisi)

target_alpha_0_deg = geometry.target_alpha_0_deg;
A_m1 = geometry.A_m1_m2;
A_0 = struct_get(geometry, 'A_0_m2', A_m1);
sigma = geometry.sigma;
beta_m1_deg = struct_get(geometry, 'beta_m1_deg', 90.0);
Gamma = struct_get(geometry, 'Gamma', 0.0);

pt_in = inlet_station.total.p;
Tt_in = inlet_station.total.T;
mdot = inlet_station.mass_flow;

Cm_m1 = solve_meridional_velocity(mdot, A_m1, 0.0, 0.0, pt_in, Tt_in, eos);
static_m1 = eos_static_from_total(eos, pt_in, Tt_in, Cm_m1);

[beta_0_deg, geom, delta_star_deg] = igv_solve_exit_metal_angle_deg(target_alpha_0_deg, beta_m1_deg, sigma); %#ok<ASGLU>

angles = igv_stall_incidence_angles(geom);
i_deg = angles.i_star_deg;

D_eq = igv_equivalent_diffusion_factor(geom, delta_star_deg, i_deg, A_m1, A_0, Gamma);
omega = igv_loss_coefficient(geom, delta_star_deg, i_deg, angles, A_m1, A_0, D_eq);

pt_out = vaned_diffuser_assemble_discharge_total_pressure(pt_in, static_m1.p, omega);
Tt_out = Tt_in;

Cm_0 = Cm_m1;
Cu_0 = Cm_0 * tan(deg2rad(target_alpha_0_deg));
C_0 = hypot(Cm_0, Cu_0);
static_0 = eos_static_from_total(eos, pt_out, Tt_out, C_0);

r_ref = struct_get(geometry, 'r_ref_m', 0.0);

outlet_station = new_station_state('0');
outlet_station.geom = new_geometry();
outlet_station.geom.r = r_ref;
outlet_station.vel = new_velocity_triangle();
outlet_station.vel.Cm = Cm_0; outlet_station.vel.Cu = Cu_0; outlet_station.vel.C = C_0;
outlet_station.total = new_fluid_state(pt_out, Tt_out);
outlet_station.static = new_fluid_state(static_0.p, static_0.T, static_0.rho, [], [], static_0.a);
outlet_station.mass_flow = mdot;
outlet_station.angular_momentum = r_ref * Cu_0;
outlet_station.loss_total_pressure = omega;
outlet_station.igv_beta_0_deg = beta_0_deg;

end
