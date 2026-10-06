function omega_dd = distortion_loss(lam, Cm2, W1)
%DISTORTION_LOSS losses/impeller_losses.py portu.
%   Eq. (5-36): omega_DD = [(lambda - 1)*Cm2/W1]^2
omega_dd = ((lam - 1.0) * Cm2 / W1)^2;
end
