function val = struct_get(s, field, default)
%STRUCT_GET Python'daki dict.get(key, default) davranisinin MATLAB portu.
%   Alan struct'ta YOKSA default dondurulur (Python semantigiyle ayni:
%   sadece anahtarin varligina bakar, deger bos/0 olsa bile onu dondurur).
if isfield(s, field)
    val = s.(field);
else
    val = default;
end
end
