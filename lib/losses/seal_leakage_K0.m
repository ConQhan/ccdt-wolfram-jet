function K0 = seal_leakage_K0(s, d)
%SEAL_LEAKAGE_K0 losses/disk_friction.py portu.
%   Eq. (4-15): K0 = 0.46/(1+2*s/d)
%   s: eksenel bosluk [m], d: disk capi [m] (= 2*r2 genelde)
K0 = 0.46 / (1.0 + 2.0 * s / d);
end
