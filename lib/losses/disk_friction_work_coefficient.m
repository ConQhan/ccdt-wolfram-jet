function I_DF = disk_friction_work_coefficient(C_MD, rho2, U2, r2, m_dot, C_MC)
%DISK_FRICTION_WORK_COEFFICIENT losses/disk_friction.py portu.
%   Eq. (4-32) [DUZELTILDI -- boyutsal analizle teyit edildi]:
%     I_DF = (C_MD + C_MC)*rho2*U2*r2^2 / (2*m_dot)
%   NOT: kaynakta U2 (KARESI DEGIL) kullanildigi boyutsal turetmeyle
%   dogrulanmis -- bu port o duzeltilmis hali birebir tasiyor.
%   C_MC=0 varsayimi: acik impeller (kapak/cover yok).
if nargin < 6 || isempty(C_MC)
    C_MC = 0.0;
end
I_DF = (C_MD + C_MC) * rho2 * U2 * r2^2 / (2.0 * m_dot);
end
