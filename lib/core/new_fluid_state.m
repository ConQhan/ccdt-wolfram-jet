function fs = new_fluid_state(p, T, rho, h, s, a, z)
%NEW_FLUID_STATE core/station.py :: FluidState dataclass portu.
%   Bir noktadaki termodinamik durum (statik veya total).
%   a, z Python'da Optional[float] (None olabilir) -- MATLAB'de bos
%   dizi [] ile temsil ediliyor.

if nargin < 1 || isempty(p); p = 0.0; end
if nargin < 2 || isempty(T); T = 0.0; end
if nargin < 3 || isempty(rho); rho = 0.0; end
if nargin < 4 || isempty(h); h = 0.0; end
if nargin < 5 || isempty(s); s = 0.0; end
if nargin < 6; a = []; end
if nargin < 7; z = []; end

fs.p = p;
fs.T = T;
fs.rho = rho;
fs.h = h;
fs.s = s;
fs.a = a;
fs.z = z;

end
