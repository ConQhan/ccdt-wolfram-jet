function delta_p_CL = clearance_gap_pressure_difference(m_dot, r1, r2, Cu1, Cu2, z_eff, L_B, b1, b2)
%CLEARANCE_GAP_PRESSURE_DIFFERENCE losses/impeller_losses.py portu.
%   Eq. (4-18): delta_p_CL = m_dot*(r2*Cu2 - r1*Cu1) / (z_eff*r_bar*b_bar*L)
%     r_bar=(r1+r2)/2, b_bar=(b1+b2)/2
%   NOT (Python docstring'inden): paydadaki "L", bu portta da L_B
%   (kanat camber uzunlugu) ile ayni kabul edildi -- [YAKLASIM],
%   kaynaktaki orijinal belirsizlik birebir tasindi.
r_bar = (r1 + r2) / 2.0;
b_bar = (b1 + b2) / 2.0;
delta_p_CL = m_dot * (r2 * Cu2 - r1 * Cu1) / (z_eff * r_bar * b_bar * L_B);
end
