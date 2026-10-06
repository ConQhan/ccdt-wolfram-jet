function Tt = vaneless_diffuser_total_temperature(eos, T_static, C)
%VANELESS_DIFFUSER_TOTAL_TEMPERATURE components/vaneless_diffuser.py :: VanelessDiffuser._total_temperature() portu.
if isfield(eos, 'cp') && ~isempty(eos.cp)
    cp = eos.cp;
else
    cp = eos_enthalpy(eos, 101325.0, T_static + 1.0) - eos_enthalpy(eos, 101325.0, T_static);
end
Tt = T_static + 0.5 * C^2 / cp;
end
