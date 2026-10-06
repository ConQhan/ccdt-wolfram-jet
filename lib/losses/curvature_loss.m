function I_C = curvature_loss(kappa_m, pt_minus_p, Cm, rho, C)
%CURVATURE_LOSS losses/diffuser_losses.py portu.
%   Eq. (5-56): I_C = kappa_m*(pt-p)*Cm / (13*rho*C)
%   Vanesiz difuzorler icin ihmal edilebilir (kappa_m~=0), ama
%   crossover bend'ler icin (kappa_m~=0) BASKIN olabilir.
I_C = kappa_m * pt_minus_p * Cm / (13.0 * rho * C);
end
