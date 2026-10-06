function [Cu1_hub, Cu1_mean, Cu1_shroud] = forced_vortex_prewhirl(inlet_prewhirl_angle_deg, ...
    Cm1_shroud, r1_hub, r1_mean, r1_shroud)
%FORCED_VORTEX_PREWHIRL design/impeller_sizing.py :: [YENI -- preswirl kinematigi].
%   Girdi kilavuz kanadi (IGV) tarafindan cark girisine verilen teget hiz
%   bilesenini (Cu1), FORCED-VORTEX kanunuyla ($V_{\theta1}/r=\text{sabit}$)
%   hub/mean/shroud'a dagitir.
%
%   *** NEDEN FORCED-VORTEX, FREE-VORTEX DEGIL ***
%   Free-vortex dagilimi ($rV_{\theta1}=\text{sabit}$) shroud'da (r EN
%   BUYUK oldugu icin) $V_{\theta1}$'i EN KUCUK yapar -- tam da bagil Mach
%   sayisi sorununun EN CIDDI oldugu yerde etkisiz kalir (kaynak: literatur
%   arastirmasi, "Free-Vortex Prewhirl ... not effective in decreasing the
%   relative Mach number" cunku Vtheta1 shroud'da minimum). Forced-vortex
%   ($V_{\theta1}/r=\text{sabit}$, yani $V_{\theta1}$ r ile DOGRUSAL artar)
%   shroud'da MAKSIMUM teget hiz verir -- tam ihtiyac duyulan yerde etkili.
%
%   Tasarim girdisi, shroud'daki MUTLAK akis acisidir (meridyenden
%   olculur, alpha1_prime_deg'in RELATIF acisiyla ayni aileden ama mutlak
%   cercevede): Cu1_shroud = Cm1_shroud * tan(inlet_prewhirl_angle_deg).
%   Buradan K = Cu1_shroud/r1_shroud sabiti ile Cu1(r) = K*r her yaricapta
%   hesaplanir.
%
%   inlet_prewhirl_angle_deg = 0 ise Cu1_hub=Cu1_mean=Cu1_shroud=0 --
%   ESKI DAVRANISLA (preswirl'suz) BIREBIR AYNI.
%
%   Girdiler: inlet_prewhirl_angle_deg [derece], Cm1_shroud [m/s],
%             r1_hub, r1_mean, r1_shroud [m]
%   Cikti: Cu1_hub, Cu1_mean, Cu1_shroud [m/s]

Cu1_shroud = Cm1_shroud * tan(deg2rad(inlet_prewhirl_angle_deg));
K = Cu1_shroud / r1_shroud;

Cu1_hub = K * r1_hub;
Cu1_mean = K * r1_mean;

end
