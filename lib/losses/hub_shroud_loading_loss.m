function omega_hs = hub_shroud_loading_loss(kappa_m_bar, b1, b2, W1, W2)
%HUB_SHROUD_LOADING_LOSS losses/impeller_losses.py portu.
%   Eq. (5-35): omega_HS = (kappa_m_bar * b_bar * W_bar / W1)^2 / 6
%     b_bar=(b1+b2)/2, W_bar=(W1+W2)/2
b_bar = (b1 + b2) / 2.0;
W_bar = (W1 + W2) / 2.0;
omega_hs = (kappa_m_bar * b_bar * W_bar / W1)^2 / 6.0;
end
