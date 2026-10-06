function angles = igv_stall_incidence_angles(geom)
%IGV_STALL_INCIDENCE_ANGLES losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.4 / Eq 5-17-5-19 BIREBIR portu].
%   Herrig ve ark. (1957) NACA kaskad verisinden gelistirilen korelasyonlar:
%   Eq. (5-17): i* = (3.6+theta/3.42)*sqrt(sigma) + gamma - kappa_{-1}
%   Eq. (5-18): i_S - i* = 4*(a/c)^2*(10deg + 0.36*theta)
%   Eq. (5-19): i* - i_C = 2*(a/c)*(9deg - 0.06*theta)
%
%   geom: igv_camber_geometry.m ciktisi
%   Cikti (struct): i_star_deg (minimum-kayip hucum acisi), i_S_deg
%   (pozitif stall), i_C_deg (negatif stall) -- hepsi [derece]

theta = geom.theta_deg;

i_star_deg = (3.6 + theta / 3.42) * sqrt(geom.sigma) + geom.gamma_deg - geom.kappa_m1;
i_S_minus_i_star = 4.0 * geom.a_over_c^2 * (10.0 + 0.36 * theta);
i_star_minus_i_C = 2.0 * geom.a_over_c * (9.0 - 0.06 * theta);

angles.i_star_deg = i_star_deg;
angles.i_S_deg = i_star_deg + i_S_minus_i_star;
angles.i_C_deg = i_star_deg - i_star_minus_i_C;

end
