function C_sep = wake_separation_velocity(C3, C_theta, C4)
%WAKE_SEPARATION_VELOCITY losses/vaned_diffuser_losses.py portu.
%   Eq. (5-81): C_SEP = C3/(1+2*C_theta) ; C_SEP >= C4 kisiti uygulanir.
%   NOT: buradaki C_theta, correction_coefficients()'ten gelen DUZELTME
%   katsayisidir (theta_C acisi degil).
C_sep = C3 / (1.0 + 2.0 * C_theta);
C_sep = max(C_sep, C4);
end
