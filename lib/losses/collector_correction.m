function omega_U_collector = collector_correction(omega_U)
%COLLECTOR_CORRECTION losses/volute_losses.py portu.
%   Eq. (5-108): (omega_U)_collector = (1+omega_U)/2
%   Sadece collector (volut DEGIL, kesiti cevresel olarak SABIT olan
%   toplayici) icin.
omega_U_collector = 0.5 * (1.0 + omega_U);
end
