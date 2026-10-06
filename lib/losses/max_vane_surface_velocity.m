function C_max = max_vane_surface_velocity(C6, C7, delta_C)
%MAX_VANE_SURFACE_VELOCITY losses/return_channel_losses.py portu.
%   Eq. (5-96): Cmax = 0.5*(C6+C7) + delta_C ; Cmax >= C6 kisiti uygulanir.
C_max = 0.5 * (C6 + C7) + delta_C;
C_max = max(C_max, C6);
end
