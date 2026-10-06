function [Deq, W_max] = equivalent_diffusion_factor(W1, W2, delta_W_val)
%EQUIVALENT_DIFFUSION_FACTOR losses/impeller_losses.py portu.
%   Eq. (4-41): Wmax = (W1+W2+delta_W)/2, Deq = Wmax/W2
W_max = (W1 + W2 + delta_W_val) / 2.0;
Deq = W_max / W2;
end
