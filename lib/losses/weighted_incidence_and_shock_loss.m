function omega_weighted = weighted_incidence_and_shock_loss(omega_hub, omega_mean, omega_shroud)
%WEIGHTED_INCIDENCE_AND_SHOCK_LOSS losses/impeller_losses.py portu.
%   Kitap: "the mean values are weighted 10 times as heavy as the hub
%   and shroud values."
%     omega_weighted = (omega_hub + 10*omega_mean + omega_shroud) / 12
omega_weighted = (omega_hub + 10.0 * omega_mean + omega_shroud) / 12.0;
end
