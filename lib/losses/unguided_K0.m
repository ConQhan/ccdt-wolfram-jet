function K0 = unguided_K0(M3, beta3)
%UNGUIDED_K0 losses/vaned_diffuser_losses.py portu.
%   Eq. (5-65): K0 = M3^2*sin^2(beta3)*cos(beta3) / (1 - M3^2*sin^2(beta3))
s2 = (M3 * sin(beta3))^2;
if s2 >= 1.0
    error('centrifugal:unguided_K0', ...
        'unguided_K0: M3*sin(beta3) >= 1 (sonik/supersonik bilesen) -- model gecersiz');
end
K0 = s2 * cos(beta3) / (1.0 - s2);
end
