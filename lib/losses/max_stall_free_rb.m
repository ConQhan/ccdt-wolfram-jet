function rb_m = max_stall_free_rb(rb_1, m_minus_m1, b1)
%MAX_STALL_FREE_RB losses/diffuser_losses.py portu.
%   Eq. (5-54): (rb)_m = (rb)_1 * [1 + 0.16*m/b1]
%   Pasajin asiri (kararsiz) genislemeye girmeden tasiyabilecegi
%   maksimum (rb) zarfi -- 2*theta_c=9 derece difuzor diverjans
%   acisina esdeger.
rb_m = rb_1 * (1.0 + 0.16 * m_minus_m1 / b1);
end
