function checks = aungier_design_checks(design, station1, station2, eos)
%AUNGIER_DESIGN_CHECKS Aungier'in cark icin acikca verdigi tasarim sinirlarini
%   (Bolum 5, 6, 7; derleme: Chapters/Aungier_Formulleri_ve_Sinirlari.md SS4
%   Adim 9 ve SS5.3-5.4) yakinsamis bir performans noktasinda kontrol eder.
%
%   design   : design_preliminary_stage() ciktisi
%   station1 : impeller_solve_station1() ciktisi
%   station2 : impeller_compute() / impeller_evaluate_station2() ciktisi
%              (station2.work alani gerekli)
%   eos      : ideal_gas_eos() struct'i
%
%   Cikti: table -- kriter, deger, tercih edilen sinir, kesin sinir, durum
%   ('GECTI' / 'SINIRDA' / 'KALDI'), kaynak.
%   'SINIRDA' = kesin siniri sagliyor ama Aungier'in tercih ettigi degeri degil.
%
%   Not: rake acisi (<15 derece, Bolum 6 SS5.2) kanat geometrisi gerektirir --
%   compute_impeller_blade_distribution.m ciktisinda kontrol edilir.

w = station2.work;
g = design.impeller_geometry;
U2 = 2.0 * pi * g.rotational_speed_rpm / 60.0 * g.r2_m;
z_eff = g.n_blades_full + g.n_blades_splitter * g.splitter_length_ratio;
L = g.blade_mean_camberline_length_m;

rows = {};

% 1) Kanat yukleme, Eq 6-22 (on tasarim) ve Eq 7-60 (detay tasarim) -- ayni buyukluk
dW = compute_delta_w(U2, w.I_B, z_eff, L, g.r2_m);
bl = 2.0 * dW / (w.W1 + w.W2);
rows(end+1, :) = row('dW/Wbar (kanat yukleme)', bl, '<= 0.8', '<= 1.0 (on tasarim <= 0.9)', ...
    grade(bl <= 0.8, bl <= 1.0), 'Eq 6-22, Eq 7-60');

% 2) Cark difuzyonu W2/W1
wr = w.W2 / w.W1;
rows(end+1, :) = row('W2/W1 (cark difuzyonu)', wr, '~0.75', '>= 0.65', ...
    grade(wr <= 0.80 && wr >= 0.65, wr >= 0.65 && wr <= 1.0), 'Bolum 7 SS9.3 (ortalama hat W1)');
wrs = w.W2 / station1.W1_shroud;
rows(end+1, :) = row('W2/W1s (bilgi: shroud referansli)', wrs, '~0.75', '>= 0.65', ...
    grade(wrs <= 0.80 && wrs >= 0.65, wrs >= 0.65 && wrs <= 1.0), 'Bolum 7 SS9.3 (kitap hangi W1 oldugunu notlarda belirtmiyor)');

% 3) Esdeger difuzyon faktoru
rows(end+1, :) = row('Deq (esdeger difuzyon)', w.Deq, '1.6 - 1.7', '< 2.0', ...
    grade(w.Deq <= 1.7, w.Deq < 2.0), 'Eq 4-41, Bolum 7 SS9.3');

% 4) Inducer stall
st = station1.W1_shroud / station1.Wth;
rows(end+1, :) = row('W1s/Wth (inducer stall)', st, '-', '< 1.75', ...
    grade(st < 1.75, st < 1.75), 'Eq 5-29');

% 5) Tikanma payi (Eq 6-15'in amaci: tasarim debisinden tikanmaya makul aralik)
cm = station1.A_th / station1.A_star;
rows(end+1, :) = row('A_th/A* (tikanma payi)', cm, '-', '>= 1.2', ...
    grade(cm >= 1.2, cm >= 1.2), ['Eq 6-15 (amac yorumu; notlardaki sin(beta1)>=1.2*W1/a* yazimi belirsiz). ' ...
    'A_th burada varsayilan 0.95*A1*sin(beta1) -- gercek bogaz CFTurbo geometrisinden kontrol edilmeli']);

% 6-8) Meridyonel egrilik: kappa_bar = (alphaC2-alphaC1)/L (Eq 5-35), eksenelden radyale
b_bar = 0.5 * (station1.b1 + g.b2_m);
% Eq 5-35: L = ortalama akim cizgisinin MERIDYONEL uzunlugu (kamber uzunlugu degil)
L_mer = L;
if isfield(design, 'tip') && isfield(design.tip, 'L_meridional'); L_mer = design.tip.L_meridional; end
kb = (pi / 2.0) / L_mer * b_bar;
rows(end+1, :) = row('|kappa_m*b| (gecis egriligi)', kb, '-', '<= 1', ...
    grade(kb <= 1.0, kb <= 1.0), 'Eq 7-59');
rows(end+1, :) = row('b/Rc (genislik/egrilik yaricapi)', kb, '-', '<= 0.5', ...
    grade(kb <= 0.5, kb <= 0.5), 'Bolum 6 SS5.3');
cm_ratio = (2.0 - kb) / (2.0 + kb);
rows(end+1, :) = row('Cm_min/Cm_max (hub-shroud)', cm_ratio, '0.6 - 0.7 ustu', '> 0.5', ...
    grade(cm_ratio >= 0.6, cm_ratio > 0.5), 'Eq 7-58, Bolum 7 SS9.4');

checks = cell2table(rows, 'VariableNames', {'kriter', 'deger', 'tercih', 'kesin_sinir', 'durum', 'kaynak'});

end


function r = row(name, value, preferred, hard, status, source)
r = {name, value, preferred, hard, status, source};
end


function s = grade(preferred_ok, hard_ok)
if preferred_ok
    s = 'GECTI';
elseif hard_ok
    s = 'SINIRDA';
else
    s = 'KALDI';
end
end
