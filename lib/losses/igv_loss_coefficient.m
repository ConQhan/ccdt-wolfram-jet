function omega_bar = igv_loss_coefficient(geom, delta_star_deg, i_deg, angles, A_m1, A_0, D_eq)
%IGV_LOSS_COEFFICIENT losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.5 / Eq 5-21 BIREBIR portu].
%   Eq. (5-21):
%   omega_bar = [0.018*sigma*(1+X^3)/cos(kappa_0+delta*)] *
%               [A_{-1}*cos(kappa_{-1}+i*) / (A_0*cos(kappa_0+delta*))]^2 * D_eq^2
%
%   X, hucum acisinin i*'a gore normalize edilmis sapmasidir:
%     i>=i*:  X = (i-i*)/(i_S-i*)
%     i<i*:   X = (i*-i)/(i*-i_C)
%   (Tasarim hucum acisindan uzaklastikca kayip X^3 ile HIZLA artar.)
%
%   geom: igv_camber_geometry.m ciktisi
%   delta_star_deg: Eq (5-15)
%   i_deg: hucum acisi [derece]
%   angles: igv_stall_incidence_angles.m ciktisi (i_star_deg, i_S_deg, i_C_deg)
%   A_m1, A_0: giris/cikis akim alani [m^2]
%   D_eq: igv_equivalent_diffusion_factor.m ciktisi
%   Cikti: omega_bar [-] (toplam basinc kaybi katsayisi)

i_star = angles.i_star_deg;
if i_deg >= i_star
    denom = angles.i_S_deg - i_star;
    if abs(denom) < 1e-9
        X = 0.0;
    else
        X = (i_deg - i_star) / denom;
    end
else
    denom = i_star - angles.i_C_deg;
    if abs(denom) < 1e-9
        X = 0.0;
    else
        X = (i_star - i_deg) / denom;
    end
end

kappa_0_r = deg2rad(geom.kappa_0);
kappa_m1_r = deg2rad(geom.kappa_m1);
delta_r = deg2rad(delta_star_deg);
i_star_r = deg2rad(i_star);

area_ratio = (A_m1 * cos(kappa_m1_r + i_star_r)) / (A_0 * cos(kappa_0_r + delta_r));

omega_bar = (0.018 * geom.sigma * (1.0 + X^3) / cos(kappa_0_r + delta_r)) * area_ratio^2 * D_eq^2;

end
