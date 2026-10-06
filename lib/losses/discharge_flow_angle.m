function alpha4_deg = discharge_flow_angle(beta4_deg, delta_star_deg, d_delta_di, beta3_deg, alpha3_deg)
%DISCHARGE_FLOW_ANGLE losses/vaned_diffuser_losses.py portu.
%   Eq. (5-88): alpha4 = beta4 - delta* - (d_delta/di)*(beta3-alpha3)   (DERECE)
alpha4_deg = beta4_deg - delta_star_deg - d_delta_di * (beta3_deg - alpha3_deg);
end
