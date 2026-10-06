function omega_bl = return_channel_blade_loading_loss(delta_C, C6)
%RETURN_CHANNEL_BLADE_LOADING_LOSS losses/return_channel_losses.py :: blade_loading_loss() portu.
%   Eq. (5-95): omega_BL = (delta_C/C6)^2 / 6
omega_bl = (delta_C / C6)^2 / 6.0;
end
