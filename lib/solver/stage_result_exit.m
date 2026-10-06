function st = stage_result_exit(result)
%STAGE_RESULT_EXIT solver/stage_pipeline.py :: StageResult.exit portu.
st = result.stations.(result.station_order{end});
end
