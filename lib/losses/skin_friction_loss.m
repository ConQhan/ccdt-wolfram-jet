function omega_sf = skin_friction_loss(cf, W1, W2, Wth, L_B, d_H)
%SKIN_FRICTION_LOSS losses/impeller_losses.py portu.
%   Eq. (5-33): omega_SF = 4*cf*(W_bar/W1)^2 * LB/dH
%     W_bar^2 = (W1^2+W2^2)/2, ancak W_bar^2 >= (Wth^2+W2^2)/2 olmali
W_bar_sq = 0.5 * (W1^2 + W2^2);
W_bar_sq_min = 0.5 * (Wth^2 + W2^2);
W_bar_sq = max(W_bar_sq, W_bar_sq_min);
omega_sf = 4.0 * cf * (W_bar_sq / W1^2) * (L_B / d_H);
end
