function I_L = leakage_work_coefficient_covered_impeller(m_dot_L, I_B, m_dot)
%LEAKAGE_WORK_COEFFICIENT_COVERED_IMPELLER losses/leakage_recirculation.py portu.
%   Eq. (4-39) [KAPSAM DISI -- sadece referans icin, acik-impeller
%   pipeline'ina bagli DEGIL]: I_L = m_dot_L*I_B/m_dot
I_L = m_dot_L * I_B / m_dot;
end
