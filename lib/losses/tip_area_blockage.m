function B2 = tip_area_blockage(omega_sf, pv1, pv2, W1, d_H, W2, b2, L_B, AR, rho1, rho2, delta_CL)
%TIP_AREA_BLOCKAGE losses/impeller_losses.py portu.
%   Eq. (4-12): impeller tip alan blokaji B2.
%     B2 = omega_sf*(pv1/pv2)*sqrt(W1*dH/(W2*b2))*[0.3+(b2/LB)^2]
%          * (AR^2*rho2*b2)/(rho1*LB) + delta_CL/(2*b2)
term1 = omega_sf * (pv1 / pv2) * sqrt(W1 * d_H / (W2 * b2)) * (0.3 + (b2 / L_B)^2);
term2 = (AR^2 * rho2 * b2) / (rho1 * L_B);
term3 = delta_CL / (2.0 * b2);
B2 = term1 * term2 + term3;
end
