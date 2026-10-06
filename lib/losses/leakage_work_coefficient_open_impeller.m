function I_L = leakage_work_coefficient_open_impeller(m_dot_CL, U_CL, U2, m_dot)
%LEAKAGE_WORK_COEFFICIENT_OPEN_IMPELLER losses/leakage_recirculation.py portu.
%   Eq. (4-40): I_L = m_dot_CL*U_CL / (2*U2*m_dot)
%   Acik impellerler icin: blade clearance gap'inden sizan akisin
%   yarisinin impeller tarafindan yeniden enerjilendirildigi (re-entrained)
%   ampirik varsayimina dayanir.
I_L = m_dot_CL * U_CL / (2.0 * U2 * m_dot);
end
