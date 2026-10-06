function le = leading_edge_blade_angles(Cm1, Cu1, omega, r1h, r1m, r1s, i1_deg)
%LEADING_EDGE_BLADE_ANGLES Hucum kenari kanat acilari (Aungier Bolum 6 SS5.2, SS3.4).
%   Akis acilari beta_f(r) = atan2(Cm1, omega*r - Cu1) (tegetten).
%   Kanat acisi hub'dan shroud'a DOGRUSAL; iki kosul:
%     - ortalama hatta hucum i1:      (bb_h + bb_s)/2 = bf_m + i1
%     - shroud hucumu = %25 hub hucumu: bb_s - bf_s = 0.25*(bb_h - bf_h)
%   => bb_h = [2(bf_m + i1) - bf_s + 0.25 bf_h] / 1.25
%   i1 varsayilan 0 (Bolum 6 SS3.4); tikanma payi icin artirilabilir (Eq 6-15 amaci).

if nargin < 7 || isempty(i1_deg); i1_deg = 0.0; end
bf = @(r) atan2d(Cm1, omega * r - Cu1);
le.flow_hub = bf(r1h); le.flow_mean = bf(r1m); le.flow_shroud = bf(r1s);
le.blade_hub = (2 * (le.flow_mean + i1_deg) - le.flow_shroud + 0.25 * le.flow_hub) / 1.25;
le.blade_shroud = le.flow_shroud + 0.25 * (le.blade_hub - le.flow_hub);
le.blade_mean = 0.5 * (le.blade_hub + le.blade_shroud);
le.i1_deg = i1_deg;

end
