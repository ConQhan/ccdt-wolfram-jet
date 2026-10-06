function pt = new_map_point()
%NEW_MAP_POINT solver/compressor_map.py :: MapPoint dataclass portu.
%   Tek bir (RPM, mdot) calisma noktasinin sonucu.

pt.rpm = 0.0;
pt.mdot = 0.0;
pt.ok = false;
pt.model_valid = true;  % false = surge/stall bolgesi uyarisi
pt.fail_reason = '';

pt.PR_tt = NaN;
pt.eta_tt_pct = NaN;
pt.specific_work_kJ_kg = NaN;
pt.phi = NaN;  % anlik akis katsayisi (geometriden degil, mdot/U2/rho'dan)

end
