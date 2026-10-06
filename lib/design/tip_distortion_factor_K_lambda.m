function K_lambda = tip_distortion_factor_K_lambda(b2, L_B, A2, A1, beta2, beta1)
%TIP_DISTORTION_FACTOR_K_LAMBDA design/reference_correlations.py :: tip_distortion_factor_K_lambda() portu.
%   Eq. (6-4): K_lambda = 1 + [0.3+(b2/LB)^2] * [b2*A2^2*sin^2(beta2)] / [LB*A1^2*sin^2(beta1)]
%   Tum acilar RADYAN. A1/beta1 burada impeller GIRIS/throat alanini,
%   beta1 throat blade acisini temsil eder (vaned diffuser'daki
%   "A1/beta1" sembolleriyle KARISTIRILMAMALI, burada impeller'a ozguduir).

bracket = 0.3 + (b2 / L_B)^2;
ratio = (b2 * A2^2 * sin(beta2)^2) / (L_B * A1^2 * sin(beta1)^2);
K_lambda = 1.0 + bracket * ratio;

end
