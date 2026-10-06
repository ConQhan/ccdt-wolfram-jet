function A_star = sonic_area(mdot_target, pt, Tt, gamma, R)
%SONIC_AREA core/continuity.py :: sonic_area() portu.
%   Verilen toplam kosullar (pt,Tt) ve hedef debi icin, akisi SONIK
%   (M=1) hizda tasiyacak kesit alanini (A*) hesaplar (Eq 5-32 choking
%   kaybi icin gerekli).
%
%   NOT: pt, Tt burada RELATIF toplam kosullar olmalidir (throat'ta
%   relatif akis sikistigi icin).

T_star = Tt * 2.0 / (gamma + 1.0);
p_star = pt * (2.0 / (gamma + 1.0))^(gamma / (gamma - 1.0));
rho_star = p_star / (R * T_star);
a_star = sqrt(gamma * R * T_star);
A_star = mdot_target / (rho_star * a_star);

end
