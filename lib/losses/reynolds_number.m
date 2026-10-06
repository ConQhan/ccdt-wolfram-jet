function Re = reynolds_number(rho, velocity, length_scale, mu)
%REYNOLDS_NUMBER losses/skin_friction.py :: reynolds_number() portu.
%   Re = rho*V*L/mu (Eq 5-1'in genel tanimi, Re_d = rho*V*d/mu).
%   Tum bilesenlerin (impeller, vaned diffuser, return channel, volute)
%   DINAMIK skin friction katsayisi hesaplarken kullandigi tek,
%   paylasimli Reynolds sayisi tanimidir.
Re = rho * velocity * length_scale / mu;
end
