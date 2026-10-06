function delta_star = deviation_angle_minimum_loss(a_over_c, sigma, theta_deg, beta4_deg)
%DEVIATION_ANGLE_MINIMUM_LOSS losses/vaned_diffuser_losses.py portu.
%   Eq. (5-85): delta* = theta*[0.92*(a/c)^2 + 0.02*(90-beta4)] / [sqrt(sigma)-0.02*theta]
%   Tum acilar DERECE (Howell 1947 korelasyonu).
numerator = theta_deg * (0.92 * a_over_c^2 + 0.02 * (90.0 - beta4_deg));
denominator = sqrt(sigma) - 0.02 * theta_deg;
delta_star = numerator / denominator;
end
