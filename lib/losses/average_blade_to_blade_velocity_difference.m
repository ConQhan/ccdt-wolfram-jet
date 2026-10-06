function delta_C = average_blade_to_blade_velocity_difference(r3, Cu3, r4, Cu4, n_vanes, L_B)
%AVERAGE_BLADE_TO_BLADE_VELOCITY_DIFFERENCE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-76): delta_C = 2*pi*(r3*Cu3 - r4*Cu4)/(z*LB)
delta_C = 2.0 * pi * (r3 * Cu3 - r4 * Cu4) / (n_vanes * L_B);
end
