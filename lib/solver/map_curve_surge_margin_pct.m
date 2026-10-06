function val = map_curve_surge_margin_pct(curve, design_mdot)
%MAP_CURVE_SURGE_MARGIN_PCT solver/compressor_map.py :: MapCurve.surge_margin_pct() portu.
%   Surge marji [%] = (mdot_tasarim - mdot_surge) / mdot_tasarim * 100
%   Tipik endustri hedefi: %10-15. Gecersiz girdide [] (None).

surge = map_curve_surge_limit_approx(curve);
if isempty(surge) || design_mdot <= 0
    val = [];
    return;
end
val = (design_mdot - surge) / design_mdot * 100.0;

end
