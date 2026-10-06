function m = meridional_arc_length(r_points, z_points)
%MERIDIONAL_ARC_LENGTH design/gas_path_geometry.py :: [YENI -- Bolum7_DersNotu.md SS3 / Eq 7-31 BIREBIR portu].
%   Eq. (7-31): m_i = integral_1^i sqrt((dr/di)^2 + (dz/di)^2) di
%   Parametrik (nokta-numarasi i ile) meridyonel mesafe integrasyonu --
%   kaynak metin, Eq (7-30)'daki (dr/dz kullanan) formun tekillik riski
%   tasidigini, bunun yerine PARAMETRIK (i-indisli) formun tercih
%   edildigini acikca belirtir (SS3, "boylece kismi turevlere teklik
%   olasiligi olmadan cok dogru sayisal yaklasimlar kullanilabilir").
%
%   Sayisal olarak, ardisik noktalar arasindaki Oklid mesafelerinin
%   kumulatif toplami (parca-dogrusal integrasyon) -- iyi orneklenmis bir
%   egri icin Eq (7-31)'in standart, dogru bir ayrik-lastirmasi.
%
%   Girdiler: r_points, z_points -- ayni uzunlukta 1xN vektorler (metre).
%   Cikti: m -- 1xN vektor, m(1)=0, m(N) = toplam meridyonel uzunluk [m].

if numel(r_points) ~= numel(z_points)
    error('centrifugal:meridional_arc_length', 'r_points ve z_points ayni uzunlukta olmali.');
end

dr = diff(r_points);
dz = diff(z_points);
segment_lengths = sqrt(dr.^2 + dz.^2);

m = [0.0, cumsum(segment_lengths)];

end
