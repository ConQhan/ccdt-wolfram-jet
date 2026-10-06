function omega_sf = volute_skin_friction_loss(cf, C6, C5, r5, r6, A6)
%VOLUTE_SKIN_FRICTION_LOSS losses/volute_losses.py :: skin_friction_loss() portu.
%   Eq. (5-109): omega_SF = 4*cf*(C6/C5)^2 * L/dH
L = volute_path_length(r5, r6);
d_H = volute_hydraulic_diameter(A6);
omega_sf = 4.0 * cf * (C6 / C5)^2 * (L / d_H);
end
