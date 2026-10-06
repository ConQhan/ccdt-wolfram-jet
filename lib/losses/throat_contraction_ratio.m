function Cr = throat_contraction_ratio(A1, beta1, A_th)
%THROAT_CONTRACTION_RATIO losses/impeller_losses.py portu.
%   Eq. (5-31): Cr = sqrt(A1*sin(beta1)/Ath), Cr <= 1-(A1*sin(beta1)/Ath-1)^2
ratio = A1 * sin(beta1) / A_th;
Cr_val = sqrt(ratio);
Cr_limit = 1.0 - (ratio - 1.0)^2;
Cr = min(Cr_val, Cr_limit);
end
