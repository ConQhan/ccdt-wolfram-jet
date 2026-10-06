function w = blade_to_blade_width(r, beta, n_vanes)
%BLADE_TO_BLADE_WIDTH losses/vaned_diffuser_losses.py portu.
%   Nomenclature (s.71): w = (2*pi*r*sin(beta))/z
w = 2.0 * pi * r * sin(beta) / n_vanes;
end
