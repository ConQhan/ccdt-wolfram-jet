function ok = delta_W_design_limit_check(delta_W_val, W1, W2)
%DELTA_W_DESIGN_LIMIT_CHECK losses/impeller_losses.py portu.
%   Eq. (6-22) tasarim kisiti: 2*delta_W/(W1+W2) <= 0.9 saglaniyor mu?
ok = (2.0 * delta_W_val / (W1 + W2)) <= 0.9;
end
