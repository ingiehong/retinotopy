function ok = setGenICam(src, name, value)
% Set a camera source property if it exists, trying the usual GenICam spellings of booleans.
% Returns true when the property was set, false (with a one-line message) otherwise.
ok = false;
if ~isprop(src, name)
    fprintf('setGenICam: %s is not a property of this camera, skipped\n', name);
    return
end
candidates = {value};
if islogical(value)
    if value, candidates = {'True', 'On', true, 1}; else, candidates = {'False', 'Off', false, 0}; end
end
for k = 1:numel(candidates)
    try
        src.(name) = candidates{k};
        ok = true;
        return
    catch
    end
end
fprintf('setGenICam: could not set %s to %s (check propinfo(src,''%s''))\n', name, char(string(value)), name);
