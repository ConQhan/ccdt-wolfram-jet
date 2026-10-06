function omega_U = tangential_velocity_head_loss(r5, Cu5, r6, C5, SP)
%TANGENTIAL_VELOCITY_HEAD_LOSS losses/volute_losses.py portu.
%   Eq. (5-107): tegetsel hiz basligi kaybi.
%     SP >= 1:  omega_U = 0.5*(r5*Cu5^2)/(r6*C5^2) * [1 - 1/SP^2]
%     SP <  1:  omega_U = (r5*Cu5^2)/(r6*C5^2) * [1 - 1/SP]^2
prefactor = (r5 * Cu5^2) / (r6 * C5^2);
if SP >= 1.0
    omega_U = 0.5 * prefactor * (1.0 - 1.0 / SP^2);
else
    omega_U = prefactor * (1.0 - 1.0 / SP)^2;
end
end
