function E = diffusion_efficiency(D, Dm)
%DIFFUSION_EFFICIENCY losses/diffuser_losses.py portu.
%   Eq. (5-52): Difuzyon verimliligi E.
%     E = 1                    ; D <= 0
%     E = 1 - 0.2*(D/Dm)^2     ; 0 < D < Dm
%     E = 0.8*sqrt(Dm/D)       ; D >= Dm
if D <= 0.0
    E = 1.0;
elseif D < Dm
    E = 1.0 - 0.2 * (D / Dm)^2;
else
    E = 0.8 * sqrt(Dm / D);
end
end
