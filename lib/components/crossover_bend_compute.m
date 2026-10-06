function station6 = crossover_bend_compute(eos, geometry, inlet_station)
%CROSSOVER_BEND_COMPUTE components/crossover_bend.py :: CrossoverBend.compute() portu.
%   Eq. (5-44) -> (5-61)'i kappa_m~=0 ile kullanan crossover bend analizi
%   (ICE akis, r6<r4/r5 -- march_vaneless_passage'in yon-genellestirmesi
%   bunu otomatik yakalar).

g = geometry;

r_in = inlet_station.geom.r;
b_in = inlet_station.geom.b;
Cm_in = inlet_station.vel.Cm;
Cu_in = inlet_station.vel.Cu;
p_in = inlet_station.static.p;
T_in = inlet_station.static.T;
mdot = inlet_station.mass_flow;

r_out = g.r6_m;
b_out = g.b6_m;
roughness_m = struct_get(g, 'roughness_m', 1.0e-6);
mu = struct_get(g, 'mu_Pa_s', 1.8e-5);
delta_in = struct_get(g, 'inlet_boundary_layer_thickness_m', []);
n_steps = struct_get(g, 'n_marching_steps', 150);
sin_alpha_C = struct_get(g, 'sin_alpha_C', 0.65);  % [BASITLESTIRME] -- bkz Python modul basi notu

kappa_m = struct_get(g, 'kappa_m_per_m', []);
if isempty(kappa_m)
    R_ch = struct_get(g, 'R_ch_m', []);
    if isempty(R_ch) || R_ch <= 0.0
        error('centrifugal:crossover_bend_compute', ...
            ['CrossoverBend: ''kappa_m_per_m'' veya pozitif bir ''R_ch_m'' ' ...
             '(Eq 6-30, hub egrilik yaricapi) verilmelidir.']);
    end
    kappa_m = 1.0 / R_ch;
end

result = march_vaneless_passage(mdot, r_in, r_out, b_in, b_out, Cm_in, Cu_in, ...
    p_in, T_in, eos, mu, roughness_m, delta_in, kappa_m, sin_alpha_C, n_steps, 6);
outlet = result.stations(end);

station6 = new_station_state('6');
station6.geom = new_geometry();
station6.geom.r = outlet.r; station6.geom.b = outlet.b;
station6.geom.area = 2.0 * pi * outlet.r * outlet.b;
station6.geom.blockage = outlet.B;

station6.vel = new_velocity_triangle();
station6.vel.Cm = outlet.Cm; station6.vel.Cu = outlet.Cu; station6.vel.C = outlet.C;
station6.vel.alpha = atan2(outlet.Cm, outlet.Cu);

station6.total = new_fluid_state(outlet.pt, vaneless_diffuser_total_temperature(eos, outlet.T, outlet.C));
station6.static = new_fluid_state(outlet.p, outlet.T, outlet.rho, [], [], eos_speed_of_sound(eos, outlet.p, outlet.T));

station6.mass_flow = mdot;
station6.angular_momentum = outlet.r * outlet.Cu;
station6.loss_total_pressure = result.omega_total;

station6.march_result = result;

end
