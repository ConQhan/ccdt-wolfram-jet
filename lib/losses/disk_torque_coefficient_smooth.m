function C_M = disk_torque_coefficient_smooth(s_over_r, Re)
%DISK_TORQUE_COEFFICIENT_SMOOTH losses/disk_friction.py portu.
%   Eq. (4-22)-(4-25): dort akis rejimi icin torque coefficient
%   tahminleri; dogru rejim EN BUYUK C_M degerini veren rejimdir.
%     C_M1 = 2*pi / [(s/r)*Re]                       (laminer, birlesik)
%     C_M2 = 3.7*(s/r)^0.1 / sqrt(Re)                 (laminer, ayrik)
%     C_M3 = 0.08 / [(s/r)^(1/6) * Re^0.25]           (turbulansli, birlesik)
%     C_M4 = 0.102*(s/r)^0.1 / Re^0.2                 (turbulansli, ayrik)
C_M1 = 2.0 * pi / (s_over_r * Re);
C_M2 = 3.7 * s_over_r^0.1 / sqrt(Re);
C_M3 = 0.08 / (s_over_r^(1.0/6.0) * Re^0.25);
C_M4 = 0.102 * s_over_r^0.1 / Re^0.2;
C_M = max([C_M1, C_M2, C_M3, C_M4]);
end
