function pts = map_curve_clean_points(curve)
%MAP_CURVE_CLEAN_POINTS solver/compressor_map.py :: MapCurve.clean_points() portu.
%   Sadece model_valid=true olan noktalar.

valid = map_curve_valid_points(curve);
if isempty(valid)
    pts = struct([]);
    return;
end
pts = valid([valid.model_valid]);

end
