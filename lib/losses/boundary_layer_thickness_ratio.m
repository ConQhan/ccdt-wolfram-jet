function ratio = boundary_layer_thickness_ratio(cf, L_B, d_H)
%BOUNDARY_LAYER_THICKNESS_RATIO losses/vaned_diffuser_losses.py portu.
%   Eq. (5-68): 2*delta/dH = 5.142*cf*LB/dH
%   Eq. (5-69): 2*delta/dH <= 1 kisiti uygulanir.
ratio = 5.142 * cf * L_B / d_H;
ratio = min(ratio, 1.0);
end
