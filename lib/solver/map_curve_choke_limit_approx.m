function val = map_curve_choke_limit_approx(curve)
%MAP_CURVE_CHOKE_LIMIT_APPROX solver/compressor_map.py :: MapCurve.choke_limit_approx() portu.
%   En yuksek basarili debi. Yoksa [] (None).

valid = map_curve_valid_points(curve);
if isempty(valid)
    val = [];
    return;
end
val = max([valid.mdot]);

end
