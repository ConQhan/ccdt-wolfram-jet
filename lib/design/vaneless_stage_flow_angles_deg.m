function angles = vaneless_stage_flow_angles_deg(phi)
%VANELESS_STAGE_FLOW_ANGLES_DEG design/component_matching.py :: vaneless_stage_flow_angles_deg() portu.
%   Vanesiz difuzor kademeleri icin Eq. (6-10)/(6-11)/(6-12):
%     Eq (6-10): tan(alpha2) = 0.26 + 3*phi   (impeller tip mutlak akis acisi)
%     Eq (6-11): alpha4 = 30 + (phi/0.06)^2    (difuzor cikis akis acisi) [derece]
%     Eq (6-12): tan(alpha6) = 0.32 + 1.7*phi  (return channel giris akis acisi)
%   Cikti struct alanlari: alpha2_deg, alpha4_deg, alpha6_deg.

angles.alpha2_deg = rad2deg(atan(0.26 + 3.0 * phi));
angles.alpha4_deg = 30.0 + (phi / 0.06)^2;
angles.alpha6_deg = rad2deg(atan(0.32 + 1.7 * phi));

end
