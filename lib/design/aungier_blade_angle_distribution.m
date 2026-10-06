function bd = aungier_blade_angle_distribution(design, station1, n_points)
%AUNGIER_BLADE_ANGLE_DISTRIBUTION Aungier Eq (6-17) hub/shroud kanat acisi
%   dagilimi, 3-B duz-cizgi-elemanli (ruled) kanat icin (Bolum 6 SS5.2,
%   Bolum 7 SS1, SS4).
%
%   Kitaptaki insa (Bolum 6 SS5.2 ve Aungier_Formulleri_ve_Sinirlari.md SS5.4):
%     - Shroud:  beta_s(z) = beta_1s + (beta_2 - beta_1s)*(3z^2 - 2z^3)
%                (LE ve TE'de sifir egim; yuksek Mach'li shroud girisinde
%                yuklemeyi azaltir)
%     - Hub:     beta_h(z) = beta_1h + A z + B z^2 + C z^3
%                beta_h_bar = 90K + (1-K)(beta_2 + beta_1h)/2   (z = 0.5'teki deger)
%                A = -4(beta_2 - 2 beta_h_bar + beta_1h)
%                B = 11 beta_2 - 16 beta_h_bar + 5 beta_1h
%                C = -6 beta_2 + 8 beta_h_bar - 2 beta_1h
%                (TE'de sifir egim)
%     - Firar kenarinda hub ve shroud AYNI beta_2 ile biter.
%     - Hucum kenarinda kanat acisi hub'dan shroud'a DOGRUSAL degisir;
%       ortalama hatta hucum acisi i1 (varsayilan 0, Bolum 6 SS3.4) saglanir,
%       shroud hucum acisi hub hucum acisinin %25'i olur.
%     - K parametresi rake (sirt) acilarini kontrol eder: LE ve TE rake
%       acilari esit buyuklukte ve zit isaretli; mumkunse < 15 derece, K <= 1.
%   Tum acilar TEGETTEN olculur (90 derece = radyal), CFTurbo ile ayni.
%
%   Kutupsal aci: cot(beta) = r dtheta/dm (Eq 7-1, duz-cizgi-elemanli)
%   -> theta(m) = integral cot(beta)/r dm.
%
%   Meridyonel konturlar [KOPRU]: hub, kitabin onerdigi dairesel-yay + dogru
%   (Eq 7-11..7-14, circular_arc_contour_solve.m); shroud icin kitap 3-nokta
%   kubik spline oneriyor (Eq 7-15..7-20) ama ara kontrol noktasi on tasarimda
%   tanimli olmadigindan AYNI dairesel-yay insasi kullaniliyor. Eksenel
%   uzunluk Eq (6-3) (design.impeller_geometry.axial_length_z_m). Tam-inducer:
%   LE z=0 duzleminde, cikis radyal, shroud TE z = Lz - b2'de.
%
%   Girdi: design (design_preliminary_stage), station1 (impeller_solve_station1),
%          n_points (varsayilan 41)
%   Cikti struct: hub/shroud (z, r, m, zeta, beta_deg, theta_rad), K,
%          rake_LE_deg, rake_TE_deg, beta1 (blade/flow/incidence hub-mean-shroud),
%          span_table (5 span: LE/TE blade acisi, CFTurbo girisi icin),
%          kappa_b (Eq 7-59 icin ortalama gecis egriligi*genislik).

if nargin < 3 || isempty(n_points); n_points = 41; end

g = design.impeller_geometry;
r1h = g.r1_hub_m; r1s = g.r1_shroud_m; r2 = g.r2_m; b2 = g.b2_m;
Lz = g.axial_length_z_m;
beta2 = g.blade_angle_2_deg;
omega = 2 * pi * g.rotational_speed_rpm / 60;

% --- Meridyonel konturlar (z yatay, r dusey) ---
[zh, rh] = contour_points(0.0, r1h, Lz, r2, n_points);
[zs, rs] = contour_points(0.0, r1s, Lz - b2, r2, n_points);
mh = meridional_arc_length(rh, zh);
ms = meridional_arc_length(rs, zs);
zeta_h = mh / mh(end);
zeta_s = ms / ms(end);

% --- Hucum kenari: akis acilari ve %25 kurali ---
Cm1 = station1.Cm1_mean;
Cu1 = struct_get(station1, 'Cu1_mean', 0.0);
r1m = station1.r1_mean;
bf = @(r) atan2d(Cm1, omega * r - Cu1);
% Ortalama hucum i1: varsayilan 0 (Bolum 6 SS3.4); tasarim tikanma payi icin
% artirmissa (Eq 6-15 amaci) geometri alanindan okunur.
i1 = struct_get(g, 'leading_edge_incidence_deg', 0.0);
le = leading_edge_blade_angles(Cm1, Cu1, omega, r1h, r1m, r1s, i1);
bf_h = le.flow_hub; bf_m = le.flow_mean; bf_s = le.flow_shroud;
bb_h = le.blade_hub; bb_s = le.blade_shroud;

% --- Shroud dagilimi (K'dan bagimsiz) ---
beta_s = bb_s + (beta2 - bb_s) * (3 * zeta_s.^2 - 2 * zeta_s.^3);
theta_s = cumtrapz(ms, cotd(beta_s) ./ rs);

% --- K taramasi: |rake| minimum, K <= 1 ---
b1 = r1s - r1h;
K_grid = linspace(-1.0, 1.0, 801);
best = struct('rake', Inf);
for K = K_grid
    [beta_h, theta_h] = hub_distribution(K, bb_h, beta2, zeta_h, mh, rh);
    D = theta_s(end) - theta_h(end);
    % LE ofseti delta: rake_LE = -rake_TE  ->  r1m*delta/b1 = -r2*(delta+D)/b2
    delta = -D * (r2 / b2) / (r1m / b1 + r2 / b2);
    rake_TE = atand(r2 * (delta + D) / b2);
    rake_LE = atand(r1m * delta / b1);
    if abs(rake_TE) < best.rake
        best = struct('rake', abs(rake_TE), 'K', K, 'beta_h', beta_h, 'theta_h', theta_h, ...
            'delta', delta, 'rake_TE', rake_TE, 'rake_LE', rake_LE);
    end
end

bd.hub = struct('z', zh, 'r', rh, 'm', mh, 'zeta', zeta_h, 'beta_deg', best.beta_h, ...
    'theta_rad', best.theta_h);
bd.shroud = struct('z', zs, 'r', rs, 'm', ms, 'zeta', zeta_s, 'beta_deg', beta_s, ...
    'theta_rad', theta_s + best.delta);
bd.K = best.K;
bd.rake_LE_deg = best.rake_LE;
bd.rake_TE_deg = best.rake_TE;
bd.rake_ok = abs(best.rake_TE) <= 15.0;
bd.beta1 = struct('blade_hub', bb_h, 'blade_shroud', bb_s, 'blade_mean', 0.5 * (bb_h + bb_s), ...
    'flow_hub', bf_h, 'flow_mean', bf_m, 'flow_shroud', bf_s, ...
    'inc_hub', bb_h - bf_h, 'inc_mean', 0.5 * (bb_h + bb_s) - bf_m, 'inc_shroud', bb_s - bf_s);
bd.beta2_deg = beta2;
bd.wrap_hub_deg = rad2deg(bd.hub.theta_rad(end) - bd.hub.theta_rad(1));
bd.wrap_shroud_deg = rad2deg(bd.shroud.theta_rad(end) - bd.shroud.theta_rad(1));

% Eq 7-59 icin: ortalama hat egriligi ~ (alphaC2 - alphaC1)/L_ortalama
L_mean = 0.5 * (mh(end) + ms(end));
bd.kappa_b = (pi / 2) / L_mean * 0.5 * (b1 + b2);

% --- CFTurbo 5-span tablosu (duz-cizgi elemanli: LE dogrusal, TE sabit) ---
span = [0; 0.25; 0.5; 0.75; 1.0];
names = {'Hub'; '2'; 'Middle'; '4'; 'Shroud'};
beta_LE = bb_h + (bb_s - bb_h) * span;
r_LE = r1h + (r1s - r1h) * span;
beta_flow_LE = bf(r_LE);
bd.span_table = table(names, span, r_LE * 1e3, beta_flow_LE, beta_LE, beta_LE - beta_flow_LE, ...
    repmat(beta2, 5, 1), 'VariableNames', {'Span', 'span_frac', 'r_LE_mm', 'beta1_akis_deg', ...
    'beta1_kanat_deg', 'hucum_deg', 'beta2_kanat_deg'});

end


function [z, r] = contour_points(z1, r1, z2, r2, n)
% Eksenel giris (alpha_C = 0) -> radyal cikis (alpha_C = 90 deg), minimum egrilik
c = circular_arc_contour_solve(z1, r1, 0.0, z2, r2, pi / 2);
[z, r] = circular_arc_contour_points(c, n);
end


function [beta_h, theta_h] = hub_distribution(K, beta1h, beta2, zeta, m, r)
beta_bar = 90 * K + (1 - K) * (beta2 + beta1h) / 2;
A = -4 * (beta2 - 2 * beta_bar + beta1h);
B = 11 * beta2 - 16 * beta_bar + 5 * beta1h;
C = -6 * beta2 + 8 * beta_bar - 2 * beta1h;
beta_h = beta1h + A * zeta + B * zeta.^2 + C * zeta.^3;
theta_h = cumtrapz(m, cotd(beta_h) ./ r);
end
