function B4 = discharge_area_blockage(Cm3, beta4, Cm4, beta3, two_theta_C_deg, L, L_B, w4)
%DISCHARGE_AREA_BLOCKAGE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-79)/(5-80): B4 = [K1 + K2*(CbarR^2-1)] * LB/w4
%     CbarR = 0.5*[Cm3*sin(beta4)/(Cm4*sin(beta3)) + 1]
%     K1 = 0.2*[1 - 1/(C_L*C_theta)]
%     K2 = (2*theta_C)/(125*C_theta) * [1 - (2*theta_C)/(22*C_theta)]
%   NOT: K1/K2 formullerinde 2*theta_C DERECE biriminde kullanilir.
[C_theta, C_L] = correction_coefficients(two_theta_C_deg, L);
C_R_bar = 0.5 * (Cm3 * sin(beta4) / (Cm4 * sin(beta3)) + 1.0);
K1 = 0.2 * (1.0 - 1.0 / (C_L * C_theta));
K2 = (two_theta_C_deg / (125.0 * C_theta)) * (1.0 - two_theta_C_deg / (22.0 * C_theta));
B4 = (K1 + K2 * (C_R_bar^2 - 1.0)) * L_B / w4;
end
