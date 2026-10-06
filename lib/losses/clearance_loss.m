function omega_cl = clearance_loss(m_dot_clearance, delta_p_CL, m_dot, rho1, W1)
%CLEARANCE_LOSS losses/impeller_losses.py portu.
%   Eq. (5-40): omega_CL = 2*m_dot_CL*delta_p_CL / (m_dot*rho1*W1^2)
%   [DUZELTME -- kaynaktan aynen tasindi] Basta "2" carpani var (onceki
%   surumde eksikti, kaynak kodda zaten duzeltilmis haliyle).
omega_cl = 2.0 * (m_dot_clearance * delta_p_CL) / (m_dot * rho1 * W1^2);
end
