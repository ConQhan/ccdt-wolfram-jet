function eps_lim = slip_factor_limiting_radius_ratio_aungier(sigma, beta2)
%SLIP_FACTOR_LIMITING_RADIUS_RATIO_AUNGIER losses/impeller_losses.py :: [YENI -- Aungier_Formulleri_ve_Sinirlari.md SS5.5 / Eq 4-9 portu].
%   Eq. (4-9): sigma* = sin(19 deg + 0.2*beta2_deg)
%              eps_LIM = (sigma - sigma*) / (1 - sigma*)
%   Aungier'in (1993b/1995) Busemann sonuclarina dayanan, Wiesner'in Eq
%   (4-8) sinirindan DAHA ISABETLI limiting radius ratio tahmini --
%   dokumanda "Aungier'in daha dogru sinirlayici oran" olarak nitelenir.
%
%   sigma: bu beta2'de Eq (4-7) (slip_factor_wiesner.m) ile hesaplanmis
%          duzeltilmemis kayma faktoru [-]
%   beta2: [rad] -- 19 derece ve 0.2 katsayisi kaynakta DERECE cinsinden
%          verildigi icin fonksiyon ici rad2deg donusumu yapilir.

beta2_deg = rad2deg(beta2);
sigma_star = sin(deg2rad(19.0 + 0.2 * beta2_deg));
eps_lim = (sigma - sigma_star) / (1.0 - sigma_star);

end
