function omega = entrance_diffusion_loss_with_stall_limit(W1s, Wth, W1, omega_inc)
%ENTRANCE_DIFFUSION_LOSS_WITH_STALL_LIMIT losses/impeller_losses.py portu.
%   Eq. (5-30): Inducer stall ongoruluyorsa difuzyon kaybi su limitle
%   sinirlanir: omega_DIF >= [(W1s - 1.75*Wth)/W1]^2 - omega_inc
base = entrance_diffusion_loss(Wth, W1);
if ~inducer_stall_predicted(W1s, Wth)
    omega = base;
    return
end
floor_val = (W1s - 1.75 * Wth)^2 / W1^2 - omega_inc;
omega = max(base, floor_val);
end
