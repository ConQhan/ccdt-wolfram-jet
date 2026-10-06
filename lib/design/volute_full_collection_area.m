function A6 = volute_full_collection_area(A4, r4, alpha4_deg, r6, SP)
%VOLUTE_FULL_COLLECTION_AREA design/volute_sizing.py :: volute_full_collection_area() portu.
%   Eq. (6-33): A6 = SP*(A4*r6*tan(alpha4)/r4)
%
%   SP: volut sizing parametresi (Eq 5-106) -- SP=1.0 ideal (acisal
%   momentum korunumlu) tasarimdir.
%
%   NOT: r6, A6'nin KENDISINE bagli bir dongu icerir (kitap: "Since r6
%   is a function of r4, A6 and the aspect ratio, an iterative process
%   is required" -- s.125). Bu fonksiyon TEK ADIM hesaplar; cagiran kod
%   r6 tahmini ile bu fonksiyonu sabit-nokta iterasyonunda kullanmalidir
%   (bkz. volute_sizing_iterate.m).

if nargin < 5 || isempty(SP)
    SP = 1.0;
end

A6 = SP * (A4 * r6 * tan(deg2rad(alpha4_deg)) / r4);

end
