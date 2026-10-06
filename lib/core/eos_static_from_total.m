function s = eos_static_from_total(eos, p_total, T_total, velocity)
%EOS_STATIC_FROM_TOTAL core/equation_of_state.py :: IdealGasEOS.static_from_total() portu.
%   Verilen total basinc/sicaklik ve hizdan statik kosullari dondurur.
%   Cikti struct alanlari: p, T, rho, h, a, z (Python sozlugu ile birebir).

T_static = T_total - (velocity^2) / (2.0 * eos.cp);
p_static = p_total * (T_static / T_total) ^ (eos.gamma / (eos.gamma - 1.0));

s.p = p_static;
s.T = T_static;
s.rho = eos_density(eos, p_static, T_static);
s.h = eos_enthalpy(eos, p_static, T_static);
s.a = eos_speed_of_sound(eos, p_static, T_static);
s.z = 1.0;

end
