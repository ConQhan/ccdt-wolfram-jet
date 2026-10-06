function [Cm_wake, Cm_mix] = return_channel_wake_mixing_velocities(C_sep, Cu7, Cm7, A7, r7_shroud, r7_hub, b7)
%RETURN_CHANNEL_WAKE_MIXING_VELOCITIES losses/return_channel_losses.py :: wake_mixing_velocities() portu.
%   Eq. (5-97): Cm,wake = sqrt(C_sep^2 - Cu7^2)
%               Cm,mix  = Cm7*A7 / [pi*(r7s+r7h)*b7]
%   NOT: paydadaki (r7s+r7h), return channel cikisinin hub/shroud
%   yaricaplarinin AYRI AYRI verilmesinden kaynaklanir.
inside = C_sep^2 - Cu7^2;
Cm_wake = sqrt(max(inside, 0.0));
Cm_mix = Cm7 * A7 / (pi * (r7_shroud + r7_hub) * b7);
end
