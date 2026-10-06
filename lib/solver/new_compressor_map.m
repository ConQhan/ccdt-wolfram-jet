function cmap = new_compressor_map(design_rpm, design_mdot)
%NEW_COMPRESSOR_MAP solver/compressor_map.py :: CompressorMap dataclass portu.
%   Tum hiz egrilerini kapsayan kompresor haritasi.

if nargin < 1
    design_rpm = [];
end
if nargin < 2
    design_mdot = [];
end

cmap.speedlines = struct([]);
cmap.design_rpm = design_rpm;
cmap.design_mdot = design_mdot;

end
