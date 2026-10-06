function result = recommend_vane_count(z_impeller)
%RECOMMEND_VANE_COUNT design/diffuser_sizing.py :: recommend_vane_count() portu.
%   s.122: Tercih edilen secimler Z_VD = Z_I +/- 1. Stall araligini
%   artirmak icin 10 <= Z_VD <= 20 ZORUNLU. Bu aralikta degilse,
%   |Z_VD - Z_I| >= 8 ZORUNLU (kesin secim detayli tasarima birakilir).
%
%   Cikti struct alanlari: z_impeller, preferred_candidates,
%   preferred_in_range, fallback_min_difference, note.

candidates = [z_impeller - 1, z_impeller + 1];
preferred = candidates(candidates >= 10 & candidates <= 20);

result.z_impeller = z_impeller;
result.preferred_candidates = candidates;
result.preferred_in_range = preferred;
result.fallback_min_difference = 8;
result.note = ['Tercih edilen Z_VD=Z_I' char(177) '1 10-20 araliginda degilse, ' ...
    '|Z_VD-Z_I|>=8 kosulunu saglayan bir deger detayli ' ...
    'tasarim asamasinda secilmelidir.'];

end
