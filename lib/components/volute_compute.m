function station7 = volute_compute(eos, geometry, inlet_station)
%VOLUTE_COMPUTE components/volute.py :: Volute.compute() portu.
%   Eq. (5-105) -> (5-110)'u zincirleyen volut/collector analizi.
%   IKI ASAMALI cozum: once C6 (tam-toplama duzlemi) icin fzero, sonra
%   C7 (exit cone cikisi) icin ayri bir fzero.

g = geometry;

r5 = inlet_station.geom.r;
Cm5 = inlet_station.vel.Cm;
Cu5 = inlet_station.vel.Cu;
C5 = hypot(Cm5, Cu5);
p5 = inlet_station.static.p;
T5 = inlet_station.static.T;
mdot_target = inlet_station.mass_flow;

pt5_state = eos_total_from_static(eos, p5, T5, C5);
pt5 = pt5_state.p; Tt5 = pt5_state.T;

A6 = g.A6_m2;
r6 = g.r6_m;
A7 = struct_get(g, 'A7_m2', A6);
cf_override = struct_get(g, 'skin_friction_cf', []);
mu = struct_get(g, 'mu_Pa_s', 1.8e-5);
roughness_m = struct_get(g, 'roughness_m', 1.0e-6);
rho5 = eos_density(eos, p5, T5);
is_collector = struct_get(g, 'is_collector', false);

omega_m = meridional_velocity_head_loss(Cm5, C5);

last6_SP = []; last6_omega_U = []; last6_omega_SF = []; last6_sum3 = []; %#ok<NASGU>
last6_pt6 = []; last6_static6 = []; last6_mdot_calc = [];

    function r = residual_C6(C6)
        SP_ = volute_sizing_parameter(r5, Cu5, r6, C6);
        omega_U_ = tangential_velocity_head_loss(r5, Cu5, r6, C5, SP_);
        if is_collector
            omega_U_ = collector_correction(omega_U_);
        end

        if ~isempty(cf_override)
            cf = cf_override;
        else
            d_H = volute_hydraulic_diameter(A6);
            Re_d = reynolds_number(rho5, C6, d_H, mu);
            cf = skin_friction_coefficient(Re_d, roughness_m, d_H);
        end
        omega_SF_ = volute_skin_friction_loss(cf, C6, C5, r5, r6, A6);

        sum3_ = omega_m + omega_U_ + omega_SF_;
        pt6_ = pt5 - (pt5 - p5) * sum3_;
        static6_ = eos_static_from_total(eos, pt6_, Tt5, C6);
        rho6_ = static6_.rho;
        mdot_calc_ = rho6_ * C6 * A6;

        last6_SP = SP_; last6_omega_U = omega_U_; last6_omega_SF = omega_SF_;
        last6_sum3 = sum3_; last6_pt6 = pt6_; last6_static6 = static6_; last6_mdot_calc = mdot_calc_;

        r = mdot_calc_ - mdot_target;
    end

    function tf = validity_C6()
        if isempty(last6_sum3)
            tf = false;
        else
            tf = last6_sum3 < 1.0;
        end
    end

C6_lo = 0.05 * C5;
C6_hi = 3.0 * C5;
C6_solution = volute_bracket_and_solve(@residual_C6, C6_lo, C6_hi, 'C6 (tam-toplama duzlemi)', @validity_C6);
residual_C6(C6_solution);
sum3 = last6_sum3;
SP_final = last6_SP;

last7_omega_EC = []; last7_sum_total = []; last7_pt7 = []; last7_static7 = []; last7_mdot_calc = [];

    function r = residual_C7(C7)
        omega_EC_ = exit_cone_loss(C6_solution, C7, C5);
        sum_total_ = sum3 + omega_EC_;
        pt7_ = pt5 - (pt5 - p5) * sum_total_;
        static7_ = eos_static_from_total(eos, pt7_, Tt5, C7);
        rho7_ = static7_.rho;
        mdot_calc_ = rho7_ * C7 * A7;

        last7_omega_EC = omega_EC_; last7_sum_total = sum_total_;
        last7_pt7 = pt7_; last7_static7 = static7_; last7_mdot_calc = mdot_calc_;

        r = mdot_calc_ - mdot_target;
    end

    function tf = validity_C7()
        if isempty(last7_sum_total)
            tf = false;
        else
            tf = last7_sum_total < 1.0;
        end
    end

C7_lo = 0.05 * C5;
C7_hi = 3.0 * C5;
C7_solution = volute_bracket_and_solve(@residual_C7, C7_lo, C7_hi, 'C7 (exit cone cikisi)', @validity_C7);
residual_C7(C7_solution);

station7 = new_station_state('7');
station7.geom = new_geometry();
station7.geom.r = r6; station7.geom.area = A7;

station7.vel = new_velocity_triangle();
station7.vel.Cm = 0.0; station7.vel.Cu = 0.0; station7.vel.C = C7_solution;

station7.total = new_fluid_state(last7_pt7, Tt5);
station7.static = new_fluid_state(last7_static7.p, last7_static7.T, last7_static7.rho, [], [], last7_static7.a);

station7.mass_flow = last7_mdot_calc;
station7.angular_momentum = 0.0;
station7.loss_total_pressure = last7_sum_total;

station7.volute_C6 = C6_solution;
station7.volute_SP = SP_final;

end
