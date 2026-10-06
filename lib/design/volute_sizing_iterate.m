function result = volute_sizing_iterate(A4, r4, alpha4_deg, SP, aspect_ratio, r_max, n_iterations)
%VOLUTE_SIZING_ITERATE design/volute_sizing.py :: volute_sizing_iterate() portu.
%   Eq. (6-33)'u r6 uzerinde sabit-nokta iterasyonuyla cozer.
%
%   r_max verilmemisse (kasing kisiti yok): kare/dairesel kesit,
%       r6 = r4 + sqrt(A6/pi) civarinda bir baslangic tahmini kullanilir
%       (difuzor cikisinin HEMEN uzerinde konumlanan dairesel kesit).
%   r_max verilmisse: r6 = r4 ZORUNLU (s.125: "r6 = r4 is required"),
%       kesit dikdortgen/eliptik, eksenel-radyal en-boy orani
%       aspect_ratio (<=1.5) ile.
%
%   Cikti struct alanlari: r6, A6, aspect_ratio_used, cross_section.

if nargin < 4 || isempty(SP)
    SP = 1.0;
end
if nargin < 5 || isempty(aspect_ratio)
    aspect_ratio = 1.0;
end
if nargin < 6
    r_max = [];
end
if nargin < 7 || isempty(n_iterations)
    n_iterations = 20;
end

if ~isempty(r_max)
    r6 = r4;
    A6 = volute_full_collection_area(A4, r4, alpha4_deg, r6, SP);
    aspect_ratio_used = min(aspect_ratio, 1.5);
    result.r6 = r6;
    result.A6 = A6;
    result.aspect_ratio_used = aspect_ratio_used;
    result.cross_section = 'rectangular_or_elliptical';
    return;
end

r6 = r4 * 1.3;
A6 = volute_full_collection_area(A4, r4, alpha4_deg, r6, SP);
for iter = 1:n_iterations
    radius_of_cross_section = sqrt(A6 / pi);
    r6_new = r4 + radius_of_cross_section;
    A6_new = volute_full_collection_area(A4, r4, alpha4_deg, r6_new, SP);
    if abs(r6_new - r6) < 1.0e-9
        r6 = r6_new;
        A6 = A6_new;
        break;
    end
    r6 = r6_new;
    A6 = A6_new;
end

result.r6 = r6;
result.A6 = A6;
result.aspect_ratio_used = 1.0;
result.cross_section = 'square_or_circular';

end
