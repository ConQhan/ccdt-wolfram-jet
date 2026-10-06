function h = eos_enthalpy(eos, p, T) %#ok<INUSL>
%EOS_ENTHALPY core/equation_of_state.py :: IdealGasEOS.enthalpy() portu.
%   Ideal gazda h sadece T'ye baglidir; p parametresi arayuz
%   tutarliligi icin (Python'daki gibi) korunuyor.
h = eos.cp * T;
end
