classdef CompressorDesignApp < handle
    %COMPRESSORDESIGNAPP Graphical front end of the compressor design tool.
    %   app = CompressorDesignApp opens the window. Start it with launch.m.
    %
    %   Workflow (one tab per step):
    %     1 Inputs        - operating point, geometry limits, sweep grid
    %     2 Sweep         - r2 x r1_hub sweep, plots, click a row to select
    %     3 Design point  - summary, stations, Aungier checklist
    %     4 Blade         - blade angle / wrap distributions, meridional view
    %     5 CFturbo       - screen-by-screen CFturbo inputs and wrap table
    %     6 CFturbo export- read the TurboGrid export, check edges, gaps and
    %                       interfaces, compare with the MATLAB design
    %     7 Stator        - vaned diffuser + bend + guide vane 1D sizing
    %     8 Map           - off-design speed lines of the selected design
    %
    %   The app only calls the functions in api/; every result can also be
    %   produced from a script (see examples/run_design_point.m).

    properties (Access = public)
        Figure matlab.ui.Figure
    end

    properties (Access = private)
        Tabs
        StatusLabel
        Fields = struct()          % input field handles, one per input
        SweepAxes
        SweepTable
        SummaryTable
        StationTable
        ChecksTable
        BladeAxes
        MeridionalAxes
        MeridionalMode
        CfturboTable
        WrapTable
        Sweep = []                 % last cdt_run_sweep result
        Details = []               % last cdt_design_details result
        Inputs                     % inputs used by the last sweep
        CancelButton
        RunButton
        CancelFlag = false
        ExportFolderField
        ExportAxes
        ExportCompTable
        ExportIfaceTable
        ExportCompareTable
        ExportWarnings
        Export = []                % struct('comps', .., 'chk', ..)
        StatorFields = struct()
        Stator3Table
        StatorTable
        StatorNote
        Stator = []
        MapSpeedField
        MapFlowField
        MapAxes
        MapLinesTable
        Map = []
    end

    properties (Constant, Access = private)
        % {field, label, group, kind}; kind: 'num' | 'range' | 'list:a,b'
        Specs = {
            'mdot',                   'Mass flow [kg/s]',                  'Operating point', 'num'
            'N_rpm',                  'Speed [rpm]',                       'Operating point', 'num'
            'p0',                     'Inlet total pressure [Pa]',         'Operating point', 'num'
            'T0',                     'Inlet total temperature [K]',       'Operating point', 'num'
            'R',                      'Gas constant R [J/kg K]',           'Gas',             'num'
            'gamma',                  'Heat capacity ratio [-]',           'Gas',             'num'
            'cp',                     'cp [J/kg K]',                       'Gas',             'num'
            'impeller_type',          'Impeller',                          'Machine',         'list:open,covered'
            'n_blades_main',          'Main blades (+ same splitters)',    'Machine',         'num'
            'splitter_ratio',         'Splitter length ratio [-]',         'Machine',         'num'
            'tip_clearance_mm',       'Tip clearance [mm]',                'Machine',         'num'
            'le_thickness_hub_mm',    'LE thickness hub [mm]',             'Machine',         'num'
            'le_thickness_shroud_mm', 'LE thickness shroud [mm]',          'Machine',         'num'
            'b2_mm',                  'b2 [mm] (NaN = Aungier)',           'Machine',         'num'
            'r2_mm',                  'r2 values [mm]',                    'Sweep grid',      'range'
            'r1_hub_mm',              'r1 hub values [mm]',                'Sweep grid',      'range'
            'PR_min',                 'Minimum PR after bend [-]',         'Selection',       'num'
            'zeta_bend',              'Exit bend loss coefficient [-]',    'Selection',       'num'
            'r_max_mm',               'Casing radius limit [mm]',          'Selection',       'num'
            'blade_loading_max',      'Blade loading limit dW/W [-]',      'Selection',       'num'
            'shaft_tau_MPa',          'Shaft allowable shear [MPa]',       'Selection',       'num'
            'shaft_SF',               'Shaft safety factor [-]',           'Selection',       'num'
            }
        StatorSpecs = {
            'mdot',              'Mass flow [kg/s]',                     'num'
            'mdot_choke',        'Impeller choke flow (throat sizing) [kg/s]', 'num'
            'r2_mm',             'Impeller exit radius r2 [mm]',         'num'
            'b2_mm',             'Impeller exit width b2 [mm]',          'num'
            'Cu2',               'Impeller exit Cu2 [m/s] (CFD)',        'num'
            'Cm2',               'Impeller exit Cm2 [m/s] (CFD)',        'num'
            'p2',                'Impeller exit static p2 [Pa] (CFD)',   'num'
            'T2',                'Impeller exit static T2 [K] (CFD)',    'num'
            'Cx_out',            'Target exit axial velocity [m/s]',     'num'
            'Cu_out',            'Target exit tangential velocity [m/s]','num'
            'z_vanes',           'Diffuser vane counts',                 'range'
            'r4_mm',             'Diffuser exit radii [mm]',             'range'
            'alpha4_deg',        'Diffuser exit flow angles [deg]',      'range'
            't_le_mm',           'Vane thickness at throat [mm]',        'num'
            'carter_m',          'Carter deviation constant m [-]',      'num'
            'two_theta_max',     'Max divergence 2*theta [deg]',         'num'
            'loading_max',       'Max vane loading L [-]',               'num'
            'max_rows',          'Max guide vane rows',                  'num'
            'de_haller_min',     'Min de Haller ratio [-]',              'num'
            }
    end

    % ------------------------------------------------------------------
    methods
        function app = CompressorDesignApp()
            app.build();
            app.setInputs(cdt_default_inputs());
            app.setStatorInputs(cdt_default_stator_inputs());
            % The button callbacks hold references to the app object, so the
            % window stays open even when the caller drops the handle.
        end

        function runSweep(app)
            %RUNSWEEP Run the sweep with the current inputs (same as the button).
            try
                in = app.readInputs();
            catch err
                app.showError(err.message);
                return;
            end
            n = numel(in.r2_mm) * numel(in.r1_hub_mm);
            app.CancelFlag = false;
            app.RunButton.Enable = 'off';
            app.CancelButton.Enable = 'on';
            restore = onCleanup(@() app.endRun());
            try
                sw = cdt_run_sweep(in, @(k, n) app.progress(k, n));
            catch err
                if strcmp(err.identifier, 'cdt:cancelled')
                    app.setStatus('Sweep cancelled.');
                else
                    app.showError(['Sweep failed: ' err.message]);
                end
                return;
            end
            app.Inputs = in;
            app.Sweep = sw;
            app.showSweep();
            app.Tabs.SelectedTab = app.Tabs.Children(2);
            if isnan(sw.selected)
                app.setStatus(sprintf('%d points, none feasible. Relax the criteria or change the grid.', n));
            else
                app.selectDesign(sw.selected);
            end
        end
    end

    % ------------------------------------------------------------------
    methods (Access = private)
        function build(app)
            app.Figure = uifigure('Name', 'Centrifugal Compressor Design Tool', ...
                'Position', [60 60 1400 860]);
            root = uigridlayout(app.Figure, [3 1], 'RowHeight', {36, '1x', 22}, 'Padding', [6 6 6 6]);

            bar = uigridlayout(root, [1 7], 'ColumnWidth', {130, 90, 130, 130, 130, 130, '1x'}, 'Padding', [0 0 0 0]);
            app.RunButton = uibutton(bar, 'Text', 'Run sweep', 'FontWeight', 'bold', ...
                'BackgroundColor', [0.85 0.92 1], 'ButtonPushedFcn', @(~, ~) app.runSweep());
            app.CancelButton = uibutton(bar, 'Text', 'Cancel', 'Enable', 'off', ...
                'ButtonPushedFcn', @(~, ~) app.requestCancel());
            uibutton(bar, 'Text', 'Export results', 'ButtonPushedFcn', @(~, ~) app.onExport());
            uibutton(bar, 'Text', 'Save inputs...', 'ButtonPushedFcn', @(~, ~) app.onSaveInputs());
            uibutton(bar, 'Text', 'Load inputs...', 'ButtonPushedFcn', @(~, ~) app.onLoadInputs());
            uibutton(bar, 'Text', 'Reset defaults', 'ButtonPushedFcn', @(~, ~) app.setInputs(cdt_default_inputs()));

            app.Tabs = uitabgroup(root);
            app.buildInputsTab(uitab(app.Tabs, 'Title', '1  Inputs'));
            app.buildSweepTab(uitab(app.Tabs, 'Title', '2  Sweep'));
            app.buildDesignTab(uitab(app.Tabs, 'Title', '3  Design point'));
            app.buildBladeTab(uitab(app.Tabs, 'Title', '4  Blade & meridional'));
            app.buildCfturboTab(uitab(app.Tabs, 'Title', '5  CFturbo inputs'));
            app.buildExportTab(uitab(app.Tabs, 'Title', '6  CFturbo export check'));
            app.buildStatorTab(uitab(app.Tabs, 'Title', '7  Stator sizing'));
            app.buildMapTab(uitab(app.Tabs, 'Title', '8  Compressor map'));

            app.StatusLabel = uilabel(root, 'Text', 'Ready. Set the inputs and press "Run sweep".');
        end

        function buildInputsTab(app, tab)
            groups = unique(app.Specs(:, 3), 'stable');
            g = uigridlayout(tab, [1 numel(groups) + 1], 'ColumnWidth', [repmat({'1x'}, 1, numel(groups)), {300}]);
            for k = 1:numel(groups)
                rows = app.Specs(strcmp(app.Specs(:, 3), groups{k}), :);
                p = uipanel(g, 'Title', groups{k}, 'FontWeight', 'bold');
                n = size(rows, 1);
                pg = uigridlayout(p, [2 * n + 1, 1], 'RowHeight', [repmat({16, 24}, 1, n), {'1x'}], ...
                    'RowSpacing', 4);
                for j = 1:n
                    lb = uilabel(pg, 'Text', rows{j, 2});
                    lb.Layout.Row = 2 * j - 1;
                    kind = rows{j, 4};
                    if startsWith(kind, 'list:')
                        h = uidropdown(pg, 'Items', strsplit(extractAfter(kind, 'list:'), ','));
                    elseif strcmp(kind, 'range')
                        h = uieditfield(pg, 'text', 'Tooltip', 'MATLAB syntax, e.g. 60:1:72 or [62 66 70]');
                    else
                        h = uieditfield(pg, 'numeric', 'AllowEmpty', 'on', 'ValueDisplayFormat', '%.6g');
                    end
                    h.Layout.Row = 2 * j;
                    app.Fields.(rows{j, 1}) = h;
                end
            end
            help = uipanel(g, 'Title', 'How to use', 'FontWeight', 'bold');
            hg = uigridlayout(help, [1 1]);
            uitextarea(hg, 'Editable', 'off', 'Value', {
                '1. Set the operating point and machine data.'
                '2. Set the sweep grid (r2 and r1 hub).'
                '3. Press "Run sweep" (about 1 s per point).'
                '4. Sweep tab: feasible points are filled'
                '   markers; click a table row to select a'
                '   design. The default is the highest'
                '   efficiency among feasible points.'
                '5. Design point / Blade / CFturbo tabs show'
                '   the selected design.'
                '6. "Export results" writes CSV + PNG files'
                '   to the output folder.'
                ''
                'Feasible = PR after bend >= minimum, shaft'
                'margin >= 0, fits the casing and blade'
                'loading below the limit.'
                ''
                'b2 = NaN uses Aungier Eq 6-10; enter a value'
                'to fix b2 (e.g. 5.41 for the V2/V3 design).'});
        end

        function buildSweepTab(app, tab)
            g = uigridlayout(tab, [2 1], 'RowHeight', {'1.4x', '1x'});
            ag = uigridlayout(g, [1 4]);
            app.SweepAxes = gobjects(1, 4);
            for k = 1:4; app.SweepAxes(k) = uiaxes(ag); end
            app.SweepTable = uitable(g, 'SelectionType', 'row', ...
                'CellSelectionCallback', @(~, ev) app.onSweepRowSelected(ev));
        end

        function buildDesignTab(app, tab)
            g = uigridlayout(tab, [2 2], 'ColumnWidth', {'1x', '1.6x'}, 'RowHeight', {'1x', '1x'});
            p = uipanel(g, 'Title', 'Summary');
            p.Layout.Row = [1 2]; p.Layout.Column = 1;
            app.SummaryTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(g, 'Title', 'Stations (total and static state, absolute velocities)');
            p.Layout.Row = 1; p.Layout.Column = 2;
            app.StationTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(g, 'Title', 'Aungier design checklist');
            p.Layout.Row = 2; p.Layout.Column = 2;
            app.ChecksTable = uitable(uigridlayout(p, [1 1]));
        end

        function buildBladeTab(app, tab)
            g = uigridlayout(tab, [1 2], 'ColumnWidth', {'1.2x', '1x'});
            left = uigridlayout(g, [2 1]);
            app.BladeAxes = [uiaxes(left), uiaxes(left)];
            right = uigridlayout(g, [2 1], 'RowHeight', {28, '1x'});
            top = uigridlayout(right, [1 2], 'ColumnWidth', {90, 200}, 'Padding', [0 0 0 0]);
            uilabel(top, 'Text', 'Drawing:');
            app.MeridionalMode = uidropdown(top, 'Items', {'dimensions', 'symbols'}, ...
                'ValueChangedFcn', @(~, ~) app.drawMeridional());
            app.MeridionalAxes = uiaxes(right);
        end

        function buildCfturboTab(app, tab)
            g = uigridlayout(tab, [1 2], 'ColumnWidth', {'2x', '1x'});
            p = uipanel(g, 'Title', 'Values to enter in CFturbo (screen by screen)');
            app.CfturboTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(g, 'Title', 'Blade mean lines: wrap angle per span');
            app.WrapTable = uitable(uigridlayout(p, [1 1]));
        end

        function buildExportTab(app, tab)
            g = uigridlayout(tab, [2 2], 'RowHeight', {30, '1x'}, 'ColumnWidth', {'1x', '1.3x'});
            top = uigridlayout(g, [1 4], 'ColumnWidth', {70, '1x', 90, 110}, 'Padding', [0 0 0 0]);
            top.Layout.Column = [1 2];
            uilabel(top, 'Text', 'Folder:');
            app.ExportFolderField = uieditfield(top, 'text', 'Tooltip', ...
                'CFturbo project folder (...\dp0\CFT) or one export folder ({GUID})');
            uibutton(top, 'Text', 'Browse...', 'ButtonPushedFcn', @(~, ~) app.onBrowseExport());
            uibutton(top, 'Text', 'Read & check', 'FontWeight', 'bold', 'ButtonPushedFcn', @(~, ~) app.onReadExport());
            app.ExportAxes = uiaxes(g);
            right = uigridlayout(g, [4 1], 'RowHeight', {'1.2x', '0.6x', '1x', '0.6x'});
            p = uipanel(right, 'Title', 'Blade rows (mm, deg)');
            app.ExportCompTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(right, 'Title', 'Component interfaces');
            app.ExportIfaceTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(right, 'Title', 'Impeller: CFturbo vs MATLAB design (selected design)');
            app.ExportCompareTable = uitable(uigridlayout(p, [1 1]));
            p = uipanel(right, 'Title', 'Warnings');
            app.ExportWarnings = uitextarea(uigridlayout(p, [1 1]), 'Editable', 'off');
        end

        function buildStatorTab(app, tab)
            g = uigridlayout(tab, [1 2], 'ColumnWidth', {330, '1x'});
            p = uipanel(g, 'Title', 'Stator inputs (impeller exit state from CFD)', 'FontWeight', 'bold');
            n = size(app.StatorSpecs, 1);
            pg = uigridlayout(p, [2 * n + 2, 1], 'RowHeight', [repmat({14, 22}, 1, n), {30, '1x'}], ...
                'RowSpacing', 2, 'Scrollable', 'on');
            for j = 1:n
                lb = uilabel(pg, 'Text', app.StatorSpecs{j, 2});
                lb.Layout.Row = 2 * j - 1;
                if strcmp(app.StatorSpecs{j, 3}, 'range')
                    h = uieditfield(pg, 'text');
                else
                    h = uieditfield(pg, 'numeric', 'ValueDisplayFormat', '%.6g');
                end
                h.Layout.Row = 2 * j;
                app.StatorFields.(app.StatorSpecs{j, 1}) = h;
            end
            b = uibutton(pg, 'Text', 'Size stator', 'FontWeight', 'bold', ...
                'BackgroundColor', [0.85 0.92 1], 'ButtonPushedFcn', @(~, ~) app.onSizeStator());
            b.Layout.Row = 2 * n + 1;
            right = uigridlayout(g, [3 1], 'RowHeight', {110, '1x', 70});
            p = uipanel(right, 'Title', 'Vaneless gap exit (station 3) and diffuser throat');
            app.Stator3Table = uitable(uigridlayout(p, [1 1]));
            p = uipanel(right, 'Title', 'Feasible combinations (sorted: fewest guide rows, smallest diameter)');
            app.StatorTable = uitable(uigridlayout(p, [1 1]));
            app.StatorNote = uitextarea(right, 'Editable', 'off', 'Value', { ...
                'Angles: radial diffuser from tangential, guide vanes from axial. beta = blade angle, alpha = flow angle.', ...
                'V3 CFD showed about 15 deg more guide vane deviation than the Carter rule (0.3 mm tip gap):', ...
                'increase the guide vane exit metal angle accordingly.'});
        end

        function buildMapTab(app, tab)
            g = uigridlayout(tab, [3 1], 'RowHeight', {30, '1.6x', '1x'});
            top = uigridlayout(g, [1 5], 'ColumnWidth', {170, 200, 150, 200, 130}, 'Padding', [0 0 0 0]);
            uilabel(top, 'Text', 'Speeds (fraction of design):');
            app.MapSpeedField = uieditfield(top, 'text', 'Value', '[0.6 0.7 0.8 0.9 1.0]');
            uilabel(top, 'Text', 'Mass flows (fraction):');
            app.MapFlowField = uieditfield(top, 'text', 'Value', '0.30:0.05:1.30');
            uibutton(top, 'Text', 'Compute map', 'FontWeight', 'bold', 'BackgroundColor', [0.85 0.92 1], ...
                'ButtonPushedFcn', @(~, ~) app.onComputeMap());
            ag = uigridlayout(g, [1 2]);
            app.MapAxes = [uiaxes(ag), uiaxes(ag)];
            app.MapLinesTable = uitable(g);
        end

        % --------------------------------------------------------------
        function setInputs(app, in)
            names = fieldnames(app.Fields);
            for k = 1:numel(names)
                h = app.Fields.(names{k});
                v = in.(names{k});
                if isa(h, 'matlab.ui.control.DropDown')
                    h.Value = v;
                elseif isa(h, 'matlab.ui.control.NumericEditField') && isscalar(v) && isnan(v)
                    h.Value = [];
                elseif isa(h, 'matlab.ui.control.EditField')
                    h.Value = app.rangeToText(v);
                else
                    h.Value = v;
                end
            end
            app.Inputs = in;
        end

        function in = readInputs(app)
            in = cdt_default_inputs();
            names = fieldnames(app.Fields);
            for k = 1:numel(names)
                h = app.Fields.(names{k});
                if isa(h, 'matlab.ui.control.EditField')
                    v = str2num(h.Value); %#ok<ST2NM> range syntax such as 60:1:72
                    if isempty(v); error('cdt:input', 'Cannot read "%s" as a list of numbers.', h.Value); end
                    in.(names{k}) = v;
                else
                    v = h.Value;
                    if isempty(v); v = NaN; end
                    in.(names{k}) = v;
                end
            end
        end

        function txt = rangeToText(~, v)
            if numel(v) > 2 && all(abs(diff(v, 2)) < 1e-9)
                txt = sprintf('%g:%g:%g', v(1), v(2) - v(1), v(end));
            else
                txt = ['[' strjoin(compose('%g', v), ' ') ']'];
            end
        end

        % --------------------------------------------------------------
        function progress(app, k, n)
            drawnow;   % lets the Cancel button callback run
            if app.CancelFlag; error('cdt:cancelled', 'cancelled'); end
            app.setStatus(sprintf('Working: step %d of %d ...', k, n));
        end

        function requestCancel(app)
            app.CancelFlag = true;
        end

        function endRun(app)
            if isvalid(app) && isvalid(app.Figure)
                app.RunButton.Enable = 'on';
                app.CancelButton.Enable = 'off';
            end
        end

        function showError(app, msg)
            app.StatusLabel.FontColor = [0.75 0 0];
            app.StatusLabel.Text = ['Error: ' msg];
            fprintf(2, 'CompressorDesignApp: %s\n', msg);
        end

        function showSweep(app)
            sw = app.Sweep;
            cdt_plot_sweep(app.SweepAxes, sw);
            T = sw.table;
            app.SweepTable.Data = T;
            app.SweepTable.ColumnFormat = {};
            removeStyle(app.SweepTable);
            bad = find(~T.feasible);
            if ~isempty(bad)
                addStyle(app.SweepTable, uistyle('FontColor', [0.55 0.55 0.55]), 'row', bad);
            end
        end

        function onSweepRowSelected(app, ev)
            if isempty(ev.Indices); return; end
            k = ev.Indices(1, 1);
            if isempty(app.Sweep.designs{k})
                app.setStatus(sprintf('Row %d has no valid meanline solution: %s', k, app.Sweep.table.reason(k)));
                return;
            end
            app.Sweep.selected = k;
            app.Sweep.rule = 'selected in the sweep table';
            cdt_plot_sweep(app.SweepAxes, app.Sweep);
            app.selectDesign(k);
        end

        function selectDesign(app, k)
            d = app.Sweep.designs{k};
            app.setStatus('Evaluating the selected design...');
            drawnow;
            try
                app.Details = cdt_design_details(app.Inputs, d);
            catch err
                app.showError(['Design evaluation failed: ' err.message]);
                return;
            end
            app.showDetails();
            T = app.Sweep.table;
            app.setStatus(sprintf('Selected r2 = %g mm, r1 hub = %g mm (%s). PR after bend %.3f, eta %.2f %%, %s', ...
                T.r2_mm(k), T.r1_hub_mm(k), app.Sweep.rule, T.PR_after_bend(k), T.eta_tt_pct(k), ...
                app.feasibleText(T, k)));
        end

        function s = feasibleText(~, T, k)
            if T.feasible(k); s = 'feasible.'; else; s = ['NOT feasible: ' char(T.reason(k))]; end
        end

        function showDetails(app)
            det = app.Details;
            app.SummaryTable.Data = app.textValues(det.summary);
            app.StationTable.Data = det.stations;
            app.ChecksTable.Data = det.checks;
            removeStyle(app.ChecksTable);
            colors = {'PASS', [0.85 1 0.85]; 'MARGINAL', [1 0.95 0.75]; 'FAIL', [1 0.82 0.82]};
            for c = 1:size(colors, 1)
                rows = find(det.checks.status == colors{c, 1});
                if ~isempty(rows)
                    addStyle(app.ChecksTable, uistyle('BackgroundColor', colors{c, 2}), 'row', rows);
                end
            end
            cdt_plot_blade(app.BladeAxes, det);
            app.drawMeridional();
            app.CfturboTable.Data = app.textValues(cdt_cfturbo_inputs(app.Inputs, det));
            app.WrapTable.Data = det.wrap;
        end

        function T = textValues(~, T)
            % Show numbers with 5 significant digits; rows whose value is
            % NaN carry text in the unit column, which is moved to value.
            v = strings(height(T), 1);
            for k = 1:height(T)
                if isnan(T.value(k))
                    v(k) = string(T.unit{k});
                    T.unit{k} = '';
                else
                    v(k) = string(sprintf('%.5g', T.value(k)));
                end
            end
            T.value = v;
        end

        function drawMeridional(app)
            if isempty(app.Details); return; end
            cdt_plot_meridional(app.MeridionalAxes, cdt_meridional_geometry(app.Details), ...
                app.MeridionalMode.Value);
        end

        % --------------------------------------------------------------
        function onExport(app)
            if isempty(app.Sweep) && isempty(app.Export) && isempty(app.Stator)
                app.showError('Nothing to export yet.');
                return;
            end
            app.setStatus('Exporting...'); drawnow;
            extra = struct('cfturbo', app.Export, 'stator', app.Stator, 'map', app.Map);
            folder = cdt_export(app.Sweep, app.Details, [], extra);
            app.setStatus(['Results written to ' folder]);
            if ispc; winopen(folder); end
        end

        function onSaveInputs(app)
            try
                in = app.readInputs(); %#ok<NASGU>
            catch err
                app.showError(err.message); return;
            end
            [f, p] = uiputfile('*.mat', 'Save inputs', 'inputs.mat');
            if isequal(f, 0); return; end
            save(fullfile(p, f), 'in');
            app.setStatus(['Inputs saved to ' fullfile(p, f)]);
        end

        function onLoadInputs(app)
            [f, p] = uigetfile('*.mat', 'Load inputs');
            if isequal(f, 0); return; end
            s = load(fullfile(p, f));
            if ~isfield(s, 'in'); app.showError('File does not contain inputs.'); return; end
            in = cdt_default_inputs();
            names = fieldnames(s.in);
            for k = 1:numel(names); in.(names{k}) = s.in.(names{k}); end
            app.setInputs(in);
            app.setStatus(['Inputs loaded from ' fullfile(p, f)]);
        end

        function setStatorInputs(app, st)
            names = fieldnames(app.StatorFields);
            for k = 1:numel(names)
                h = app.StatorFields.(names{k});
                if isa(h, 'matlab.ui.control.EditField')
                    h.Value = app.rangeToText(st.(names{k}));
                else
                    h.Value = st.(names{k});
                end
            end
        end

        function st = readStatorInputs(app)
            st = cdt_default_stator_inputs();
            names = fieldnames(app.StatorFields);
            for k = 1:numel(names)
                h = app.StatorFields.(names{k});
                if isa(h, 'matlab.ui.control.EditField')
                    v = str2num(h.Value); %#ok<ST2NM> range syntax such as 13:2:31
                    if isempty(v); error('cdt:input', 'Cannot read "%s".', h.Value); end
                    st.(names{k}) = v;
                else
                    st.(names{k}) = h.Value;
                end
            end
        end

        function onBrowseExport(app)
            start = app.ExportFolderField.Value;
            if isempty(start) || ~isfolder(start); start = pwd; end
            d = uigetdir(start, 'CFturbo export folder (dp0\CFT)');
            figure(app.Figure);
            if isequal(d, 0); return; end
            app.ExportFolderField.Value = d;
            app.onReadExport();
        end

        function onReadExport(app)
            folder = app.ExportFolderField.Value;
            try
                comps = cdt_read_cfturbo_export(folder);
                chk = cdt_cfturbo_check(comps, app.Details);
            catch err
                app.showError(['CFturbo export: ' err.message]);
                return;
            end
            app.Export = struct('comps', comps, 'chk', chk);
            cdt_plot_cfturbo_meridional(app.ExportAxes, comps, app.Details);
            app.ExportCompTable.Data = chk.components;
            app.ExportIfaceTable.Data = chk.interfaces;
            app.ExportCompareTable.Data = chk.compare;
            if isempty(chk.warnings)
                app.ExportWarnings.Value = {'No problems found.'};
            else
                app.ExportWarnings.Value = cellstr(chk.warnings);
            end
            app.setStatus(sprintf('Read %d components from %s', numel(comps), folder));
        end

        function onSizeStator(app)
            try
                st = app.readStatorInputs();
                in = app.readInputs();
                app.setStatus('Sizing the stator...'); drawnow;
                out = cdt_stator_sizing(st, in);
            catch err
                app.showError(['Stator sizing: ' err.message]);
                return;
            end
            app.Stator = out;
            s3 = out.station3;
            app.Stator3Table.Data = table(s3.r3_mm, s3.alpha3_deg, s3.Cu3, s3.Cm3, s3.Mach3, ...
                s3.throat_area_mm2, 'VariableNames', {'r3_mm', 'alpha3_deg_tangential', 'Cu3', 'Cm3', ...
                'Mach3', 'throat_area_total_mm2'});
            app.StatorTable.Data = out.table;
            if height(out.table) == 0
                app.showError('No stator combination meets every limit. Widen the ranges or relax the limits.');
            else
                b = out.best;
                app.setStatus(sprintf(['Stator: %d combinations. Best: %d vanes, r4 = %g mm, beta3/beta4 = %.1f/%.1f deg, ' ...
                    '%d guide row(s), annulus %.1f mm, OD %.0f mm.'], height(out.table), b.vanes, b.r4_mm, ...
                    b.beta3_deg, b.beta4_deg, b.guide_rows, b.annulus_h_mm, b.outer_diameter_mm));
            end
        end

        function onComputeMap(app)
            if isempty(app.Details)
                app.showError('Select a design first (run the sweep).');
                return;
            end
            sp = str2num(app.MapSpeedField.Value); %#ok<ST2NM>
            fl = str2num(app.MapFlowField.Value); %#ok<ST2NM>
            if isempty(sp) || isempty(fl)
                app.showError('Cannot read the speed or mass flow lists.');
                return;
            end
            app.CancelFlag = false;
            app.CancelButton.Enable = 'on';
            restore = onCleanup(@() app.endRun()); %#ok<NASGU>
            try
                mp = cdt_compressor_map(app.Inputs, app.Details.design, sp, fl, @(k, n) app.progress(k, n));
            catch err
                if strcmp(err.identifier, 'cdt:cancelled')
                    app.setStatus('Map cancelled.');
                else
                    app.showError(['Map: ' err.message]);
                end
                return;
            end
            app.Map = mp;
            cdt_plot_map(app.MapAxes, mp);
            app.MapLinesTable.Data = mp.lines;
            app.setStatus(sprintf('Map: %d speed lines. Surge margin at design speed (PR-peak estimate): %.0f %%.', ...
                height(mp.lines), mp.surge_margin_pct));
        end


        function setStatus(app, msg)
            app.StatusLabel.FontColor = [0 0 0];
            app.StatusLabel.Text = msg;
        end
    end
end
