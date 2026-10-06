function result = march_vaneless_passage(mdot, r_in, r_out, b_in, b_out, Cm_in, Cu_in, ...
    p_in, T_in, eos, mu, roughness_m, delta_in, kappa_m, sin_alpha_C, n_steps, inner_iterations)
%MARCH_VANELESS_PASSAGE core/marching.py :: march_vaneless_passage() portu.
%   Eq. (5-44) -> (5-47)'yi giris istasyonundan cikisa marching ile cozer.
%
%   Cift yonlu pasaj desteklenir: r_out>r_in (disa akan, vanesiz difuzor)
%   VEYA r_out<r_in (ice akan, crossover bend). Yon r_in/r_out
%   karsilastirmasindan OTOMATIK cikarilir; sin_alpha_C bir BUYUKLUK
%   ([0,1], 1.0=tam radyal), YON ayri (`direction`) ile ele alinir.
%
%   Girdiler (Python docstring'iyle birebir):
%     mdot: kutlesel debi [kg/s] (korunan)
%     r_in,r_out: pasaj giris/cikis yaricapi [m]
%     b_in,b_out: pasaj giris/cikis genisligi [m] (aradaki degisim dogrusal)
%     Cm_in,Cu_in: giris ORTALAMA meridyenel/tegetsel hiz [m/s]
%     p_in,T_in: giris STATIK basinc/sicaklik [Pa,K]
%     eos: ideal_gas_eos() struct'i
%     mu: gaz viskozitesi [Pa.s]
%     roughness_m: peak-to-valley yuzey puruzlulugu [m] (varsayilan 1e-6)
%     delta_in: giris sinir tabakasi kalinligi [m]; [] ise Eq(5-61) ile tahmin edilir
%     kappa_m: pasaj egriligi [1/m], HER ZAMAN POZITIF (varsayilan 0.0)
%     sin_alpha_C: meridyenel hat egim acisinin sinusunun BUYUKLUGU (varsayilan 1.0)
%     n_steps: marching adim sayisi (varsayilan 150)
%     inner_iterations: her adimda fixed-point iterasyon sayisi (varsayilan 6)
%
%   Cikti: result struct -- stations (1xN struct dizisi), omega_total,
%   I_D_total, I_C_total, direction.

if nargin < 12 || isempty(roughness_m); roughness_m = 1.0e-6; end
if nargin < 13; delta_in = []; end
if nargin < 14 || isempty(kappa_m); kappa_m = 0.0; end
if nargin < 15 || isempty(sin_alpha_C); sin_alpha_C = 1.0; end
if nargin < 16 || isempty(n_steps); n_steps = 150; end
if nargin < 17 || isempty(inner_iterations); inner_iterations = 6; end

if r_out == r_in
    error('centrifugal:march_vaneless_passage', ...
        'march_vaneless_passage: r_in ve r_out birbirine esit olamaz (sifir uzunluklu pasaj).');
end

direction = 1.0;
if r_out < r_in
    direction = -1.0;
end
sin_alpha_C_signed = direction * sin_alpha_C;

dm = abs(r_out - r_in) / n_steps / sin_alpha_C;

C_in = hypot(Cm_in, Cu_in);
if isfield(eos, 'cp') && ~isempty(eos.cp)
    cp = eos.cp;
else
    cp = eos_enthalpy(eos, p_in, T_in + 1.0) - eos_enthalpy(eos, p_in, T_in);
end
ht_in = eos_enthalpy(eos, p_in, T_in) + 0.5 * C_in^2;

rho_in = eos_density(eos, p_in, T_in);

% Giris blokaji: sureklilikten TAM (yaklasik degil) hesaplanir.
B_in = 1.0 - mdot / (rho_in * Cm_in * 2.0 * pi * r_in * b_in);
if B_in < -1.0e-6
    error('centrifugal:march_vaneless_passage', ...
        ['march_vaneless_passage: giris verisi tutarsiz -- verilen mdot (%.4g kg/s), ' ...
         'Cm_in (%.4g m/s) ve geometri (r_in=%.4g, b_in=%.4g) ile sureklilik (Eq 5-44) ' ...
         'negatif blokaj (B_in=%.4g) gerektiriyor; bu fiziksel olarak imkansizdir. ' ...
         'Cm_in''i artirin veya mdot''u azaltin.'], mdot, Cm_in, r_in, b_in, B_in);
end
B_in = max(B_in, 0.0);

if isempty(delta_in)
    if B_in > 1.0e-6
        delta_in = 4.0 * b_in * B_in;  % Eq (5-58) tersinden
    else
        % [DUZELTME -- H10 ile birlikte] Giris ortalama (karismis) akis ise
        % sureklilik blokaj bilgisi tasimaz. Aungier Eq (5-61):
        % 2*delta/b = 1 - (b/r)^0.15 ile baslangic sinir tabakasi; mutlak
        % Cm_in ORTALAMA hiz oldugu icin cekirdek hiz kutle korunacak sekilde
        % Cm_in/(1-B_in) olarak alinir (B = delta/(4b), Eq 5-58).
        delta_in = 0.5 * b_in * (1.0 - (b_in / r_in)^0.15);
        B_in = delta_in / (4.0 * b_in);
        Cm_in = mdot / (rho_in * 2.0 * pi * r_in * b_in * (1.0 - B_in));
        C_in = hypot(Cm_in, Cu_in);
        ht_in = eos_enthalpy(eos, p_in, T_in) + 0.5 * C_in^2;
    end
end
delta_in = min(delta_in, b_in / 2.0);

rCu_avg_in = r_in * Cu_in;
rCu_edge = edge_angular_momentum_from_inlet(rCu_avg_in, delta_in, b_in);

pt_in_state = eos_total_from_static(eos, p_in, T_in, C_in);
pt_in = pt_in_state.p;

rb_1 = r_in * b_in;

station0 = struct('m', 0.0, 'r', r_in, 'b', b_in, 'Cm', Cm_in, 'Cu', Cu_in, 'C', C_in, ...
    'p', p_in, 'T', T_in, 'rho', rho_in, 'pt', pt_in, 'delta', delta_in, 'B', B_in, ...
    'flow_angle', atan2(Cm_in, Cu_in), 'I_D', 0.0);
stations = station0;

L_total = abs(r_out - r_in) / sin_alpha_C;

r_prev = r_in; b_prev = b_in;
Cm_prev = Cm_in; Cu_prev = Cu_in;
p_prev = p_in; T_prev = T_in; rho_prev = rho_in; C_prev = C_in;
rCu_avg_prev = rCu_avg_in;
I_D_running = 0.0;
I_C_running = 0.0;

for i = 1:n_steps
    r_next = r_in + (r_out - r_in) * i / n_steps;
    b_next = b_in + (b_out - b_in) * i / n_steps;
    m_next = i * dm;

    delta_prev = stations(end).delta;
    if delta_prev > 0
        Re_d_prev = rho_prev * C_prev * (2.0 * delta_prev) / mu;
    else
        Re_d_prev = 1.0;
    end
    cf_prev = skin_friction_coefficient(Re_d_prev, roughness_m, max(2.0 * delta_prev, 1.0e-6));

    d_rCu_dm = -r_prev * C_prev * Cu_prev * cf_prev / (b_prev * Cm_prev);
    rCu_avg_next = rCu_avg_prev + dm * d_rCu_dm;
    Cu_next = rCu_avg_next / r_next;

    Cm_next = Cm_prev;
    p_next = p_prev; T_next = T_prev; rho_next = rho_prev; C_next = C_prev; %#ok<NASGU>
    I_D_candidate = I_D_running;

    for inner = 1:inner_iterations %#ok<NASGU>
        dCm_dm = (Cm_next - Cm_prev) / dm;
        C_candidate = hypot(Cm_next, Cu_next);
        dC_dm = (C_candidate - C_prev) / dm;

        T_candidate = (ht_in - 0.5 * C_candidate^2) / cp;

        r_avg = 0.5 * (r_prev + r_next);
        b_avg = 0.5 * (b_prev + b_next);
        Cm_avg = 0.5 * (Cm_prev + Cm_next);
        Cu_avg = 0.5 * (Cu_prev + Cu_next);
        C_avg = 0.5 * (C_prev + C_candidate);
        rho_avg = rho_prev;

        if Cu_avg ~= 0
            flow_angle = atan2(Cm_avg, Cu_avg);
        else
            flow_angle = pi / 2.0;
        end
        D_local = divergence_parameter_local(b_avg, C_avg, dC_dm);
        Dm_local = optimum_divergence_local(b_in, L_total, flow_angle);
        E = diffusion_efficiency(D_local, Dm_local);

        pt_minus_p = stations(end).pt - p_prev;

        dI_D_dm = diffusion_loss_rate(pt_minus_p, E, rho_avg, C_avg, dC_dm);
        I_D_step = dI_D_dm * dm;

        I_C_local = curvature_loss(kappa_m, pt_minus_p, Cm_avg, rho_avg, C_avg);

        dp_dm = rho_avg * ( ...
            (Cu_avg^2) * sin_alpha_C_signed / r_avg ...
            - Cm_avg * dCm_dm ...
            - C_avg * Cm_avg * cf_prev / b_avg ...
            - dI_D_dm ...
            - I_C_local);
        p_candidate = p_prev + dp_dm * dm;
        rho_candidate = eos_density(eos, p_candidate, T_candidate);

        rb_m_envelope = max_stall_free_rb(rb_1, m_next, b_in);
        rb_local = r_next * b_next;
        I_D_candidate = I_D_running + I_D_step;
        I_D_alt = diffusion_loss_alternate(pt_minus_p, rb_m_envelope, rb_local, rho_candidate);
        if I_D_alt > I_D_candidate
            I_D_candidate = I_D_alt;
        end

        [B_candidate, ~] = boundary_layer_blockage_from_edge_ratio(rCu_avg_next, rCu_edge);

        Cm_updated = mdot / (2.0 * pi * r_next * rho_candidate * b_next * (1.0 - B_candidate));

        converged = abs(Cm_updated - Cm_next) < 1.0e-7 * max(Cm_updated, 1.0);

        Cm_next = Cm_updated;
        p_next = p_candidate; T_next = T_candidate; rho_next = rho_candidate;
        C_next = hypot(Cm_next, Cu_next);

        if converged
            break
        end
    end

    I_D_running = I_D_candidate;
    I_C_running = I_C_running + curvature_loss(kappa_m, stations(end).pt - p_prev, ...
        0.5 * (Cm_prev + Cm_next), rho_prev, 0.5 * (C_prev + C_next)) * dm;

    if rCu_edge
        ratio_next = rCu_avg_next / rCu_edge;
    else
        ratio_next = 1.0;
    end
    delta_next = boundary_layer_thickness_from_ratio(ratio_next, b_next);
    [B_next, ~] = boundary_layer_blockage_from_edge_ratio(rCu_avg_next, rCu_edge);
    pt_next_state = eos_total_from_static(eos, p_next, T_next, C_next);
    pt_next = pt_next_state.p;

    station = struct('m', m_next, 'r', r_next, 'b', b_next, 'Cm', Cm_next, 'Cu', Cu_next, ...
        'C', C_next, 'p', p_next, 'T', T_next, 'rho', rho_next, 'pt', pt_next, ...
        'delta', delta_next, 'B', B_next, 'flow_angle', atan2(Cm_next, Cu_next), 'I_D', I_D_running);
    stations(end+1) = station; %#ok<AGROW>

    r_prev = r_next; b_prev = b_next;
    Cm_prev = Cm_next; Cu_prev = Cu_next;
    p_prev = p_next; T_prev = T_next; rho_prev = rho_next; C_prev = C_next;
    rCu_avg_prev = rCu_avg_next;
end

outlet = stations(end);
omega_total = (pt_in - outlet.pt) / (pt_in - p_in);

result.stations = stations;
result.omega_total = omega_total;
result.I_D_total = outlet.I_D;
result.I_C_total = I_C_running;
result.direction = direction;

end
