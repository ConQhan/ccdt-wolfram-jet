function cmap = compute_compressor_map(eos, components_factory, rpm_values, mdot_values, ...
    p0, T0, design_rpm, design_mdot, verbose)
%COMPUTE_COMPRESSOR_MAP solver/compressor_map.py :: compute_compressor_map() portu.
%   Sabit geometri uzerinde kompresor haritasi hesaplar.
%
%   eos                : ideal_gas_eos() ile uyumlu EOS struct'i
%   components_factory : @(rpm) -> Nx2 cell array {label, fn} dondüren
%                        function handle (Python'daki pipeline_factory(rpm)
%                        -> StagePipeline karsiligi; bu port StagePipeline
%                        nesnesi yerine run_stage_pipeline'in bekledigi
%                        components hucre dizisini kullaniyor).
%   rpm_values         : Taranacak RPM degerleri
%   mdot_values        : Her RPM icin taranacak kutlesel debi listesi [kg/s]
%   p0, T0             : Giris toplam kosullari [Pa, K]
%   design_rpm         : Tasarim RPM'i (print'lerde isaretlenir)
%   design_mdot        : Tasarim debisi (print'lerde isaretlenir)
%   verbose            : Ilerleme mesajlarini goster
%
%   Cikti: new_compressor_map.m struct'i.

if nargin < 5 || isempty(p0); p0 = 101325.0; end
if nargin < 6 || isempty(T0); T0 = 288.15; end
if nargin < 7; design_rpm = []; end
if nargin < 8; design_mdot = []; end
if nargin < 9 || isempty(verbose); verbose = true; end

cmap = new_compressor_map(design_rpm, design_mdot);
n_total = numel(rpm_values) * numel(mdot_values);
n_done = 0; %#ok<NASGU>

curves = cell(1, numel(rpm_values));

for ri = 1:numel(rpm_values)
    rpm = rpm_values(ri);
    curve = new_map_curve(rpm);

    try
        components = components_factory(rpm);
    catch exc
        if verbose
            fprintf('RPM=%.0f: pipeline oluşturulamadı: %s\n', rpm, exc.message);
        end
        curves{ri} = curve;
        continue;
    end

    sorted_mdot = sort(mdot_values);
    pts = cell(1, numel(sorted_mdot));
    for mi = 1:numel(sorted_mdot)
        mdot = sorted_mdot(mi);
        pt = new_map_point();
        pt.rpm = rpm;
        pt.mdot = mdot;

        prev_warn_state = [];
        try
            inlet = new_station_state('0');
            inlet.total = new_fluid_state(p0, T0);
            inlet.mass_flow = mdot;

            prev_warn_state = warning('off', 'all');
            lastwarn('');
            result = run_stage_pipeline(components, inlet);
            [~, wid] = lastwarn();
            warning(prev_warn_state);

            model_valid = isempty(wid) || ~startsWith(wid, 'centrifugal:');

            summary = stage_result_summary(result, eos);
            pr = summary.pressure_ratio_total_to_total;
            eta = summary.isentropic_efficiency_total_to_total;
            w = summary.specific_work_J_per_kg;

            if isfield(result.stations, 'impeller')
                st_imp = result.stations.impeller;
                omega_rad = 2.0 * pi * rpm / 60.0;
                U2 = omega_rad * st_imp.geom.r;
                rho_t0 = eos_density(eos, p0, T0);
                Q0 = mdot / rho_t0;
                r2 = st_imp.geom.r;
                phi = Q0 / (pi * r2^2 * U2);
            else
                phi = NaN;
            end

            pt.ok = true;
            pt.model_valid = model_valid;
            pt.PR_tt = pr;
            if truthy_local(eta)
                pt.eta_tt_pct = eta * 100.0;
            else
                pt.eta_tt_pct = NaN;
            end
            if truthy_local(w)
                pt.specific_work_kJ_kg = w / 1000.0;
            else
                pt.specific_work_kJ_kg = NaN;
            end
            pt.phi = phi;

        catch exc
            if ~isempty(prev_warn_state)
                warning(prev_warn_state);
            end
            msg = exc.message;
            pt.fail_reason = msg(1:min(100, numel(msg)));
        end

        pts{mi} = pt;
        n_done = n_done + 1; %#ok<NASGU>
    end

    if ~isempty(pts)
        curve.points = [pts{:}];
    end
    curves{ri} = curve;

    if verbose
        vpts = map_curve_valid_points(curve);
        n_warn = sum(~[vpts.model_valid]);
        fprintf('  RPM=%7.0f: %d/%d OK  (%d model_validity_flagged)\n', ...
            rpm, numel(vpts), numel(mdot_values), n_warn);
    end
end

if ~isempty(curves)
    cmap.speedlines = [curves{:}];
end

if verbose
    fprintf('Harita tamamlandı: %d hız eğrisi, %d toplam nokta.\n', numel(rpm_values), n_total);
end

end

function tf = truthy_local(v)
tf = ~isempty(v) && v ~= 0;
end
