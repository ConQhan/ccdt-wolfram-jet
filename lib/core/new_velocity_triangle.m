function vt = new_velocity_triangle()
%NEW_VELOCITY_TRIANGLE core/station.py :: VelocityTriangle dataclass portu.
%   Bir istasyondaki hiz ucgeni bilesenleri (mutlak C, relatif W, tegetsel U).
%
%   NOT: Python'daki VelocityTriangle.M @property'si her zaman
%   NotImplementedError firlatiyor (hicbir yerde cagrilmiyor) -- bu
%   yuzden MATLAB'e portlanmadi. Mach sayisi StationState uzerinden
%   (station_mach_absolute/station_mach_relative) hesaplanir.

vt.Cm = 0.0;
vt.Cu = 0.0;
vt.C = 0.0;
vt.Wm = 0.0;
vt.Wu = 0.0;
vt.W = 0.0;
vt.U = 0.0;
vt.beta = 0.0;
vt.alpha = 0.0;

end
