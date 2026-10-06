function [C_theta, C_L] = correction_coefficients(two_theta_C_deg, L)
%CORRECTION_COEFFICIENTS losses/vaned_diffuser_losses.py portu.
%   Eq. (5-78): C_theta = max(1, 2*theta_C/11) ; C_L = max(1, 3*L)
%   (kaynaktaki OCR/yorum belirsizligi -- bu yorum kaynak dosyada
%   benimsenmis, birebir tasindi: esik alti 1'e sabit, esik ustu
%   oranti ile buyuyen duzeltme katsayilari.)
C_theta = max(1.0, two_theta_C_deg / 11.0);
C_L = max(1.0, 3.0 * L);
end
