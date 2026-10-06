function C3_star = optimum_incidence_velocity(Cm3, beta3, alpha_th)
%OPTIMUM_INCIDENCE_VELOCITY losses/vaned_diffuser_losses.py portu.
%   Eq. (5-70): sin(alpha3*) = Cm3/C3* = sqrt(sin(beta3)*sin(alpha_th))
%   => C3* = Cm3 / sqrt(sin(beta3)*sin(alpha_th))
s = sin(beta3) * sin(alpha_th);
if s <= 0.0
    error('centrifugal:optimum_incidence_velocity', ...
        'optimum_incidence_velocity: sin(beta3)*sin(alpha_th) <= 0');
end
sin_alpha3_star = sqrt(s);
C3_star = Cm3 / sin_alpha3_star;
end
