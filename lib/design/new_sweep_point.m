function pt = new_sweep_point()
%NEW_SWEEP_POINT design/parametric_sweep.py :: SweepPoint dataclass portu.
%   Tek bir (rpm, r2, mdot, diffuser_type, impeller_type, stage_type)
%   noktasinin sonucu. Tum alanlar Python dataclass varsayilanlariyla
%   ayni degerlerle baslatilir.

% --- Girdiler ---
pt.rpm = 0.0;
pt.r2_m = 0.0;
pt.mdot = 0.0;
pt.diffuser_type = '';
pt.impeller_type = '';
pt.stage_type = 'voluted';
pt.splitter_length_ratio = 0.50;
pt.p0 = 101325.0;
pt.T0 = 288.15;
pt.r_min_m = NaN;               % [YENI] goz/mil yaricap kisiti (verilmisse)
pt.r_max_m = NaN;               % [YENI] kasa yaricap kisiti (verilmisse)
pt.inlet_prewhirl_angle_deg = 0.0;  % [YENI]
pt.b2_over_r2_ratio = NaN;          % tip kanal genisligi orani (NaN: Aungier Eq 6-10 + sureklilik)
pt.plenum_target_C_exit_m_s = NaN;  % [YENI] stage_type='dump_with_plenum' icin hedef hiz

% --- Birincil performans metrikleri ---
pt.ok = false;
pt.fail_reason = '';

pt.phi = NaN;
pt.U2_m_s = NaN;
pt.PR_tt = NaN;
pt.eta_tt_pct = NaN;
pt.specific_work_kJ_kg = NaN;
pt.Power_kW = NaN;          % [YENI] = mdot * specific_work -- eta'dan bagimsiz, daha az hassas
pt.M1s_rel = NaN;            % [YENI] inducer shroud bagil Mach sayisi
pt.mass_flow_balance_ok = false;
pt.C2_impeller_exit_m_s = NaN;   % [YENI]
pt.C_exit_m_s = NaN;             % [YENI] kademe cikis (difuzor sonrasi) hizi
pt.diffuser_physically_valid = NaN;  % [YENI] C_exit <= C2 mi (false ise sahte cozum)

% --- Impeller geometrisi (BladeGen girdisi) ---
pt.r1_hub_mm = NaN;
pt.r1_shroud_mm = NaN;
pt.r2_mm = NaN;
pt.b2_mm = NaN;
pt.beta1_deg = NaN;
pt.beta2_deg = NaN;
pt.n_blades_full = 0;
pt.n_blades_splitter = 0;
pt.axial_length_mm = NaN;  % [KOPRU_TAHMINI] camberline uzunlugu yaklasimi

% --- Difuzor geometrisi ---
pt.r3_mm = NaN;   % vaned: vane LE, vaneless: = r4
pt.r4_mm = NaN;
pt.b4_mm = NaN;
pt.n_vanes_diffuser = 0;  % vaned icin, yoksa 0
pt.beta3_diff_deg = NaN;
pt.beta4_diff_deg = NaN;

% --- Crossover + Return channel (sadece stage_type='return_channel') ---
pt.r6_mm = NaN;
pt.b6_mm = NaN;
pt.R_ch_mm = NaN;
pt.r7_mm = NaN;
pt.b7_mm = NaN;

% --- Volut (sadece stage_type='voluted') ---
pt.r_volute_mm = NaN;
pt.A_volute_cm2 = NaN;

% --- Dump plenum (sadece stage_type='dump_with_plenum') [YENI] ---
pt.r5_mm = NaN;
pt.b5_mm = NaN;
pt.A5_cm2 = NaN;

% --- Genel disaridan boyut kontrolu [YENI] ---
pt.D2_mm = NaN;              % = 2*r2_mm, kolaylik icin
pt.D_overall_mm = NaN;       % = 2*max(r4_mm, r_volute_mm) -- kademenin kapladigi en genis cap
pt.fits_casing = NaN;        % r_max_m verilmisse: D_overall_mm/2 <= r_max_m*1000 mi (bool, NaN=kontrol edilmedi)

% --- Kayip katsayilari ---
pt.omega_impeller = NaN;
pt.omega_diffuser = NaN;
pt.omega_crossover = NaN;
pt.omega_return_channel = NaN;
pt.omega_volute = NaN;
pt.omega_plenum = NaN;

end
