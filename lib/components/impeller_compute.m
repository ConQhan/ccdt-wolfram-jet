function outlet_station = impeller_compute(imp, inlet_station)
%IMPELLER_COMPUTE components/impeller.py :: Impeller.compute() portu.
%
%   *** SAGLAMLASTIRMA (kaynaktan aynen tasindi) ***
%   mdot_calc(Cm2) fonksiyonu genel olarak monotonik DEGILDIR (deep-surge
%   bolgesinde B2/I_R guvenlik sinirlarina carpip sahte isaret degisimi
%   yaratabilir). Bu yuzden: [lo,hi] araligi taranip TUM isaret degisimi
%   bracket'leri toplanir; her bracket icin cozum bulunup
%   model_validity_flagged olmayanlar arasindan EN BUYUK Cm2 secilir;
%   hicbiri "temiz" degilse ilk bracket kullanilir ama uyari verilir.

mdot_target = inlet_station.mass_flow;
pt0 = inlet_station.total.p;
Tt0 = inlet_station.total.T;

station1 = impeller_solve_station1(imp, pt0, Tt0, mdot_target);

U2 = imp.omega_rad_s * imp.geometry.r2_m;

last_station2 = [];
last_loss_result = [];

    function r = residual(Cm2)
        [s2, lr, mdc] = impeller_evaluate_station2(imp, Cm2, station1, pt0, Tt0, mdot_target);
        last_station2 = s2;
        last_loss_result = lr;
        r = mdc - mdot_target;
    end

Cm2_lo = 0.01 * U2;
Cm2_hi = 0.95 * U2;
n_scan = 80;
scan_points = Cm2_lo + (Cm2_hi - Cm2_lo) * (0:n_scan) / n_scan;
scan_values = nan(1, n_scan + 1);
for i = 1:(n_scan + 1)
    try
        scan_values(i) = residual(scan_points(i));
    catch
        scan_values(i) = NaN;
    end
end

all_brackets = zeros(0, 2);
for i = 1:n_scan
    a = scan_values(i); b = scan_values(i+1);
    if isnan(a) || isnan(b)
        continue
    end
    if a * b <= 0
        all_brackets(end+1, :) = [scan_points(i), scan_points(i+1)]; %#ok<AGROW>
    end
end

if isempty(all_brackets)
    valid_values = scan_values(~isnan(scan_values));
    if ~isempty(valid_values)
        max_mdot = max(valid_values) + mdot_target;
    else
        max_mdot = NaN;
    end
    error('centrifugal:impeller_compute', ...
        ['Impeller dis donguyu: [%.4g, %.4g] m/s taramasinda isaret degisimi ' ...
         'bulunamadi (ulasilabilen max ~%.4g kg/s, hedef %.4g kg/s). ' ...
         'Hedef debi bu geometriyle ulasilamiyor olabilir.'], Cm2_lo, Cm2_hi, max_mdot, mdot_target);
end

% [DUZELTME] mdot(Cm2) tikanma noktasinda tepe yapar: solunda debi Cm2 ile
% ARTAR (fiziksel, ses-alti dal), saginda AZALIR (tikanma-otesi sahte dal).
% Eskiden "en buyuk temiz kok" seciliyordu; iki kok de taramaya girince
% (orn. buyuk tip clearance) sahte dal seciliyordu. Artik sadece debinin
% arttigi bracket'lerdeki (residual: - -> +) temiz kokler aday.
opts = optimset('TolX', 1e-6);
clean_solutions = [];
for i = 1:size(all_brackets, 1)
    idx = find(scan_points == all_brackets(i, 1), 1);
    rising = scan_values(idx) < scan_values(idx + 1);
    Cm2_candidate = fzero(@residual, all_brackets(i, :), opts);
    if rising && ~(isfield(last_station2, 'model_validity_flagged') && last_station2.model_validity_flagged)
        clean_solutions(end+1) = Cm2_candidate; %#ok<AGROW>
    end
end

if ~isempty(clean_solutions)
    Cm2_solution = max(clean_solutions);
else
    Cm2_solution = fzero(@residual, all_brackets(1, :), opts);
    warning('centrifugal:impeller_compute', ...
        ['Impeller cozumu bulundu ama TUM kok adaylarinda B2 veya I_R guvenlik ' ...
         'sinirina carpildi -- sonuc model gecerlilik sinirlari disinda olabilir ' ...
         '(deep-surge / cok dusuk phi2 bolgesi). Sonuclari dikkatli yorumlayin.']);
end

residual(Cm2_solution);

outlet_station = last_station2;
outlet_station.loss_total_pressure = impeller_loss_result_total_omega(last_loss_result);

end
