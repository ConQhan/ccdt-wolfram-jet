function angles = vaned_stage_flow_angles_deg(phi, b2)
%VANED_STAGE_FLOW_ANGLES_DEG design/component_matching.py :: vaned_stage_flow_angles_deg() portu.
%   Vanli difuzor kademeleri icin Eq. (6-12)/(6-13)/(6-14):
%     Eq (6-13): alpha2 = 18 + 0.5*ln(phi) + 585*phi^2          [derece]
%                alpha3 = 18 + (alpha2-18)/4   ; alpha2 <= 18
%                alpha3 = 18                   ; alpha2 > 18
%     Eq (6-14): b3 <= b2 (zorunlu kisit -- cagiran kod b3'u hesapladiktan
%                sonra bu kisiti uygulamali; burada sadece bayrak olarak
%                raporlaniyor cunku b3'u hesaplamak difuzor boyutlandirma
%                adimina ait)
%     Eq (6-12): tan(alpha6) = 0.32 + 1.7*phi   (vanesiz kademelerle AYNI)
%
%   b2 (opsiyonel) Python kaynaginda da SADECE bilgi/hatirlatici amacli --
%   fonksiyon govdesinde kullanilmiyor (requires_b3_le_b2 her zaman true).

if nargin < 2
    b2 = []; %#ok<NASGU>
end

alpha2_deg = 18.0 + 0.5 * log(phi) + 585.0 * phi^2;
if alpha2_deg <= 18.0
    alpha3_deg = 18.0 + (alpha2_deg - 18.0) / 4.0;
else
    alpha3_deg = 18.0;
end
alpha6_deg = rad2deg(atan(0.32 + 1.7 * phi));

angles.alpha2_deg = alpha2_deg;
angles.alpha3_deg = alpha3_deg;
angles.alpha6_deg = alpha6_deg;
angles.requires_b3_le_b2 = true;

end
