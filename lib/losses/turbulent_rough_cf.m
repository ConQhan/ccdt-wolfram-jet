function cf = turbulent_rough_cf(roughness_e, d)
%TURBULENT_ROUGH_CF losses/skin_friction.py :: turbulent_rough_cf() portu.
%   Eq. (5-3): 1/sqrt(4cf) = -2*log10(e/(3.71*d))  (tam puruzlu rejim, Re_d'den bagimsiz)
if roughness_e <= 0
    error('centrifugal:turbulent_rough_cf', 'Tam puruzlu rejim icin e>0 gereklidir');
end
root4cf_inv = -2.0 * log10(roughness_e / (3.71 * d));
cf = 1.0 / (4.0 * root4cf_inv^2);
end
