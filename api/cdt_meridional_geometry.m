function geo = cdt_meridional_geometry(det)
%CDT_MERIDIONAL_GEOMETRY Meridional (z, r) outline of a MATLAB design.
%   geo = cdt_meridional_geometry(det) builds the outline used by
%   cdt_plot_meridional from the Aungier blade distribution in DET.
%   All coordinates are in mm, z measured from the blade leading edge.
%
%   geo fields: hub_z/hub_r, shroud_z/shroud_r (impeller + vaneless
%   diffuser), LE_hub, LE_shroud, TE_hub, TE_shroud, splitter_hub,
%   splitter_shroud ([r z] pairs), r2, r4, b2, tip_gap, source.

bd = det.blade;
d = det.design;
g = d.impeller_geometry;
dg = d.diffuser_geometry;

hz = bd.hub.z(:) * 1e3;  hr = bd.hub.r(:) * 1e3;
sz = bd.shroud.z(:) * 1e3; sr = bd.shroud.r(:) * 1e3;

% Vaneless diffuser: straight radial walls from r2 to r4, width b2 -> b4
r2 = g.r2_m * 1e3;
r4 = dg.r4_m * 1e3;
b2 = g.b2_m * 1e3;
b4 = dg.b4_m * 1e3;
zmid = 0.5 * (hz(end) + sz(end));
rd = linspace(r2, r4, 20)';
bw = b2 + (b4 - b2) * (rd - r2) / (r4 - r2);
geo.hub_z = [hz; zmid + bw(2:end) / 2];
geo.hub_r = [hr; rd(2:end)];
geo.shroud_z = [sz; zmid - bw(2:end) / 2];
geo.shroud_r = [sr; rd(2:end)];

geo.LE_hub = [hr(1) hz(1)];
geo.LE_shroud = [sr(1) sz(1)];
geo.TE_hub = [hr(end) hz(end)];
geo.TE_shroud = [sr(end) sz(end)];

% Splitter leading edge at (1 - splitter ratio) of the meridional length
f = 1 - g.splitter_length_ratio;
geo.splitter_hub = [interp1(bd.hub.zeta, hr, f), interp1(bd.hub.zeta, hz, f)];
geo.splitter_shroud = [interp1(bd.shroud.zeta, sr, f), interp1(bd.shroud.zeta, sz, f)];

geo.r2 = r2;
geo.r4 = r4;
geo.b2 = b2;
geo.tip_gap = 0;
if isfield(g, 'tip_clearance_m'); geo.tip_gap = g.tip_clearance_m * 1e3; end
geo.source = 'MATLAB design';
end
