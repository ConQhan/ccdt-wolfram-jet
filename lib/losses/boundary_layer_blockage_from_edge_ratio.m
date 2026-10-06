function [B, ratio] = boundary_layer_blockage_from_edge_ratio(rCu_avg, rCu_edge)
%BOUNDARY_LAYER_BLOCKAGE_FROM_EDGE_RATIO losses/diffuser_losses.py portu.
%   Eq. (5-58) ve Eq. (5-60)'in BIRLESIK (kapali-form) cozumu:
%     2*delta/(4.5*b) = 1 - rCu_avg/rCu_e
%     B = 2*delta/(8*b) = (4.5/8)*(1 - rCu_avg/rCu_e) = 0.5625*(1-ratio)
%
%   rCu_edge, pasaj boyunca (sinir tabakalari pasaji doldurana kadar)
%   KORUNAN degerdir; rCu_avg ise marching'in urettigi ORTALAMA
%   (surtunmeyle dusen) degerdir.
%
%   Returns: [B, ratio] -- ratio = rCu_avg/rCu_edge.
if rCu_edge == 0.0
    B = 0.0;
    ratio = 1.0;
    return
end
ratio = rCu_avg / rCu_edge;
ratio = min(ratio, 1.0);  % delta>=0 fiziksel kisiti
B = 0.5625 * (1.0 - ratio);
end
