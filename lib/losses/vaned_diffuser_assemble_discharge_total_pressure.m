function pt4 = vaned_diffuser_assemble_discharge_total_pressure(pt3, p3, sum_omega)
%VANED_DIFFUSER_ASSEMBLE_DISCHARGE_TOTAL_PRESSURE losses/vaned_diffuser_losses.py :: assemble_discharge_total_pressure() portu.
%   Eq. (5-84): pt4 = pt3 - (pt3-p3)*sum(omega_i)
%   NOT: impeller'in Eq(5-24/25)'inden farkli olarak burada entropi
%   duzeltme faktoru (fc) YOKTUR -- sabit/stationary bilesenlerde toplam
%   basinc kaybi bilesen boyunca degismez. (impeller'daki ayni isimli
%   fonksiyonla cakismamasi icin 'vaned_diffuser_' onekli.)
pt4 = pt3 - (pt3 - p3) * sum_omega;
end
