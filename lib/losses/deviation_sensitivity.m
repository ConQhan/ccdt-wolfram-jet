function d_delta_di = deviation_sensitivity(beta3_deg, sigma)
%DEVIATION_SENSITIVITY losses/vaned_diffuser_losses.py portu.
%   Eq. (5-87): d(delta)/di = exp[((1.5-beta3/60)^2 - 3.3)*sigma]  (DERECE)
d_delta_di = exp(((1.5 - beta3_deg / 60.0)^2 - 3.3) * sigma);
end
