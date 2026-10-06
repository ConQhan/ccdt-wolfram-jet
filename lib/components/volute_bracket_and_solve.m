function solution = volute_bracket_and_solve(residual_fn, lo, hi, label, validity_fn)
%VOLUTE_BRACKET_AND_SOLVE components/volute.py :: Volute._bracket_and_solve() portu.
%   TUM isaret degisimi bracket'leri taranir. validity_fn verilirse
%   (residual'in son cagrisinin ARDINDAN kontrol edilen bir fonksiyon
%   handle), bu fonksiyonu saglayan ("temiz") cozumler arasindan en
%   BUYUK deger secilir; hicbiri temiz degilse en buyuk (ham) cozum
%   kullanilir ve uyari verilir. validity_fn=[] ise dogrudan en buyuk
%   cozum secilir.

if nargin < 5
    validity_fn = [];
end

n_scan = 60;
scan_points = lo + (hi - lo) * (0:n_scan) / n_scan;
scan_values = nan(1, n_scan + 1);
for i = 1:(n_scan + 1)
    try
        scan_values(i) = residual_fn(scan_points(i));
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
        max_val = max(valid_values);
    else
        max_val = NaN;
    end
    error('centrifugal:volute_bracket_and_solve', ...
        'Volute dis dongu (%s): [%.4g, %.4g] m/s taramasinda isaret degisimi bulunamadi (max kalan %.4g).', ...
        label, lo, hi, max_val);
end

opts = optimset('TolX', 1e-6);
n_b = size(all_brackets, 1);
candidates = zeros(1, n_b);
for i = 1:n_b
    candidates(i) = fzero(residual_fn, all_brackets(i, :), opts);
end

if isempty(validity_fn)
    solution = max(candidates);
    return
end

clean_candidates = [];
for i = 1:n_b
    c = candidates(i);
    residual_fn(c);  % closure'daki durumu bu c icin guncelle
    if validity_fn()
        clean_candidates(end+1) = c; %#ok<AGROW>
    end
end

if ~isempty(clean_candidates)
    solution = max(clean_candidates);
    return
end

warning('centrifugal:volute_bracket_and_solve', ...
    ['Volute (%s): TUM kok adaylarinda gecerlilik kontrolu (sum_omega<1.0) ' ...
     'basarisiz oldu -- sonuc model gecerlilik sinirlari disinda olabilir. ' ...
     'Sonuclari dikkatli yorumlayin.'], label);
solution = max(candidates);

end
