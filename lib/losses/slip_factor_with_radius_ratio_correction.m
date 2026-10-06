function [sigma_cor, was_corrected] = slip_factor_with_radius_ratio_correction(beta2, z_eff, ...
    r1_shroud_m, r2_m, alpha_C2)
%SLIP_FACTOR_WITH_RADIUS_RATIO_CORRECTION losses/impeller_losses.py :: [YENI -- Eq 4-7/4-9/4-10 orkestrasyonu].
%   slip_factor_wiesner.m'nin (Eq 4-7) DUZELTILMEMIS sonucunu, Aungier'in
%   daha isabetli sinirlayici oranina (Eq 4-9) gore kontrol edip, gerekirse
%   Eq (4-10) duzeltmesini uygular. Bu, kodun kendi docstring'inde ("Python
%   kaynaginda da HENUZ eklenmemis") acikca eksik olarak isaretlenmis bir
%   adimdi -- bkz. slip_factor_wiesner.m.
%
%   r1_shroud_m verilmezse ([] veya atlanirsa) eps=0 kabul edilir --
%   yani DUZELTME UYGULANMAZ (eski davranisla GERIYE-DONUK UYUMLU): eps=0
%   her zaman eps_LIM'in altinda kalir.
%
%   Girdiler:
%     beta2, z_eff, alpha_C2 : slip_factor_wiesner.m ile AYNI (beta2 [rad])
%     r1_shroud_m, r2_m      : eps = r1_shroud_m/r2_m hesaplamak icin [m];
%                               ikisi de bos birakilirsa duzeltme atlanir.
%
%   Cikti:
%     sigma_cor      : (gerekirse) duzeltilmis kayma faktoru [-]
%     was_corrected  : eps > eps_LIM oldugu icin Eq (4-10)'un devreye
%                      girip girmedigini bildiren bool -- diger
%                      model_validity_flagged mekanizmalariyla (orn.
%                      B2_clamped, I_R_clamped -- impeller_evaluate_station2.m)
%                      AYNI desende kullanilmak uzere.

if nargin < 5 || isempty(alpha_C2)
    alpha_C2 = pi / 2.0;
end
if nargin < 3 || isempty(r1_shroud_m) || nargin < 4 || isempty(r2_m)
    eps = 0.0;
else
    eps = r1_shroud_m / r2_m;
end

sigma = slip_factor_wiesner(beta2, z_eff, alpha_C2);
eps_lim = slip_factor_limiting_radius_ratio_aungier(sigma, beta2);

was_corrected = eps > eps_lim;
sigma_cor = slip_factor_corrected(sigma, eps, eps_lim, beta2);

end
