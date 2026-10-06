function r = new_impeller_loss_result()
%NEW_IMPELLER_LOSS_RESULT losses/impeller_losses.py :: ImpellerLossResult dataclass portu.
%   Tum impeller kayip bilesenleri -- HER BIRI BOYUTSUZ omega katsayisidir
%   (giris relatif dinamik basincina gore normalize edilmis, Eq. 2-53).
r.shock_and_incidence = 0.0;
r.entrance_diffusion = 0.0;
r.choking = 0.0;
r.blade_loading = 0.0;
r.hub_shroud_loading = 0.0;
r.skin_friction = 0.0;
r.distortion = 0.0;
r.clearance = 0.0;
r.mixing = 0.0;
r.supercritical_shock = 0.0;
end
