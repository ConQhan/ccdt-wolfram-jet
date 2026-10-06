function targets = reference_design_targets(phi, impeller_type)
%REFERENCE_DESIGN_TARGETS design/reference_correlations.py :: reference_design_targets() portu.
%   Eq. (6-1) [kapali/covered impeller] veya Eq. (6-2) [acik/open impeller].
%   phi: stage akis katsayisi, gecerlilik araligi 0.003 -> 0.2.
%   Cikti struct alanlari: phi, impeller_type, I, mu_p_vd, eta_p_vd,
%   mu_p_vld, eta_p_vld (Python ReferenceDesignTargets dataclass ile birebir).

if nargin < 2 || isempty(impeller_type)
    impeller_type = 'covered';
end
if ~(strcmp(impeller_type, 'covered') || strcmp(impeller_type, 'open'))
    error('centrifugal:reference_design_targets', "impeller_type 'covered' veya 'open' olmali");
end

if strcmp(impeller_type, 'covered')
    I = 0.62 - (phi / 0.4)^3 + 0.0014 / phi;
    mu_p_vd = 0.51 + phi - 7.6 * phi^2 - 0.00025 / phi;
else
    I = 0.68 - (phi / 0.37)^3 + 0.002 / phi;
    mu_p_vd = 0.59 + 0.7 * phi - 7.5 * phi^2 - 0.00025 / phi;
end

if I ~= 0.0
    eta_p_vd = mu_p_vd / I;
else
    eta_p_vd = NaN;
end

eta_p_vld = eta_p_vd - 0.017 / (0.04 + 5.0 * phi + eta_p_vd^3);
mu_p_vld = I * eta_p_vld;

targets.phi = phi;
targets.impeller_type = impeller_type;
targets.I = I;
targets.mu_p_vd = mu_p_vd;
targets.eta_p_vd = eta_p_vd;
targets.mu_p_vld = mu_p_vld;
targets.eta_p_vld = eta_p_vld;

end
