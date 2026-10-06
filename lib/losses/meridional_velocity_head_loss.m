function omega_m = meridional_velocity_head_loss(Cm5, C5)
%MERIDIONAL_VELOCITY_HEAD_LOSS losses/volute_losses.py portu.
%   Eq. (5-105): omega_m = (Cm5/C5)^2
%   Meridyenel hiz bilesenin TAMAMEN kayboldugu (volut icinde swirl'e
%   donusup downstream'de dagildigi) kabulu.
omega_m = (Cm5 / C5)^2;
end
