function bep = map_curve_best_efficiency_point(curve)
%MAP_CURVE_BEST_EFFICIENCY_POINT solver/compressor_map.py :: MapCurve.best_efficiency_point() portu.
%   En yuksek eta_tt degerine sahip (temiz) nokta. Yoksa [] (None) doner.

pts = map_curve_clean_points(curve);
if isempty(pts)
    bep = [];
    return;
end
eta = [pts.eta_tt_pct];
eta(isnan(eta)) = -1e9;
[~, idx] = max(eta);
bep = pts(idx);

end
