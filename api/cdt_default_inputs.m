function in = cdt_default_inputs()
%CDT_DEFAULT_INPUTS Default input set for the compressor design workflow.
%   in = cdt_default_inputs() returns a struct with every input used by the
%   sweep / design / blade / CFturbo-input steps. All lengths are in mm and
%   all angles in degrees unless the field name says otherwise.
%
%   Defaults reproduce the project design point (V3): 0.585 kg/s, 70 000 rpm,
%   open impeller with 10 main + 10 splitter blades, 0.3 mm tip clearance.

% --- Operating point
in.mdot = 0.585;            % design mass flow [kg/s]
in.N_rpm = 70000;           % shaft speed [rpm]
in.p0 = 101325.0;           % inlet total pressure [Pa]
in.T0 = 288.15;             % inlet total temperature [K]

% --- Gas (ideal gas, constant properties)
in.R = 287.05;              % [J/(kg K)]
in.gamma = 1.4;             % [-]
in.cp = 1005.0;             % [J/(kg K)]

% --- Machine configuration
in.impeller_type = 'open';      % 'open' (unshrouded) | 'covered'
in.diffuser_type = 'vaneless';  % 'vaneless' | 'vaned' (1D model)
in.stage_type = 'dump';         % 'dump': diffuser exit is the stage exit
in.n_blades_main = 10;          % main blades (same number of splitters)
in.splitter_ratio = 0.70;       % splitter length / main blade length
in.tip_clearance_mm = 0.3;      % open impeller tip clearance
in.le_thickness_hub_mm = 0.8;   % leading edge thickness at hub
in.le_thickness_shroud_mm = 0.5;% leading edge thickness at shroud
in.b2_mm = NaN;                 % NaN: b2 from Aungier Eq 6-10 + continuity

% --- Sweep grid
in.r2_mm = 60:1:72;             % impeller tip radius values
in.r1_hub_mm = 7:1:12;          % inlet hub radius values

% --- Selection criteria
in.PR_min = 3.5;                % minimum stage PR after the exit bend
in.zeta_bend = 0.4;             % exit bend loss coefficient (dynamic head)
in.r_max_mm = 125;              % casing radius limit
in.blade_loading_max = 1.0;     % Aungier Eq 7-60 hard limit (dW/W <= 1)
in.shaft_tau_MPa = 40;          % allowable shaft shear stress
in.shaft_SF = 1.25;             % shaft safety factor
in.phi_min = 0.003;             % flow coefficient window
in.phi_max = 0.20;
in.U2_max = 700;                % tip speed limit [m/s]

% --- Selected design (empty: highest efficiency among feasible points)
in.select_r2_mm = [];
in.select_r1_hub_mm = [];

% --- Blade design (1D)
in.n_blade_points = 41;         % points along each meanline
end
