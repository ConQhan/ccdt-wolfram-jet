function imp = impeller_new(eos, loss_coeffs, geometry, solver_options, mu_Pa_s, roughness_m)
%IMPELLER_NEW components/impeller.py :: Impeller.__init__() portu.
%   Dogrulanmis Aungier formullerini zincirleyen impeller analiz yapisi.

if nargin < 5 || isempty(mu_Pa_s); mu_Pa_s = 1.8e-5; end
if nargin < 6 || isempty(roughness_m); roughness_m = 1.0e-6; end

imp.eos = eos;
imp.loss_coeffs = loss_coeffs;
imp.geometry = geometry;
imp.solver_options = solver_options;
imp.mu = mu_Pa_s;
imp.roughness = roughness_m;
imp.omega_rad_s = 2.0 * pi * struct_get(geometry, 'rotational_speed_rpm', 0.0) / 60.0;
imp.z_eff = geometry.n_blades_full + struct_get(geometry, 'n_blades_splitter', 0) * struct_get(geometry, 'splitter_length_ratio', 0.5);

end
