function tf = inducer_stall_predicted(W1s, Wth)
%INDUCER_STALL_PREDICTED losses/impeller_losses.py portu.
%   Eq. (5-29): inducer stall kriteri -- W1s/Wth >= 1.75 ise stall ongorulur.
tf = (W1s / Wth) >= 1.75;
end
