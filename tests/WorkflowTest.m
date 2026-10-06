classdef WorkflowTest < matlab.unittest.TestCase
    %WORKFLOWTEST Regression tests of the design workflow.
    %   Reference values come from the original project scripts
    %   (parametrik_tasarim_0D_1D.m, 2026-10-06) for the V2 locked point:
    %   0.54 kg/s, 70 000 rpm, r2 = 66 mm, r1 hub = 8 mm, open impeller.
    %   Run with: runtests('tests')

    methods (TestClassSetup)
        function addPaths(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'lib'), ...
                'IncludingSubfolders', true));
            tc.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(root, 'api')));
        end
    end

    methods (Test)
        function v2LockedPointAungierB2(tc)
            in = cdt_default_inputs();
            in.mdot = 0.54;
            r = cdt_evaluate_point(in, 66, 8);
            tc.verifyTrue(r.feasible);
            tc.verifyEqual(r.row.b2_mm, 3.8217, 'AbsTol', 1e-3);
            tc.verifyEqual(r.row.beta2_deg, 56.336, 'AbsTol', 1e-2);
            tc.verifyEqual(r.row.PR_diffuser, 3.84574, 'AbsTol', 1e-4);
            tc.verifyEqual(r.row.eta_tt_pct, 81.2591, 'AbsTol', 1e-3);
            tc.verifyEqual(r.row.power_kW, 90.332, 'AbsTol', 1e-2);
        end

        function fixedB2DesignPoint(tc)
            in = cdt_default_inputs();
            in.b2_mm = 5.41;
            r = cdt_evaluate_point(in, 66, 8);
            tc.verifyEqual(r.row.b2_mm, 5.41, 'AbsTol', 1e-9);
            tc.verifyEqual(r.row.beta2_deg, 46.975, 'AbsTol', 1e-2);
            tc.verifyEqual(r.row.PR_diffuser, 3.72677, 'AbsTol', 1e-4);
        end

        function detailsAndCfturboInputs(tc)
            in = cdt_default_inputs();
            in.mdot = 0.54;
            r = cdt_evaluate_point(in, 66, 8);
            det = cdt_design_details(in, r.design);
            tc.verifyEqual(det.wrap.TE_dphi_deg(1), 83.0, 'AbsTol', 0.1);   % V2 CFturbo wrap angle
            tc.verifyEqual(height(det.checks), 9);
            tc.verifyTrue(all(ismember(det.checks.status, ["PASS", "MARGINAL", "FAIL"])));
            T = cdt_cfturbo_inputs(in, det);
            dS = T.value(T.field == "Shroud diameter dS");
            tc.verifyEqual(dS, 65.876, 'AbsTol', 1e-2);
        end

        function statorSizingMatchesV3Script(tc)
            % Reference: V3_stator_onboyutlandirma.m (54 combinations; first
            % row 31 vanes, r4 = 96 mm, beta4 = 43.18 deg, OD = 212.8 mm)
            out = cdt_stator_sizing(cdt_default_stator_inputs(), cdt_default_inputs());
            tc.verifyEqual(height(out.table), 54);
            tc.verifyEqual(out.best.vanes, 31);
            tc.verifyEqual(out.best.r4_mm, 96);
            tc.verifyEqual(out.best.beta4_deg, 43.184, 'AbsTol', 1e-3);
            tc.verifyEqual(out.best.outer_diameter_mm, 212.84, 'AbsTol', 1e-2);
            tc.verifyEqual(out.station3.r3_mm, 73.43, 'AbsTol', 1e-2);
        end

        function mapDesignSpeedLine(tc)
            in = cdt_default_inputs();
            in.mdot = 0.54;
            r = cdt_evaluate_point(in, 66, 8);
            mp = cdt_compressor_map(in, r.design, 1.0, [0.6 0.8 1.0]);
            p = mp.points(abs(mp.points.mdot - 0.54) < 1e-9, :);
            tc.verifyEqual(p.PR_tt, 3.84574, 'AbsTol', 1e-4);   % same point as the sweep
            tc.verifyTrue(all(mp.points.valid));
        end

        function readsCfturboExport(tc)
            % Set the environment variable CDT_CFTURBO_EXPORT to a CFturbo
            % export folder (...\dp0\CFT) with one impeller and two stator exports.
            folder = getenv('CDT_CFTURBO_EXPORT');
            tc.assumeTrue(~isempty(folder) && isfolder(folder), 'CDT_CFTURBO_EXPORT not set');
            comps = cdt_read_cfturbo_export(folder);
            tc.verifyEqual(numel(comps), 3);
            chk = cdt_cfturbo_check(comps);
            tc.verifyEqual(chk.components.n_blades', [20 20 31 31]);
            tc.verifyTrue(all(chk.interfaces.coincide));
        end

        function sweepSelectsFeasibleMaximum(tc)
            in = cdt_default_inputs();
            in.mdot = 0.54;
            in.r2_mm = [64 66];
            in.r1_hub_mm = [8 9];
            sw = cdt_run_sweep(in);
            tc.verifyEqual(height(sw.table), 4);
            ok = sw.table.feasible;
            tc.assumeTrue(any(ok));
            tc.verifyEqual(sw.table.eta_tt_pct(sw.selected), max(sw.table.eta_tt_pct(ok)));
        end
    end
end
