%% Set up DAQ to listen for both Photo detector and camera trigger pulse
%
% Origination 3/2/2018
% Grace Hwang and Ingie Hong
%
% Revision 4/26/2018 Changed pause(s.DurationInSeconds-2) to +2
% Revision 4/27/2018 Added commands to save image from memory
% Revision 4/28/2018 Added code to save syncInfo structure containing
% dispSyncs and acqSyncs.
% Revision 5/30/2018 Added new camera code to allow settings to be changed
% from within MATLAB
% Massive revision June 2018

global fileID savePath analogIN lh

daq.getDevices;

%% configSyncInput.m

analogIN =daq.createSession('ni');
analogIN.Rate=5000;
%analogIN.IsContinuous = true ; continuous sampling relies on CPU to start/stop and is not accurate enough (Ingie)
analogIN.DurationInSeconds = 60; %  use 20 for debugging and 200 for ISI. Allow extra 15 second when doing data collect
DurationInSeconds = analogIN.DurationInSeconds;

ch_camera = addAnalogInputChannel(analogIN,'dev1', 'ai0', 'Voltage'); %camera pulse set up
ch_camera.TerminalConfig = 'SingleEnded'; 
ch_camera.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 
ch_stim = addAnalogInputChannel(analogIN,'dev1','ai1', 'Voltage');     %Photodiode set up
ch_stim.TerminalConfig = 'SingleEnded';
ch_stim.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 
%%
saveFlag=1; %set to 1 to save image files
fileID=['' datestr(now, 'yymmdd_HHMMSS') ];
savePath=['C:\Users\Huganir lab\Documents\imager_data\' datestr(now, 'yymmdd') '\'];
if ~exist(savePath)
    mkdir(savePath)
end
%%
analogIN.NotifyWhenDataAvailableExceeds = analogIN.Rate*(DurationInSeconds) ; %50000;
lh = addlistener(analogIN,'DataAvailable',@plotData); 

%% Camera initialization - in imager.m?

vid = videoinput('pointgrey', 1, 'F7_Mono16_480x300_Mode5');
src = getselectedsource(vid);

preview(vid)  % Turn on preview to allow change of FrameRate (possibly bug)
src.FrameRateMode = 'Manual';
src.FrameRate = 10;
stoppreview(vid);
closepreview(vid);

srcinfo=propinfo(src,'Shutter');
if srcinfo.ConstraintValue(2)<30
    error('Shutter could not be set to 30ms. Please restart Matlab and try again.')
end
src.ShutterMode = 'Manual';
src.Shutter=30;
src.Gain=1;
src.GammaMode = 'Manual';
src.SharpnessMode = 'Manual';
src.ExposureMode = 'Manual';

%src.Strobe2 
src.Strobe2 = 'Off';

triggerconfig(vid, 'manual')
vid.FramesPerTrigger = (DurationInSeconds-2)*src.FrameRate ;
preview(vid);
disp('Preview started')


%% Start acquisition -- run this section after initial set up - run2.m and sendtoImager.m
startBackground(analogIN);
pause(1)
src.Strobe2 = 'On';
start(vid);
trigger(vid);
disp('Triggered!')
pause(DurationInSeconds-2) %this specifies how long camera will stay in strobe2=on mode
%above line should be +2 to enable saving
stop(vid)
src.Strobe2 = 'Off';
pause(1)
delete(lh)
stop(analogIN); 

% saving data from memory
if saveFlag==0  % change to 1 to save mat files
    im = getdata(vid);
    save([ savePath fileID '.mat'], 'im');
    clear im;   
end

stoppreview(vid);
closepreview(vid);

%% run2.m and getsync
function plotData(src,event)
    global fileID savePath analogIN
     %plot(event.TimeStamps, event.Data)
     %s.Rate=5000; %redundant - why can't I get this to be a global variable or pass into function
     %fileID='test_u004_008'; %redundant - why can't I get this to be a global variable or pass into function
     %savePath='C:\Users\Huganir lab\Documents\imager_data\TEST_04272018\'; %redundant
    timestamps=event.TimeStamps;
    data=event.Data;
    figure; plot(timestamps,data);
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    legend('camera','photodiode');
    title('Raw data from photodiode and camera');
    % convert strobe pulse to time stamp in seconds with four significant digits
    % only works on square pulse; pay attention to shutter width, signal must have a
    % zero crossing for this extraction to work properly
    %figure; plot(diff(data(:,1))); % shows all positive going pulse
%     figure; plot(timestamps(2:end), diff(data(:,1))>1);
%     xlabel('Time (seconds)');
%     ylabel('voltage (volts)');
%     title('Camera pulse');
    cameraPulseInd=find(diff(data(:,1)>1)==1);
    acqSyncTimes=cameraPulseInd/analogIN.Rate; % this will end up being syncInfo.acqSyncs
    size(acqSyncTimes)
    % convert photodiode pulse into start time
    temp1=sgolayfilt(data(:,2),27,51);%27,51); 15,27
    temp2=temp1; temp2(temp1<1)=0; temp2(temp1>=1.5)=5; 
    PDchan=find(diff(temp2>1.5)==1);   
    dispSyncTimes=PDchan/analogIN.Rate  %this will become syncInfo.dispSyncs
%     figure; plot(timestamps(1:end), temp2, 'r');
%     xlabel('Time (seconds)');
%     ylabel('voltage (volts)');
%     title('Photodiode Pulse');
    figure; plot(timestamps(2:end), diff(data(:,1))>1);
    hold on
    plot(timestamps(1:end), temp2>1, 'r')
    legend('camera','photodiode');
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    title('Processed data from photodiode and camera');
%create structure syncInfo
%syncInfo.dispSyncs
    %dtg=char(datetime('now','TimeZone','local','Format','MMddHHmm'));
    syncInfo={};
        syncInfo=setfield(syncInfo, 'dispSyncs', dispSyncTimes);
        syncInfo=setfield(syncInfo, 'acqSyncs', acqSyncTimes);
    save([ savePath fileID '_syncInfo'], 'syncInfo' );
disp(['saving ...' fileID ])
end



