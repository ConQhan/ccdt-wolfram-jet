function I_D_alt = diffusion_loss_alternate(pt_minus_p, rb_max_stall_free, rb_local, rho)
%DIFFUSION_LOSS_ALTERNATE losses/diffuser_losses.py portu.
%   Eq. (5-55): I_D_alt = 0.65*(pt-p)*[1-(rb)_m/(rb)] / rho
%   Yerel alan, kararli difuzyon zarfini (Eq 5-54) astiginda devreye
%   giren IKINCI (alan-bazli) difuzyon kaybi tahmini. Cagiran kod,
%   integre edilmis I_D ile bunu karsilastirip buyuk olani secmeli.
%   rb_local <= rb_max_stall_free ise 0.0 dondurulur (kisit henuz asilmamis).
if rb_local <= rb_max_stall_free
    I_D_alt = 0.0;
    return
end
I_D_alt = 0.65 * pt_minus_p * (1.0 - rb_max_stall_free / rb_local) / rho;
end
