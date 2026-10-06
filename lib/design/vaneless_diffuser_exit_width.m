function result = vaneless_diffuser_exit_width(r2, r4, Cu2, b2, cf, alpha_bar_deg)
%VANELESS_DIFFUSER_EXIT_WIDTH design/diffuser_sizing.py :: vaneless_diffuser_exit_width() portu.
%   Eq. (6-24): ln[(r4*Cu4)/(r2*Cu2)] = -cf*(r4-r2)/(b_bar*sin(alpha_bar))
%
%   Bu denklem r4*Cu4'u (surtunme duzeltmeli acisal momentum) verir; b4
%   ise kutle korunumundan turetilir. Burada basitlestirilmis bir
%   sureklilik kapanisi kullaniliyor: b_bar (ortalama genislik, b2 ve
%   aranan b4'un ortalamasi) icin SABIT NOKTA iterasyonu yapilir.
%
%   Yogunluk degisimi IHMAL EDILIYOR [BASITLESTIRME] -- bu adim sadece
%   ILK TAHMIN uretmek icindir.
%
%   Cikti struct alanlari: Cu4, b4, b4_clamped.

alpha_bar = deg2rad(alpha_bar_deg);
b_bar = b2;
b4_candidate = b2;
Cu4 = Cu2;

for iter = 1:20
    ln_ratio = -cf * (r4 - r2) / (b_bar * sin(alpha_bar));
    Cu4 = Cu2 * (r2 / r4) * exp(ln_ratio);
    Cm4 = Cu4 * tan(alpha_bar);
    Cm2 = Cu2 * tan(alpha_bar);
    if Cm4 ~= 0.0
        b4_candidate = (r2 * b2 * Cm2) / (r4 * Cm4);
    else
        b4_candidate = b2;
    end
    b_bar_new = 0.5 * (b2 + b4_candidate);
    if abs(b_bar_new - b_bar) < 1.0e-9
        b_bar = b_bar_new;
        break;
    end
    b_bar = b_bar_new;
end

b4 = min(b4_candidate, b2);

result.Cu4 = Cu4;
result.b4 = b4;
result.b4_clamped = b4_candidate > b2;

end
