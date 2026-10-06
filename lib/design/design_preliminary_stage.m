function result = design_preliminary_stage(mdot, p0, T0, rotational_speed_rpm, r2_m, eos, ...
    impeller_type, diffuser_type, stage_type, splitter_length_ratio, mu_Pa_s, roughness_m, ...
    r_min_m, r_max_m, r_next_stage_eye_m, inlet_prewhirl_angle_deg, b2_over_r2_ratio, ...
    plenum_target_C_exit_m_s, tip_clearance_m, n_blades_full_fixed, le_thickness_m)
%DESIGN_PRELIMINARY_STAGE design/preliminary_design.py :: design_preliminary_stage() portu.
%   Chapter 6'nin tum katmanlarini (referans korelasyonlar, bilesen
%   eslestirme, boyutlandirma) zincirleyen ust seviye orkestrator.
%
%   stage_type : "voluted" (varsayilan) -- Volut ile sonlanan kademe
%                "return_channel"       -- CrossoverBend+ReturnChannel ile
%                                         sonlanan ARA kademe (cok kademeli
%                                         kompresorun orta kademeleri icin)
%                "dump"                 -- [YENI] Toplayici (volut/return
%                                         channel) YOK -- difuzor cikisi
%                                         DOGRUDAN performans degerlendirme
%                                         son istasyonu (ornegin difuzorden
%                                         cikan havanin dogrudan yanma
%                                         odasi/plenum'a gittigi mikro jet
%                                         motoru duzeni icin). PR/eta/Power
%                                         difuzor cikisindaki (istasyon 4)
%                                         toplam kosullardan hesaplanir.
%                "dump_with_plenum"     -- [YENI] "dump" ile AYNI, AMA
%                                         difuzor cikisindan sonra ayrica
%                                         bir ANULER DUMP PLENUM (ani
%                                         genisleme, Aungier disi -- bkz.
%                                         annular_dump_plenum_compute.m ve
%                                         Aungier_ve_Metodoloji/Dump_Plenum_
%                                         Boyutlandirma.md) eklenir; bu
%                                         plenum akisi plenum_target_C_exit_m_s
%                                         hizina kadar yavaslatir (Secenek A:
%                                         r5=r4 sabit, b5 buyur). PR/eta/Power
%                                         artik istasyon 5'e (plenum cikisi)
%                                         gore hesaplanir.
%
%   plenum_target_C_exit_m_s : stage_type="dump_with_plenum" icin ZORUNLU --
%       plenum cikisinda (yanma odasi girisi) hedeflenen hiz [m/s].
%
%   r_next_stage_eye_m : bir sonraki kademenin impeller goz yaricapi (sadece
%       stage_type="return_channel" icin, Eq 6-30'daki b8 tahminine girer;
%       verilmezse b8 icin [KOPRU_TAHMINI] kullanilir).
%
%   Cikti struct alanlari: phi, U2, targets, beta2_deg, z_eff_recommended,
%   impeller_geometry, diffuser_geometry, diffuser_type, stage_type,
%   volute_geometry, crossover_geometry, return_channel_geometry, warnings
%   (cell array of char).
%
%   *** "KOPRU TAHMINLERI" HAKKINDA ACIKLAMA *** -- bkz. Python kaynagindaki
%   design/preliminary_design.py modul docstring'i: kitabin Chapter 6
%   metni impeller'in TAM 3B geometrisini uretecek kapali-form formuller
%   icermiyor (Chapter 7'ye birakiliyor); bu fonksiyon SADECE bu bosluğu
%   kapatmak icin, Chapter 6 formulleriyle TUTARLI ama kitaptan DOGRUDAN
%   gelmeyen basit muhendislik tahminleri kullaniyor -- her biri
%   [KOPRU_TAHMINI N] olarak yorum satirlarinda isaretli, AYNEN korunuyor.

if nargin < 7 || isempty(impeller_type); impeller_type = 'covered'; end
if nargin < 8 || isempty(diffuser_type); diffuser_type = 'vaneless'; end
if nargin < 9 || isempty(stage_type); stage_type = 'voluted'; end
if nargin < 10 || isempty(splitter_length_ratio); splitter_length_ratio = 0.50; end
if nargin < 11 || isempty(mu_Pa_s); mu_Pa_s = 1.8e-5; end
if nargin < 12 || isempty(roughness_m); roughness_m = 1.0e-6; end
if nargin < 13; r_min_m = []; end
if nargin < 14; r_max_m = []; end
if nargin < 15; r_next_stage_eye_m = []; end
if nargin < 16 || isempty(inlet_prewhirl_angle_deg); inlet_prewhirl_angle_deg = 0.0; end
if nargin < 17; b2_over_r2_ratio = []; end  % bos/NaN -> b2 Aungier zincirinden (Eq 6-10 + sureklilik)
if nargin < 18; plenum_target_C_exit_m_s = []; end
if nargin < 19 || isempty(tip_clearance_m); tip_clearance_m = 0.0; end  % acik cark uc boslugu [m]
if nargin < 20; n_blades_full_fixed = []; end  % bos: kanat sayisi Eq 6-22 onerisinden
if nargin < 21; le_thickness_m = []; end  % bos: 0.005*r2 kopru tahmini (hucum kenari kalinligi)

if ~(strcmp(stage_type, 'voluted') || strcmp(stage_type, 'return_channel') || ...
        strcmp(stage_type, 'dump') || strcmp(stage_type, 'dump_with_plenum'))
    error('centrifugal:design_preliminary_stage', ...
        "stage_type 'voluted', 'return_channel', 'dump' veya 'dump_with_plenum' olmali");
end
if strcmp(stage_type, 'dump_with_plenum') && isempty(plenum_target_C_exit_m_s)
    error('centrifugal:design_preliminary_stage', ...
        "stage_type='dump_with_plenum' icin plenum_target_C_exit_m_s ZORUNLU");
end

result.stage_type = stage_type;
result.warnings = {};

omega_rad_s = 2.0 * pi * rotational_speed_rpm / 60.0;
U2 = omega_rad_s * r2_m;

rho_t0 = eos_density(eos, p0, T0);
Q0 = mdot / rho_t0;
phi = Q0 / (pi * r2_m^2 * U2);
result.phi = phi;
result.U2 = U2;

targets = reference_design_targets(phi, impeller_type);
result.targets = targets;
I_par = parasitic_work_coefficient_target(phi, impeller_type);
I_B_target = blade_work_input_coefficient_target(targets.I, I_par);

if strcmp(diffuser_type, 'vaneless')
    angles = vaneless_stage_flow_angles_deg(phi);
elseif strcmp(diffuser_type, 'vaned')
    angles = vaned_stage_flow_angles_deg(phi);
else
    error('centrifugal:design_preliminary_stage', "diffuser_type 'vaneless' veya 'vaned' olmali");
end
incidence = default_incidence_angles_deg();
alpha1_prime_deg = impeller_inlet_relative_flow_angle_default_deg();

alpha2_deg = angles.alpha2_deg;

if ~isempty(r_min_m)
    r1_hub = r_min_m;
else
    r1_hub = 0.225 * r2_m;  % [KOPRU_TAHMINI 1]
end

rho1_estimate = rho_t0;  % [BASITLESTIRME] giris yogunluk dususu ihmal

% *** [YENI -- eski (alpha1'=30 derece varsayimli, KOPRU_TAHMINI) alan
% iterasyonunun YERINE GECTI] ***
% r1_shroud, W1s'i (shroud bagil hizini) MINIMIZE EDEN kapali-form
% cozumden baslar (optimum_inducer_shroud_radius.m; r1_hub->0 limitinde
% klasik tan(beta_s1)=sqrt(2) sonucuna indirgenen, birinci-ilkelerden
% turetilmis ve ayri testlerle dogrulanmis bir sonuc), AMA bu tek basina
% DEBI KAPASITESINI kontrol etmez -- feasible_inducer_shroud_radius.m
% [YENI] bu optimumu bogaz kapasitesine gore GEREKIRSE buyuterek
% kullanilabilir hale getirir (bkz. sohbet: N=75000rpm/mdot=0.5kg/s
% bulgusu -- optimum goz bazi calisma noktalarinda hedef debiyi hic
% gecemiyordu, r2'den BAGIMSIZ olarak).
inducer_fit = feasible_inducer_shroud_radius(mdot, rho1_estimate, omega_rad_s, r1_hub, p0, T0, eos);
r1_shroud = inducer_fit.r1_shroud_m;
if inducer_fit.was_scaled_up
    result.warnings{end+1} = sprintf(...
        ['Inducer gozu (r1_shroud), bogaz debi kapasitesi yetersiz oldugu icin ' ...
         'W1s-optimumundan (%.4f m) %.4f m''ye (%.0f%%) BUYUTULDU -- optimum geometri ' ...
         'hedef debiyi (%.3f kg/s) gecemiyordu (maks ~%.3f kg/s).'], ...
        inducer_fit.r1_shroud_optimum_m, r1_shroud, (inducer_fit.scale_factor - 1.0) * 100.0, ...
        mdot, inducer_fit.mdot_max_at_throat_kg_s);
end
if ~inducer_fit.feasible
    result.warnings{end+1} = sprintf(...
        ['Inducer gozu %.0f%% buyutuldukten SONRA BILE hedef debiyi gecemiyor ' ...
         '(maks ~%.3f kg/s < hedef %.3f kg/s) -- bu calisma noktasi bu r1_hub/N ' ...
         'kombinasyonuyla FIZIBIL OLMAYABILIR.'], ...
        (inducer_fit.scale_factor - 1.0) * 100.0, inducer_fit.mdot_max_at_throat_kg_s, mdot);
end
r1_mean = 0.5 * (r1_hub + r1_shroud);

U1 = omega_rad_s * r1_mean;
A1 = pi * (r1_shroud^2 - r1_hub^2);
Cm1 = mdot / (rho1_estimate * A1);

W1 = hypot(Cm1, U1);
beta1_deg = rad2deg(atan2(Cm1, U1));

% Eq 6-3: Impeller eksenel uzunlugu (Delta_zI) -- DOGRUDAN Z koordinati icin
% d0h = 2*r1_hub (goz hub capi)
axial_length_z_m = impeller_axial_length_ratio(phi, 2 * r2_m, 2 * r1_hub);

% Duz-cizgi uzunluk: cark L_B iterasyonunun BASLANGIC degeri (gercek L_B ve
% d_H asagida Eq 6-17 geometrisinden, birlikte hesaplanir -- H9). Kanatli
% difuzor / geri donus kanali boyutlandirmasi hala bu tahmini kullaniyor
% [KOPRU_TAHMINI 3].
L_B_estimate = hypot(r2_m - r1_mean, axial_length_z_m);

% *** [DUZELTME -- H1/H2/H5] Cark ucu boyutlandirma, Aungier Bolum 6 sirasiyla ***
% Eskiden: b2 = 0.06-0.075*r2 [kopru tahmini], rho2 = 0.85*rho_t0 (gercekte
% cark cikisinda yogunluk girisin ~1.7 kati) -> Cm2 ~2x sisik -> beta2 yanlis
% phi2 ile cozuluyor ve W2 sisik oldugu icin Eq 6-22 kanat sayisi kontrolu
% sahte geciyordu. K_lambda de Eq 6-4 yerine 1+0.3*phi tahminiydi.
% Simdi (Bolum 6 SS2.4, SS3.2, SS5.4; derleme belge SS4 Adim 2-4):
%   1) Cu2 = I_B*U2 (Eq 6-18), alpha2 Eq 6-10 (vanesiz) -> Cm2 = Cu2*tan(alpha2)
%   2) eta_2H (Eq 6-9) ile pt2 (kanat isi), Tt2 tum is (Eq 4-1) -> rho2
%   3) b2 = mdot/(2*pi*r2*rho2*Cm2) (sureklilik; Cm2 geometrik-alan ortalamasi,
%      blokaj yalnizca lambda ile is denklemine girer -- Bolum 5 SS3.4)
%   4) Gercek W2 ile Eq 6-22 -> z_eff; Eq 6-19/6-20 -> beta2; Eq 6-4/6-5 ->
%      lambda; lambda <-> beta2 yakinsayana kadar iterasyon.
% b2_over_r2_ratio verilirse (NaN/bos degilse) b2 sabitlenir ve Cm2
% sureklilikten cikar (alpha2 artik Eq 6-10'dan gelmez) -- tarama/override icin.
cp = eos.cp;
gam = eos.gamma;
eta_2H = impeller_internal_efficiency(phi);
Cu2_estimate = I_B_target * U2;
Tt2_estimate = T0 + targets.I * U2^2 / cp;
pt2_estimate = p0 * (1.0 + eta_2H * I_B_target * U2^2 / (cp * T0))^(gam / (gam - 1.0));
b2_fixed = ~(isempty(b2_over_r2_ratio) || isnan(b2_over_r2_ratio));

if b2_fixed
    b2 = b2_over_r2_ratio * r2_m;
    Cm2 = Cu2_estimate * tan(deg2rad(alpha2_deg));
    for it = 1:50
        rho2_estimate = local_tip_static_density(Cm2, Cu2_estimate, Tt2_estimate, pt2_estimate, cp, gam, eos);
        Cm2_new = mdot / (2.0 * pi * r2_m * b2 * rho2_estimate);
        if abs(Cm2_new - Cm2) < 1e-9 * Cm2; Cm2 = Cm2_new; break; end
        Cm2 = Cm2_new;
    end
    alpha2_deg = rad2deg(atan2(Cm2, Cu2_estimate));
    b2_source = 'override (b2_over_r2_ratio)';
else
    Cm2 = Cu2_estimate * tan(deg2rad(alpha2_deg));
    rho2_estimate = local_tip_static_density(Cm2, Cu2_estimate, Tt2_estimate, pt2_estimate, cp, gam, eos);
    b2 = mdot / (2.0 * pi * r2_m * rho2_estimate * Cm2);
    b2_source = 'Aungier Eq 6-10 + sureklilik';
end
phi2 = Cm2 / U2;
W2 = hypot(Cm2, U2 - Cu2_estimate);
A2 = 2.0 * pi * r2_m * b2;

% *** [DUZELTME -- H9] L_B ve d_H gercek kanat geometrisinden ***
% Eskiden L_B = hypot(r2-r1m, Lz) (duz cizgi) ve d_H = 2*b2 kopru tahminleriydi.
% ~100 derece sarimli kanatta gercek orta kamber uzunlugu ~1.5 kat daha uzun;
% Eq 4-42'de L_B paydada oldugundan kanat yuku ~1.5 kat fazla, dolayisiyla
% kanat sayisi gereginden fazla cikiyordu. Simdi:
%   - Kanat acisi dagilimi Eq 6-17 (aungier_blade_angle_distribution.m)
%   - L_B = hub ve shroud kamber uzunluklarinin ortalamasi, integral dm/sin(beta)
%   - d_H = bogaz ve uc hidrolik caplarinin ortalamasi (Eq 5-7, Eq 5-33 tanimi)
%   - Kanat sayisi <-> beta2 <-> geometri birlikte yakinsatilir.
% Kopru kalan: kanat kalinligi uc d_H'de ihmal.
%
% *** [DUZELTME -- H12] Bogaz ve hucum acisi ***
% Bogaz alani artik LE kanat acisi ve kalinligindan (inducer_throat_area.m);
% eskiden 0.95*A1*sin(beta1_ort) varsayilani vardi. Ortalama hucum i1, Aungier
% Bolum 6 SS3.4'teki gibi 0'dan baslar ve bogaz >= 1.2*A* olana kadar artirilir
% (Eq 6-15'in amaci: tasarim debisinden tikanmaya makul aralik). Pozitif hucumun
% kaybi Eq 5-27 ile performans analizinde hesaplanir.
if isempty(le_thickness_m)
    t_LE = 0.005 * r2_m;  % [KOPRU_TAHMINI 2] -- eski varsayilan
else
    t_LE = le_thickness_m;  % skaler (hub = shroud) veya [t_hub, t_shroud]
end
if isscalar(t_LE); t_LE = [t_LE, t_LE]; end  % [hub, shroud] -- LE kalinligi span boyunca dogrusal
static1_est = eos_static_from_total(eos, p0, T0, Cm1);
rel1_est = eos_total_from_static(eos, static1_est.p, static1_est.T, W1);
A_star_1 = sonic_area(mdot, rel1_est.p, rel1_est.T, eos.gamma, eos.R);
throat_margin_target = 1.2;

L_B_imp = L_B_estimate;
z_prev = -1;
geom_iter.Cm1_mean = Cm1; geom_iter.Cu1_mean = 0.0; geom_iter.r1_mean = r1_mean;
for outer = 1:20
    if isempty(n_blades_full_fixed)
        try
            blade_count_result = recommend_blade_count(U2, I_B_target, r2_m, L_B_imp, W1, W2);
            z_eff_recommended = blade_count_result.z_eff_recommended;
        catch exc
            z_eff_recommended = 24;
            count_warning = sprintf('Kanat sayisi onerisi basarisiz: %s', exc.message);
        end
    else
        z_eff_recommended = n_blades_full_fixed * (1.0 + splitter_length_ratio);
    end

    % Eq 4-11: z_eff = z_full + z_splitter * (L_SB/L); z_splitter = z_full.
    % Yukari yuvarlama: gercek z_eff, Eq 6-22'yi saglayan onerinin ALTINA dusmesin.
    % Uretilebilirlik icin tam kanat sayisi disaridan sabitlenebilir; kanat yuku
    % bu durumda tip.blade_loading_ratio ile raporlanir (<= 0.9, asla > 1.0).
    if ~isempty(n_blades_full_fixed)
        n_blades_full = n_blades_full_fixed;
        n_blades_splitter = (splitter_length_ratio > 0) * n_blades_full_fixed;
    elseif splitter_length_ratio > 0
        n_blades_full = max(1, ceil(z_eff_recommended / (1.0 + splitter_length_ratio) - 1e-9));
        n_blades_splitter = n_blades_full;
    else
        n_blades_full = z_eff_recommended;
        n_blades_splitter = 0;
    end
    z_eff_actual = n_blades_full + n_blades_splitter * splitter_length_ratio;

    lam = tip_distortion_factor_target(phi, 1.0, impeller_type);
    for it = 1:50
        beta2_deg = solve_tip_blade_angle_deg(I_B_target, lam, phi2, z_eff_actual, ...
            [], [], r1_shroud, r2_m);
        K_lambda = tip_distortion_factor_K_lambda(b2, L_B_imp, A2, A1, ...
            deg2rad(beta2_deg), deg2rad(beta1_deg));
        lam_new = tip_distortion_factor_target(phi, K_lambda, impeller_type);
        if abs(lam_new - lam) < 1e-10
            lam = lam_new;
            break;
        end
        lam = lam_new;
    end
    beta2_deg = solve_tip_blade_angle_deg(I_B_target, lam, phi2, z_eff_actual, [], [], r1_shroud, r2_m);

    % Hucum acisi: bogaz >= 1.2*A* saglayan en kucuk i1 >= 0 (0.25 derece adim)
    for i1_deg = 0:0.25:10
        le_angles = leading_edge_blade_angles(Cm1, 0.0, omega_rad_s, r1_hub, r1_mean, r1_shroud, i1_deg);
        A_th = inducer_throat_area(r1_hub, r1_shroud, le_angles.blade_hub, le_angles.blade_shroud, ...
            n_blades_full, t_LE(1), t_LE(2));
        if A_th >= throat_margin_target * A_star_1; break; end
    end

    % Gercek geometri (Eq 6-17) -> L_B, d_H
    geo_design.impeller_geometry = struct('r1_hub_m', r1_hub, 'r1_shroud_m', r1_shroud, ...
        'r2_m', r2_m, 'b2_m', b2, 'axial_length_z_m', axial_length_z_m, ...
        'blade_angle_2_deg', beta2_deg, 'rotational_speed_rpm', rotational_speed_rpm, ...
        'leading_edge_incidence_deg', i1_deg);
    bd_geo = aungier_blade_angle_distribution(geo_design, geom_iter, 81);
    L_hub = trapz(bd_geo.hub.m, 1 ./ sind(bd_geo.hub.beta_deg));
    L_shr = trapz(bd_geo.shroud.m, 1 ./ sind(bd_geo.shroud.beta_deg));
    L_B_new = 0.5 * (L_hub + L_shr);

    b1 = r1_shroud - r1_hub;
    s_th = A_th / (n_blades_full * b1);  % bogaz gecit genisligi (kanat basina)
    d_H_th = 2.0 * s_th * b1 / (s_th + b1);
    w_2 = 2.0 * pi * r2_m * sin(deg2rad(beta2_deg)) / (n_blades_full + n_blades_splitter);
    d_H_2 = 2.0 * w_2 * b2 / (w_2 + b2);
    d_H_imp = 0.5 * (d_H_th + d_H_2);

    converged = abs(L_B_new - L_B_imp) < 1e-7 && z_eff_actual == z_prev;
    L_B_imp = L_B_new;
    z_prev = z_eff_actual;
    if converged; break; end
end
if exist('count_warning', 'var')
    result.warnings{end+1} = count_warning;
end
if A_th < throat_margin_target * A_star_1
    result.warnings{end+1} = sprintf(['Inducer bogazi i1=%.1f derecede bile %.2f*A* altinda ' ...
        '(A_th/A* = %.3f) -- LE kalinligini azaltin veya inducer''i yeniden boyutlandirin.'], ...
        i1_deg, throat_margin_target, A_th / A_star_1);
end

result.beta2_deg = beta2_deg;
result.z_eff_recommended = z_eff_recommended;
result.z_eff_actual = z_eff_actual;
result.tip = struct('b2_source', b2_source, 'alpha2_deg', alpha2_deg, 'Cm2', Cm2, ...
    'Cu2', Cu2_estimate, 'rho2', rho2_estimate, 'eta_2H', eta_2H, 'lambda', lam, ...
    'K_lambda', K_lambda, 'W1', W1, 'W2', W2, ...
    'blade_loading_ratio', 2.0 * compute_delta_w(U2, I_B_target, z_eff_actual, L_B_imp, r2_m) / (W1 + W2), ...
    'L_B_camber', L_B_imp, 'L_B_straight', L_B_estimate, 'd_H', d_H_imp, ...
    'd_H_throat', d_H_th, 'd_H_tip', d_H_2, 'wrap_deg', bd_geo.wrap_hub_deg, 'outer_iterations', outer, ...
    'L_meridional', 0.5 * (bd_geo.hub.m(end) + bd_geo.shroud.m(end)), ...
    'A_throat', A_th, 'A_star_inlet', A_star_1, 'throat_margin', A_th / A_star_1, ...
    'i1_deg', i1_deg, 'beta1_blade_hub', le_angles.blade_hub, ...
    'beta1_blade_shroud', le_angles.blade_shroud, 'le_thickness', t_LE);  % [hub, shroud]

blade_thickness_estimate = mean(t_LE);  % Eq 5-27 blokaj terimi icin ortalama LE kalinligi

impeller_geometry.r1_hub_m = r1_hub;
impeller_geometry.r1_shroud_m = r1_shroud;
impeller_geometry.r2_m = r2_m;
impeller_geometry.b2_m = b2;
% [YENI -- preswirl] r1_shroud, PRESWIRL'SUZ optimum (W1s minimizasyonu,
% bkz. optimum_inducer_shroud_radius.m) uzerinden hesaplaniyor -- preswirl
% bu SABIT geometri uzerine performans analizinde (impeller_solve_station1.m,
% forced_vortex_prewhirl.m) ikinci bir ayar olarak uygulanir. Birlesik
% (r1_shroud+preswirl) optimizasyonu kapsam disi (bkz. plan notu) --
% preswirl arttikca W1s hep azaldigi icin kapali-form bir ic-minimum yok.
impeller_geometry.inlet_prewhirl_angle_deg = inlet_prewhirl_angle_deg;
impeller_geometry.blade_angle_2_deg = beta2_deg;
impeller_geometry.blade_angle_1_deg = le_angles.blade_mean;          % ortalama hat LE kanat acisi (akis + i1)
impeller_geometry.blade_angle_1_hub_deg = le_angles.blade_hub;       % [H12] yerel LE acilari
impeller_geometry.blade_angle_1_shroud_deg = le_angles.blade_shroud;
impeller_geometry.leading_edge_incidence_deg = i1_deg;
impeller_geometry.throat_area_m2 = A_th;                             % [H12] geometrik bogaz
impeller_geometry.n_blades_full = n_blades_full;
impeller_geometry.n_blades_splitter = n_blades_splitter;
impeller_geometry.splitter_length_ratio = splitter_length_ratio;
impeller_geometry.blade_leading_edge_thickness_m = blade_thickness_estimate;
impeller_geometry.blade_le_thickness_hub_m = t_LE(1);     % bogaz hesabi (inducer_throat_area.m)
impeller_geometry.blade_le_thickness_shroud_m = t_LE(2);
impeller_geometry.blade_mean_camberline_length_m = L_B_imp;  % [H9] Eq 6-17 geometrisinden
impeller_geometry.axial_length_z_m = axial_length_z_m;
impeller_geometry.meridional_length_m = result.tip.L_meridional;  % [H11] Eq 5-35 egrilik icin
impeller_geometry.mean_hydraulic_diameter_m = d_H_imp;  % [H9] bogaz + uc ortalamasi (Eq 5-7)
impeller_geometry.throat_blade_angle_deg = le_angles.blade_mean;
impeller_geometry.rotational_speed_rpm = rotational_speed_rpm;
impeller_geometry.impeller_type = impeller_type;  % istasyon 2'de sizinti modeli secimi (Eq 4-39 / 4-40)
impeller_geometry.tip_clearance_m = tip_clearance_m;  % Eq 4-12 (3. terim), 4-17..4-19, 5-40 -- sadece acik cark
result.impeller_geometry = impeller_geometry;

if strcmp(diffuser_type, 'vaneless')
    % [YENI -- duzeltme] vaneless_diffuser_exit_radius.m KENDI ICINDE
    % (test edilmis, kitaba sadik kalan) sozlesmesini koruyor: r_max
    % verilirse DOGRUDAN onu donduruyor (Aungier'in "eger maksimum yaricap
    % belirtilmisse kullanilir" ifadesi). AMA vanesiz difuzorde TOPLAM
    % basinc akis boyunca SADECE azalir (is girdisi yok, sadece surtunme) --
    % yani difuzoru gereksiz yere kasa sinirina KADAR uzatmak, ekstra
    % surtunme kaybindan baska bir sey eklemez ve PR_tt/eta_tt'yi
    % DUSURUR (olcerek dogrulandi: r2=59mm/mdot=0.54'te r4=125mm->
    % eta=80.8%, r4=96.6mm(dogal)->eta=84.9%). Bu yuzden BURADA (cagiran
    % tarafta) r_max sadece bir UST SINIR olarak uygulanir -- dogal
    % (Eq 6-23) deger zaten r_max'in altindaysa dogal deger kullanilir.
    r4_natural = vaneless_diffuser_exit_radius(r2_m, phi);
    if ~isempty(r_max_m)
        r4 = min(r4_natural, r_max_m);
    else
        r4 = r4_natural;
    end
    width_result = vaneless_diffuser_exit_width(r2_m, r4, Cu2_estimate, b2, 0.005, ...
        0.5 * (alpha2_deg + angles.alpha4_deg));
    diffuser_geometry.r4_m = r4;
    diffuser_geometry.b4_m = width_result.b4;
    diffuser_geometry.roughness_m = roughness_m;
    diffuser_geometry.mu_Pa_s = mu_Pa_s;
    alpha4_for_volute = angles.alpha4_deg;
else
    M2 = hypot(Cm2, Cu2_estimate) / eos_speed_of_sound(eos, p0, T0);
    r3 = vaned_diffuser_inlet_radius(r2_m, angles.alpha3_deg, M2);
    b3 = b2;  % Eq (6-14): b3<=b2, ilk tahminde en gevsek kabul
    vane_count_info = recommend_vane_count(z_eff_recommended);
    if ~isempty(vane_count_info.preferred_in_range)
        z_vanes = vane_count_info.preferred_in_range(1);
    else
        z_vanes = z_eff_recommended + 8;
    end

    C3_estimate = hypot(Cm2, Cu2_estimate);  % [KOPRU_TAHMINI] C3~C2
    Cu3_estimate = Cu2_estimate * r2_m / r3;
    if ~isempty(r_max_m)
        r4_max_for_search = r_max_m;
    else
        r4_max_for_search = r2_m * 2.0;
    end
    beta3_deg = angles.alpha3_deg - incidence.i3_deg;

    discharge = vaned_diffuser_discharge_sizing(r3, r4_max_for_search, beta3_deg, ...
        Cu3_estimate, C3_estimate, 0.6 * C3_estimate, z_vanes, L_B_estimate);

    % [KOPRU_TAHMINI] Throat alani tahmini -- impeller.m'nin kendi
    % varsayilan kuraliyla TUTARLI, ama vanli difuzor girisindeki ek
    % belirsizlik icin DAHA GENIS bir pay birakiliyor.
    A_th_estimate = (2.0 * pi * r3 * b3) * sin(deg2rad(beta3_deg));

    % [YENI -- kapasite kontrolu] Yukaridaki A_th_estimate SADECE
    % geometriden geliyor, hicbir termodinamik (pt3/Tt3) kontrolunden
    % gecmiyor. run_stage_pipeline'daki GERCEK vaned_diffuser_compute.m
    % ise ayni A_th'i GERCEK (kayipli) pt3/Tt3 ile test ediyor ve bazi
    % (kucuk r2) noktalarda pipeline ortasinda kriptik bir "isaret
    % degisimi bulunamadi" hatasiyla patliyordu (bkz. sohbet -- r2=58mm,
    % ulasilabilen ~0.4986 kg/s < hedef 0.5 kg/s). Burada ERKEN ve ACIK
    % bir kapasite kontrolu ekleniyor -- Euler is denklemi (rothalpi
    % korunumu, U1*Cu1 terimi ihmal edilebilir -- preswirl kucuk) ve
    % mevcut rho2_estimate ile TUTARLI bir pt3/Tt3 tahmini kullanilarak
    % (yeni bir "kafadan" katsayi UYDURULMUYOR, sadece zaten var olan
    % tahminler ileri tasiniyor).
    cp = eos.cp;
    Tt3_estimate = T0 + (U2 * Cu2_estimate) / cp;  % rothalpi korunumu, Cu1~=0
    % pt3 icin IZANTROPIK (kayipsiz) tahmin kullaniliyor -- rho2_estimate
    % (=0.85*rho_t0, sadece Cm2 kutle-korunumu icin kaba bir SURTUNME/
    % dagilim tahmini) burada YANILTICI cunku gercek toplam basinci degil
    % statik-benzeri bir buyuklugu temsil ediyor. Izantropik iliski
    % (standart termodinamik, uydurma katsayi degil) EN IYIMSER (en
    % yuksek pt3, dolayisiyla EN KUCUK gerekli A*) tahmini verir --
    % yani bu kontrol A_th < A*_izantropik bulursa, gercek (kayipli)
    % pipeline'da KESINLIKLE de yetersiz kalacaktir (konservatif/
    % false-negative-guvenli kontrol).
    pt3_estimate = p0 * (Tt3_estimate / T0)^(eos.gamma / (eos.gamma - 1.0));
    A_star_estimate = sonic_area(mdot, pt3_estimate, Tt3_estimate, eos.gamma, eos.R);
    if A_th_estimate < A_star_estimate
        result.warnings{end+1} = sprintf(...
            ['Vanli difuzor boyunu (throat, A_th=%.4g m^2) tahmini sonik alandan ' ...
             '(A*~%.4g m^2) KUCUK -- bu tasarim noktasi kanatli difuzorde ' ...
             'BOGAZLANABILIR (run_stage_pipeline asamasinda basarisiz olabilir). ' ...
             'b3<=b2 (Eq 6-14) kisitindan dolayi throat alani burada buyutulemiyor; ' ...
             'r2, r_min veya diffuser_type degistirmeyi degerlendirin.'], ...
            A_th_estimate, A_star_estimate);
    end

    diffuser_geometry.r4_m = discharge.r4;
    diffuser_geometry.b4_m = b3;
    diffuser_geometry.blade_angle_3_deg = beta3_deg;
    diffuser_geometry.blade_angle_4_deg = discharge.beta4_deg;
    diffuser_geometry.n_vanes = z_vanes;
    diffuser_geometry.throat_area_m2 = A_th_estimate;
    diffuser_geometry.throat_width_m = A_th_estimate / (z_vanes * b3);
    diffuser_geometry.blade_mean_camberline_length_m = L_B_estimate;
    diffuser_geometry.mean_hydraulic_diameter_m = 2.0 * b3;
    diffuser_geometry.mu_Pa_s = mu_Pa_s;
    diffuser_geometry.roughness_m = roughness_m;
    diffuser_geometry.r3_m_for_inlet_station = r3;
    alpha4_for_volute = discharge.beta4_deg;
end

result.diffuser_type = diffuser_type;
result.diffuser_geometry = diffuser_geometry;

% ----------------------------------------------------------------
% Katman 5: Volut VEYA Crossover+Return channel boyutlandirma
% ----------------------------------------------------------------

result.volute_geometry = struct();
result.crossover_geometry = struct();
result.return_channel_geometry = struct();
result.plenum_geometry = struct();

if strcmp(stage_type, 'voluted')
    % --- A) Volutlu son kademe (Eq 6-33) ---
    A4 = 2.0 * pi * diffuser_geometry.r4_m * diffuser_geometry.b4_m;
    volute_result = volute_sizing_iterate(A4, diffuser_geometry.r4_m, alpha4_for_volute, ...
        [], [], r_max_m);
    result.volute_geometry.r6_m = volute_result.r6;
    result.volute_geometry.A6_m2 = volute_result.A6;
    result.volute_geometry.A7_m2 = volute_result.A6 * 0.7;  % [KOPRU_TAHMINI] exit cone kontraksiyonu
    result.volute_geometry.mu_Pa_s = mu_Pa_s;
    result.volute_geometry.roughness_m = roughness_m;

elseif strcmp(stage_type, 'dump')
    % --- C) [YENI] Toplayici yok -- difuzor cikisi (istasyon 4) pipeline'in
    % son istasyonu olarak birakiliyor. volute_geometry/crossover_geometry/
    % return_channel_geometry bos struct olarak kaliyor (yukarida zaten
    % ayarlandi) -- sweep_build_components.m bu durumda pipeline'a hicbir
    % ek bilesen eklemiyor.

elseif strcmp(stage_type, 'dump_with_plenum')
    % --- D) [YENI] "dump" ile ayni + difuzor cikisindan sonra bir aniler
    % dump plenum (bkz. annular_dump_plenum_compute.m, Aungier disi --
    % Borda-Carnot ani genisleme). Sadece hedef hizi burada saklıyoruz;
    % gercek A5/r5/b5/pt5 hesaplarini bileşenin kendisi (pipeline
    % calisirken) yapiyor -- design-stage'de sadece GEOMETRIYI/hedefi
    % gecirmek yeterli.
    result.plenum_geometry.target_C_exit_m_s = plenum_target_C_exit_m_s;

else
    % --- B) Ara kademe: Crossover Bend + Return Channel (Eq 6-29->6-32) ---
    r4 = diffuser_geometry.r4_m;
    b4 = diffuser_geometry.b4_m;

    % Crossover bend giris akis acisi icin difuzor cikis acisini kullan
    alpha4_for_crossover = alpha4_for_volute;  % ayni degisken, farkli kullanim

    % --- Eq 6-29: crossover discharge width (b6) ---
    alpha6_deg = angles.alpha6_deg;
    B_M6_estimate = 0.04;  % [KOPRU_TAHMINI] return channel giris metal blokaji

    b6 = crossover_discharge_width(b4, alpha4_for_crossover, alpha6_deg, B_M6_estimate);

    % --- Eq 6-30: hub egrilik yaricapi (R_ch) ---
    if ~isempty(r_next_stage_eye_m)
        omega_next = 2.0 * pi * rotational_speed_rpm / 60.0;
        U_eye_next = omega_next * r_next_stage_eye_m;
        rho_eye_next = eos_density(eos, p0, T0) * 0.9;  % [KOPRU_TAHMINI]
        Cm_eye_next = inlet_meridional_velocity(U_eye_next, alpha1_prime_deg);
        A_eye_next = mdot / (rho_eye_next * Cm_eye_next);
        r_hub_next = r_next_stage_eye_m * 0.45;  % [KOPRU_TAHMINI]
        r_shroud_next = sqrt(r_hub_next^2 + A_eye_next / pi);
        b8_estimate = r_shroud_next - r_hub_next;
    else
        b8_estimate = b2 * 2.5;  % [KOPRU_TAHMINI] bir sonraki kademe goz genisligi
        result.warnings{end+1} = 'r_next_stage_eye_m verilmedi -- b8 tahmini [KOPRU_TAHMINI] kullanildi.';
    end

    R_ch = crossover_hub_radius_of_curvature(b6, b4, b8_estimate);

    % --- Crossover yaricapi: r4'ten r6'ya gecis ---
    % [KOPRU_TAHMINI] Crossover cikisinda yaricap: Chapter 6 r6'yi dogrudan
    % vermez; return system'in sigacagi yaricap r4'un belirli bir fraksiyonu.
    % Tipik crossover cikis yaricapi r4'un %55-75'i arasinda -- ortada bir
    % tahminle %65 kullaniliyor.
    if ~isempty(r_min_m)
        r6 = max(r4 * 0.65, r_min_m * 3.0);
    else
        r6 = r4 * 0.65;  % [KOPRU_TAHMINI]
    end

    % Eq 6-31: Shroud elips eksenleri (diagnostik, zorunlu degil)
    ellipse = crossover_shroud_ellipse_axes(R_ch, b4, b6);

    result.crossover_geometry.r6_m = r6;
    result.crossover_geometry.b6_m = b6;
    result.crossover_geometry.R_ch_m = R_ch;
    result.crossover_geometry.sin_alpha_C = 0.65;  % [KOPRU_TAHMINI] -- bkz. CrossoverBend aciklamasi
    result.crossover_geometry.mu_Pa_s = mu_Pa_s;
    result.crossover_geometry.roughness_m = roughness_m;
    result.crossover_geometry.ellipse_A_CO = ellipse.A_CO;
    result.crossover_geometry.ellipse_B_CO = ellipse.B_CO;

    % --- Return Channel boyutlandirma (Eq 6-29 tamamlayicisi) ---
    if ~isempty(r_next_stage_eye_m)
        r7 = r_next_stage_eye_m * 1.05;
    else
        r7 = r6 * 0.40;  % [KOPRU_TAHMINI]
    end
    r7 = min(r7, r6 / 2.1);  % r6/r7 >= 2.1 kisiti (saglamlik)

    % b7: return channel cikis genisligi
    b7 = b8_estimate * 1.1;  % [KOPRU_TAHMINI] exit turn icin biraz daha genis

    % Return channel kanat sayisi (Eq 6-14/6-15 bant kurallari)
    if z_eff_recommended < 15
        z_rc = z_eff_recommended + 4;
    else
        z_rc = z_eff_recommended + 2;
    end
    z_rc = min(z_rc, 24);  % [KOPRU_TAHMINI]

    % Return channel throat alani (vanesiz/genis aci kabuluyle)
    A6_annular = 2.0 * pi * r6 * b6;
    A_th_rc = A6_annular * sin(deg2rad(max(alpha6_deg - 2.0, 10.0)));

    % Eq 6-32: Exit turn radii (diagnostik, zorunlu degil)
    exit_radii = exit_turn_radii_of_curvature(b8_estimate);

    % Return channel blade angles
    % [KOPRU_TAHMINI] beta7=90 derece cok agresif; 55-65 derece arasi
    % tipik endustriyel deger.
    beta6_deg_rc = max(alpha6_deg - incidence.i6_deg, 10.0);
    beta7_deg_rc = 60.0;  % [KOPRU_TAHMINI] orta bir cikis kanat acisi

    result.return_channel_geometry.r7_m = r7;
    result.return_channel_geometry.b7_m = b7;
    result.return_channel_geometry.blade_angle_6_deg = beta6_deg_rc;
    result.return_channel_geometry.blade_angle_7_deg = beta7_deg_rc;
    result.return_channel_geometry.n_vanes = z_rc;
    result.return_channel_geometry.throat_area_m2 = A_th_rc;
    result.return_channel_geometry.blade_mean_camberline_length_m = L_B_estimate;
    result.return_channel_geometry.mean_hydraulic_diameter_m = 2.0 * b6;
    result.return_channel_geometry.mu_Pa_s = mu_Pa_s;
    result.return_channel_geometry.roughness_m = roughness_m;
    result.return_channel_geometry.vane_trailing_edge_thickness_m = 0.001 * r2_m / 0.110;
    result.return_channel_geometry.exit_turn_R_cEXs = exit_radii.R_cEXs;
    result.return_channel_geometry.exit_turn_R_cEXh = exit_radii.R_cEXh;
end

end


function rho2 = local_tip_static_density(Cm2, Cu2, Tt2, pt2, cp, gam, eos)
% Cark ucu statik yogunlugu: Tt2 (tum is, Eq 4-1) ve pt2 (kanat isi + eta_2H,
% Eq 6-9) ile, C2 hiz basi dusulerek (Bolum 6 SS2.4).
C2 = hypot(Cm2, Cu2);
T2 = Tt2 - C2^2 / (2.0 * cp);
p2 = pt2 * (T2 / Tt2)^(gam / (gam - 1.0));
rho2 = eos_density(eos, p2, T2);
end
