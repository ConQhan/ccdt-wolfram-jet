function geom = igv_camber_geometry(beta_m1, beta_0, sigma)
%IGV_CAMBER_GEOMETRY losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.1-2.2 / Eq 5-9-5-14 BIREBIR portu].
%   IGV (Inlet Guide Vane) kanat geometrisini, teget-referansli metal
%   acilarindan (beta_{-1} giris, beta_0 cikis -- santrifuj kompresor
%   konvansiyonuyla ayni, teget'ten olculur) meridyen-referansli aciklara
%   (kappa) cevirir ve kamber/solidite parametrelerini hesaplar.
%
%   Eq. (5-9):  K = (beta_0-beta_{-1}) / |beta_0-beta_{-1}|   (isaret duzeltmesi)
%   Eq. (5-10): kappa_{-1} = K*(90deg - beta_{-1})
%   Eq. (5-11): kappa_0    = K*(90deg - beta_0)
%   Eq. (5-12): kappa_bar  = K*(90deg - beta_bar), beta_bar=(beta_{-1}+beta_0)/2
%   Eq. (5-13): theta = kappa_{-1}-kappa_0 (kamber), gamma=(kappa_{-1}+kappa_bar+kappa_0)/3 (siralama)
%   Eq. (5-14): a/c = (2-|kappa_bar-kappa_0|/theta)/3
%
%   Girdiler: beta_m1, beta_0 [derece, teget'ten olculur, IGV giris/cikis
%             METAL acilari], sigma [-] (solidite)
%   Cikti (struct): K, kappa_m1, kappa_0, kappa_bar, theta_deg, gamma_deg, a_over_c, sigma

if beta_0 == beta_m1
    error('centrifugal:igv_camber_geometry', 'beta_0 ve beta_{-1} esit olamaz (K tanimsiz -- kamber yok).');
end

K = sign(beta_0 - beta_m1);

kappa_m1 = K * (90.0 - beta_m1);
kappa_0 = K * (90.0 - beta_0);
beta_bar = 0.5 * (beta_m1 + beta_0);
kappa_bar = K * (90.0 - beta_bar);

theta_deg = kappa_m1 - kappa_0;
gamma_deg = (kappa_m1 + kappa_bar + kappa_0) / 3.0;
a_over_c = (2.0 - abs(kappa_bar - kappa_0) / theta_deg) / 3.0;

geom.K = K;
geom.kappa_m1 = kappa_m1;
geom.kappa_0 = kappa_0;
geom.kappa_bar = kappa_bar;
geom.theta_deg = theta_deg;
geom.gamma_deg = gamma_deg;
geom.a_over_c = a_over_c;
geom.sigma = sigma;

end
