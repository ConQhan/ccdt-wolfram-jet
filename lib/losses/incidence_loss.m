function omega_inc = incidence_loss(Cm1, W1, beta1, z_eff, tb1, r1)
%INCIDENCE_LOSS losses/impeller_losses.py portu.
%   Eq. (5-27): omega_inc = 0.8*[1 - Cm1/(W1*sin(beta1))]^2
%                          + [z*tb1/(2*pi*r1*sin(beta1))]^2
%   TEK bir akis yuzeyi (hub, mean veya shroud) icin hesap yapar --
%   uc yuzeydeki sonuclarin agirlikli ortalamasi alinmalidir (bkz.
%   weighted_incidence_and_shock_loss).
term1 = 0.8 * (1.0 - Cm1 / (W1 * sin(beta1)))^2;
term2 = (z_eff * tb1 / (2.0 * pi * r1 * sin(beta1)))^2;
omega_inc = term1 + term2;
end
