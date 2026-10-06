function T = cdt_cfturbo_inputs(in, det)
%CDT_CFTURBO_INPUTS Screen-by-screen CFturbo input values for one design.
%   T = cdt_cfturbo_inputs(in, det) returns a table with columns
%   screen / field / value / unit / note. DET comes from cdt_design_details.
%
%   CFturbo builds its velocity triangles from the pressure ratio and
%   efficiency entered on the setup screens. Entering the IMPELLER values
%   (not the stage values) makes CFturbo see the same specific work as the
%   MATLAB model.

d = det.design;
g = d.impeller_geometry;
bd = det.blade;
im = det.impeller;
yesno = {'no', 'yes'};

r = {
    'Global setup', 'Mass flow', in.mdot, 'kg/s', ''
    'Global setup', 'Total pressure ratio (impeller)', im.PR_tt, '-', 'impeller exit / inlet'
    'Global setup', 'Speed', in.N_rpm, 'rpm', ''
    'Global setup', 'Inlet total pressure', in.p0 / 1e5, 'bar', ''
    'Global setup', 'Inlet total temperature', in.T0 - 273.15, 'degC', 'no pre-swirl'
    'Main dimensions > Parameters', 'Total-to-total efficiency (impeller)', 100 * im.eta_tt, '%', ''
    'Main dimensions', 'Unshrouded', NaN, yesno{1 + strcmp(in.impeller_type, 'open')}, ''
    'Main dimensions', 'Tip clearance (in = out)', in.tip_clearance_mm, 'mm', ''
    'Main dimensions (manual)', 'Hub diameter dH', 2 * g.r1_hub_m * 1e3, 'mm', ''
    'Main dimensions (manual)', 'Shroud diameter dS', 2 * g.r1_shroud_m * 1e3, 'mm', ''
    'Main dimensions (manual)', 'Tip diameter d2', 2 * g.r2_m * 1e3, 'mm', ''
    'Main dimensions (manual)', 'Exit width b2', g.b2_m * 1e3, 'mm', ''
    'Meridional contour', 'Axial extension', g.axial_length_z_m * 1e3, 'mm', 'Aungier Eq 6-3'
    'Blade setup', 'Number of blades (main + splitter)', g.n_blades_full + g.n_blades_splitter, '-', 'splitter linked'
    'Blade setup', 'Blade shape', NaN, 'Ruled surface 3D', ''
    'Blade angles', 'betaB1 hub', bd.beta1.blade_hub, 'deg', 'from tangential'
    'Blade angles', 'betaB1 shroud', bd.beta1.blade_shroud, 'deg', 'from tangential'
    'Blade angles', 'betaB2 hub = shroud', g.blade_angle_2_deg, 'deg', 'ruled blade: one TE angle (Eq 6-17)'
    'Blade mean lines', 'Wrap angle (hub TE)', det.wrap.TE_dphi_deg(1), 'deg', 'see wrap table'
    'Blade mean lines', 'Rake angle LE', bd.rake_LE_deg, 'deg', ''
    'Blade mean lines', 'Rake angle TE', bd.rake_TE_deg, 'deg', ''
    'Blade mean lines', 'Splitter LE position', 100 * (1 - g.splitter_length_ratio), '%', 'relative to main blade'
    'Blade properties', 'LE thickness hub', g.blade_le_thickness_hub_m * 1e3, 'mm', ''
    'Blade properties', 'LE thickness shroud', g.blade_le_thickness_shroud_m * 1e3, 'mm', ''
    };
T = cell2table(r, 'VariableNames', {'screen', 'field', 'value', 'unit', 'note'});
end
