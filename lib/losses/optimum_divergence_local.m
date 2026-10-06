function Dm = optimum_divergence_local(b1, L, flow_angle)
%OPTIMUM_DIVERGENCE_LOCAL losses/diffuser_losses.py portu.
%   Eq. (5-51): Dm = 0.4*(b1/L)^0.35 * sin(alpha)
%   flow_angle: YEREL akis acisi [rad] (tangent'e gore, atan2(Cm,Cu)).
Dm = 0.4 * (b1 / L)^0.35 * sin(flow_angle);
end
