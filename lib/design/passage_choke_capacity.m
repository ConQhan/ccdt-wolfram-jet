function pc = passage_choke_capacity(design, bd, p01, T01, eos, opts)
%PASSAGE_CHOKE_CAPACITY Cark kanali boyunca (LE -> TE) bogulma debisi kapasitesi.
%   Onceki tikanma kontrolu (A_th/A*, Eq 6-15 amaci) yalnizca inducer
%   girisindeki bogazi kapsiyordu. 2026-09-30 CFD'si (70k rpm, kaba mesh,
%   High Resolution) carkin RADYAL kisimda (ζ ~ 0.7) boguldugunu gosterdi:
%   debi ~0.44 kg/s'de takildi (tasarim 0.54). Bu fonksiyon kanal boyunca
%   her quasi-ortogonal kesitin gecirebilecegi en yuksek (sonik) debiyi hesaplar.
%
%   Kesit (bir ana kanat araligi icin), hub->shroud seritleri uzerinden:
%       A_n(ζ) = Σ ( 2π r sin(β)/Z(ζ) - t ) dn
%       β: kanat acisi TEGETTEN (Eq 6-17, bd), sin(β) = cos(meridyonelden aci)
%       Z(ζ): ζ < 1 - L_splitter/L ise ana kanat sayisi, sonrasi 2 kat
%       t: kanat kalinligi (ana + splitter, akisa dik), LE->TE dogrusal
%   Sonik akı, rothalpi korunumu ile (on-donmesiz giris):
%       T0rel(r) = T01 + U^2/(2 cp),  p0rel = p01 (T0rel/T01)^(γ/(γ-1))  (kayipsiz)
%       G* = p0rel/sqrt(R T0rel) * sqrt(γ) * (2/(γ+1))^((γ+1)/(2(γ-1)))
%   m*_ideal(ζ) = Z(ζ) * Σ G* dA
%
%   [KOPRU / CFD KALIBRASYONU] Kayipsiz, blokajsiz kapasite gercek bogulmayi
%   asiri tahmin eder (sinir tabaka, jet-wake, uc sizintisi blokaji + bagil
%   toplam basinc kaybi). Etkin kapasite:
%       m*_eff(ζ) = f(ζ) * m*_ideal(ζ)
%   f_radial (ζ >= zeta_radial): CFD'den -- CFX_004 (2026-09-30, 70k rpm, 2.5 atm,
%   High Resolution, kaba mesh 439k): bogulma debisi 0.4365 kg/s; ayni CFTurbo
%   geometrisinin radyal kisim ideal kapasitesi (kanal_kesit_analizi.m) 0.688 kg/s
%   -> f = 0.634. Bu tek bir kaba mesh CFD'sinden gelir; ince mesh ile guncellenmeli.
%   Sonik cizgi CFD'de ζ ~ 0.7'deydi; ζ ~ 0.35'te (CFTurbo ideal minimumu 0.601)
%   bogulma YOKTU -> orada f >= 0.4365/0.601 = 0.73. Bu yuzden f_radial yalnizca
%   ζ >= zeta_radial = 0.6 bolgesine uygulanir.
%   f_inducer (ζ < 0.6): CFD yalnizca alt sinir veriyor (>= 0.73). Varsayilan
%   0.90 (Aungier B ~ %5 + %5 toplam basinc kaybi) [KOPRU] -- inducer icin asil
%   kontrol A_th/A* (design.tip.throat_margin) olarak kalir.
%
%   Girdi : design (design_preliminary_stage), bd (aungier_blade_angle_distribution),
%           p01, T01, eos, opts (istege bagli, asagidaki alanlar)
%   Cikti : pc.zeta, pc.m_ideal, pc.m_eff, pc.A_n_mm2, pc.r_mean_mm,
%           pc.m_eff_min, pc.zeta_min, pc.region_min ('inducer'/'radyal'),
%           pc.m_ideal_inducer_min, pc.m_ideal_radial_min

if nargin < 6 || isempty(opts); opts = struct(); end
g = design.impeller_geometry;
gam = struct_get(eos, 'gamma', 1.4);
R = struct_get(eos, 'R', 287.05);
cp = struct_get(eos, 'cp', gam * R / (gam - 1));

n_st = struct_get(opts, 'n_stations', 81);
n_sp = struct_get(opts, 'n_span', 11);
f_rad = struct_get(opts, 'f_radial', 0.634);
f_ind = struct_get(opts, 'f_inducer', 0.90);
zeta_rad = struct_get(opts, 'zeta_radial', 0.60);
% Kalinliklar [hub shroud] (m): LE tasarimdan, TE kullanici karari (CFTurbo 1.0/0.6 mm)
t_le = [struct_get(g, 'blade_le_thickness_hub_m', 0.8e-3), struct_get(g, 'blade_le_thickness_shroud_m', 0.5e-3)];
t_te = struct_get(opts, 'te_thickness_m', [1.0e-3, 0.6e-3]);

Zf = g.n_blades_full;
Zs = struct_get(g, 'n_blades_splitter', 0);
Ls = struct_get(g, 'splitter_length_ratio', 0);
zeta_split = 1 - Ls;
omega = 2 * pi * g.rotational_speed_rpm / 60;
Gfac = sqrt(gam) * (2 / (gam + 1))^((gam + 1) / (2 * (gam - 1)));

zq = linspace(0, 1, n_st);
hz = interp1(bd.hub.zeta, [bd.hub.r(:), bd.hub.z(:), bd.hub.beta_deg(:)], zq);
sz = interp1(bd.shroud.zeta, [bd.shroud.r(:), bd.shroud.z(:), bd.shroud.beta_deg(:)], zq);
sp = linspace(0, 1, n_sp)';

m_ideal = zeros(1, n_st); A_n = zeros(1, n_st); r_mean = zeros(1, n_st); blk = zeros(1, n_st);
for j = 1:n_st
    r = hz(j, 1) + (sz(j, 1) - hz(j, 1)) * sp;          % duz-cizgi eleman (ruled)
    z = hz(j, 2) + (sz(j, 2) - hz(j, 2)) * sp;
    b = hz(j, 3) + (sz(j, 3) - hz(j, 3)) * sp;           % tegetten
    t_h = t_le(1) + (t_te(1) - t_le(1)) * zq(j);
    t_s = t_le(2) + (t_te(2) - t_le(2)) * zq(j);
    t = t_h + (t_s - t_h) * sp;
    has_split = Zs > 0 && zq(j) >= zeta_split;
    % bir ANA kanat araligi: ana kanat + (varsa) bir splitter kalinligi
    w = 2 * pi * r .* sind(b) / Zf - t * (1 + has_split);
    w = max(w, 0);
    dn = hypot(diff(r), diff(z));
    U = omega * r;
    T0r = T01 + U.^2 / (2 * cp);
    p0r = p01 * (T0r / T01).^(gam / (gam - 1));
    G = p0r ./ sqrt(R * T0r) * Gfac;
    wG = w .* G;
    m_ideal(j) = Zf * sum(0.5 * (wG(1:end-1) + wG(2:end)) .* dn);
    A_n(j) = sum(0.5 * (w(1:end-1) + w(2:end)) .* dn);
    open_geo = 2 * pi * r .* sind(b) / Zf;
    blk(j) = 1 - A_n(j) / sum(0.5 * (open_geo(1:end-1) + open_geo(2:end)) .* dn);
    r_mean(j) = mean(r);
end

f = f_ind * ones(1, n_st);
f(zq >= zeta_rad) = f_rad;
m_eff = f .* m_ideal;
% LE ve TE uclari (kalinlik kapanisi / kesik TE) fiziksel bogaz degil: haric tut
valid = zq > 0.02 & zq < 0.98;
iv = find(valid);
[pc.m_eff_min, k] = min(m_eff(iv));
k = iv(k);
pc.zeta_min = zq(k);
if zq(k) >= zeta_rad; pc.region_min = 'radyal'; else; pc.region_min = 'inducer'; end
pc.zeta = zq; pc.m_ideal = m_ideal; pc.m_eff = m_eff; pc.f = f;
pc.A_n_mm2 = A_n * 1e6; pc.r_mean_mm = r_mean * 1e3; pc.blade_blockage = blk;
pc.m_ideal_inducer_min = min(m_ideal(valid & zq < zeta_rad));
pc.m_ideal_radial_min = min(m_ideal(valid & zq >= zeta_rad));
pc.m_eff_inducer_min = min(m_eff(valid & zq < zeta_rad));
pc.m_eff_radial_min = min(m_eff(valid & zq >= zeta_rad));
pc.f_radial = f_rad; pc.f_inducer = f_ind; pc.zeta_radial = zeta_rad;
end
