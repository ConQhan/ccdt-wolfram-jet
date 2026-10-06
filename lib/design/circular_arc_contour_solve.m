function contour = circular_arc_contour_solve(X1, Y1, alpha_C1, X2, Y2, alpha_C2)
%CIRCULAR_ARC_CONTOUR_SOLVE design/gas_path_geometry.py :: [YENI -- Bolum7_DersNotu.md SS2.2 / Eq 7-11-7-14 BIREBIR portu].
%   Dairesel-yay + dogru-parca konturu (Bolum 7 SS2.2, "Bolum 6'da cark hub
%   konturu icin kullanilan insa"): iki uc nokta (X1,Y1) ve (X2,Y2), her
%   birinde bir teget acisi (alpha_C1, alpha_C2 [rad], X-ekseninden olculur)
%   verildiginde, bu uc noktalari ve teget yonlerini saglayan MINIMUM
%   egrilikli dairesel-yay + dogru-parca konturunu insa eder.
%
%   Eq. (7-11): dX = R_C(sin(aC2)-sin(aC1)) + L2*cos(aC2) + L1*cos(aC1)
%   Eq. (7-12): dY = R_C(cos(aC1)-cos(aC2)) + L2*sin(aC2) + L1*sin(aC1)
%   Eq. (7-13): L2-L1 = [dY(sin(aC2)-sin(aC1)) - dX(cos(aC1)-cos(aC2))] / ...
%                       [1 - sin(aC1)sin(aC2) - cos(aC1)cos(aC2)]
%   Eq. (7-14): X_C = X1 + L1*cos(aC1) - R_C*sin(aC1)
%               Y_C = Y1 + L1*sin(aC1) + R_C*cos(aC1)
%
%   *** L1/L2 SECIMI (kaynak metin: "L, ucnoktadaki MINIMUM kabul edilebilir
%   dogru parca uzunlugudur, SIFIR OLABILIR") *** -- Eq (7-13) sadece
%   (L2-L1) farkini sabitler; bu fonksiyon, ikisinden HANGISI L2-L1'in
%   isaretine gore "gereksiz" ise onu SIFIRA sabitleyip digerini cozer --
%   kaynak metnin acikca izin verdigi, minimum-uzunluk bir secim (uydurma
%   bir varsayim degil, metindeki "sifir olabilir" ifadesinin dogrudan
%   uygulanmasi).
%
%   Girdiler: X1,Y1,X2,Y2 [m], alpha_C1, alpha_C2 [rad]
%   Cikti (struct): R_C [m], X_C, Y_C [m], L1, L2 [m], Xa,Ya (yayin L1
%   sonrasi baslangic noktasi), Xb,Yb (yayin L2 oncesi bitis noktasi).

dX = X2 - X1;
dY = Y2 - Y1;

sC1 = sin(alpha_C1); cC1 = cos(alpha_C1);
sC2 = sin(alpha_C2); cC2 = cos(alpha_C2);

denom_13 = 1.0 - sC1 * sC2 - cC1 * cC2;
if abs(denom_13) < 1e-12
    error('centrifugal:circular_arc_contour_solve', ...
        'Eq (7-13) paydasi sifira cok yakin (alpha_C1 ve alpha_C2 nerdeyse ayni) -- kontur tanimsiz.');
end
L2_minus_L1 = (dY * (sC2 - sC1) - dX * (cC1 - cC2)) / denom_13;

if L2_minus_L1 >= 0.0
    L1 = 0.0;
    L2 = L2_minus_L1;
else
    L2 = 0.0;
    L1 = -L2_minus_L1;
end

denom_sin = sC2 - sC1;
denom_cos = cC1 - cC2;
if abs(denom_sin) >= abs(denom_cos)
    % Eq (7-11)'den R_C
    R_C = (dX - L2 * cC2 - L1 * cC1) / denom_sin;
else
    % Eq (7-12)'den R_C (sin(aC2)-sin(aC1) sifira yakinsa daha saglam)
    R_C = (dY - L2 * sC2 - L1 * sC1) / denom_cos;
end

X_C = X1 + L1 * cC1 - R_C * sC1;
Y_C = Y1 + L1 * sC1 + R_C * cC1;  % Eq (7-14)

contour.R_C = R_C;
contour.X_C = X_C;
contour.Y_C = Y_C;
contour.L1 = L1;
contour.L2 = L2;
contour.alpha_C1 = alpha_C1;
contour.alpha_C2 = alpha_C2;
contour.Xa = X1 + L1 * cC1;
contour.Ya = Y1 + L1 * sC1;
contour.Xb = X2 - L2 * cC2;
contour.Yb = Y2 - L2 * sC2;
contour.X1 = X1; contour.Y1 = Y1;
contour.X2 = X2; contour.Y2 = Y2;

end
