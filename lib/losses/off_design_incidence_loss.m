function omega_i = off_design_incidence_loss(C3, C3_star, C3s, C_th)
%OFF_DESIGN_INCIDENCE_LOSS losses/vaned_diffuser_losses.py portu.
%   Eq. (5-72)/(5-73): tasarim-disi hucum kaybi.
%     C3 <= C3s:  omega_i = 0.8*[(C3-C3*)/C3]^2
%     C3 >  C3s:  omega_i = 0.8*[((C3/C3s)^2-1)*Cth^2/C3^2 + (C3s-C3*)^2/C3s^2]
if C3 <= C3s
    omega_i = 0.8 * ((C3 - C3_star) / C3)^2;
    return
end
omega_i = 0.8 * (((C3 / C3s)^2 - 1.0) * C_th^2 / C3^2 + (C3s - C3_star)^2 / C3s^2);
end
