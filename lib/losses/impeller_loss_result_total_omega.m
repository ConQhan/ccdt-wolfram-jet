function total = impeller_loss_result_total_omega(r)
%IMPELLER_LOSS_RESULT_TOTAL_OMEGA losses/impeller_losses.py :: ImpellerLossResult.total_omega portu.
%   Sum(omega) -- Eq. (5-24)'te kullanilacak toplam boyutsuz kayip katsayisi.
total = r.shock_and_incidence + r.entrance_diffusion + r.choking ...
    + r.blade_loading + r.hub_shroud_loading + r.skin_friction ...
    + r.distortion + r.clearance + r.mixing + r.supercritical_shock;
end
