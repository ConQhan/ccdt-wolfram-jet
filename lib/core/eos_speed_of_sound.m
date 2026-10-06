function a = eos_speed_of_sound(eos, p, T) %#ok<INUSL>
%EOS_SPEED_OF_SOUND core/equation_of_state.py :: IdealGasEOS.speed_of_sound() portu.
a = sqrt(eos.gamma * eos.R * T);
end
