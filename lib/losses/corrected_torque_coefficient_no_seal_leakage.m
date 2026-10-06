function C_M = corrected_torque_coefficient_no_seal_leakage(C_M0, K0)
%CORRECTED_TORQUE_COEFFICIENT_NO_SEAL_LEAKAGE losses/disk_friction.py portu.
%   Eq. (4-30), K=K0 (sizinti yok) OZEL DURUMU icin sadelestirilmis:
%     C_M = C_M0*(1-K)^2/(1-K0)  ->  K=K0 ise  ->  C_M = C_M0*(1-K0)
C_M = C_M0 * (1.0 - K0);
end
