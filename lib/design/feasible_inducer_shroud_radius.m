function result = feasible_inducer_shroud_radius(mdot, rho1, omega_rad_s, r1_hub, pt0, T0, eos)
%FEASIBLE_INDUCER_SHROUD_RADIUS design/impeller_sizing.py :: [YENI -- kapasite-farkindali inducer boyutlandirma].
%   optimum_inducer_shroud_radius.m SADECE W1s'i minimize eder, BOGAZ
%   (throat) DEBI KAPASITESINI HIC KONTROL ETMEZ. Bazi calisma
%   noktalarinda (orn. yuksek N, r2'den BAGIMSIZ olarak -- cunku
%   optimum formul r2'yi kullanmaz) bu, hedef debiyi GECIREMEYEN bir goz
%   uretebilir (bkz. sohbet: N=75000rpm/mdot=0.5kg/s bulgusu).
%
%   Bu fonksiyon: (1) once optimum (W1s-min) r1_shroud'u dener, (2) bogaz
%   kapasitesini (Eq (5-32) sonik alan mantigi, sonic_area.m ile AYNI
%   formul) kontrol eder, (3) yetersizse r1_shroud'u KADEMELI olarak
%   (%2 artislarla, maks %50'ye kadar) buyutup her adimda tekrar kontrol
%   eder -- ilk yeterli kapasiteyi veren r1_shroud'u doner.
%
%   *** ONEMLI: bu bir ON-KONTROLDUR *** -- burada kullanilan pt1_rel/
%   Tt1_rel hesaplamasi, tam impeller_solve_station1.m'nin (Cu1, egrilik
%   duzeltmesi vb. iceren) BASITLESTIRILMIS bir versiyonudur (Cu1=0,
%   egrilik=0 varsayimlariyla) -- amac kesin bir throat cozumu degil,
%   design_preliminary_stage.m icin MAKUL bir baslangic r1_shroud'u
%   secmek. Nihai/kesin dogrulama impeller_compute.m'de (tam cozum)
%   yapilir.
%
%   Cikti (struct): r1_shroud_m (secilen), was_scaled_up (bool),
%   scale_factor (optimum'a gore carpan), mdot_max_at_throat_kg_s
%   (secilen geometride bogazin tasiyabildigi maksimum debi -- feasible
%   ise >= mdot).

r1_shroud_optimum = optimum_inducer_shroud_radius(mdot, rho1, omega_rad_s, r1_hub);
gamma = eos.gamma; R = eos.R;

scale_factors = [1.0, 1.02:0.02:1.50];
was_scaled_up = false;
chosen_r1_shroud = r1_shroud_optimum;
chosen_mdot_max = NaN;

for k = 1:numel(scale_factors)
    r1_shroud_trial = r1_shroud_optimum * scale_factors(k);
    r1_mean = 0.5 * (r1_hub + r1_shroud_trial);
    U1_mean = omega_rad_s * r1_mean;
    A1 = pi * (r1_shroud_trial^2 - r1_hub^2);
    Cm1 = mdot / (rho1 * A1);
    W1_mean = hypot(Cm1, U1_mean);
    beta1_rad = atan2(Cm1, U1_mean);

    static1 = eos_static_from_total(eos, pt0, T0, Cm1);
    rel_total = eos_total_from_static(eos, static1.p, static1.T, W1_mean);
    pt1_rel = rel_total.p; Tt1_rel = rel_total.T;

    A_th = 0.95 * A1 * sin(beta1_rad);
    A_star_per_unit_mdot = sonic_area(1.0, pt1_rel, Tt1_rel, gamma, R);
    mdot_max_at_throat = A_th / A_star_per_unit_mdot;

    chosen_r1_shroud = r1_shroud_trial;
    chosen_mdot_max = mdot_max_at_throat;
    was_scaled_up = (k > 1);

    if mdot_max_at_throat >= mdot * 1.02  % [KOPRU_TAHMINI] %2 guvenlik payi
        break
    end
end

result.r1_shroud_m = chosen_r1_shroud;
result.r1_shroud_optimum_m = r1_shroud_optimum;
result.was_scaled_up = was_scaled_up;
result.scale_factor = chosen_r1_shroud / r1_shroud_optimum;
result.mdot_max_at_throat_kg_s = chosen_mdot_max;
result.feasible = chosen_mdot_max >= mdot;

end
