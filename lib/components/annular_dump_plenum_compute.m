function station5 = annular_dump_plenum_compute(eos, geometry, inlet_station)
%ANNULAR_DUMP_PLENUM_COMPUTE [YENI -- Aungier kapsami DISINDA, bkz. asagi]
%   Difuzor cikisindan (istasyon 4) sonra, kanatsiz/vanesiz bir ANI
%   GENISLEME (sudden expansion) ile akisi hedef bir hiza (C5_target)
%   dusuren basit bir "dump plenum" -- yanma odasi girisine gitmeden
%   once son hiz kesme adimi.
%
%   *** KAYNAK NOTU *** -- Bu bilesen Aungier'in Chapter 5/6 zincirinde
%   YOK (kitap, difuzor cikisindan sonrasini -- volut/return channel
%   disinda -- kapsamiyor). Burada kullanilan Borda-Carnot ani genisleme
%   kaybi formulu STANDART bir akiskanlar mekanigi sonucu (bkz. Idelchik
%   "Handbook of Hydraulic Resistance", White "Fluid Mechanics" sudden
%   expansion loss) -- kitaptan degil ama UYDURMA da degil, yerlesik/
%   dogrulanabilir bir kaynaga dayaniyor. Sikistirilamaz akis icin turetilen
%   omega = (1 - A4/A5)^2 katsayisi burada YEREL YOGUNLUKLA (sikistirilabilir
%   duzeltme YOK) uygulaniyor -- [BASITLESTIRME], bu Mach araliginda (M<0.6)
%   makul bir ilk yaklasim.
%
%   geometry.target_C_exit_m_s : plenum cikisinda hedeflenen hiz [m/s]
%       (ornegin yanma odasi girisi icin ~30-60 m/s).
%
%   Yontem: mdot, A4, C4, pt4, Tt4 bilinen (istasyon 4) degerlerden,
%   A5'i (gerekli plenum kesit alani) ve sonuc pt5'i sabit-nokta
%   iterasyonuyla (yogunluk degisimi icin) cozer:
%     0) A4 = mdot/(rho4*C4)  -- ETKIN 1B alan (istasyon 4'un GERCEK
%        geometrik alani -- 2*pi*r4*b4 -- DEGIL! Geometrik alan sadece
%        meridyen bilesenle (Cm4) tutarli, ama C4=hypot(Cm4,Cu4) swirl'u
%        da iceriyor; Borda-Carnot'un tek-boyutlu turetimiyle TUTARLI
%        kalmak icin "A4" burada C4 ile es-tutarli TANIMLANIYOR -- bu
%        bilesenin kendi ic tutarliligi icin gerekli, istasyon 4'un
%        difuzor cikisindaki GERCEK r4/b4 GEOMETRISI degildir (o, r5
%        hesaplamak icin ayrica -- adim 7'de -- kullaniliyor)
%     1) rho5_guess = rho4 ile basla
%     2) A5 = mdot / (rho5_guess * C5_target)
%     3) x = A4/A5,  dp0 = 0.5*rho4*C4^2*(1-x)^2   (Borda-Carnot)
%     4) pt5 = pt4 - dp0,  Tt5 = Tt4 (adyabatik, is yok)
%     5) static5 = eos_static_from_total(pt5,Tt5,C5_target) -> rho5_new
%     6) yakinsayana kadar tekrarla
%
%   Cikti: yeni_station_state('5') -- vel.Cu=0 [BASITLESTIRME, plenumun
%   swirl'u de soktugu varsayiliyor -- gercekte kismi kalabilir],
%   vel.Cm=C5_target. loss_total_pressure = omega = (1-A4/A5)^2.
%
%   *** GEOMETRI SECENEGI A (onaylandi, bkz. Dump_Plenum_Boyutlandirma.md) ***
%   r5 = r4 (SABIT -- kasa capini hic zorlamaz), b5 = A5/(2*pi*r5) ile
%   genislik buyutulerek A5 alani elde edilir. Diger secenekler (B: r
%   buyutme, C: izotropik) kasa sinirini (125mm) her hedef hizda asiyordu
%   -- sadece A tum senaryolarda (40/50/60 m/s) kasaya sigiyor.

g = geometry;
C5_target = g.target_C_exit_m_s;

r4 = inlet_station.geom.r;
Cm4 = inlet_station.vel.Cm;
Cu4 = inlet_station.vel.Cu;
C4 = hypot(Cm4, Cu4);
p4 = inlet_station.static.p;
T4 = inlet_station.static.T;
pt4 = inlet_station.total.p;
Tt4 = inlet_station.total.T;
mdot = inlet_station.mass_flow;

rho4 = eos_density(eos, p4, T4);
A4 = mdot / (rho4 * C4);  % etkin 1B alan -- yukaridaki adim 0'a bkz.

rho5 = rho4;
for iter = 1:20
    A5 = mdot / (rho5 * C5_target);
    x = A4 / A5;
    if x > 1.0
        error('centrifugal:annular_dump_plenum_compute', ...
            ['annular_dump_plenum_compute: A4 (%.4g m^2) plenum alanindan (A5=%.4g m^2) ' ...
             'BUYUK -- hedef hiz (%.1f m/s) giris hizindan (%.1f m/s) daha YUKSEK istenmis ' ...
             'olabilir (plenum daralmasi anlamsiz, sadece genisleme modelleniyor).'], ...
            A4, A5, C5_target, C4);
    end
    dp0 = 0.5 * rho4 * C4^2 * (1.0 - x)^2;
    pt5 = pt4 - dp0;
    static5 = eos_static_from_total(eos, pt5, Tt4, C5_target);
    rho5_new = static5.rho;
    if abs(rho5_new - rho5) / rho5 < 1.0e-8
        rho5 = rho5_new;
        break;
    end
    rho5 = rho5_new;
end

omega = (1.0 - x)^2;

% Secenek A: r5=r4 sabit, b5 genisletilerek A5 elde edilir.
r5 = r4;
b5 = A5 / (2.0 * pi * r5);

station5 = new_station_state('5');
station5.geom = new_geometry();
station5.geom.r = r5; station5.geom.b = b5; station5.geom.area = A5;

station5.vel = new_velocity_triangle();
station5.vel.Cm = C5_target; station5.vel.Cu = 0.0; station5.vel.C = C5_target;

station5.total = new_fluid_state(pt5, Tt4);
station5.static = new_fluid_state(static5.p, static5.T, static5.rho, [], [], static5.a);

station5.mass_flow = mdot;
station5.loss_total_pressure = omega;

end
