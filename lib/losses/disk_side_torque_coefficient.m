function C_MD = disk_side_torque_coefficient(C_M)
%DISK_SIDE_TORQUE_COEFFICIENT losses/disk_friction.py portu.
%   Eq. (4-31): C_MD = 0.75*C_M ("deneyim" faktoru 0.75)
C_MD = 0.75 * C_M;
end
