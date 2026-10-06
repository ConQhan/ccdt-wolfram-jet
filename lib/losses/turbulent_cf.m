function cf_t = turbulent_cf(Re_d, roughness_e, d)
%TURBULENT_CF losses/skin_friction.py :: turbulent_cf() portu.
%   Eq. (5-5): Duz-puruzlu gecis agirliklandirmasi.
%   cf_t = cf_smooth                                       ; Re_e < 60
%   cf_t = cf_smooth + (cf_rough-cf_smooth)*(1-60/Re_e)     ; Re_e >= 60

cf_smooth = turbulent_smooth_cf(Re_d);
if roughness_e <= 0.0
    cf_t = cf_smooth;
    return
end

Re_e = roughness_reynolds(Re_d, roughness_e, d);
if Re_e < 60.0
    cf_t = cf_smooth;
    return
end

cf_rough = turbulent_rough_cf(roughness_e, d);
cf_t = cf_smooth + (cf_rough - cf_smooth) * (1.0 - 60.0 / Re_e);

end
