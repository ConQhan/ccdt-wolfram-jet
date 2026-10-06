function Cm1 = inlet_meridional_velocity(U1, alpha1_prime_deg)
%INLET_MERIDIONAL_VELOCITY design/impeller_sizing.py :: inlet_meridional_velocity() portu.
%   Eq. (6-21): Cm1 = U1*tan(alpha'_1)
%   alpha1_prime_deg: impeller giris RELATIF akis acisi [derece],
%   varsayilan 30 derece -- kitabin "reasonable first estimate... which
%   (approximately) minimizes W1" onerisi (s.115).

if nargin < 2 || isempty(alpha1_prime_deg)
    alpha1_prime_deg = 30.0;
end

Cm1 = U1 * tan(deg2rad(alpha1_prime_deg));

end
