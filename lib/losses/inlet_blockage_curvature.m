function B6 = inlet_blockage_curvature(kappa_m, b6)
%INLET_BLOCKAGE_CURVATURE losses/return_channel_losses.py portu.
%   Eq. (5-90): B6 = (kappa_m*b6)^2 / (12 + (kappa_m*b6)^2) (inviscid egrilik tahmini)
x = (kappa_m * b6)^2;
B6 = x / (12.0 + x);
end
