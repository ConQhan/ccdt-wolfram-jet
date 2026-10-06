function rho = eos_density(eos, p, T)
%EOS_DENSITY core/equation_of_state.py :: IdealGasEOS.density() portu.
rho = p / (eos.R * T);
end
