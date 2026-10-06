function AR = tip_area_ratio(A1, beta1_th, A2, beta2)
%TIP_AREA_RATIO losses/impeller_losses.py portu.
%   Eq. (4-13): AR = A2*sin(beta2) / (A1*sin(beta1_th))
AR = (A2 * sin(beta2)) / (A1 * sin(beta1_th));
end
