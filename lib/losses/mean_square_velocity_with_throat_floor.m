function c_bar_sq = mean_square_velocity_with_throat_floor(C3, C4, C_th)
%MEAN_SQUARE_VELOCITY_WITH_THROAT_FLOOR losses/vaned_diffuser_losses.py portu.
%   [BASITLESTIRME] Impeller Eq(5-33) analojisiyle: Cbar^2=(C3^2+C4^2)/2,
%   throat hiziyla alttan sinirli: Cbar^2 >= (Cth^2+C4^2)/2.
c_bar_sq = 0.5 * (C3^2 + C4^2);
c_bar_sq_floor = 0.5 * (C_th^2 + C4^2);
c_bar_sq = max(c_bar_sq, c_bar_sq_floor);
end
