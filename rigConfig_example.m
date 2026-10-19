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

if exist('cfg', 'var') && isstruct(cfg)           % master: camera profile
    cfg.profile = 'blackflyS';                    % 'blackflyS' or 'grasshopper3'
    cfg.fps = 15;
    cfg.exposure_ms = 30;
    cfg.binning = 8;                              % 8x8 keeps a 191 s Mono16 trial at 2.2 GB
    % cfg.roi = [315 225 700 700];                % or 4x4 binning plus a crop around the window
end

if exist('rip', 'var')                            % slave: master (acquisition) computer's IP address
    rip = '192.168.0.100';
end
