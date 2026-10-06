function cf = skin_friction_coefficient(Re_d, roughness_e, d)
%SKIN_FRICTION_COEFFICIENT losses/skin_friction.py :: skin_friction_coefficient() portu.
%   Eq. (5-1) -> (5-6): tam genellestirilmis surtunme katsayisi.
%   Re_d < 2000          -> laminer (Eq 5-1)
%   2000 <= Re_d <= 4000 -> gecis bolgesi (Eq 5-6)
%   Re_d > 4000           -> tam turbulansli (Eq 5-5)
%
%   d: referans cap [m] (genel pasajlarda hidrolik cap d_H, sinir
%      tabakasi akisinda 2*delta). roughness_e: peak-to-valley puruzluluk [m].

if Re_d <= 0
    error('centrifugal:skin_friction_coefficient', 'Re_d pozitif olmali');
end

if Re_d < 2000.0
    cf = laminar_cf(Re_d);
    return
end

if Re_d > 4000.0
    cf = turbulent_cf(Re_d, roughness_e, d);
    return
end

% Gecis bolgesi, Eq. (5-6)
cf_l = laminar_cf(Re_d);
cf_t = turbulent_cf(Re_d, roughness_e, d);
weight = Re_d / 2000.0 - 1.0;
cf = cf_l + (cf_t - cf_l) * weight;

end
