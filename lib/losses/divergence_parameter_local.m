function D = divergence_parameter_local(b, C, dC_dm)
%DIVERGENCE_PARAMETER_LOCAL losses/diffuser_losses.py portu.
%   Eq. (5-50): D = -(b/C) * dC/dm
%   Vanesiz pasaj icin diverjans-analojisinin YEREL (marching sirasinda
%   her istasyonda hesaplanan) hali.
D = -(b / C) * dC_dm;
end
