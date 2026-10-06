function Re = disk_reynolds_number(rho, omega, r, mu)
%DISK_REYNOLDS_NUMBER losses/disk_friction.py portu.
%   Eq. (4-21): Re = rho*omega*r^2/mu
Re = rho * omega * r^2 / mu;
end
