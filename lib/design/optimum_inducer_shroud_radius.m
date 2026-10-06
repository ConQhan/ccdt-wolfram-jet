function r1_shroud_m = optimum_inducer_shroud_radius(mdot, rho1, omega_rad_s, r1_hub_m)
%OPTIMUM_INDUCER_SHROUD_RADIUS design/impeller_sizing.py :: [YENI -- Aungier'in 9 bolumunde
%   bulunamadi, birinci-ilkelerden turetildi, klasik sonucla capraz dogrulandi].
%
%   Verilen debi (mdot), yogunluk (rho1), acisal hiz (omega_rad_s) ve GOBEK
%   yaricapinda (r1_hub_m) sabit tutulmus bir inducer icin, SHROUD'daki bagil
%   hizi (W1s = hypot(Cm1, U1s)) MINIMIZE EDEN shroud yaricapini kapali-form
%   olarak doner.
%
%   *** TURETIM (bu dosyanin disinda dogrulanmali, kaynak metinde YAZILI DEGIL) ***
%   Sureklilik: Cm1(r1s) = mdot / (rho1 * pi * (r1s^2 - r1h^2))
%   Hedef: minimize W1s^2 = Cm1(r1s)^2 + (omega*r1s)^2
%   d(W1s^2)/d(r1s) = 0  =>  (omega*r1s)^2 - (omega*r1h)^2 = 2*Cm1(r1s)^2
%   x := r1s^2 - r1h^2 yerine koyulursa:
%       omega^2 * x^3 = 2*mdot^2 / (rho1*pi)^2
%       x = (2*mdot^2 / (rho1*pi*omega)^2)^(1/3)
%       r1s = sqrt(r1h^2 + x)
%
%   *** SINIR-DURUM CAPRAZ DOGRULAMASI (kaynak: klasik turbomakina literaturu,
%   orn. Whitfield & Baines "Design of Radial Turbomachines"; Aungier'in kendi
%   9 bolumde bahsettigi ama TURETMEDIGI "alpha1'~30 derece W1'i yaklasik
%   minimize eder" ifadesiyle AYNI AILEDEN bir sonuc) ***
%   r1_hub_m -> 0 (gobeksiz idealize limit) alinirsa:
%       U1s^2 = 2*Cm1^2  =>  U1s/Cm1 = sqrt(2)
%   Yani meridyenel eksenden olculen bagil aki acisi icin tan(beta1s) = sqrt(2)
%   (beta1s = 54.7356 derece) -- kullanicinin hafizasindan verdigi "tan
%   beta_s1 = sqrt(2)" ifadesiyle BIREBIR ORTUSUYOR. NOT: bu koddaki
%   impeller_solve_station1.m'deki beta1_deg = atan2(Cm1, U1) tanimi acidan
%   TEGETE gore olculdugu icin (meridyenden degil), ayni limitte
%   tan(beta1_kod) = 1/sqrt(2) cikar -- iki tanim birbirinin tumleyenidir
%   (35.2644 + 54.7356 = 90 derece), FIZIKSEL sonuc aynidir.
%
%   Girdiler:
%     mdot         - kutlesel debi [kg/s]
%     rho1         - inducer girisi statik yogunluk [kg/m^3] (BASITLESTIRME:
%                    optimizasyon boyunca sabit kabul edilir -- ayni
%                    design_preliminary_stage.m'deki rho1_estimate=rho_t0
%                    basitlestirmesiyle TUTARLI)
%     omega_rad_s  - acisal hiz [rad/s]
%     r1_hub_m     - gobek (mil) yaricapi [m], sabit tutulan tasarim kisiti
%
%   Cikti: r1_shroud_m [m] -- W1s'i minimize eden shroud yaricapi.

x = (2.0 * mdot^2 / (rho1 * pi * omega_rad_s)^2)^(1.0/3.0);
r1_shroud_m = sqrt(r1_hub_m^2 + x);

end
