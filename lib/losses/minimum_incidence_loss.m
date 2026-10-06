function omega_i0 = minimum_incidence_loss(C3, C3_star, C_th, n_vanes, blade_thickness_le, r3)
%MINIMUM_INCIDENCE_LOSS losses/vaned_diffuser_losses.py portu.
%   Eq. (5-71): omega_i0 = 0.8*[(C3*-Cth)/C3]^2 + [z*tb3/(2*pi*r3)]^2
velocity_term = 0.8 * ((C3_star - C_th) / C3)^2;
blockage_term = (n_vanes * blade_thickness_le / (2.0 * pi * r3))^2;
omega_i0 = velocity_term + blockage_term;
end
