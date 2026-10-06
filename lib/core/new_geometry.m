function g = new_geometry()
%NEW_GEOMETRY core/station.py :: Geometry dataclass portu.
%   Istasyona ait lokal geometri bilgisi (istasyon tipine gore
%   alanlarin bir kismi bos/0 kalabilir). n_blades Python'da
%   Optional[int] -- MATLAB'de bos dizi [] ile temsil ediliyor.

g.r = 0.0;
g.b = 0.0;
g.area = 0.0;
g.blade_angle = 0.0;
g.blockage = 0.0;
g.n_blades = [];

end
