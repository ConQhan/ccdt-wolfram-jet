function [Cm_hub, Cm_shroud] = entrance_velocity_curvature_correction(Cm1_mean, kappa_m1, b1)
%ENTRANCE_VELOCITY_CURVATURE_CORRECTION losses/impeller_losses.py portu.
%   Eq. (5-26): Hub ve shroud'daki meridyenel hizi, ortalama akistan
%   egrilik etkisiyle duzeltir.
%     Cm,h1 = Cm1 * [1 + kappa_m1*b1/2]   (hub)
%     Cm,s1 = Cm1 * [1 - kappa_m1*b1/2]   (shroud)
correction = kappa_m1 * b1 / 2.0;
Cm_hub = Cm1_mean * (1.0 + correction);
Cm_shroud = Cm1_mean * (1.0 - correction);
end
