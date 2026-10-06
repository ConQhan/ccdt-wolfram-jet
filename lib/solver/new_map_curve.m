function curve = new_map_curve(rpm)
%NEW_MAP_CURVE solver/compressor_map.py :: MapCurve dataclass portu.
%   Tek bir RPM'deki tum calisma noktalari (bir 'speedline').

curve.rpm = rpm;
curve.points = struct([]);

end
