function D_eq = igv_equivalent_diffusion_factor(geom, delta_star_deg, i_deg, A_m1, A_0, Gamma)
%IGV_EQUIVALENT_DIFFUSION_FACTOR losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.5 / Eq 5-20 BIREBIR portu].
%   Eq. (5-20): D_eq = [1.12+0.61*Gamma*cos^2(kappa_{-1}+i)]*A_0*cos(kappa_0+delta*)
%                      / (A_{-1}*cos(kappa_{-1}+i))
%
%   *** GAMMA HAKKINDA NOT *** -- Bolum5_DersNotu.md'de Gamma (kanat
%   yukleme dagilimi sabiti, Lieblein 1959) SAYISAL OLARAK TANIMLANMAMIS
%   (kaynak metinde formul var ama Gamma'nin degeri/tanimi bu bolumde
%   verilmiyor). Gamma=0 varsayilirsa (klasik Lieblein formuna indirgenen,
%   yaygin kullanilan bir basitlestirme) formul D_eq=1.12*A_0*cos(delta*
%   -referansli terim)/(A_{-1}*cos(kappa_{-1}+i)) haline duser. BU
%   FONKSIYON Gamma'yi ZORUNLU GIRDI yapar (varsayilan atamiyor) --
%   cagiran kod bilinctli bir deger (orn. 0.0) gecmeli, boylece varsayim
%   ORTULU degil ACIK olur.
%
%   geom: igv_camber_geometry.m ciktisi (kappa_m1, kappa_0)
%   delta_star_deg: Eq (5-15) sapma acisi
%   i_deg: hucum acisi [derece]
%   A_m1, A_0: giris/cikis akim alani [m^2]
%   Gamma: kanat yukleme sabiti [-] -- ZORUNLU, varsayim yok

i_r = deg2rad(i_deg);
kappa_m1_r = deg2rad(geom.kappa_m1);
kappa_0_r = deg2rad(geom.kappa_0);
delta_r = deg2rad(delta_star_deg);

numerator = (1.12 + 0.61 * Gamma * cos(kappa_m1_r + i_r)^2) * A_0 * cos(kappa_0_r + delta_r);
denominator = A_m1 * cos(kappa_m1_r + i_r);

D_eq = numerator / denominator;

end
