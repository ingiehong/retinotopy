function ok = roomForCopy(bytes)
%ROOMFORCOPY  True when a second array of this many bytes fits in the free physical memory.
%   Windows only (memory); elsewhere the answer is always true.
ok = true;
if ispc
    [~, sys] = memory;
    ok = sys.PhysicalMemory.Available > 1.1 * bytes + 2^30;
end
