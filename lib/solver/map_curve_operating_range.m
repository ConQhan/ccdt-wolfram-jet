function rng = map_curve_operating_range(curve)
%MAP_CURVE_OPERATING_RANGE solver/compressor_map.py :: MapCurve.operating_range() portu.
%   Hiz egrisi calisma araligi ozeti. Bulunamayan degerler [] (None) olur.

bep = map_curve_best_efficiency_point(curve);
pts = map_curve_clean_points(curve);

rng.rpm = curve.rpm;

if isempty(pts)
    rng.mdot_min = [];
    rng.mdot_max = [];
else
    rng.mdot_min = min([pts.mdot]);
    rng.mdot_max = max([pts.mdot]);
end

% PR_at_min_mdot: pts icinde mdot==mdot_min olan ILK noktanin PR_tt'si
rng.PR_at_min_mdot = [];
if ~isempty(pts)
    for i = 1:numel(pts)
        if pts(i).mdot == rng.mdot_min
            rng.PR_at_min_mdot = pts(i).PR_tt;
            break;
        end
    end
end

% PR_at_max_mdot: reversed(pts) icinde mdot==mdot_max olan ILK nokta
% (yani pts icinde mdot==mdot_max olan SON noktanin PR_tt'si)
rng.PR_at_max_mdot = [];
if ~isempty(pts)
    for i = numel(pts):-1:1
        if pts(i).mdot == rng.mdot_max
            rng.PR_at_max_mdot = pts(i).PR_tt;
            break;
        end
    end
end

if ~isempty(bep)
    rng.bep_mdot = bep.mdot;
    rng.bep_PR = bep.PR_tt;
    rng.bep_eta_pct = bep.eta_tt_pct;
else
    rng.bep_mdot = [];
    rng.bep_PR = [];
    rng.bep_eta_pct = [];
end

rng.n_valid = numel(pts);
rng.n_flagged = numel(map_curve_valid_points(curve)) - numel(pts);

end
