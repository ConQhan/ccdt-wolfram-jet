function eta_tt = stage_result_isentropic_efficiency(eos, pt_in, Tt_in, pt_out, specific_work)
%STAGE_RESULT_ISENTROPIC_EFFICIENCY solver/stage_pipeline.py :: StageResult._isentropic_efficiency() portu.
%   [TODO_VERIFY -- sadece ideal gaz] eta_tt = Delta_h_isentropic / Delta_h_actual
%   Delta_h_isentropic = cp*Tt_in*[(pt_out/pt_in)^((gamma-1)/gamma) - 1]
%   eos'ta gamma/cp yoksa (orn. RealGasEOS -- bu portta yok) [] doner.

if ~isfield(eos, 'gamma') || ~isfield(eos, 'cp') || isempty(specific_work) || specific_work == 0.0
    eta_tt = [];
    return
end
if isempty(pt_in) || pt_in <= 0.0 || isempty(pt_out)
    eta_tt = [];
    return
end

gamma = eos.gamma; cp = eos.cp;
delta_h_isentropic = cp * Tt_in * ((pt_out / pt_in)^((gamma - 1.0) / gamma) - 1.0);
eta_tt = delta_h_isentropic / specific_work;

end
