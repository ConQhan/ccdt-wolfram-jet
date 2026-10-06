function result = run_stage_pipeline(components, inlet_station)
%RUN_STAGE_PIPELINE solver/stage_pipeline.py :: StagePipeline.run() portu.
%   Bilesenleri (her biri tek-argumanli, inlet_station->outlet_station
%   fonksiyon handle'i -- Python'daki component.compute(inlet) bound
%   metoduna karsilik gelir) SIRAYLA zincirleyen ince bir orkestrasyon.
%
%   components: Nx2 cell array, her satir {label(char), compute_fn(handle)}.
%   Ornek: {{'impeller', @(inlet) impeller_compute(imp, inlet)}, ...
%           {'vaneless_diffuser', @(inlet) vaneless_diffuser_compute(eos, diff_geom, inlet)}}
%
%   Cikti: result.stations (struct, alan adlari = 'inlet' + label'lar),
%   result.station_order (cell array, sira bilgisini korur).

stations = struct();
stations.inlet = inlet_station;
order = {'inlet'};
current = inlet_station;

for i = 1:size(components, 1)
    label = components{i, 1};
    compute_fn = components{i, 2};
    try
        current = compute_fn(current);
    catch exc
        error('centrifugal:run_stage_pipeline', ...
            ['StagePipeline: ''%s'' bileseninde hata olustu (onceki istasyon: ''%s''). ' ...
             'Orijinal hata: %s'], label, order{end}, exc.message);
    end
    stations.(label) = current;
    order{end+1} = label; %#ok<AGROW>
end

result.stations = stations;
result.station_order = order;

end
