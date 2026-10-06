function chk = cdt_cfturbo_check(comps, det)
%CDT_CFTURBO_CHECK Geometry checks of a CFturbo export before meshing.
%   chk = cdt_cfturbo_check(comps) measures every component read by
%   cdt_read_cfturbo_export. chk = cdt_cfturbo_check(comps, det) also
%   compares the first bladed component (the impeller) with the MATLAB
%   design DET from cdt_design_details.
%
%   chk fields:
%     components - one row per blade row: edge positions, gaps, wrap, tip gap
%     interfaces - outlet of each component against the inlet of the next
%     compare    - impeller: CFturbo vs MATLAB (empty without DET)
%     warnings   - string array of problems that break TurboGrid or CFD
%
%   Known TurboGrid failures this check catches:
%     * blade edge on the domain inlet/outlet -> "Trim operation failed"
%     * neighbouring components that do not share the interface radius

warn = strings(0, 1);
rows = {};
for k = 1:numel(comps)
    c = comps(k);
    mid = cdt_mid_curve(c.hub, c.shroud);
    for b = 1:numel(c.blades)
        prof = c.blades{b};
        [hubP, tipP, tipGap, extended] = cdt_tip_profile(prof, c, mid);
        [LEh, TEh, mLE, mTE] = cdt_edges(hubP, mid);
        [LEt, TEt] = cdt_edges(tipP, mid);
        th = unwrap(atan2(hubP(:, 2), hubP(:, 1)));
        wrap = rad2deg(max(th) - min(th));
        gapIn = mLE;
        gapOut = mid.m(end) - mTE;
        if b == 1; label = 'main'; else; label = 'splitter'; end
        if extended
            tipTxt = "blade extended: gap set in TurboGrid";
        elseif tipGap == 0
            tipTxt = "none (blade on shroud)";
        else
            tipTxt = string(sprintf('%.3f', tipGap));
        end
        rows(end + 1, :) = {string(c.name), string(label), c.n_blades, LEh(1), LEh(2), LEt(1), LEt(2), ...
            TEh(1), TEh(2), TEt(1), TEt(2), gapIn, gapOut, wrap, tipTxt}; %#ok<AGROW>
        if b == 1 && gapOut < 0.5
            warn(end + 1) = sprintf(['%s: trailing edge only %.2f mm before the domain outlet. ' ...
                'TurboGrid may fail ("Trim operation failed"); extend the outlet or move the TE.'], c.name, gapOut); %#ok<AGROW>
        end
        if b == 1 && gapIn < 0.5
            warn(end + 1) = sprintf('%s: leading edge only %.2f mm after the domain inlet.', c.name, gapIn); %#ok<AGROW>
        end
    end
end
chk.components = cell2table(rows, 'VariableNames', {'component', 'blade', 'n_blades', ...
    'LE_hub_r', 'LE_hub_z', 'LE_tip_r', 'LE_tip_z', 'TE_hub_r', 'TE_hub_z', 'TE_tip_r', 'TE_tip_z', ...
    'LE_gap_to_inlet', 'TE_gap_to_outlet', 'wrap_deg', 'tip_gap_mm'});

% Interfaces between consecutive components
irows = {};
for k = 1:numel(comps) - 1
    a = comps(k); b = comps(k + 1);
    dh = norm(a.hub(end, :) - b.hub(1, :));
    ds = norm(a.shroud(end, :) - b.shroud(1, :));
    ok = dh < 0.05 && ds < 0.05;
    irows(end + 1, :) = {sprintf('%s -> %s', a.name, b.name), a.hub(end, 1), a.hub(end, 2), ...
        a.shroud(end, 1), a.shroud(end, 2), b.hub(1, 1), b.hub(1, 2), b.shroud(1, 1), b.shroud(1, 2), ok}; %#ok<AGROW>
    if ~ok
        warn(end + 1) = sprintf('%s -> %s: outlet and inlet do not coincide (hub %.2f mm, shroud %.2f mm apart).', ...
            a.name, b.name, dh, ds); %#ok<AGROW>
    end
end
if isempty(irows)
    chk.interfaces = table();
else
    chk.interfaces = cell2table(irows, 'VariableNames', {'interface', 'out_hub_r', 'out_hub_z', ...
        'out_shroud_r', 'out_shroud_z', 'in_hub_r', 'in_hub_z', 'in_shroud_r', 'in_shroud_z', 'coincide'});
end

chk.compare = table();
if nargin > 1 && ~isempty(det)
    chk.compare = cdt_compare_impeller(chk.components(1, :), comps(1), det);
end
chk.warnings = warn;
end

% ----------------------------------------------------------------------
function mid = cdt_mid_curve(hub, shroud)
% Mid-channel line (hub and shroud resampled by normalised arc length)
n = 400;
H = cdt_resample(hub, n);
S = cdt_resample(shroud, n);
mid.rz = 0.5 * (H + S);
mid.m = [0; cumsum(hypot(diff(mid.rz(:, 1)), diff(mid.rz(:, 2))))];
mid.H = H;
mid.S = S;
mid.width = hypot(H(:, 1) - S(:, 1), H(:, 2) - S(:, 2));
end

function P = cdt_resample(rz, n)
s = [0; cumsum(hypot(diff(rz(:, 1)), diff(rz(:, 2))))];
[s, iu] = unique(s / s(end));
P = interp1(s, rz(iu, :), linspace(0, 1, n)');
end

function [LE, TE, mLE, mTE] = cdt_edges(P, mid)
rz = [hypot(P(:, 1), P(:, 2)), P(:, 3)];
[~, j] = min(pdist2(rz, mid.rz), [], 2);
m = mid.m(j);
[mLE, a] = min(m);
[mTE, b] = max(m);
LE = rz(a, :);
TE = rz(b, :);
end

function [hubP, tipP, gap, extended] = cdt_tip_profile(prof, c, ~)
% Hub profile = first one. The signed distance to the shroud (positive
% inside the channel) tells whether a profile lies beyond the shroud: then
% the blade is extended and TurboGrid creates the tip gap. Otherwise the
% tip gap is the distance of the outermost profile below the shroud.
hubP = prof{1};
n = numel(prof);
ds = zeros(n, 1);
beyond = false(n, 1);
for k = 1:n
    rz = [hypot(prof{k}(:, 1), prof{k}(:, 2)), prof{k}(:, 3)];
    d = cdt_signed_distance(rz, c.shroud, c.hub);
    beyond(k) = any(d < -0.02);
    ds(k) = median(abs(d));
end
extended = any(beyond);
if extended
    [~, kt] = min(ds .* ~beyond + 1e3 * beyond);   % outermost profile inside
else
    [~, kt] = min(ds);
end
tipP = prof{kt};
cand = ds(2:end);
cand = cand(cand > 0.01 & ~beyond(2:end));
gap = min([cand; Inf]);
if isinf(gap) || gap > 1.5; gap = 0; end     % no profile close to the shroud
end

function d = cdt_signed_distance(P, S, H)
% Distance of points P to polyline S, positive on the side of polyline H.
A = S(1:end - 1, :); B = S(2:end, :); AB = B - A;
L2 = sum(AB .^ 2, 2);
d = zeros(size(P, 1), 1);
sgnH = 0;
for i = 1:size(P, 1)
    t = max(0, min(1, ((P(i, 1) - A(:, 1)) .* AB(:, 1) + (P(i, 2) - A(:, 2)) .* AB(:, 2)) ./ L2));
    Q = A + t .* AB;
    dist = hypot(P(i, 1) - Q(:, 1), P(i, 2) - Q(:, 2));
    [d(i), j] = min(dist);
    nrm = [-AB(j, 2), AB(j, 1)];
    if sgnH == 0
        [~, h] = min(hypot(H(:, 1) - Q(j, 1), H(:, 2) - Q(j, 2)));
        sgnH = sign(nrm * (H(h, :) - Q(j, :))');
    end
    if sign(nrm * (P(i, :) - Q(j, :))') == -sgnH && d(i) > 1e-6
        d(i) = -d(i);
    end
end
end

function T = cdt_compare_impeller(row, c, det)
bd = det.blade;
g = det.design.impeller_geometry;
mat = [bd.hub.r(1), bd.hub.z(1), bd.shroud.r(1), bd.shroud.z(1), bd.hub.r(end), bd.hub.z(end), ...
    bd.shroud.r(end), bd.shroud.z(end)] * 1e3;
% CFturbo z is measured from its own inlet; shift MATLAB so both LE hub z match
dz = row.LE_hub_z - mat(2);
cf = [row.LE_hub_r, row.LE_hub_z, row.LE_tip_r, row.LE_tip_z, row.TE_hub_r, row.TE_hub_z, ...
    row.TE_tip_r, row.TE_tip_z];
mat([2 4 6 8]) = mat([2 4 6 8]) + dz;
q = ["LE hub r"; "LE hub z"; "LE shroud r"; "LE shroud z"; "TE hub r"; "TE hub z"; "TE shroud r"; "TE shroud z"];
q(end + 1) = "b2 at TE";
cf(end + 1) = abs(row.TE_hub_z - row.TE_tip_z);
mat(end + 1) = g.b2_m * 1e3;
q(end + 1) = "Blade axial length (hub)";
cf(end + 1) = row.TE_hub_z - row.LE_hub_z;
mat(end + 1) = (bd.hub.z(end) - bd.hub.z(1)) * 1e3;
q(end + 1) = "Wrap angle (hub)";
cf(end + 1) = row.wrap_deg;
mat(end + 1) = bd.wrap_hub_deg;
T = table(q, cf(:), mat(:), cf(:) - mat(:), 'VariableNames', {'quantity', 'CFturbo', 'MATLAB', 'difference'});
T.Properties.Description = 'Lengths in mm, angles in deg. MATLAB z shifted to the CFturbo LE hub z.';
if isfield(g, 'tip_clearance_m'); end %#ok<ISFLD> tip clearance shown in the components table
if c.n_blades ~= g.n_blades_full + g.n_blades_splitter
    T(end + 1, :) = {"Blade count", c.n_blades, g.n_blades_full + g.n_blades_splitter, ...
        c.n_blades - g.n_blades_full - g.n_blades_splitter};
end
end
