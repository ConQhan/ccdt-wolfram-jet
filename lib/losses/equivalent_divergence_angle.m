function two_theta_C = equivalent_divergence_angle(w3, w4, b3, b4, tb3, tb4, L_B)
%EQUIVALENT_DIVERGENCE_ANGLE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-74): 2*theta_C = 2*atan{ [(w4-tb4)*b4/b3 - w3+tb3] / (2*LB) }
arg = ((w4 - tb4) * b4 / b3 - w3 + tb3) / (2.0 * L_B);
two_theta_C = 2.0 * atan(arg);
end
