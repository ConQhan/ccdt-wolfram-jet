function r4 = vaneless_diffuser_exit_radius(r2, phi, r_max)
%VANELESS_DIFFUSER_EXIT_RADIUS design/diffuser_sizing.py :: vaneless_diffuser_exit_radius() portu.
%   Eq. (6-23): r4 = (1.55+phi)*r2   (maksimum (casing) yaricap verilmemisse).
%
%   r_max verilirse (kasing kisiti), DOGRUDAN r_max kullanilir (kitap:
%   "If the maximum (casing) radius has been specified, it is used to
%   compute the discharge radius with allowance for the crossover or
%   volute to follow" -- bu basit preliminary design adiminda crossover/
%   volut payi [BASITLESTIRME] olarak r_max'in kendisine esitleniyor).

if nargin >= 3 && ~isempty(r_max)
    r4 = r_max;
    return;
end
r4 = (1.55 + phi) * r2;

end
