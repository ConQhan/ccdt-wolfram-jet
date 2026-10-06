function omega_dif = entrance_diffusion_loss(Wth, W1)
%ENTRANCE_DIFFUSION_LOSS losses/impeller_losses.py portu.
%   Eq. (5-28): omega_DIF = 0.8*[1 - Wth/W1]^2  (omega_DIF >= 0 olmali)
omega_dif = 0.8 * (1.0 - Wth / W1)^2;
omega_dif = max(omega_dif, 0.0);
end
