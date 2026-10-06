function L = blade_loading_parameter(delta_C, C3, C4)
%BLADE_LOADING_PARAMETER losses/vaned_diffuser_losses.py portu.
%   Eq. (5-75): L = delta_C/(C3-C4)
L = delta_C / (C3 - C4);
end
