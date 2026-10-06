function [Cm_wake, Cm_mix] = wake_mixing_velocities(C_sep, Cu4, Cm4, A4, r4, b4)
%WAKE_MIXING_VELOCITIES losses/vaned_diffuser_losses.py portu.
%   Eq. (5-82): Cm,wake = sqrt(C_sep^2 - Cu4^2) ; Cm,mix = A4*Cm4/(2*pi*r4*b4)
inside = C_sep^2 - Cu4^2;
Cm_wake = sqrt(max(inside, 0.0));
Cm_mix = A4 * Cm4 / (2.0 * pi * r4 * b4);
end
