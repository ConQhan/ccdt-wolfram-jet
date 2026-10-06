function result = recommend_blade_count(U2, I_B, r2, L_B, W1, W2, z_min, z_max)
%RECOMMEND_BLADE_COUNT design/impeller_sizing.py :: recommend_blade_count() portu.
%   Eq. (6-22) tasarim kisitini (2*delta_W/(W1+W2) <= 0.9) saglayan EN
%   KUCUK kanat sayisini (z_eff) onerir -- daha az kanat genellikle daha
%   az surtunme/blokaj kaybi demektir, bu yuzden kisiti saglayan en
%   kucuk deger tercih edilir.
%
%   z_min/z_max arasinda tam sayi taramasi yapilir (delta_W, z_eff'e
%   gore monoton AZALIR -- Eq 4-42'den: delta_W ~ 1/z_eff -- bu nedenle
%   basit bir dogrusal tarama yeterli).
%
%   Cikti struct alanlari: z_eff_recommended, delta_W, constraint_satisfied,
%   scan (struct array: z_eff, delta_W, satisfied).

if nargin < 7 || isempty(z_min)
    z_min = 8;
end
if nargin < 8 || isempty(z_max)
    z_max = 24;
end

n = z_max - z_min + 1;
scan(n) = struct('z_eff', [], 'delta_W', [], 'satisfied', []);
recommended = [];
for idx = 1:n
    z_eff = z_min + idx - 1;
    dW = compute_delta_w(U2, I_B, z_eff, L_B, r2);
    satisfied = delta_W_design_limit_check(dW, W1, W2);
    scan(idx).z_eff = z_eff;
    scan(idx).delta_W = dW;
    scan(idx).satisfied = satisfied;
    if satisfied && isempty(recommended)
        recommended = z_eff;
    end
end

if isempty(recommended)
    error('centrifugal:recommend_blade_count', ...
        ['recommend_blade_count: [%d, %d] araliginda Eq (6-22) kisitini saglayan bir kanat ' ...
         'sayisi bulunamadi (en yuksek z_eff=%d''te bile 2*delta_W/(W1+W2) > 0.9). Daha fazla ' ...
         'kanat veya farkli bir tip geometrisi gerekebilir.'], z_min, z_max, z_max);
end

dW_recommended = [];
for idx = 1:n
    if scan(idx).z_eff == recommended
        dW_recommended = scan(idx).delta_W;
        break;
    end
end

result.z_eff_recommended = recommended;
result.delta_W = dW_recommended;
result.constraint_satisfied = true;
result.scan = scan;

end
