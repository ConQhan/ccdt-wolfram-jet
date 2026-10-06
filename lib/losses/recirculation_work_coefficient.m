function I_R = recirculation_work_coefficient(Deq, Wu2, Cm2, beta2, Cm2_floor_ratio, I_R_max)
%RECIRCULATION_WORK_COEFFICIENT losses/leakage_recirculation.py portu.
%   Eq. (4-43):
%     I_R = (Deq/2 - 1) * [Wu2/Cm2 - 2*cot(beta2)] ;  Deq > 2
%     I_R = 0                                       ;  Deq <= 2
%     I_R >= 0  (negatif cikarsa 0'a sinirlanir)
%
%   Sayisal saglamlik: Cm2 paydaya girmeden once kucuk bir taban degerle
%   korunur (Cm2_floor_ratio*|Wu2|), sonuc I_R_max ile ustten sinirlanir.

if nargin < 5 || isempty(Cm2_floor_ratio); Cm2_floor_ratio = 1e-3; end
if nargin < 6 || isempty(I_R_max); I_R_max = 2.0; end

if Deq <= 2.0
    I_R = 0.0;
    return
end

Cm2_safe = max(abs(Cm2), Cm2_floor_ratio * max(abs(Wu2), 1.0));
if Cm2 < 0
    Cm2_safe = -Cm2_safe;
end

I_R_val = (Deq / 2.0 - 1.0) * (Wu2 / Cm2_safe - 2.0 / tan(beta2));
I_R_val = max(I_R_val, 0.0);
I_R = min(I_R_val, I_R_max);

end
