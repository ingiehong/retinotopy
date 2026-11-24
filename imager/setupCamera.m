function [vid, src, fps] = setupCamera(vid, src, cfg)
% Apply the camera profile (cameraConfig.m) to a videoinput object and its source: binning, crop,
% exposure, gain, frame rate, link throughput and the strobe line. Works for the 'pointgrey'
% (Grasshopper3) and 'gentl' (Blackfly S) adaptors; properties that do not exist are reported and skipped.
% Returns vid and src because a binning change reconnects to the camera (new objects), and fps, the
% frame rate the camera reports it will deliver (cfg.fps or lower). A trial always reserves room for
% total_time x cfg.fps frames and lasts total_time; fps only tells GrabSave how many frames to expect.
[vid, src, bin, reconnected] = applyBinning(vid, src, cfg);
try
    fps = configure(vid, src, cfg, bin);
catch e
    if reconnected   % the caller still holds the old, deleted object: do not leave a second connection open that nothing points to
        try delete(vid); catch, end
    end
    rethrow(e)
end


function [vid, src, bin, reconnected] = applyBinning(vid, src, cfg)
% Binning (gentl: GenICam features; pointgrey: part of the Format7 mode). cfg.binning is applied for
% any value, 1 included: the camera keeps its last binning while it has power, so 1 must be set
% explicitly. bin is [horizontal vertical] as READ BACK from the camera ([] when it has no binning
% feature); cfg.binning = [] leaves the camera's binning alone but still reads it.
bin = []; reconnected = false;
if ~(isprop(src, 'BinningHorizontal') && isprop(src, 'BinningVertical'))
    if ~isempty(cfg.binning), fprintf('setupCamera: this camera has no BinningHorizontal/BinningVertical property; binning not applied\n'); end
    return
end
if isprop(src, 'BinningSelector'), setGenICam(src, 'BinningSelector', 'All'); end
binBefore = readBinning(src); bin = binBefore;
if isempty(cfg.binning), return; end
fullBefore = double(vid.VideoResolution);
if ~isempty(cfg.binningMode)
    setGenICam(src, 'BinningHorizontalMode', cfg.binningMode);
    setGenICam(src, 'BinningVerticalMode', cfg.binningMode);
end
setGenICam(src, 'BinningHorizontal', cfg.binning);
setGenICam(src, 'BinningVertical', cfg.binning);
bin = readBinning(src);
if isempty(bin), return; end
if ~isequal(bin, [cfg.binning cfg.binning])
    warning('setupCamera:binning', 'cfg.binning = %d was requested but the camera reports %d x %d binning (allowed values: %s). The camera''s value is used.', ...
        cfg.binning, bin(1), bin(2), allowedValues(src, 'BinningHorizontal'));
end
if bin(1) ~= bin(2)
    warning('setupCamera:binning', 'horizontal and vertical binning differ (%d x %d): the pixels are not square', bin(1), bin(2));
end
if ~isempty(binBefore) && ~isequal(binBefore, bin)
    % The videoinput object read the frame size when it was created, at the old binning.
    % Connect again so that it starts from the frame size of the new binning.
    fprintf('setupCamera: binning changed from %d x %d to %d x %d; reconnecting to the camera to use the new frame size\n', binBefore, bin);
    [vid, src] = reconnect(vid, cfg);
    reconnected = true;
    if isprop(src, 'BinningSelector'), setGenICam(src, 'BinningSelector', 'All'); end
    kept = readBinning(src);
    if ~isempty(kept) && ~isequal(kept, bin)   % the camera did not keep the value across the reconnect: set it on this connection
        setGenICam(src, 'BinningHorizontal', bin(1));
        setGenICam(src, 'BinningVertical', bin(2));
        kept = readBinning(src); if ~isempty(kept), bin = kept; end
    end
    full = double(vid.VideoResolution); expected = fullBefore .* binBefore ./ bin;
    if any(abs(full - expected) > 16)
        fprintf('setupCamera: note: the full frame is reported as %d x %d px where about %.0f x %.0f px was expected after the binning change\n', full, expected);
    end
end


function fps = configure(vid, src, cfg, bin)
% Everything after the binning: crop, exposure, gain, link, frame rate, strobe, trigger, report.
gentl = ~isempty(bin);                           % a camera with binning features: the gentl path
binv = [1 1]; if gentl, binv = bin; end

%% one snapshot, so the toolbox refreshes its idea of the frame size before the crop (after a binning
% change it can keep the old size until streaming starts, and then reset its ROI to the full frame)
if gentl, snapshot(vid); end

%% crop. cfg.roi is in binned pixels; cfg.roiSensor is in unbinned sensor pixels and is divided by the
% binning, so the field of view stays the same when the binning changes. [width height] centres the
% crop, [xoffset yoffset width height] places it. Applied through the toolbox ROI (the gentl adaptor
% hides the camera's Width/Height/Offset features and manages them itself), or on the camera when an
% adaptor exposes those features.
onDevice = isprop(src, 'Width') && isprop(src, 'Height') && isprop(src, 'OffsetX') && isprop(src, 'OffsetY');
if ~isempty(cfg.roi) || ~isempty(cfg.roiSensor)
    if onDevice
        setGenICam(src, 'OffsetX', 0); setGenICam(src, 'OffsetY', 0);      % offsets to zero so the full size is readable
        full = [featureMax(src, 'Width') featureMax(src, 'Height')];
    else
        full = double(vid.VideoResolution);                                % the full frame at the current binning
    end
    if ~isempty(cfg.roi)                                                   % binned pixels
        roi = double(cfg.roi(:)');
        if numel(roi) == 2, roi = [floor((full - roi) / 2) roi]; end
    else                                                                   % sensor pixels -> binned pixels
        rs = double(cfg.roiSensor(:)');
        if numel(rs) == 2
            sensor = 64 * round(full .* binv / 64);                        % the same at every binning (the camera rounds the binned full frame down)
            rs = [floor((sensor - rs) / 2) rs];
        end
        rs(1:2) = 32 * floor(max(rs(1:2), 0) / 32); rs(3:4) = 64 * floor(rs(3:4) / 64);   % the same sensor region at binning 1, 2 and 4
        roi = floor(rs ./ [binv binv]);
    end
    roi(1:2) = 8 * floor(max(roi(1:2), 0) / 8); roi(3:4) = 16 * floor(roi(3:4) / 16);     % GenICam offset/size increments
    roi(3:4) = min(roi(3:4), 16 * floor((full - roi(1:2)) / 16));
    if any(roi(3:4) < 16)
        error('setupCamera:crop', 'the crop %s does not fit on the %d x %d px frame at binning %d x %d: check cfg.roi / cfg.roiSensor in rigConfig.m', mat2str(roi), full(1), full(2), binv(1), binv(2));
    end
    if onDevice
        setGenICam(src, 'Width', roi(3)); setGenICam(src, 'Height', roi(4));   % size first, then position
        setGenICam(src, 'OffsetX', roi(1)); setGenICam(src, 'OffsetY', roi(2));
    else
        vid.ROIPosition = roi;
        if gentl                                 % a snapshot sends the crop to the camera, so the frame-rate limit below is that of the crop
            snapshot(vid);
            if ~isequal(frameSize(vid), roi(3:4)), vid.ROIPosition = roi; end   % the toolbox reset its ROI at that moment: set it once more
        end
    end
    res = frameSize(vid);
    if isequal(res, roi(3:4))
        fprintf('setupCamera: crop %d x %d px at offset (%d, %d) of the %d x %d px frame at binning %d x %d = sensor px %d..%d across, %d..%d down\n', ...
            roi(3), roi(4), roi(1), roi(2), full(1), full(2), binv(1), binv(2), roi(1) * binv(1), (roi(1) + roi(3)) * binv(1), roi(2) * binv(2), (roi(2) + roi(4)) * binv(2));
    else
        warning('setupCamera:crop', 'asked for a %d x %d px crop but the ROI reports %d x %d px: the trial will be larger than planned', roi(3), roi(4), res(1), res(2));
    end
    if ~isempty(cfg.roi) && gentl && any(binv ~= 4)
        warning('setupCamera:roiUnits', ['cfg.roi is in BINNED pixels: at binning %d x %d this crop is a different, smaller part of the sensor than it was at binning 4 x 4. ' ...
            'To keep the field of view it had at binning 4, replace the cfg.roi line in rigConfig.m by:   cfg.roiSensor = %s;'], binv(1), binv(2), mat2str(4 * double(cfg.roi(:)')));
    end
elseif gentl && ~onDevice
    vid.ROIPosition = [0 0 double(vid.VideoResolution)];   % no crop: say so explicitly instead of relying on what a new connection starts with
end

%% 12-bit conversion for 16-bit formats (the camera can be left at 8 or 10 bits, which a Mono16 frame hides)
if isprop(src, 'AdcBitDepth') && ~isempty(regexp(vid.VideoFormat, '16', 'once')), setGenICam(src, 'AdcBitDepth', 'Bit12'); end

%% exposure and gain
setGenICam(src, 'ExposureAuto', 'Off');
if isprop(src, 'ExposureTime')                     % GenICam: microseconds
    setGenICam(src, 'ExposureTime', cfg.exposure_ms * 1000);
elseif isprop(src, 'Shutter')                      % pointgrey: milliseconds
    setGenICam(src, 'ShutterMode', 'Manual');
    setGenICam(src, 'Shutter', cfg.exposure_ms);
end
setGenICam(src, 'GainAuto', 'Off');
setGenICam(src, 'Gain', cfg.gain_dB);
if isprop(src, 'GammaMode'), setGenICam(src, 'GammaMode', 'Manual'); end
if isprop(src, 'GammaEnable'), setGenICam(src, 'GammaEnable', false); end
if isprop(src, 'SharpnessMode'), setGenICam(src, 'SharpnessMode', 'Manual'); end
if isprop(src, 'ExposureMode') && isprop(src, 'Shutter'), setGenICam(src, 'ExposureMode', 'Manual'); end

%% link throughput (USB3 Blackfly S)
if ~isempty(cfg.throughputLimit) && isprop(src, 'DeviceLinkThroughputLimit')
    setGenICam(src, 'DeviceLinkThroughputLimit', cfg.throughputLimit);
end

%% frame rate
if isprop(src, 'AcquisitionFrameRateEnable'), setGenICam(src, 'AcquisitionFrameRateEnable', true); end
if isprop(src, 'AcquisitionFrameRate')
    setGenICam(src, 'AcquisitionFrameRate', cfg.fps);
    actual = double(src.AcquisitionFrameRate);
    if isprop(src, 'AcquisitionResultingFrameRate')   % what the camera will really deliver with this frame size, format and exposure
        resulting = double(src.AcquisitionResultingFrameRate);
        if isscalar(resulting) && isfinite(resulting) && resulting > 0, actual = min(actual, resulting); end
    end
elseif isprop(src, 'FrameRate')
    setGenICam(src, 'FrameRate', cfg.fps);
    actual = src.FrameRate;
elseif isprop(src, 'FrameRatePercentage')
    src.FrameRatePercentage = 100; actual = NaN;
    disp('setupCamera: FrameRatePercentage set to 100 %; the frame rate cannot be set directly on this camera.')
else
    actual = NaN;
end
link = '';
if isprop(src, 'DeviceCurrentSpeed'), link = sprintf(', USB link %s', char(src.DeviceCurrentSpeed)); end   % SuperSpeed = USB 3, HighSpeed = USB 2
if isprop(src, 'DeviceLinkSpeed'), link = sprintf('%s (%.0f MB/s)', link, double(src.DeviceLinkSpeed) / 1e6); end
fps = cfg.fps;
if ~isnan(actual) && abs(actual - cfg.fps) > 0.5
    r = frameSize(vid); b = 2; if ~isempty(regexp(vid.VideoFormat, 'Mono8|RGB8|8$', 'once')), b = 1; end
    if isprop(src, 'DeviceCurrentSpeed') && ~isempty(regexpi(char(src.DeviceCurrentSpeed), 'high|full|low', 'once'))
        warning('setupCamera:fps', ['requested %.2f fps but the camera reports %.2f fps%s. At %d x %d px x %d bytes that is %.0f MB/s: ' ...
            'a USB 2 port, hub or cable (HighSpeed) limits the Blackfly S to about 25 MB/s. Use a USB 3 (SuperSpeed) port.'], ...
            cfg.fps, actual, link, r(1), r(2), b, actual * r(1) * r(2) * b / 1e6);
    else
        warning('setupCamera:fps', ['requested %.2f fps but the camera can deliver %.2f fps for %d x %d px frames at binning %d x %d in %s%s. ' ...
            'The limit is the sensor readout, which grows with the number of sensor ROWS read (on the BFS-U3-244S8 about 27 us per row in Mono16, ' ...
            'more when the binning is done by the camera''s image processor). For a higher rate use fewer rows (a smaller cfg.roiSensor height) ' ...
            'or a larger cfg.binning. A trial keeps its duration and simply has fewer frames; the DAQ pulses still match the saved frames.'], ...
            cfg.fps, actual, r(1), r(2), binv(1), binv(2), vid.VideoFormat, link);
    end
end
if ~isnan(actual) && actual >= 1 && actual < cfg.fps, fps = actual; end   % also when it is only slightly lower (14.996 for 15)

%% strobe line: configured now, enabled only while GrabSave logs frames
cameraStrobe(src, false, cfg);

%% manual trigger; FramesPerTrigger is set per trial by sendtoImager('I ...') from the frame rate
triggerconfig(vid, 'manual');
total_time = str2num(get(findobj('Tag', 'timetxt'), 'String')); %#ok<ST2NM>
if isempty(total_time), total_time = 10; end
vid.FramesPerTrigger = floor(total_time * cfg.fps + 1e-6);   % the most frames a trial can have

%% report
res = frameSize(vid);
if isempty(bin), binTxt = 'set by the video format'; else, binTxt = sprintf('%d x %d (read from the camera)', bin); end
fprintf('Camera profile ''%s'': %s %s, %d x %d px, %.2f fps (requested %g), exposure %g ms, binning %s, strobe %s, up to %.2f GB of frames per %g s trial%s\n', ...
    cfg.profile, cfg.adaptor, vid.VideoFormat, res(1), res(2), actual, cfg.fps, cfg.exposure_ms, binTxt, cfg.strobeLine, frameGB(vid, vid.FramesPerTrigger), total_time, link);

function m = featureMax(src, name)
% Largest value a GenICam integer feature accepts: WidthMax/HeightMax when the camera has them, else
% the upper end of the property's range, else its current value.
m = double(src.(name));
if isprop(src, [name 'Max'])
    m = double(src.([name 'Max'])); return
end
try
    pinfo = propinfo(src, name);
    if isnumeric(pinfo.ConstraintValue) && numel(pinfo.ConstraintValue) == 2
        m = double(pinfo.ConstraintValue(2));
    end
catch
end

function snapshot(vid)
% One frame, to make the toolbox and the camera agree on the frame size.
try
    getsnapshot(vid);
catch e
    fprintf('setupCamera: snapshot to refresh the frame size failed (%s)\n', e.message);
end

function b = readBinning(src)
% [horizontal vertical] binning as the camera reports it, [] when it cannot be read.
try
    b = [double(src.BinningHorizontal) double(src.BinningVertical)];
catch
    b = [];
end

function txt = allowedValues(src, name)
% The values or range a camera property accepts, as text for a message.
txt = 'unknown';
try
    pinfo = propinfo(src, name);
    if isnumeric(pinfo.ConstraintValue) && ~isempty(pinfo.ConstraintValue)
        txt = mat2str(double(pinfo.ConstraintValue(:)'));
    end
catch
end

function [vid, src] = reconnect(vid, cfg)
% Delete the videoinput object and create it again with the same format. The camera keeps its
% settings (binning included) while it has power, so the new object sees the new frame size.
fmt = vid.VideoFormat;
try
    delete(vid);
    try
        vid = videoinput(cfg.adaptor, cfg.deviceID, fmt);
    catch
        imaqreset;                                   % the device was not released yet: reset the toolbox and try once more
        vid = videoinput(cfg.adaptor, cfg.deviceID, fmt);
    end
catch e
    error('setupCamera:reconnect', ['the binning was changed in the camera, but reconnecting to it failed (%s). ' ...
        'Close the imager and start Retinotopy_Master again: the new binning is already stored in the camera.'], e.message);
end
src = getselectedsource(vid);

function gb = frameGB(vid, nFrames)
% Size of one trial in GB (no check: checkFrameMemory decides at the start of each trial).
res = frameSize(vid);
bpp = 2; if ~isempty(regexp(vid.VideoFormat, 'Mono8|RGB8|8$', 'once')), bpp = 1; end
gb = res(1) * res(2) * bpp * double(nFrames) / 2^30;

