function dW = compute_delta_w(U2, I_B, z_eff, L_B, r2)
%COMPUTE_DELTA_W losses/impeller_losses.py :: delta_W() portu.
%   Eq. (4-42): delta_W = 2*pi*d2*U2*I_B / (z_eff*L_B), d2 = 2*r2
%
%   NOT: Python'daki fonksiyon adi 'delta_W' idi; MATLAB'de bu isim,
%   cagiran kodda (components/impeller.py portunda) ayni isimli bir
%   DEGISKENLE (fonksiyonun donus degeri) golgelenme riski tasidigindan
%   (Python'da ayri isim uzaylari sayesinde sorun degil, MATLAB'de
%   degisken fonksiyonu golgeler) 'compute_delta_w' olarak adlandirildi.
d2 = 2.0 * r2;
dW = 2.0 * pi * d2 * U2 * I_B / (z_eff * L_B);
end
