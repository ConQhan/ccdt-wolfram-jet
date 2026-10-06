function C_sep = return_channel_wake_separation_velocity(C_max, C7)
%RETURN_CHANNEL_WAKE_SEPARATION_VELOCITY losses/return_channel_losses.py :: wake_separation_velocity() portu.
%   Eq. (5-97) oncesi metin: Cmax > 2*C7 ise ayrisma C_SEP=Cmax/2'de
%   gerceklesir, aksi halde C_SEP=C7.
if C_max > 2.0 * C7
    C_sep = C_max / 2.0;
else
    C_sep = C7;
end
end
