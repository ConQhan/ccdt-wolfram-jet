function Re_e = roughness_reynolds(Re_d, roughness_e, d)
%ROUGHNESS_REYNOLDS losses/skin_friction.py :: roughness_reynolds() portu.
%   Eq. (5-4): Re_e = (Re_d - 2000) * e/d  (puruzlulugun onem kazandigi esik: Re_e > 60)
Re_e = (Re_d - 2000.0) * roughness_e / d;
end
