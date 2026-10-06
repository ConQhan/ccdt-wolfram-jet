function eos = ideal_gas_eos(R, gamma, cp)
%IDEAL_GAS_EOS core/equation_of_state.py :: IdealGasEOS portu.
%   Sabit ozgul isi orani (gamma) ve gaz sabiti (R) ile ideal gaz modeli.
%   cp verilmezse cp = gamma*R/(gamma-1) ile hesaplanir.
%
%   NOT: Python tarafindaki RealGasEOS (CoolProp tabanli) BU PORTUN
%   KAPSAMI DISINDA birakildi -- README'ye gore su an paket zaten
%   sadece ideal gaz (hava) kullaniyor, golden-run vakalarinin hicbiri
%   RealGasEOS kullanmiyor.

if nargin < 3 || isempty(cp)
    cp = gamma * R / (gamma - 1.0);
end

eos.type = 'ideal';
eos.R = R;
eos.gamma = gamma;
eos.cp = cp;

end
