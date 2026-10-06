function delta_star_deg = igv_deviation_angle(geom)
%IGV_DEVIATION_ANGLE losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.3 / Eq 5-15 BIREBIR portu].
%   Howell (1947) sapma acisi korelasyonu:
%   Eq. (5-15): delta* = theta*[0.92*(a/c)^2 + 0.02*kappa_0] / (sqrt(sigma) - 0.02*theta)
%
%   geom: igv_camber_geometry.m ciktisi (theta_deg, a_over_c, kappa_0, sigma alanlarini kullanir)
%   Cikti: delta_star_deg [derece]

theta = geom.theta_deg;
denom = sqrt(geom.sigma) - 0.02 * theta;
if abs(denom) < 1e-9
    error('centrifugal:igv_deviation_angle', 'Eq (5-15) paydasi sifira cok yakin.');
end

delta_star_deg = theta * (0.92 * geom.a_over_c^2 + 0.02 * geom.kappa_0) / denom;

end
