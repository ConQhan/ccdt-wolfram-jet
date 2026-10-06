function omega_mix = wake_mixing_loss(Deq, W2, Wu2, Cm2, A2, r2, b2, W1)
%WAKE_MIXING_LOSS losses/impeller_losses.py portu.
%   Eq. (5-37)/(5-38)/(5-39):
%     Wsep   = W2          ; Deq <= 2
%     Wsep   = W2*Deq/2    ; Deq > 2
%     Cm,wake = sqrt(Wsep^2 - Wu2^2)
%     Cm,mix  = Cm2*A2 / (pi*d2*b2)
%     omega_mix = [(Cm,wake - Cm,mix)/W1]^2
%
%   [DUZELTME -- kaynaktan aynen tasindi] Wsep=W2 (Deq<=2 icin SABIT,
%   Deq'ye bagli degil, W2/Deq DEGIL).

if Deq <= 2.0
    W_sep = W2;
else
    W_sep = W2 * Deq / 2.0;
end

if W_sep <= abs(Wu2)
    Cm_wake = 0.0;
else
    Cm_wake = sqrt(W_sep^2 - Wu2^2);
end

d2 = 2.0 * r2;
Cm_mix = Cm2 * A2 / (pi * d2 * b2);
omega_mix = ((Cm_wake - Cm_mix) / W1)^2;

end
