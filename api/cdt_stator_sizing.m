function out = cdt_stator_sizing(st, in)
%CDT_STATOR_SIZING 1D sizing of vaned diffuser + 90 deg bend + axial guide vanes.
%   out = cdt_stator_sizing(st, in) sizes the stator downstream of an
%   impeller whose exit state is given in ST (see cdt_default_stator_inputs).
%   IN supplies the gas properties (cdt_default_inputs).
%
%   Method (angles from tangential in the radial diffuser, from axial in
%   the guide vanes):
%     2 -> 3  vaneless gap, r3 from Aungier Eq 6-25
%     3 -> 4  vaned diffuser: exit flow angle alpha4 is chosen; continuity
%             and r*Cu give C4; blade angle beta4 = alpha4 + Carter deviation;
%             throat passes the impeller choke flow (purpose of Eq 6-15);
%             2*theta_C <= limit (Eq 6-26), loading L <= limit (Eq 6-27)
%     4 -> 5  90 deg bend at the hub radius r4, r*Cu conserved
%     5 -> 6  guide vane row(s), de Haller C_out/C_in >= limit per row
%     6 -> 7  annular expansion to the target axial velocity
%
%   out fields:
%     table    - every combination that meets all limits, sorted by
%                (guide vane rows, outer diameter)
%     station3 - vaneless gap exit: r3, Cu3, Cm3, alpha3, Mach, throat area
%     best     - first row of the table (fewest rows, smallest diameter)

eos = cdt_eos(in);
g = eos.gamma; R = eos.R; cp = eos.cp;
mdot = st.mdot;
r2 = st.r2_mm * 1e-3; b2 = st.b2_mm * 1e-3;
t_le = st.t_le_mm * 1e-3;

% --- 2 -> 3 vaneless gap
s2 = new_station_state('2');
s2.geom = new_geometry(); s2.geom.r = r2; s2.geom.b = b2;
s2.vel = new_velocity_triangle(); s2.vel.Cu = st.Cu2; s2.vel.Cm = st.Cm2;
s2.static = new_fluid_state(st.p2, st.T2); s2.mass_flow = mdot;
C2 = hypot(st.Cm2, st.Cu2);
M2 = C2 / eos_speed_of_sound(eos, st.p2, st.T2);
alpha2 = atand(st.Cm2 / st.Cu2);
r3 = r2 * (1 + alpha2 / 360 + M2^2 / 15);
b3 = b2;
s3 = vaneless_diffuser_compute(eos, struct('r4_m', r3, 'b4_m', b3), s2);
Cu3 = s3.vel.Cu; Cm3 = s3.vel.Cm; C3 = s3.vel.C;
alpha3 = atand(Cm3 / Cu3);
pt3 = s3.total.p; Tt3 = s3.total.T;
Gstar = pt3 / sqrt(R * Tt3) * sqrt(g) * (2 / (g + 1))^((g + 1) / (2 * (g - 1)));
A_th = st.mdot_choke / Gstar / 0.97;
out.station3 = struct('r3_mm', r3 * 1e3, 'Cu3', Cu3, 'Cm3', Cm3, 'C3', C3, 'alpha3_deg', alpha3, ...
    'Mach3', C3 / s3.static.a, 'throat_area_mm2', A_th * 1e6, 'M2', M2, 'alpha2_deg', alpha2);

rows = {};
for z = st.z_vanes
    beta3 = asind((A_th / b3 + z * t_le) / (2 * pi * r3));
    for r4 = st.r4_mm * 1e-3
        for alpha4 = st.alpha4_deg
            % station 4: continuity + r*Cu, density by iteration
            pt4 = pt3 * (1 - st.loss_coef);
            Cm4 = Cm3 * r3 / r4;
            for it = 1:30
                Cu4 = Cm4 / tand(alpha4); C4 = hypot(Cm4, Cu4);
                T4 = Tt3 - C4^2 / (2 * cp); p4 = pt4 * (T4 / Tt3)^(g / (g - 1)); rho4 = p4 / (R * T4);
                Cm4 = mdot / (rho4 * 2 * pi * r4 * b3 * (1 - st.blockage_exit));
            end
            % vane geometry, Carter deviation
            LB = (r4 - r3) / sind(0.5 * (beta3 + alpha4 + 5));
            s_m = 2 * pi * 0.5 * (r3 + r4) / z; sigma = LB / s_m;
            beta4 = alpha4;
            for k = 1:20; beta4 = alpha4 + st.carter_m * (beta4 - beta3) / sqrt(sigma); end
            LB = (r4 - r3) / sind(0.5 * (beta3 + beta4)); sigma = LB / s_m;
            tth = atand(pi * (r4 * sind(beta4) - r3 * sind(beta3)) / (z * LB));   % Eq 6-26
            L = 2 * pi * (r3 * Cu3 - r4 * Cu4) / (z * LB * (C3 - C4));            % Eq 6-27
            if 2 * tth > st.two_theta_max || L > st.loading_max; continue; end
            best = cdt_guide_vanes(st, r4, rho4, Cu4);
            if isempty(best); continue; end
            rows(end + 1, :) = {z, r4 * 1e3, beta3, beta3 - alpha3, beta4, alpha4, 2 * tth, L, sigma, ...
                LB * 1e3, Cu4, Cm4, C4, C4 / C3, best{:}}; %#ok<AGROW>
        end
    end
end
names = {'vanes', 'r4_mm', 'beta3_deg', 'incidence3_deg', 'beta4_deg', 'alpha4_deg', 'two_theta_deg', ...
    'loading', 'solidity', 'vane_length_mm', 'Cu4', 'Cm4', 'C4', 'C4_over_C3', 'guide_rows', 'annulus_h_mm', ...
    'Cx5', 'Cu5', 'guide_in_deg_axial', 'guide_out_deg_axial', 'de_haller', 'outer_diameter_mm'};
if isempty(rows)
    out.table = cell2table(cell(0, numel(names)), 'VariableNames', names);
    out.best = out.table;
    return;
end
T = cell2table(rows, 'VariableNames', names);
out.table = sortrows(T, {'guide_rows', 'outer_diameter_mm'});
out.best = out.table(1, :);
end

function best = cdt_guide_vanes(st, r4, rho4, Cu4)
% Smallest annulus that keeps every guide-vane row above the de Haller limit
best = {};
for nrow = 1:st.max_rows
    for h5 = st.annulus_height_mm * 1e-3
        rm5 = r4 + h5 / 2;
        A5 = pi * ((r4 + h5)^2 - r4^2);
        Cx5 = st.mdot / (rho4 * A5);
        Cu5 = Cu4 * r4 / rm5;
        Cu_rows = Cu5 * (st.Cu_out / Cu5) .^ ((1:nrow) / nrow);   % equal ratio per row
        Cin = [Cu5, Cu_rows(1:end - 1)];
        dH = min(hypot(Cu_rows, Cx5) ./ hypot(Cin, Cx5));
        if dH >= st.de_haller_min
            A7 = st.mdot / (rho4 * 1.02 * st.Cx_out);
            rt7 = sqrt(r4^2 + A7 / pi);
            OD = max(2 * rt7, 2 * (r4 + h5)) * 1e3;
            best = {nrow, h5 * 1e3, Cx5, Cu5, atand(Cu5 / Cx5), atand(st.Cu_out / Cx5), dH, OD};
            return;
        end
    end
end
end
