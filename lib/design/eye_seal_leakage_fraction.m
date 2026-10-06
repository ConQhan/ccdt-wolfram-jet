function frac = eye_seal_leakage_fraction(phi)
%EYE_SEAL_LEAKAGE_FRACTION design/reference_correlations.py :: eye_seal_leakage_fraction() portu.
%   Eq. (6-7): mdot_LEK/mdot = 0.005 + 0.475/(1+500*phi)
%   SADECE kapali (covered) impellerler icin anlamlidir (eye seal,
%   acik impellerde yok).

frac = 0.005 + 0.475 / (1.0 + 500.0 * phi);

end
