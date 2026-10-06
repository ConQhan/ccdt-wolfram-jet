function result = exit_turn_radii_of_curvature(b8)
%EXIT_TURN_RADII_OF_CURVATURE design/return_system_sizing.py :: exit_turn_radii_of_curvature() portu.
%   Eq. (6-32): R_cEXs = b8 ; R_cEXh = 2*b8 (exit turn shroud/hub egrilik yaricaplari).

result.R_cEXs = b8;
result.R_cEXh = 2.0 * b8;

end
