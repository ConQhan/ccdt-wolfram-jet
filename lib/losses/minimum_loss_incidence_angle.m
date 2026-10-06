function alpha_star = minimum_loss_incidence_angle(B6, alpha_th)
%MINIMUM_LOSS_INCIDENCE_ANGLE losses/return_channel_losses.py portu.
%   Eq. (5-91): tan(alpha*) = (1-B6)*tan(alpha_th)  [alpha_th = arcsin(Ath/A6)]
alpha_star = atan((1.0 - B6) * tan(alpha_th));
end
