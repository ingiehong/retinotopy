function setupCamera(vid, src, cfg)
% Apply the camera profile (cameraConfig.m) to a videoinput object and its source: binning, ROI,
% exposure, gain, frame rate, link throughput and the strobe line. Works for the 'pointgrey'
% (Grasshopper3) and 'gentl' (Blackfly S) adaptors; properties that do not exist are reported and skipped.

%% binning and ROI (gentl: GenICam features; pointgrey: part of the Format7 mode)
if ~isempty(cfg.binning) && cfg.binning > 1
    if isprop(src, 'BinningHorizontal') && isprop(src, 'BinningVertical')
        if isprop(src, 'BinningSelector'), setGenICam(src, 'BinningSelector', 'All'); end
        if ~isempty(cfg.binningMode)
            setGenICam(src, 'BinningHorizontalMode', cfg.binningMode);
            setGenICam(src, 'BinningVerticalMode', cfg.binningMode);
        end
        setGenICam(src, 'BinningHorizontal', cfg.binning);
        setGenICam(src, 'BinningVertical', cfg.binning);
    else
        fprintf('setupCamera: this camera has no BinningHorizontal/BinningVertical property; binning not applied\n');
    end
end
if ~isempty(cfg.roi)
    vid.ROIPosition = cfg.roi;   % [xoffset yoffset width height] in (binned) pixels
end

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
    actual = src.AcquisitionFrameRate;
elseif isprop(src, 'FrameRate')
    setGenICam(src, 'FrameRate', cfg.fps);
    actual = src.FrameRate;
elseif isprop(src, 'FrameRatePercentage')
    src.FrameRatePercentage = 100; actual = NaN;
    disp('setupCamera: FrameRatePercentage set to 100 %; the frame rate cannot be set directly on this camera.')
else
    actual = NaN;
end
if ~isnan(actual) && abs(actual - cfg.fps) > 0.5
    error('setupCamera:fps', 'requested %.2f fps but the camera reports %.2f fps (bandwidth, exposure or binning limit?)', cfg.fps, actual);
end

%% strobe line: configured now, enabled only while GrabSave logs frames
cameraStrobe(src, false, cfg);

%% manual trigger; FramesPerTrigger is set per trial by sendtoImager('I ...') from the frame rate
triggerconfig(vid, 'manual');
total_time = str2num(get(findobj('Tag', 'timetxt'), 'String')); %#ok<ST2NM>
if isempty(total_time), total_time = 10; end
vid.FramesPerTrigger = round(total_time * cfg.fps);

%% report
res = vid.VideoResolution;
fprintf('Camera profile ''%s'': %s %s, %d x %d px, %.2f fps (requested %g), exposure %g ms, binning %s, strobe %s\n', ...
    cfg.profile, cfg.adaptor, vid.VideoFormat, res(1), res(2), actual, cfg.fps, cfg.exposure_ms, mat2str(cfg.binning), cfg.strobeLine);
