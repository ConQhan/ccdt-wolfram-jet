function eta_2H = impeller_internal_efficiency(phi)
%IMPELLER_INTERNAL_EFFICIENCY design/reference_correlations.py :: impeller_internal_efficiency() portu.
%   Eq. (6-9): eta_2H = 0.95 - 0.0005/phi  (impeller internal/hidrolik verimlilik).

eta_2H = 0.95 - 0.0005 / phi;

end
