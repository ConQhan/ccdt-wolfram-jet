function cf = laminar_cf(Re_d)
%LAMINAR_CF losses/skin_friction.py :: laminar_cf() portu -- Eq. (5-1): cf = 16/Re_d (Re_d<2000).
if Re_d <= 0
    error('centrifugal:laminar_cf', 'Re_d pozitif olmali');
end
cf = 16.0 / Re_d;
end
