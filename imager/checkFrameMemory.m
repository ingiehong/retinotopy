function needGB = checkFrameMemory(vid, nFrames)
%CHECKFRAMEMEMORY  Refuse a trial whose frames cannot fit in physical RAM.
%   needGB = checkFrameMemory(vid, nFrames). GrabSave streams the frames out of the acquisition
%   buffer into one preallocated array while the trial runs, so a trial costs about its own size
%   once. The acquisition engine needs PHYSICAL memory ('insufficient free physical memory'), so the
%   check uses the free physical memory, not MATLAB's virtual allowance (Windows only; elsewhere the
%   estimate is only returned).
res = frameSize(vid);
bpp = 2; if ~isempty(regexp(vid.VideoFormat, 'Mono8|RGB8|8$', 'once')), bpp = 1; end
needGB = res(1) * res(2) * bpp * double(nFrames) / 2^30;
if ispc
    [~, sys] = memory; availGB = sys.PhysicalMemory.Available / 2^30;
else
    availGB = Inf;
end
if needGB + 0.5 > 0.85 * availGB
    error('checkFrameMemory:ram', ['one trial is %.1f GB of frames (%d x %d px, %d frames, %d bytes per pixel) but only %.1f GB of ' ...
        'physical memory is free. Close other programs (browser, SpinView, OneNote), crop more with cfg.roi or increase ' ...
        'cfg.binning in rigConfig.m, or shorten the trial.'], needGB, res(1), res(2), nFrames, bpp, availGB);
end
