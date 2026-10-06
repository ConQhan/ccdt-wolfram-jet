function I_B = blade_work_input_coefficient_target(I, I_par)
%BLADE_WORK_INPUT_COEFFICIENT_TARGET design/impeller_sizing.py :: blade_work_input_coefficient_target() portu.
%   Eq. (6-18): I_B = I - I_par  (toplam hedef is katsayisindan parazitik dusulur).

I_B = I - I_par;

end
