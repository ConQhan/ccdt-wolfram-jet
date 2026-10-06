function cf = impeller_compute_cf(imp, W1, W2, Wth, rho_ref, d_H)
%IMPELLER_COMPUTE_CF components/impeller.py :: Impeller._compute_cf() portu.
%   Skin friction katsayisi (Eq 5-33'te kullanilan 'cf'). loss_coeffs
%   icinde skin_friction.cf_reference verilmisse ACIK bir OVERRIDE olarak
%   kullanilir; aksi halde gercek Reynolds/puruzluluk bagimli
%   skin_friction_coefficient() (losses/skin_friction.py) kullanilir.

if isfield(imp.loss_coeffs, 'skin_friction') && isfield(imp.loss_coeffs.skin_friction, 'cf_reference') ...
        && ~isempty(imp.loss_coeffs.skin_friction.cf_reference)
    cf = imp.loss_coeffs.skin_friction.cf_reference;
    return
end

W_bar_sq = max(0.5 * (W1^2 + W2^2), 0.5 * (Wth^2 + W2^2));
W_bar = sqrt(W_bar_sq);
Re_d = reynolds_number(rho_ref, W_bar, d_H, imp.mu);
cf = skin_friction_coefficient(Re_d, imp.roughness, d_H);

end
