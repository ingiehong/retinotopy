% rigConfig_example.m - settings that differ from rig to rig and must not be committed.
%
% Copy this file to rigConfig.m in the repository root on EACH computer (master and slave), delete
% the lines you do not need and edit the rest. rigConfig.m is in .gitignore, so git pull never
% touches it and it never shows up in git status. It is a script that runs at the end of
%   configureMstate  (master and slave)  -> Mstate fields
%   updateMonitor    (slave)             -> Mstate.screenXcm / screenYcm after the monitor defaults
%   cameraConfig     (master)            -> cfg, the camera profile (see imager/cameraConfig.m)
%   configCom        (slave)             -> rip, the master computer's IP address
% The if-blocks below make each part apply only where its variable exists, so one file serves all.

global Mstate
if isstruct(Mstate)
    %% both computers
    Mstate.monitor = 'LIN';                       % monitor name; must match on master and slave
    %% master (acquisition) computer
    Mstate.stimulusIDP = '192.168.0.101';         % slave (display) computer's IP address
    Mstate.analyzerRoot = 'C:\Users\QI-Lab_2\My Documents\imager_data';   % where data are saved
    Mstate.screenDist = 10;                       % eye-to-screen distance, cm
    Mstate.DAQdevice = 'dev1';                    % NI DAQ device name
    %% slave (display) computer: physical size of the stimulus monitor, cm
    Mstate.screenXcm = 59;
    Mstate.screenYcm = 33.5;
end

if exist('cfg', 'var') && isstruct(cfg)           % master: camera profile (all settings: imager/cameraConfig.m)
    cfg.profile = 'blackflyS';                    % 'blackflyS' or 'grasshopper3'
    cfg.fps = 15;
    cfg.exposure_ms = 30;
    cfg.binning = 4;                              % 1, 2 or 4 on the BFS-U3-244S8. With Sum binning, 4 collects 16x the
                                                  % light per pixel of 1: check the saturation readout after a change.
    cfg.roiSensor = [2800 2800];                  % field of view in UNBINNED sensor pixels, centred ([x y w h] places it).
                                                  % The frame is this divided by cfg.binning, so changing cfg.binning
                                                  % keeps the same field of view. [] = whole sensor.
    % cfg.roi = [700 700];                        % alternative: a crop in BINNED pixels; when set it overrides roiSensor
    %
    % Size of one 191 s trial at 15 Hz in Mono16 with roiSensor [2800 2800] (it must fit in the FREE memory,
    % and it is saved twice, as .mat and .tif):
    %   binning 4:  688 x 688 px     2.5 GB   fine on a 16 GB PC
    %   binning 2: 1376 x 1376 px   10.1 GB   needs about 13 GB free: a 32 GB PC with other programs closed
    %   binning 1: 2752 x 2752 px   40.4 GB   does not fit; with roiSensor [1400 1400] it is 9.6 GB (a quarter of the area)
    % Frame rate: the camera reads the sensor row by row (about 27 us per sensor row in Mono16), so more rows are
    % slower: the full 2752 rows at binning 1 reach about 13 fps, not 15, and binning 2 may be slower than binning 4.
    % The imager prints the binning it READ BACK from the camera, the frame rate the camera can deliver and the
    % trial size at startup, and warns about a setting name it does not know (cfg.bin instead of cfg.binning).
end

if exist('rip', 'var')                            % slave: master (acquisition) computer's IP address
    rip = '192.168.0.100';
end
