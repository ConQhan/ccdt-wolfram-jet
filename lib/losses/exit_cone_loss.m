function omega_ec = exit_cone_loss(C6, C7, C5)
%EXIT_CONE_LOSS losses/volute_losses.py portu.
%   Eq. (5-110): omega_EC = [(C6-C7)/C5]^2
omega_ec = ((C6 - C7) / C5)^2;
end
