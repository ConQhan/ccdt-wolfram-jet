function result = vaned_diffuser_discharge_sizing(r3, r4_max, beta3_deg, Cu3, C3, C4_estimate, z_vanes, L_B, cf, b3)
%VANED_DIFFUSER_DISCHARGE_SIZING design/diffuser_sizing.py :: vaned_diffuser_discharge_sizing() portu.
%   Eq. (6-26)/(6-27)/(6-28): 2*theta_C ve AR (alan orani) tarama ile
%   L<=1/3 kisitini saglayan ILK kombinasyonu secer.
%
%       Eq (6-26): tan(theta_C) = pi*(r4*sin(beta4)-r3*sin(beta3))/(Z*LB)
%       Eq (6-27): L = 2*pi*(r3*Cu3-r4*Cu4)/(Z*LB*(C3-C4))
%       Eq (6-28): AR = r4*sin(beta4)/(r3*sin(beta3))
%
%   Tarama: 2*theta_C icin [10.5,7] derece (kitaptaki siralamayla, buyukten
%   kucuge), her biri icin AR [2.4,1.4] (buyukten kucuge) -- L<=1/3
%   saglayan ILK kombinasyon secilir.
%
%   Cu4 vanesiz difuzordeki (Eq 6-24) ILE AYNI surtunme-kayipli ustel
%   azalma modeliyle hesaplanir (bkz. Python kaynak docstring'i).
%
%   r4_max: maksimum izin verilen r4. b3: difuzor giris genisligi [m]
%   (verilmezse r3*0.07 ile kabaca tahmin edilir [BASITLESTIRME]).
%
%   Cikti struct alanlari: two_theta_C_deg, AR, r4, beta4_deg, L.
%   Hicbir kombinasyon bulunamazsa hata firlatilir.

if nargin < 9 || isempty(cf)
    cf = 0.005;
end
if nargin < 10 || isempty(b3)
    b3_est = 0.07 * r3;
else
    b3_est = b3;
end

sin_beta3 = sin(deg2rad(beta3_deg));
alpha3_est = deg2rad(beta3_deg);

two_theta_C_list = [10.5, 10.0, 9.0, 8.0, 7.0];
AR_list = [2.4, 2.0, 1.7, 1.4];

for i = 1:numel(two_theta_C_list)
    two_theta_C_deg = two_theta_C_list(i);
    for j = 1:numel(AR_list)
        AR = AR_list(j);
        sin_beta4 = AR * sin_beta3;
        if sin_beta4 > 1.0
            continue;
        end
        r4 = r3 * AR;
        r4 = min(r4, r4_max);
        beta4_deg = rad2deg(asin(min(sin_beta4, 1.0)));

        ln_ratio = -cf * (r4 - r3) / (b3_est * sin(alpha3_est));
        Cu4 = Cu3 * (r3 / r4) * exp(ln_ratio);

        L = (2.0 * pi * (r3 * Cu3 - r4 * Cu4)) / (z_vanes * L_B * max(C3 - C4_estimate, 1e-6));

        if abs(L) <= 1.0 / 3.0
            result.two_theta_C_deg = two_theta_C_deg;
            result.AR = AR;
            result.r4 = r4;
            result.beta4_deg = beta4_deg;
            result.L = L;
            return;
        end
    end
end

error('centrifugal:vaned_diffuser_discharge_sizing', ...
    ['vaned_diffuser_discharge_sizing: taranan [2*theta_C, AR] izgarasinda ' ...
     'L<=1/3 kisitini saglayan bir kombinasyon bulunamadi -- impeller tip ' ...
     'hiz ucgenini (Cu3/C3) degistirmeyi deneyin (s.122).']);

end
