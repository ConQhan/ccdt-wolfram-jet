function omega_ch = choking_loss(Cr, A_th, A_star)
%CHOKING_LOSS losses/impeller_losses.py portu.
%   Eq. (5-32): tikanma kaybi.
%     X = 11 - 10*Cr*Ath/A*
%     omega_CH = 0                  ; X <= 0
%     omega_CH = 0.5*(0.05*X + X^7) ; X > 0
X = 11.0 - 10.0 * Cr * A_th / A_star;
if X <= 0.0
    omega_ch = 0.0;
    return
end
omega_ch = 0.5 * (0.05 * X + X^7);
end
