function alpha3s = solve_stall_inlet_flow_angle(r3, h_th, alpha_th, K0, target)
%SOLVE_STALL_INLET_FLOW_ANGLE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-66): K + K0 = 0.39 -- alpha3 icin KAPALI FORM cozum.
%     cos(alpha3s) = cos(alpha_th) * [1 + (target-K0)*h_th/r3]
if nargin < 5 || isempty(target)
    target = 0.39;
end
cos_alpha3s = cos(alpha_th) * (1.0 + (target - K0) * h_th / r3);
cos_alpha3s = min(max(cos_alpha3s, -1.0), 1.0);
alpha3s = acos(cos_alpha3s);
end
