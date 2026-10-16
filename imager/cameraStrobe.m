function cameraStrobe(src, on, cfg)
% Turn the camera's per-frame strobe output on or off.
%   pointgrey adaptor (Grasshopper3): the Strobe2 property.
%   gentl adaptor (Blackfly S): the GenICam line in cfg.strobeLine driven by ExposureActive.
% The strobe is enabled only while GrabSave logs frames, so that the camera pulses recorded by the
% DAQ match the frames that were saved (the analysis indexes frames by strobe pulse).
if nargin < 3 || isempty(cfg), cfg = cameraConfig; end
if isprop(src, 'Strobe2')
    if on, src.Strobe2 = 'On'; else, src.Strobe2 = 'Off'; end
elseif isprop(src, 'LineSource')
    if isprop(src, 'LineSelector'), setGenICam(src, 'LineSelector', cfg.strobeLine); end
    setGenICam(src, 'LineMode', 'Output');
    if on, setGenICam(src, 'LineSource', 'ExposureActive'); else, setGenICam(src, 'LineSource', 'Off'); end
else
    warning('cameraStrobe:none', 'no strobe property found on this camera (no Strobe2 and no LineSource); the DAQ will not see camera pulses');
end
