function B6 = inlet_blockage_stall(rb_max_stall_free, r6, b6)
%INLET_BLOCKAGE_STALL losses/return_channel_losses.py portu.
%   Eq. (5-89): B6 = 1 - (rb)_m/(r6*b6)
%   (rb)_m: max_stall_free_rb() (losses/diffuser_losses.py, Eq 5-54) ile
%   hesaplanip buraya gecirilir.
B6 = 1.0 - rb_max_stall_free / (r6 * b6);
B6 = max(B6, 0.0);
end
