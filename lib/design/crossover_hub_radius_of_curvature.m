function R_ch = crossover_hub_radius_of_curvature(b6, b4, b8)
%CROSSOVER_HUB_RADIUS_OF_CURVATURE design/return_system_sizing.py :: crossover_hub_radius_of_curvature() portu.
%   Eq. (6-30): R_ch = (b6+b4)/2 ; R_ch >= 0.8*(b8-b6) kisiti.
%
%   b8: bir sonraki kademenin impeller eye genisligi [m] (stage
%   performans hedefleri ve mass flow'dan hesaplanir -- preliminary
%   design cagiran kodunun sorumlulugu).

R_ch_base = 0.5 * (b6 + b4);
R_ch_min = 0.8 * (b8 - b6);
R_ch = max(R_ch_base, R_ch_min);

end
