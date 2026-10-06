function [X, Y] = circular_arc_contour_points(contour, n_points)
%CIRCULAR_ARC_CONTOUR_POINTS design/gas_path_geometry.py :: [YENI -- circular_arc_contour_solve.m ciktisindan noktalar].
%   circular_arc_contour_solve.m'nin cozdugu dogru-yay-dogru bilesik
%   konturu boyunca n_points ayrik (X,Y) noktasi uretir -- yay uzerindeki
%   herhangi bir noktanin merkeze gore konumu, Eq (7-14)'un tersinden
%   (bkz. circular_arc_contour_solve.m ic yorumu): bir noktadaki yerel
%   teget acisi phi ise, o nokta (X_C+R_C*sin(phi), Y_C-R_C*cos(phi))'dedir.
%
%   Noktalar, uc segmentin (L1 dogru + yay + L2 dogru) UZUNLUKLARIYLA
%   ORANTILI olarak dagitilir (yay uzunlugu = R_C*|alpha_C2-alpha_C1|),
%   boylece Eq (7-31)'e (meridional_arc_length.m) verildiginde tekdüze
%   bir orneklemeyle dogru sonuc üretilir.
%
%   Cikti: X, Y -- 1xn_points vektorler (X1'den X2'ye, artan sirada).

if nargin < 2 || isempty(n_points)
    n_points = 50;
end

L1 = contour.L1; L2 = contour.L2;
arc_len = contour.R_C * abs(contour.alpha_C2 - contour.alpha_C1);
total_len = L1 + arc_len + L2;

n1 = max(0, round(n_points * L1 / total_len));
n3 = max(0, round(n_points * L2 / total_len));
n2 = max(2, n_points - n1 - n3);

X = zeros(1, 0); Y = zeros(1, 0);

if n1 > 0
    t = linspace(0.0, L1, n1 + 1);
    t = t(1:end-1);  % L1 sonundaki nokta (Xa,Ya) yay parcasinda tekrarlanacak
    X = [X, contour.X1 + t * cos(contour.alpha_C1)];
    Y = [Y, contour.Y1 + t * sin(contour.alpha_C1)];
end

phi = linspace(contour.alpha_C1, contour.alpha_C2, n2);
X = [X, contour.X_C + contour.R_C * sin(phi)];
Y = [Y, contour.Y_C - contour.R_C * cos(phi)];

if n3 > 0
    t = linspace(0.0, L2, n3 + 1);
    t = t(2:end);  % L2 basindaki nokta (Xb,Yb) yay parcasinda zaten var
    X = [X, contour.Xb + t * cos(contour.alpha_C2)];
    Y = [Y, contour.Yb + t * sin(contour.alpha_C2)];
end

end
