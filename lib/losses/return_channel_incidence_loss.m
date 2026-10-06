function omega_inc = return_channel_incidence_loss(Cm6, C6, alpha_star)
%RETURN_CHANNEL_INCIDENCE_LOSS losses/return_channel_losses.py :: incidence_loss() portu.
%   Eq. (5-92): omega_inc = 0.8*[1 - Cm6/(C6*sin(alpha*))]^2
omega_inc = 0.8 * (1.0 - Cm6 / (C6 * sin(alpha_star)))^2;
end
