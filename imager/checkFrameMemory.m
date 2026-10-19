function needGB = checkFrameMemory(vid, nFrames)
%CHECKFRAMEMEMORY  Refuse a trial whose frames cannot fit in RAM (the IMAQ engine keeps the whole
%   trial in memory until getdata, which then makes a second copy).
%   needGB = checkFrameMemory(vid, nFrames) errors with the numbers and the fix when
%   2 x (frame bytes x nFrames) exceeds 80 % of the free physical memory (Windows only; elsewhere
%   it only returns the estimate).
res = double(vid.VideoResolution);
bpp = 2; if ~isempty(regexp(vid.VideoFormat, 'Mono8|RGB8|8$', 'once')), bpp = 1; end
needGB = res(1) * res(2) * bpp * double(nFrames) / 2^30;
if ispc
    m = memory; availGB = m.MemAvailableAllArrays / 2^30;
else
    availGB = Inf;
end
if 2 * needGB > 0.8 * availGB
    error('checkFrameMemory:ram', ['one trial is %.1f GB of frames (%d x %d px, %d frames, %d bytes per pixel) and ' ...
        'needs about twice that in RAM, but only %.1f GB is free. Crop with cfg.roi (e.g. [700 700], a centred ' ...
        'window) or increase cfg.binning in rigConfig.m / cameraConfig.m, or shorten the trial.'], needGB, res(1), res(2), nFrames, bpp, availGB);
end
