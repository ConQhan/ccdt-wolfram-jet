function result = crossover_shroud_ellipse_axes(R_ch, b4, b6)
%CROSSOVER_SHROUD_ELLIPSE_AXES design/return_system_sizing.py :: crossover_shroud_ellipse_axes() portu.
%   Eq. (6-31): A_CO = R_ch + (b4+b6)/2 ; B_CO = R_ch + b4.

result.A_CO = R_ch + 0.5 * (b4 + b6);
result.B_CO = R_ch + b4;

end
