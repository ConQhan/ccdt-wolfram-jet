function angles = default_incidence_angles_deg()
%DEFAULT_INCIDENCE_ANGLES_DEG design/component_matching.py :: default_incidence_angles_deg() portu.
%   s.117: "Reasonable first estimates are i1=0, i3=-0.5 deg, i6=4 deg for
%   impellers, vaned diffusers and return channels, respectively."

angles.i1_deg = 0.0;
angles.i3_deg = -0.5;
angles.i6_deg = 4.0;

end
