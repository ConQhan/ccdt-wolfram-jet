function alpha_th = geometric_throat_flow_angle(A_th, A3)
%GEOMETRIC_THROAT_FLOW_ANGLE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-64) icindeki: sin(alpha_th) = A_th/A3 -- SAF GEOMETRIK oran.
ratio = A_th / A3;
ratio = min(max(ratio, -1.0), 1.0);
alpha_th = asin(ratio);
end
