function lam = tip_distortion_factor_target(phi, K_lambda, impeller_type)
%TIP_DISTORTION_FACTOR_TARGET design/reference_correlations.py :: tip_distortion_factor_target() portu.
%   Eq. (6-5): lambda = K_lambda + (0.00175/phi)^2 + 0.0015/phi - 0.022*ln(phi)  [kapali]
%   Acik impellerler icin kitap: "lambda is increased by 2% over the
%   value predicted by Eq. (6-5) due to clearance effects" (s.114).

if nargin < 3 || isempty(impeller_type)
    impeller_type = 'covered';
end

lam = K_lambda + (0.00175 / phi)^2 + 0.0015 / phi - 0.022 * log(phi);
if strcmp(impeller_type, 'open')
    lam = lam * 1.02;
end

end
