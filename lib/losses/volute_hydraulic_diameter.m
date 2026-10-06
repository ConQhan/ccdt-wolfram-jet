function d_H = volute_hydraulic_diameter(A6)
%VOLUTE_HYDRAULIC_DIAMETER losses/volute_losses.py portu.
%   Eq. (5-109) icindeki dH = sqrt(4*A6/pi) (dairesel kesit esdegeri)
d_H = sqrt(4.0 * A6 / pi);
end
