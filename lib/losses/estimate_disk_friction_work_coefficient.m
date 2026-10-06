function I_DF = estimate_disk_friction_work_coefficient(rho2, omega_rad_s, r2, mu, s, U2, m_dot)
%ESTIMATE_DISK_FRICTION_WORK_COEFFICIENT losses/disk_friction.py portu.
%   Eq. (4-20)->(4-32) zincirini ACIK IMPELLER + SIZINTI YOK kabuluyle
%   tek seferde calistirir ve I_DF dondurur.
%   s: disk-housing eksenel boslugu [m]. mu: akiskan dinamik viskozitesi [Pa.s].
d2 = 2.0 * r2;
Re = disk_reynolds_number(rho2, omega_rad_s, r2, mu);
s_over_r = s / r2;
C_M0 = disk_torque_coefficient_smooth(s_over_r, Re);
K0 = seal_leakage_K0(s, d2);
C_M = corrected_torque_coefficient_no_seal_leakage(C_M0, K0);
C_MD = disk_side_torque_coefficient(C_M);
I_DF = disk_friction_work_coefficient(C_MD, rho2, U2, r2, m_dot, 0.0);
end
