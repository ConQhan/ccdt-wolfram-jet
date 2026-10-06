function beta2_deg = solve_tip_blade_angle_deg(I_B_target, lam, phi2, z_eff, alpha_C2, ...
    beta2_bracket_deg, r1_shroud_m, r2_m)
%SOLVE_TIP_BLADE_ANGLE_DEG design/impeller_sizing.py :: solve_tip_blade_angle_deg() portu.
%   Eq. (6-19)/(6-20)'nin TERSI: verilen I_B hedefi, tip distortion
%   faktoru (lam), tip flow coefficient (phi2=Cm2/U2) ve etkin kanat
%   sayisindan (z_eff) tip blade acisini (beta2) cozer.
%
%       sigma(beta2) = 1 - sqrt(sin(beta2))*sin(alpha_C2)/z_eff^0.7    (Eq 6-19)
%       I_B(beta2)   = sigma(beta2) * (1 - lam*phi2*cot(beta2))        (Eq 6-20)
%
%   fzero, I_B(beta2) - I_B_target = 0 denklemini beta2_bracket_deg
%   araliginda (varsayilan [5,80] derece) cozer.
%
%   r1_shroud_m, r2_m verilirse [YENI], sigma her iterasyonda Eq (4-9)/(4-10)
%   sinirlayici yaricap orani duzeltmesiyle hesaplanir (bkz.
%   slip_factor_with_radius_ratio_correction.m) -- verilmezse (varsayilan)
%   ESKI DAVRANISLA (duzeltmesiz Eq 6-19/4-7) birebir AYNI sonucu verir.
%
%   Cikti: beta2 [derece] (tangent'e gore, kitabin blade angle
%   nomenclature'iyla uyumlu).

if nargin < 5 || isempty(alpha_C2)
    alpha_C2 = pi / 2.0;
end
if nargin < 6 || isempty(beta2_bracket_deg)
    beta2_bracket_deg = [5.0, 80.0];
end
if nargin < 7; r1_shroud_m = []; end
if nargin < 8; r2_m = []; end

lo_rad = deg2rad(beta2_bracket_deg(1));
hi_rad = deg2rad(beta2_bracket_deg(2));

    function r = residual(beta2_rad)
        sigma = slip_factor_with_radius_ratio_correction(beta2_rad, z_eff, r1_shroud_m, r2_m, alpha_C2);
        I_B = blade_work_input_coefficient(sigma, lam, phi2, beta2_rad);
        r = I_B - I_B_target;
    end

f_lo = residual(lo_rad);
f_hi = residual(hi_rad);
if f_lo * f_hi > 0.0
    error('centrifugal:solve_tip_blade_angle_deg', ...
        ['solve_tip_blade_angle_deg: [%g deg, %g deg] araliginda I_B_target=%.4f''e ulasan ' ...
         'bir beta2 bulunamadi (I_B(%g deg)=%.4f, I_B(%g deg)=%.4f). Hedef is katsayisi bu ' ...
         'phi2/lam/z_eff kombinasyonuyla ulasilamiyor olabilir.'], ...
        beta2_bracket_deg(1), beta2_bracket_deg(2), I_B_target, ...
        beta2_bracket_deg(1), f_lo + I_B_target, beta2_bracket_deg(2), f_hi + I_B_target);
end

beta2_rad = fzero(@residual, [lo_rad, hi_rad], optimset('TolX', 1e-8));
beta2_deg = rad2deg(beta2_rad);

end
