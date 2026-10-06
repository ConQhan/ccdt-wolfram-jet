function val = map_curve_surge_limit_approx(curve)
%MAP_CURVE_SURGE_LIMIT_APPROX solver/compressor_map.py :: MapCurve.surge_limit_approx() portu.
%   En dusuk 'model_valid' debi -- yaklasik surge siniri. Yoksa [] (None).

valid = map_curve_clean_points(curve);
if isempty(valid)
    val = [];
    return;
end
val = min([valid.mdot]);

end
