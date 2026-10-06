function dID_dm = diffusion_loss_rate(pt_minus_p, E, rho, C, dC_dm)
%DIFFUSION_LOSS_RATE losses/diffuser_losses.py portu.
%   Eq. (5-53): dI_D/dm = -2*(pt-p)*(1-E) * (1/(rho*C)) * dC/dm
%   Momentum denklemine (Eq 5-46) dogrudan giren difuzyon kaybi
%   teriminin YEREL TUREVI; marching sirasinda adim boyunca integre edilir.
dID_dm = -2.0 * pt_minus_p * (1.0 - E) / (rho * C) * dC_dm;
end
