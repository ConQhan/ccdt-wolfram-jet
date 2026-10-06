function omega_sf = vaned_diffuser_skin_friction_loss(cf, C3, C4, C_th, L_B, d_H)
%VANED_DIFFUSER_SKIN_FRICTION_LOSS losses/vaned_diffuser_losses.py :: skin_friction_loss() portu.
%   Eq. (5-67): omega_SF = 4*cf*(Cbar/C3)^2 * LB/dH / (2*delta/dH)^0.25
%
%   NOT: Python'da bu fonksiyonun adi 'skin_friction_loss' idi (impeller
%   modulundeki ayni isimli fonksiyondan AYRI, Python'da modul
%   namespace'i ile ayristiriliyordu). MATLAB'de duz fonksiyon isim
%   uzayi (addpath) ayni isimde iki dosyaya izin vermedigi icin
%   'vaned_diffuser_' onekiyle yeniden adlandirildi.
c_bar_sq = mean_square_velocity_with_throat_floor(C3, C4, C_th);
two_delta_over_dH = boundary_layer_thickness_ratio(cf, L_B, d_H);
base = 4.0 * cf * (c_bar_sq / C3^2) * (L_B / d_H);
correction = two_delta_over_dH^0.25;
if correction <= 0.0
    omega_sf = base;
    return
end
omega_sf = base / correction;
end
