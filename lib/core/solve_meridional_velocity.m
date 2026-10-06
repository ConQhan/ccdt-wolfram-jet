function Cm = solve_meridional_velocity(mdot_target, area, blockage, Cu, pt, Tt, eos, Cm_bracket, n_scan)
%SOLVE_MERIDIONAL_VELOCITY core/continuity.py :: solve_meridional_velocity() portu.
%   mdot = rho*Cm*A*(1-B) denklemini Cm icin cozer (rho, Cm'e bagli
%   oldugundan dogrudan cozulemez).
%
%   *** ONEMLI FIZIKSEL NOT (Python docstring'inden) ***
%   mdot(Cm) fonksiyonu MONOTONIK DEGILDIR: Cm arttikca once mdot artar,
%   sonik noktada (M=1) tepe yapar, sonra sanal bir kok bolgesine girer.
%   Bu yuzden [lo,hi] araligi once n_scan parcaya bolunup residual'in
%   isaret degistirdigi ILK (en dusuk Cm'deki, fiziksel subsonik) alt
%   aralik bulunur, sonra o alt aralikta fzero (Python'daki brentq
%   karsiligi) calistirilir.
%
%   mdot_target [kg/s], area [m^2], blockage [0-1], Cu [m/s] (tegetsel
%   hiz), pt [Pa], Tt [K]. Cm_bracket varsayilan [0.1, 600.0], n_scan
%   varsayilan 60.

if nargin < 8 || isempty(Cm_bracket)
    Cm_bracket = [0.1, 600.0];
end
if nargin < 9 || isempty(n_scan)
    n_scan = 60;
end

    function r = residual(Cm)
        velocity = hypot(Cm, Cu);
        static = eos_static_from_total(eos, pt, Tt, velocity);
        mdot_calc = static.rho * Cm * area * (1.0 - blockage);
        r = mdot_calc - mdot_target;
    end

lo = Cm_bracket(1);
hi = Cm_bracket(2);
scan_points = lo + (hi - lo) * (0:n_scan) / n_scan;
scan_values = arrayfun(@residual, scan_points);

bracket_lo = [];
bracket_hi = [];
for i = 1:n_scan
    if scan_values(i) * scan_values(i+1) <= 0
        bracket_lo = scan_points(i);
        bracket_hi = scan_points(i+1);
        break
    end
end

if isempty(bracket_lo)
    max_mdot = max(scan_values) + mdot_target;
    error('centrifugal:solve_meridional_velocity', ...
        ['solve_meridional_velocity: [%.4g, %.4g] taramasinda isaret degisimi ' ...
         'bulunamadi. Bu aralikta ulasilabilen maksimum debi ~%.4g kg/s ' ...
         '(hedef: %.4g kg/s). Geometri (alan) yetersiz olabilir.'], ...
        lo, hi, max_mdot, mdot_target);
end

opts = optimset('TolX', 1e-6);
Cm = fzero(@residual, [bracket_lo, bracket_hi], opts);

end
