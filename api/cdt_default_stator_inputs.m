function st = cdt_default_stator_inputs()
%CDT_DEFAULT_STATOR_INPUTS Inputs of the stator preliminary sizing.
%   Impeller exit state defaults: V2 fine-mesh CFD (CFX_015) at the design
%   point 0.585 kg/s, 70 000 rpm, mass-averaged at r2 = 66 mm.

st.mdot = 0.585;            % design mass flow [kg/s]
st.mdot_choke = 0.649;      % impeller choke mass flow; sizes the diffuser throat [kg/s]
st.r2_mm = 66;              % impeller exit radius
st.b2_mm = 5.41;            % impeller exit width (vaneless gap and diffuser keep it)
st.Cu2 = 336.11;            % impeller exit tangential velocity [m/s]
st.Cm2 = 125.80;            % impeller exit meridional velocity [m/s]
st.p2 = 242971.0;           % impeller exit static pressure [Pa]
st.T2 = 384.398;            % impeller exit static temperature [K]

% Combustor requirement at the stator exit
st.Cx_out = 30.0;           % axial velocity after the annular expansion [m/s]
st.Cu_out = 21.0;           % tangential velocity [m/s]

% Vaned diffuser
st.z_vanes = 13:2:31;       % vane counts to try (odd: no common divisor with 10/20)
st.r4_mm = 80:4:104;        % vane exit radii to try
st.alpha4_deg = 25:2.5:55;  % exit flow angles to try (from tangential)
st.t_le_mm = 0.8;           % vane thickness used in the throat sizing
st.blockage_exit = 0.05;    % exit blockage
st.loss_coef = 0.05;        % diffuser total pressure loss coefficient (density estimate)
st.carter_m = 0.25;         % Carter deviation constant: delta = m * theta / sqrt(sigma)
st.two_theta_max = 11;      % Aungier Eq 6-26 equivalent divergence limit [deg]
st.loading_max = 1/3;       % Aungier Eq 6-27 vane loading limit

% Bend + axial guide vanes
st.annulus_height_mm = 4:0.5:16;
st.max_rows = 2;
st.de_haller_min = 0.72;
end
