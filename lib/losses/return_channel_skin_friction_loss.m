function omega_sf = return_channel_skin_friction_loss(cf, C_bar, C6, L_B, d_H, Cm6, Cm7, alpha_C6, alpha_C7)
%RETURN_CHANNEL_SKIN_FRICTION_LOSS losses/return_channel_losses.py :: skin_friction_loss() portu.
%   Eq. (5-93): omega_SF = 4*cf*(Cbar/C6)^2*LB/dH + Cm6*Cm7*|alpha_C6-alpha_C7|/(13*C6^2)
%   Ikinci terim, crossover bend egriliginden kaynaklanan EK bir kayip
%   katkisidir (Eq 5-56'nin turetilmis bir bicimi); alpha_C6, alpha_C7
%   burada GEOMETRIK meridyenel hat egim acilaridir (akis acisi DEGIL).
friction_term = 4.0 * cf * (C_bar / C6)^2 * (L_B / d_H);
curvature_term = Cm6 * Cm7 * abs(alpha_C6 - alpha_C7) / (13.0 * C6^2);
omega_sf = friction_term + curvature_term;
end
