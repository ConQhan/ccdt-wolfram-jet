function [a_over_c, sigma, theta] = return_channel_camber_and_solidity(beta6, beta7, beta_mid, r6, r7, n_vanes)
%RETURN_CHANNEL_CAMBER_AND_SOLIDITY losses/return_channel_losses.py :: camber_and_solidity() portu.
%   Eq. (5-100)/(5-101)/(5-102):
%     a/c   = 2/3 - (beta_mid-beta6)/(3*(beta7-beta6))
%     sigma = z*(r6-r7)/(2*pi*r7*sin(beta_mid))
%     theta = beta7 - beta6
%
%   NOT (Python docstring'inden): return channel akisi ICE dogrudur
%   (r7<r6), vaned diffuser akisi DISA dogrudur (r4>r3) -- bu yuzden
%   vaned_diffuser_losses'daki camber_and_solidity() ile AYNI DEGIL,
%   ayri tanimlandi (ve MATLAB'de isim carpismasini onlemek icin
%   'return_channel_' onekli).
a_over_c = 2.0 / 3.0 - (beta_mid - beta6) / (3.0 * (beta7 - beta6));
sigma = n_vanes * (r6 - r7) / (2.0 * pi * r7 * sin(beta_mid));
theta = beta7 - beta6;
end
