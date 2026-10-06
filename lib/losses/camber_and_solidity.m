function [a_over_c, sigma, theta] = camber_and_solidity(beta3, beta4, beta_mid, r3, r4, n_vanes)
%CAMBER_AND_SOLIDITY losses/vaned_diffuser_losses.py portu.
%   Eq. (5-86): a/c = [2-(beta_mid-beta3)/(beta4-beta3)]/3
%               sigma = z*(r4-r3)/(2*pi*r3*sin(beta_mid))
%               theta = beta4-beta3
%   Tum acilar RADYAN; theta burada RADYAN dondurulur (derece cevrimi
%   deviation_angle_minimum_loss()'ta yapilir).
a_over_c = (2.0 - (beta_mid - beta3) / (beta4 - beta3)) / 3.0;
sigma = n_vanes * (r4 - r3) / (2.0 * pi * r3 * sin(beta_mid));
theta = beta4 - beta3;
end
