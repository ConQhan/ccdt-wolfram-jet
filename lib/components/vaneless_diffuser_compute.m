function station4 = vaneless_diffuser_compute(eos, geometry, inlet_station)
%VANELESS_DIFFUSER_COMPUTE components/vaneless_diffuser.py :: VanelessDiffuser.compute() portu.
%   Eq. (5-44) -> (5-61)'i zincirleyen vanesiz difuzor analizi --
%   core/marching.py'deki march_vaneless_passage() cozucusunu
%   StationState girdi/cikti arayuzune baglar.

g = geometry;

r_in = inlet_station.geom.r;
b_in = inlet_station.geom.b;
Cm_in = inlet_station.vel.Cm;
Cu_in = inlet_station.vel.Cu;
p_in = inlet_station.static.p;
T_in = inlet_station.static.T;
mdot = inlet_station.mass_flow;

r_out = g.r4_m;
b_out = g.b4_m;
roughness_m = struct_get(g, 'roughness_m', 1.0e-6);
mu = struct_get(g, 'mu_Pa_s', 1.8e-5);
kappa_m = struct_get(g, 'kappa_m_per_m', 0.0);
delta_in = struct_get(g, 'inlet_boundary_layer_thickness_m', []);
n_steps = struct_get(g, 'n_marching_steps', 150);

result = march_vaneless_passage(mdot, r_in, r_out, b_in, b_out, Cm_in, Cu_in, ...
    p_in, T_in, eos, mu, roughness_m, delta_in, kappa_m, 1.0, n_steps, 6);
outlet = result.stations(end);

station4 = new_station_state('4');
station4.geom = new_geometry();
station4.geom.r = outlet.r; station4.geom.b = outlet.b;
station4.geom.area = 2.0 * pi * outlet.r * outlet.b;
station4.geom.blockage = outlet.B;

station4.vel = new_velocity_triangle();
station4.vel.Cm = outlet.Cm; station4.vel.Cu = outlet.Cu; station4.vel.C = outlet.C;
station4.vel.alpha = atan2(outlet.Cm, outlet.Cu);

station4.total = new_fluid_state(outlet.pt, vaneless_diffuser_total_temperature(eos, outlet.T, outlet.C));
station4.static = new_fluid_state(outlet.p, outlet.T, outlet.rho, [], [], eos_speed_of_sound(eos, outlet.p, outlet.T));

station4.mass_flow = mdot;
station4.angular_momentum = outlet.r * outlet.Cu;
station4.loss_total_pressure = result.omega_total;

station4.march_result = result;

end
