function removed = removedPatchMask(imBefore, imAfter)
%REMOVEDPATCHMASK  Pixels of the patches that splitPatchesX dropped entirely.
%   removed = removedPatchMask(imBefore, imAfter) returns a logical mask of
%   every 4-connected patch of imBefore that has no pixel left in imAfter.
%   splitPatchesX opens and erodes every patch it keeps by a pixel or two, so
%   the raw difference (imBefore & ~imAfter) is mostly a ring around the
%   surviving patches; only whole patches that vanished must be kept away
%   from their neighbours when the borders are re-thinned in getAreaBorders.
lab = bwlabel(imBefore ~= 0, 4);
removed = false(size(lab));
for q = 1:max(lab(:))
    pix = lab == q;
    if ~any(imAfter(pix))
        removed(pix) = true;
    end
end
