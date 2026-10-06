function st = stage_result_inlet(result)
%STAGE_RESULT_INLET solver/stage_pipeline.py :: StageResult.inlet portu.
st = result.stations.(result.station_order{1});
end
