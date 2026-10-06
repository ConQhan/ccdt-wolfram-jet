function b6 = crossover_discharge_width(b4, alpha4_deg, alpha6_deg, B_M6)
%CROSSOVER_DISCHARGE_WIDTH design/return_system_sizing.py :: crossover_discharge_width() portu.
%   Eq. (6-29): b6 = b4*tan(alpha4)/tan(alpha6)/(1-B_M6) ; b4<=b6<=2*b4 kisiti.
%
%   B_M6: return channel vane giris metal blokaji [-] (z*tb6/(2*pi*r6)
%   formundadir, components/return_channel.m'deki B_M7 ile AYNI mantik,
%   burada giris istasyonu 6 icin).

b6_raw = b4 * tan(deg2rad(alpha4_deg)) / tan(deg2rad(alpha6_deg)) / (1.0 - B_M6);
b6 = min(max(b6_raw, b4), 2.0 * b4);

end
