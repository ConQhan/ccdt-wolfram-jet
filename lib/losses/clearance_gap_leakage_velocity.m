function U_CL = clearance_gap_leakage_velocity(delta_p_CL, rho2)
%CLEARANCE_GAP_LEAKAGE_VELOCITY losses/impeller_losses.py portu.
%   Eq. (4-17): U_CL = 0.816*sqrt(2*delta_p_CL/rho2)
U_CL = 0.816 * sqrt(2.0 * delta_p_CL / rho2);
end
