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
%% let the toolbox learn the binned frame size before anything depends on it. After a binning change the
% videoinput keeps reporting the old VideoResolution and maximum until streaming starts; when it finally
% notices, it resets its ROI to the full frame ('Resetting the ROI as the max width and height has been
% updated') and discards any crop set earlier. One snapshot forces that refresh now.
if ~isempty(cfg.binning) && cfg.binning > 1
    before = double(vid.VideoResolution);
    try
        getsnapshot(vid);
    catch e
        fprintf('setupCamera: snapshot to refresh the frame size failed (%s)\n', e.message);
    end
    for k = 1:30
        if ~isequal(double(vid.VideoResolution), before), break; end
        pause(0.1);
    end
    if isequal(double(vid.VideoResolution), before)   % the snapshot did not do it: a brief preview starts the stream the same way
        try
            preview(vid);
            for k = 1:30
                if ~isequal(double(vid.VideoResolution), before), break; end
                pause(0.1);
            end
            closepreview(vid);
        catch e
            fprintf('setupCamera: preview to refresh the frame size failed (%s)\n', e.message);
        end
    end
    after = double(vid.VideoResolution);
    fprintf('setupCamera: frame %d x %d px before binning, %d x %d px after\n', before(1), before(2), after(1), after(2));
end

%% crop (cfg.roi): [width height] centres it on the binned frame, [xoffset yoffset width height] places it.
% Through the toolbox ROI (the gentl adaptor hides the camera's Width/Height/Offset features and manages
% them itself), or on the camera when an adaptor exposes those features.
if ~isempty(cfg.roi)
    roi = double(cfg.roi(:)');
    onDevice = isprop(src, 'Width') && isprop(src, 'Height') && isprop(src, 'OffsetX') && isprop(src, 'OffsetY');
    if onDevice
        setGenICam(src, 'OffsetX', 0); setGenICam(src, 'OffsetY', 0);      % offsets to zero so the full size is readable
        full = [featureMax(src, 'Width') featureMax(src, 'Height')];
    else
        full = double(vid.VideoResolution);
    end
    if numel(roi) == 2
        roi = [floor((full(1) - roi(1)) / 2) floor((full(2) - roi(2)) / 2) roi(1) roi(2)];
    end
    roi(1:2) = 8 * floor(roi(1:2) / 8); roi(3:4) = 16 * floor(roi(3:4) / 16);   % GenICam offset/size increments
    roi(3:4) = min(roi(3:4), full - roi(1:2));
    if onDevice
        setGenICam(src, 'Width', roi(3)); setGenICam(src, 'Height', roi(4));   % size first, then position
        setGenICam(src, 'OffsetX', roi(1)); setGenICam(src, 'OffsetY', roi(2));
    else
        vid.ROIPosition = roi;
    end
    res = double(vid.VideoResolution);
    if isequal(res, roi(3:4))
        fprintf('setupCamera: crop %d x %d px at offset (%d, %d) of the %d x %d px binned frame\n', roi(3), roi(4), roi(1), roi(2), full(1), full(2));
    else
        warning('setupCamera:crop', 'asked for a %d x %d px crop but the videoinput reports %d x %d px: the trial will be larger than planned', roi(3), roi(4), res(1), res(2));
    end
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
link = '';
if isprop(src, 'DeviceCurrentSpeed'), link = sprintf(', USB link %s', char(src.DeviceCurrentSpeed)); end   % SuperSpeed = USB 3, HighSpeed = USB 2
if isprop(src, 'DeviceLinkSpeed'), link = sprintf('%s (%.0f MB/s)', link, double(src.DeviceLinkSpeed) / 1e6); end
if ~isnan(actual) && abs(actual - cfg.fps) > 0.5
    r = double(vid.VideoResolution); b = 2; if ~isempty(regexp(vid.VideoFormat, 'Mono8|RGB8|8$', 'once')), b = 1; end
    warning('setupCamera:fps', ['requested %.2f fps but the camera reports %.2f fps%s. At %d x %d px x %d bytes that is %.0f MB/s: ' ...
        'a USB 2 port, hub or cable (HighSpeed) limits the Blackfly S to about 25 MB/s. Use a USB 3 (SuperSpeed) port, ' ...
        'or crop (cfg.roi) or bin more. The DAQ pulses still match the saved frames, so a run is usable, just slower.'], ...
        cfg.fps, actual, link, r(1), r(2), b, actual * r(1) * r(2) * b / 1e6);
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
fprintf('Camera profile ''%s'': %s %s, %d x %d px, %.2f fps (requested %g), exposure %g ms, binning %s, strobe %s, %.2f GB of frames per %g s trial%s\n', ...
    cfg.profile, cfg.adaptor, vid.VideoFormat, res(1), res(2), actual, cfg.fps, cfg.exposure_ms, mat2str(cfg.binning), cfg.strobeLine, checkFrameMemory(vid, vid.FramesPerTrigger), total_time, link);

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
