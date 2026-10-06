function omega_mix = vaned_diffuser_wake_mixing_loss(Cm_wake, Cm_mix, C3)
%VANED_DIFFUSER_WAKE_MIXING_LOSS losses/vaned_diffuser_losses.py :: wake_mixing_loss() portu.
%   Eq. (5-83): omega_mix = [(Cm,wake - Cm,mix)/C3]^2
%   (impeller'daki ayni isimli fonksiyonla cakismamasi icin 'vaned_diffuser_' onekli.)
omega_mix = ((Cm_wake - Cm_mix) / C3)^2;
end
