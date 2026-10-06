function eos = cdt_eos(in)
%CDT_EOS Ideal-gas equation of state built from the gas fields of IN.
eos = ideal_gas_eos(in.R, in.gamma, in.cp);
end
