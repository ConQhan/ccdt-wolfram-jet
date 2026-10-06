function comps = sweep_build_components(eos, design, impeller_type, diffuser_type, stage_type) %#ok<INUSD>
%SWEEP_BUILD_COMPONENTS design/parametric_sweep.py :: _build_components() portu.
%   design cikisindan bilesen listesi olusturur (impeller_type Python
%   kaynaginda da fonksiyon govdesinde KULLANILMIYOR -- imza uyumu icin
%   parametre olarak tutuluyor).
%
%   Cikti: Nx2 cell array, run_stage_pipeline'in bekledigi {label, fn} formunda.

imp = impeller_new(eos, struct(), design.impeller_geometry, struct('mass_flow_tolerance', 1e-6));
comps = {'impeller', @(inlet) impeller_compute(imp, inlet)};

% [YENI -- preswirl] inlet_prewhirl_angle_deg != 0 ise pipeline'a bir IGV
% bileseni PREPEND edilir (Eq 5-9-5-21 kayip zinciri, igv_compute.m).
% =0 (varsayilan) ise pipeline HICBIR SEKILDE degismez -- geriye-donuk
% uyumluluk (impeller kendi ic Cu1'ini zaten g.inlet_prewhirl_angle_deg
% uzerinden bagimsiz olarak aliyor; IGV bileseni SADECE fiziksel kanat
% kaybini -- Eq 5-21 -- hesaba katmak icin ayri bir muhasebe).
prewhirl_deg = struct_get(design.impeller_geometry, 'inlet_prewhirl_angle_deg', 0.0);
if prewhirl_deg ~= 0.0
    g = design.impeller_geometry;
    A_eye = pi * (g.r1_shroud_m^2 - g.r1_hub_m^2);
    igv_geometry.target_alpha_0_deg = prewhirl_deg;
    igv_geometry.A_m1_m2 = A_eye;
    igv_geometry.A_0_m2 = A_eye;
    igv_geometry.sigma = struct_get(g, 'igv_solidity', 1.1);  % [KOPRU_TAHMINI] tipik IGV solidite araligi ~1.0-1.2
    igv_geometry.beta_m1_deg = 90.0;  % [KOPRU_TAHMINI] eksenel yaklasim (teget'ten 90 derece)
    igv_geometry.Gamma = 0.0;  % [KOPRU_TAHMINI -- kaynakta tanimlanmamis, bkz. igv_equivalent_diffusion_factor.m]
    igv_geometry.r_ref_m = g.r1_shroud_m;

    comps = [{'igv', @(inlet) igv_compute(eos, igv_geometry, inlet)}; comps];
end

if strcmp(diffuser_type, 'vaneless')
    comps(end+1, :) = {'vaneless_diffuser', @(inlet) vaneless_diffuser_compute(eos, design.diffuser_geometry, inlet)};
else
    comps(end+1, :) = {'vaned_diffuser', @(inlet) vaned_diffuser_compute(eos, design.diffuser_geometry, inlet)};
end

if strcmp(stage_type, 'return_channel')
    comps(end+1, :) = {'crossover_bend', @(inlet) crossover_bend_compute(eos, design.crossover_geometry, inlet)};
    comps(end+1, :) = {'return_channel', @(inlet) return_channel_compute(eos, design.return_channel_geometry, inlet)};
elseif strcmp(stage_type, 'voluted')
    comps(end+1, :) = {'volute', @(inlet) volute_compute(eos, design.volute_geometry, inlet)};
elseif strcmp(stage_type, 'dump_with_plenum')
    comps(end+1, :) = {'plenum', @(inlet) annular_dump_plenum_compute(eos, design.plenum_geometry, inlet)};
end
% stage_type == 'dump': hicbir toplayici bileseni eklenmiyor -- pipeline
% difuzor cikisinda (istasyon 4) sona eriyor (bkz. design_preliminary_stage.m).

end
