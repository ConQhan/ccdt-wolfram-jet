function alpha_0_deg = igv_exit_flow_angle(geom, delta_star_deg)
%IGV_EXIT_FLOW_ANGLE losses/igv_losses.py :: [YENI -- Bolum5_DersNotu.md SS2.3 / Eq 5-16 BIREBIR portu].
%   Eq. (5-16): alpha_0 = 90deg - K*(kappa_0 + delta*)
%   Sapma acisindan (delta*, Eq 5-15) GERCEK cikis akis acisini verir --
%   kanadin geometrik cikis acisinin (kappa_0) tam takip edilmedigini
%   (sinir tabakasi/sonlu kanat sayisi nedeniyle "geride kalma") hesaba katar.
%
%   geom: igv_camber_geometry.m ciktisi (K, kappa_0 alanlarini kullanir)
%   Cikti: alpha_0_deg [derece, meridyenden olculur -- teget-referansli
%          santrifuj kompresor "beta" konvansiyonuna cevirmek icin
%          90-alpha_0 kullanin]

alpha_0_deg = 90.0 - geom.K * (geom.kappa_0 + delta_star_deg);

end
