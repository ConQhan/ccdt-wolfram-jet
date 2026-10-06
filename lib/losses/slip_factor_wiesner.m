function sigma = slip_factor_wiesner(beta2, z_eff, alpha_C2)
%SLIP_FACTOR_WIESNER losses/impeller_losses.py portu.
%   Eq. (4-7): sigma = 1 - sqrt(sin(beta2)) * sin(alpha_C2) / z_eff^0.7
%
%   alpha_C2: streamline egimi ile eksenel yon arasindaki aci (Fig 4-2).
%   Varsayilan pi/2 (90 derece) -- impeller cikisinda meridyenel akisin
%   TAMAMEN RADYAL oldugu klasik varsayim (sin(alpha_C2)=1).
%
%   NOT: Bu formulun gecerliligi bir limit oranina (epsilon_Lim, Eq 4-9)
%   kadardir; uzerinde sigma_COR duzeltmesi (Eq 4-10) gerekir -- Python
%   kaynaginda da HENUZ eklenmemis, bu port de eklemiyor (birebir port).

if nargin < 3 || isempty(alpha_C2)
    alpha_C2 = pi / 2.0;
end

sigma = 1.0 - sqrt(sin(beta2)) * sin(alpha_C2) / z_eff^0.7;

end
