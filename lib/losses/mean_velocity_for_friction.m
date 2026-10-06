function C_bar = mean_velocity_for_friction(C6, C7, C_th)
%MEAN_VELOCITY_FOR_FRICTION losses/return_channel_losses.py portu.
%   Eq. (5-93) icindeki Cbar tanimi (kitapta ACIKCA verilmis, analoji DEGIL):
%     Cbar = 0.5*(C7 + max(C6, Cth))
C_bar = 0.5 * (C7 + max(C6, C_th));
end
