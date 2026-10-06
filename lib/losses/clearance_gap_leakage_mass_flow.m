function m_dot_CL = clearance_gap_leakage_mass_flow(rho2, z_eff, s_clearance, L_B, U_CL)
%CLEARANCE_GAP_LEAKAGE_MASS_FLOW losses/impeller_losses.py portu.
%   Eq. (4-19): m_dot_CL = rho2*z_eff*s*L_B*U_CL
m_dot_CL = rho2 * z_eff * s_clearance * L_B * U_CL;
end
