function delta_zI = impeller_axial_length_ratio(phi, d2, d0h)
%IMPELLER_AXIAL_LENGTH_RATIO design/reference_correlations.py :: impeller_axial_length_ratio() portu.
%   Eq. (6-3): Delta_zI/d2 = 0.014 + 0.023*d2/d0h + 1.58*phi
%   d2: impeller tip capi [m]. d0h: impeller eye (hub) capi [m].
%   Cikti: Delta_zI (impeller eksenel uzunlugu) [m].

ratio = 0.014 + 0.023 * d2 / d0h + 1.58 * phi;
delta_zI = ratio * d2;

end
