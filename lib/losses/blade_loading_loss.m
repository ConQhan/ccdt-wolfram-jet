function omega_bl = blade_loading_loss(delta_W_val, W1)
%BLADE_LOADING_LOSS losses/impeller_losses.py portu.
%   Eq. (5-34): omega_BL = (delta_W/W1)^2 / 24
%   (parametre 'delta_W_val' olarak adlandirildi -- compute_delta_w()
%   fonksiyon adiyla karismasin diye).
omega_bl = (delta_W_val / W1)^2 / 24.0;
end
