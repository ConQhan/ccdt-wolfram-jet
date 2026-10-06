function s = eos_total_from_static(eos, p_static, T_static, velocity)
%EOS_TOTAL_FROM_STATIC core/equation_of_state.py :: IdealGasEOS.total_from_static() portu.
%   Statik kosullardan total kosullari dondurur (ayni sozluk formati).

T_total = T_static + (velocity^2) / (2.0 * eos.cp);
p_total = p_static * (T_total / T_static) ^ (eos.gamma / (eos.gamma - 1.0));

s.p = p_total;
s.T = T_total;
s.rho = eos_density(eos, p_total, T_total);
s.h = eos_enthalpy(eos, p_total, T_total);
s.a = eos_speed_of_sound(eos, p_total, T_total);
s.z = 1.0;

end
