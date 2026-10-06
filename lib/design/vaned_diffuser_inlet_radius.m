function r3 = vaned_diffuser_inlet_radius(r2, alpha3_deg, M2)
%VANED_DIFFUSER_INLET_RADIUS design/diffuser_sizing.py :: vaned_diffuser_inlet_radius() portu.
%   Eq. (6-25): r3/r2 = 1 + alpha3/360 + M2^2/15.

r3 = r2 * (1.0 + alpha3_deg / 360.0 + M2^2 / 15.0);

end
