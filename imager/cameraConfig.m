function cfg = cameraConfig
% Camera profile used by imager.m / GrabSave.m. Edit this file for your rig.
%
% Profiles:
%   'grasshopper3' : FLIR Grasshopper3 (GigE/USB3) through the Image Acquisition Toolbox
%                    'pointgrey' adaptor (FlyCapture2). The strobe is the adaptor property Strobe2
%                    (GPIO2, red wire).  This is the original setup (300x480 px, 10 Hz).
%   'blackflyS'    : FLIR Blackfly S (e.g. BFS-U3-244S8M, Sony IMX540 5320x4600) through the
%                    'gentl' adaptor (Spinnaker GenTL producer). Binning, ROI, exposure, frame
%                    rate and the strobe output are GenICam features that do NOT persist across
%                    connections, so they are set here every time the imager starts.
%
% Notes for the Blackfly S:
%   * One trial of total_time seconds at cfg.fps frames/s is held in RAM three times (image
%     acquisition buffer, the returned frames, and the global Tens). Keep one trial below ~2 GB on a
%     16 GB PC: 4x4 binning gives 1330x1150 px (Mono16: 3.1 GB per 100 s at 15 Hz, too much);
%     8x8 binning (665x575 px) or 4x4 binning plus an ROI around the cranial window stays safe.
%   * Mono16 (12-bit ADC) is strongly preferred over Mono8 for 2-4 % dF/F signals; use binning
%     mode 'Sum' so binning adds well depth. Mono16 at 4x4 binning and 15 Hz needs ~46 MB/s, i.e. a
%     USB 3 port (the rear ports on the QI-Lab PC); on a USB 2 link the frame rate collapses.
%   * Strobe: the BFS 6-pin GPIO has Line0 = opto-isolated input (black), Line1 = opto-isolated
%     output (white, open collector: needs a pull-up resistor to show a pulse), Line2 = red and
%     Line3 = green non-isolated bidirectional 3.3 V lines. The NI USB-6008 ai0 threshold in run2.m
%     is 1 V, so Line2 or Line3 driven as 'Output' with LineSource 'ExposureActive' works directly.
%   * GenICam enumeration/boolean values are written as strings ('Off', 'True'); setupCamera.m
%     tries the common spellings and reports what it could not set, so check the printout once.

cfg.profile = 'blackflyS';     % 'grasshopper3' or 'blackflyS'
cfg.fps = 15;                  % frames per second requested from the camera (Mstate/looper timing uses the measured strobe times)
cfg.exposure_ms = 30;          % exposure per frame in ms (must be < 1000/fps)
cfg.gain_dB = 0;

switch cfg.profile
    case 'grasshopper3'
        cfg.adaptor = 'pointgrey';
        cfg.deviceID = 1;
        cfg.format = 'F7_Mono16_480x300_Mode5';          % 4x4 binned Format7 mode
        cfg.fallbackFormat = 'F7_Mono16_960x600_Mode1';
        cfg.binning = [];                                 % binning is part of the Format7 mode
        cfg.binningMode = '';
        cfg.roi = [];                                     % [xoffset yoffset width height], [] = full frame
        cfg.strobeLine = 'Strobe2';                       % pointgrey adaptor property
        cfg.throughputLimit = [];
    case 'blackflyS'
        cfg.adaptor = 'gentl';
        cfg.deviceID = 1;
        cfg.format = 'Mono16';                            % 12-bit data in 16-bit frames
        cfg.fallbackFormat = 'Mono8';
        cfg.binning = 8;                                  % hardware binning factor (both axes): 8 -> 665x575 px, 0.76 MB/frame, 2.2 GB per 191 s trial at 15 Hz; 4 (1330x1150 px, 3 MB/frame) needs cfg.roi
        cfg.binningMode = 'Sum';                          % 'Sum' (adds well depth) or 'Average'
        cfg.roi = [];                                     % e.g. [200 100 700 700] in binned pixels around the window; [] = full binned frame
        cfg.strobeLine = 'Line2';                         % GenICam line used as the frame strobe (red wire)
        cfg.throughputLimit = 380e6;                      % bytes/s; [] leaves the camera default (43e6 is the USB 2 figure)
    otherwise
        error('cameraConfig:profile','unknown camera profile ''%s''',cfg.profile);
end

%% rig-specific overrides: rigConfig.m (git-ignored, see rigConfig_example.m) may change any cfg field
if exist('rigConfig', 'file') == 2, rigConfig; end
