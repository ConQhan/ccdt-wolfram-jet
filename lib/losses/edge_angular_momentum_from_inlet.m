function rCu_e = edge_angular_momentum_from_inlet(rCu_avg_inlet, delta_inlet, b_inlet)
%EDGE_ANGULAR_MOMENTUM_FROM_INLET losses/diffuser_losses.py portu.
%   Eq. (5-60)'in giris istasyonunda TERSINE cozumu:
%     rCu_e = rCu_avg / [1 - 2*delta/(4.5*b)]
denom = 1.0 - 2.0 * delta_inlet / (4.5 * b_inlet);
if denom <= 0.0
    error('centrifugal:edge_angular_momentum_from_inlet', ...
        'Giris sinir tabakasi pasaji dolduruyor (2*delta>=b); gecersiz baslangic kosulu.');
end
rCu_e = rCu_avg_inlet / denom;
end
