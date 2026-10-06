function sigma_cor = slip_factor_corrected(sigma, eps, eps_lim, beta2)
%SLIP_FACTOR_CORRECTED losses/impeller_losses.py :: [YENI -- Aungier_Formulleri_ve_Sinirlari.md SS5.5 / Eq 4-10 portu].
%   Eq. (4-10): eps > eps_LIM icin
%       sigma_COR = sigma * [1 - ((eps-eps_LIM)/(1-eps_LIM))^sqrt(beta2_deg/10)]
%   eps <= eps_LIM ise duzeltme uygulanmaz (sigma_COR = sigma).
%
%   sigma:    duzeltilmemis kayma faktoru (Eq 4-7) [-]
%   eps:      r1_shroud/r2 (goz/shroud yaricapi -- cikis yaricapi orani) [-]
%   eps_lim:  slip_factor_limiting_radius_ratio_wiesner veya
%             _aungier'den gelen sinirlayici oran [-]
%   beta2:    [rad] -- ussteki 10 sabiti kaynakta DERECE cinsinden
%             verildigi icin fonksiyon ici rad2deg donusumu yapilir.

if eps <= eps_lim
    sigma_cor = sigma;
    return
end

beta2_deg = rad2deg(beta2);
sigma_cor = sigma * (1.0 - ((eps - eps_lim) / (1.0 - eps_lim))^sqrt(beta2_deg / 10.0));

end
