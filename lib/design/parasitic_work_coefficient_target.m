function I_par = parasitic_work_coefficient_target(phi, impeller_type)
%PARASITIC_WORK_COEFFICIENT_TARGET design/reference_correlations.py :: parasitic_work_coefficient_target() portu.
%   Eq. (6-6) [kapali]: I_par = 0.0014/phi
%   Eq. (6-8) [acik]:   I_par = 0.002/phi

if nargin < 2 || isempty(impeller_type)
    impeller_type = 'covered';
end

if strcmp(impeller_type, 'covered')
    I_par = 0.0014 / phi;
elseif strcmp(impeller_type, 'open')
    I_par = 0.002 / phi;
else
    error('centrifugal:parasitic_work_coefficient_target', "impeller_type 'covered' veya 'open' olmali");
end

end
