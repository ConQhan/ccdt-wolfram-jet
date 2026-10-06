function pts = map_curve_valid_points(curve)
%MAP_CURVE_VALID_POINTS solver/compressor_map.py :: MapCurve.valid_points() portu.

if isempty(curve.points)
    pts = struct([]);
    return;
end
pts = curve.points([curve.points.ok]);

end
