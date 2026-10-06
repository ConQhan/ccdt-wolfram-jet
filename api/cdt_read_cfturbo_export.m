function comps = cdt_read_cfturbo_export(folder)
%CDT_READ_CFTURBO_EXPORT Read CFturbo -> TurboGrid export files.
%   comps = cdt_read_cfturbo_export(folder) reads every export found in
%   FOLDER. FOLDER is either one export folder (with *.inf, *_hub.curve,
%   *_shroud.curve, *_profile.curve) or the CFturbo project folder (dp0\CFT)
%   that holds one {GUID} subfolder per export.
%
%   comps(k) fields:
%     name     - component name(s) from the CFturbo batch result, or folder name
%     folder   - export folder
%     inf      - struct of the .inf key/value pairs (e.g. Number_of_Blade_Sets)
%     hub      - [r z] hub curve [mm]
%     shroud   - [r z] shroud curve [mm]
%     blades   - cell of blades; each blade is a cell of profiles (N x 3 xyz [mm])
%     n_blades - number of blades in the full row (sets x blades per set)

folders = cdt_export_folders(folder);
if isempty(folders)
    error('cdt:export', 'No CFturbo export (*.inf) found in %s', folder);
end
names = cdt_component_names(folder);

comps = struct('name', {}, 'folder', {}, 'inf', {}, 'hub', {}, 'shroud', {}, ...
    'blades', {}, 'n_blades', {});
for k = 1:numel(folders)
    f = folders{k};
    infFile = dir(fullfile(f, '*.inf'));
    inf = cdt_read_inf(fullfile(f, infFile(1).name));
    scale = 1;
    if isfield(inf, 'Geometry_Units') && strcmpi(inf.Geometry_Units, 'M'); scale = 1000; end
    if isfield(inf, 'Geometry_Units') && strcmpi(inf.Geometry_Units, 'CM'); scale = 10; end

    c.folder = f;
    [~, guid] = fileparts(f);
    if isKey(names, guid); c.name = names(guid); else; c.name = guid; end
    c.inf = inf;
    c.hub = cdt_read_curve(fullfile(f, inf.Hub_Data_File), scale);
    c.shroud = cdt_read_curve(fullfile(f, inf.Shroud_Data_File), scale);
    c.blades = cdt_read_profiles(fullfile(f, inf.Profile_Data_File), scale);
    c.n_blades = str2double(inf.Number_of_Blade_Sets) * str2double(inf.Number_of_Blades_Per_Set);
    comps(end + 1) = c; %#ok<AGROW>
end

% Order along the flow path: by the radius / axial position of the inlet
key = arrayfun(@(c) c.hub(1, 1) + c.hub(1, 2), comps);
[~, order] = sort(key);
comps = comps(order);
end

function folders = cdt_export_folders(folder)
if ~isempty(dir(fullfile(folder, '*.inf')))
    folders = {folder};
    return;
end
d = dir(folder);
d = d([d.isdir] & ~startsWith({d.name}, '.'));
folders = {};
for k = 1:numel(d)
    f = fullfile(folder, d(k).name);
    if ~isempty(dir(fullfile(f, '*.inf'))); folders{end + 1} = f; end %#ok<AGROW>
end
end

function names = cdt_component_names(folder)
% The batch result file lists the export ID and the component caption(s).
names = containers.Map();
res = dir(fullfile(folder, '*.cft-res'));
if isempty(res); return; end
txt = fileread(fullfile(folder, res(1).name));
blocks = regexp(txt, '<ID>(\{[^}]*\})</ID>(.*?)</BatchAction>', 'tokens');
for k = 1:numel(blocks)
    caps = regexp(blocks{k}{2}, 'Caption="\[([^\]]*)\]"', 'tokens');
    if ~isempty(caps)
        names(blocks{k}{1}) = strjoin(cellfun(@(c) c{1}, caps, 'UniformOutput', false), ' + ');
    end
end
end

function s = cdt_read_inf(file)
s = struct();
L = readlines(file);
for k = 1:numel(L)
    t = split(L(k), ':');
    if numel(t) < 2; continue; end
    key = matlab.lang.makeValidName(replace(strtrim(t(1)), " ", "_"));
    s.(key) = strtrim(strjoin(t(2:end), ':'));
end
s = cdt_char_fields(s);
end

function s = cdt_char_fields(s)
f = fieldnames(s);
for k = 1:numel(f); s.(f{k}) = char(s.(f{k})); end
end

function rz = cdt_read_curve(file, scale)
P = readmatrix(file, 'FileType', 'text', 'CommentStyle', '#') * scale;
rz = [hypot(P(:, 1), P(:, 2)), P(:, 3)];
end

function blades = cdt_read_profiles(file, scale)
% '##' starts a new blade, '#Profile' a new profile within the blade.
L = readlines(file);
blades = {}; cur = {}; P = [];
for k = 1:numel(L)
    s = strtrim(L(k));
    if s == ""; continue; end
    if startsWith(s, "##")
        if ~isempty(P); cur{end + 1} = P; end %#ok<AGROW>
        if ~isempty(cur); blades{end + 1} = cur; end %#ok<AGROW>
        cur = {}; P = [];
        continue;
    end
    if startsWith(s, "#")
        if ~isempty(P); cur{end + 1} = P; end %#ok<AGROW>
        P = [];
        continue;
    end
    v = sscanf(s, '%f')';
    if numel(v) >= 3; P(end + 1, :) = v(1:3) * scale; end %#ok<AGROW>
end
if ~isempty(P); cur{end + 1} = P; end
if ~isempty(cur); blades{end + 1} = cur; end
end
