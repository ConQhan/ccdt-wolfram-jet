function SP = volute_sizing_parameter(r5, Cu5, r6, C6)
%VOLUTE_SIZING_PARAMETER losses/volute_losses.py portu.
%   Eq. (5-106): SP = r5*Cu5/(r6*C6). SP=1 acisal momentumun tam
%   korundugu ideal degerdir.
SP = r5 * Cu5 / (r6 * C6);
end
