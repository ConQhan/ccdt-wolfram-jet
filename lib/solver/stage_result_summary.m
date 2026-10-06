function summary = stage_result_summary(result, eos)
%STAGE_RESULT_SUMMARY solver/stage_pipeline.py :: StageResult.summary() portu.
%   Genel stage performans metrikleri.
%   Cikti alanlari: mass_flow_in_kg_s, mass_flow_out_kg_s,
%   mass_flow_balance_ok, pressure_ratio_total_to_total,
%   pressure_ratio_static_to_static, specific_work_J_per_kg,
%   isentropic_efficiency_total_to_total, total_loss_coefficients (struct).

inlet = stage_result_inlet(result);
exit_ = stage_result_exit(result);

pt_in = inlet.total.p; Tt_in = inlet.total.T;
pt_out = exit_.total.p; Tt_out = exit_.total.T; %#ok<NASGU>

if pt_in
    ht_in = eos_enthalpy(eos, pt_in, Tt_in);
else
    ht_in = [];
end
if pt_out
    ht_out = eos_enthalpy(eos, pt_out, Tt_out);
else
    ht_out = [];
end
if ~isempty(ht_in) && ~isempty(ht_out)
    specific_work = ht_out - ht_in;
else
    specific_work = [];
end

eta_tt = stage_result_isentropic_efficiency(eos, pt_in, Tt_in, pt_out, specific_work);

loss_coeffs = struct();
for i = 2:numel(result.station_order)  % "inlet" haric
    label = result.station_order{i};
    loss_coeffs.(label) = result.stations.(label).loss_total_pressure;
end

summary.mass_flow_in_kg_s = inlet.mass_flow;
summary.mass_flow_out_kg_s = exit_.mass_flow;
summary.mass_flow_balance_ok = abs(exit_.mass_flow - inlet.mass_flow) < 1.0e-4 * max(inlet.mass_flow, 1e-9);
if pt_in
    summary.pressure_ratio_total_to_total = pt_out / pt_in;
else
    summary.pressure_ratio_total_to_total = [];
end
if inlet.static.p
    summary.pressure_ratio_static_to_static = exit_.static.p / inlet.static.p;
else
    summary.pressure_ratio_static_to_static = [];
end
summary.specific_work_J_per_kg = specific_work;
summary.isentropic_efficiency_total_to_total = eta_tt;
summary.total_loss_coefficients = loss_coeffs;

end
