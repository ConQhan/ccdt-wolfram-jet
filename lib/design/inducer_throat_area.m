function A_th = inducer_throat_area(r1h, r1s, beta_hub_deg, beta_shroud_deg, z_FB, t_hub, t_shroud, n)
%INDUCER_THROAT_AREA Inducer bogaz alani, kanat acisi ve kalinligindan.
%   Hucum kenarindaki kanada dik gecit genisligi (adim*sin(beta) - t), hub'dan
%   shroud'a integre edilir -- duz-cizgi-elemanli kanatta LE acisi ve kalinlik
%   span boyunca dogrusal:
%       A_th = integral_{r1h}^{r1s} [2*pi*r*sin(beta_b(r)) - z_FB*t(r)] dr
%   Aungier Bolum 7 SS6 (Eq 7-50..7-53) bogazi konformal donusumle kanat
%   yuzeyinden hesaplar; bu ifade, bogazin hucum kenarinda olustugu inducer
%   icin onun birinci dereceden karsiligidir [KOPRU: bogaz LE'nin hafif
%   akis asagisinda olusursa gercek alan biraz daha buyuk olabilir].
%   Splitter kanatlar hucum kenarinda olmadigindan z_FB (tam kanat sayisi).

if nargin < 8 || isempty(n); n = 201; end
r = linspace(r1h, r1s, n);
s = (r - r1h) / (r1s - r1h);
beta = beta_hub_deg + (beta_shroud_deg - beta_hub_deg) * s;
t = t_hub + (t_shroud - t_hub) * s;
A_th = trapz(r, 2 * pi * r .* sind(beta) - z_FB * t);

end
