function cf = turbulent_smooth_cf(Re_d)
%TURBULENT_SMOOTH_CF losses/skin_friction.py :: turbulent_smooth_cf() portu.
%   Eq. (5-2): 1/sqrt(4cf) = -2*log10(2.51/(Re_d*sqrt(4cf)))
%   Kapali (implicit) form -- cf icin fzero ile kok bulunur (Python
%   brentq(1e-7,0.5,xtol=1e-12) karsiligi).

    function r = residual(cf)
        root4cf = sqrt(4.0 * cf);
        r = 1.0 / root4cf + 2.0 * log10(2.51 / (Re_d * root4cf));
    end

opts = optimset('TolX', 1e-12);
cf = fzero(@residual, [1.0e-7, 0.5], opts);

end
