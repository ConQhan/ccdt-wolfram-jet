function delta = boundary_layer_thickness_from_ratio(ratio, b)
%BOUNDARY_LAYER_THICKNESS_FROM_RATIO losses/diffuser_losses.py portu.
%   delta = 2.25*b*(1-ratio) (Eq 5-60'tan delta icin cozulmus hali).
%   2*delta <= b fiziksel kisiti burada uygulanir.
delta = 2.25 * b * (1.0 - ratio);
delta = min(delta, b / 2.0);
end
