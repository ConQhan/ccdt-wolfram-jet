function [beta_0_deg, geom, delta_star_deg] = igv_solve_exit_metal_angle_deg(target_alpha_0_deg, ...
    beta_m1_deg, sigma, beta_0_bracket_deg)
%IGV_SOLVE_EXIT_METAL_ANGLE_DEG design/igv_sizing.py :: [YENI -- Eq 5-9-5-16'nin TERSI].
%   Verilen bir HEDEF mutlak cikis akis acisi (target_alpha_0_deg --
%   forced_vortex_prewhirl.m'deki inlet_prewhirl_angle_deg ile AYNI
%   tanim/cerceve, meridyenden olculur) icin, Howell sapma acisi
%   korelasyonunu (Eq 5-15/5-16) SAGLAYACAK IGV kanat cikis METAL acisini
%   (beta_0, teget'ten olculur) fzero ile cozer.
%
%   Akis geride kaldigi (sapma, delta*>0) icin metal acisi HER ZAMAN
%   hedef akis acisindan biraz daha "agresif" (fazla donduren) olmali --
%   bu yuzden dogrudan analitik degil, iteratif cozum gerekir.
%
%   Girdiler:
%     target_alpha_0_deg : hedeflenen mutlak cikis akis acisi [derece]
%     beta_m1_deg        : IGV giris METAL acisi [derece], TEGET'TEN
%                           olculur (bu kod tabanindaki beta1_deg/beta2_deg
%                           ile AYNI konvansiyon) -- tipik: 90, eksenel
%                           yaklasim (swirl yok) varsayimi. DIKKAT: bu,
%                           alpha_0'in (Eq 5-16) MERIDYENDEN olculmesinden
%                           FARKLI bir referans -- kaynak metnin kendi
%                           ayrimi (SS2.1, "teget yonle olculen beta'dan
%                           farkli olarak").
%     sigma               : solidite [-]
%     beta_0_bracket_deg  : fzero arama araligi [derece], varsayilan
%                           [1, beta_m1_deg-1] (IGV swirl EKLEDIGI icin
%                           beta_0, eksenel yaklasimdan -- beta_m1_deg=90 --
%                           KUCULUR)
%
%   Cikti: beta_0_deg (cozulen IGV cikis metal acisi), geom
%   (igv_camber_geometry.m ciktisi, cozulen beta_0'da), delta_star_deg
%   (Eq 5-15, cozulen beta_0'da)

if nargin < 4 || isempty(beta_0_bracket_deg)
    % ust sinir kamber acisini (theta) ~45 derecede tutar -- Eq (5-15)
    % paydasi (sqrt(sigma)-0.02*theta) tipik solidite (sigma>=1) icin
    % theta~52 derece civarinda sifira yaklasiyor; 45 derece guvenli pay birakir.
    beta_0_bracket_deg = [max(1.0, beta_m1_deg - 45.0), beta_m1_deg - 1.0];
end

    function r = residual(beta_0_trial)
        g_trial = igv_camber_geometry(beta_m1_deg, beta_0_trial, sigma);
        d_trial = igv_deviation_angle(g_trial);
        alpha_0_trial = igv_exit_flow_angle(g_trial, d_trial);
        r = alpha_0_trial - target_alpha_0_deg;
    end

f_lo = residual(beta_0_bracket_deg(1));
f_hi = residual(beta_0_bracket_deg(2));
if f_lo * f_hi > 0.0
    error('centrifugal:igv_solve_exit_metal_angle_deg', ...
        ['igv_solve_exit_metal_angle_deg: [%g, %g] derece araliginda hedef aciya ' ...
         '(%.3f derece) ulasan bir beta_0 bulunamadi.'], ...
        beta_0_bracket_deg(1), beta_0_bracket_deg(2), target_alpha_0_deg);
end

beta_0_deg = fzero(@residual, beta_0_bracket_deg, optimset('TolX', 1e-8));

geom = igv_camber_geometry(beta_m1_deg, beta_0_deg, sigma);
delta_star_deg = igv_deviation_angle(geom);

end
