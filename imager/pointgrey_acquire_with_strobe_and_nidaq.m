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

global fileID savePath s

daq.getDevices;

%%
  s =daq.createSession('ni');
  s.Rate=5000;
  s.DurationInSeconds = 20; %  use 20 for debugging and 200 for ISI. Allow extra 15 second when doing data collect

  ch_camera = addAnalogInputChannel(s,'dev1', 'ai0', 'Voltage'); %camera pulse set up
  ch_camera.TerminalConfig = 'SingleEnded'; 
  ch_camera.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 
  ch_stim = addAnalogInputChannel(s,'dev1','ai1', 'Voltage');     %Photodiode set up
  ch_stim.TerminalConfig = 'SingleEnded';
  ch_stim.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 
%%
saveFlag=1; %set to 1 to save image files
%animID='xx0_u000_003'; % must manually update this ID each experiment
fileID=['Widefield_' datestr(now, 'yyyy-mm-dd_HHMMSS') ];
savePath='C:\Users\Huganir lab\Documents\imager_data\05302018\';
if ~exist(savePath)
    mkdir(savePath)
end
%%
s.NotifyWhenDataAvailableExceeds = s.Rate*s.DurationInSeconds ; %50000;
lh = addlistener(s,'DataAvailable',@plotData); 

%% Camera initialization

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
src.Gain=10;
src.GammaMode = 'Manual';
src.SharpnessMode = 'Manual';
src.ExposureMode = 'Manual';

%vid = videoinput('pointgrey', 1, 'F7_Raw16_1920x1200_Mode7');
% vid = videoinput('pointgrey', 1, 'F7_Mono16_480x300_Mode5');
% src = getselectedsource(vid);
% src.ExposureMode = 'Manual';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
% src.FrameRateMode = 'Manual';
% src.GainMode = 'Manual';
% src.GammaMode = 'Manual';
% src.SharpnessMode = 'Manual';
% src.ShutterMode = 'Manual';
% src.FrameRate = 10;
% src.Shutter=30;
% src.Gain=10;

%if abs(src.Shutter-99.5003) > 1 
%    error('Wrong framerate or shutter time. Run FlyCapture and set framerate to 10FPS.')
%end
%If frame rate cannot be adjusted using MATLAB, use FlyCapture2 Camera
%Selection tool
src.Strobe2 = 'Off';
%triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');
triggerconfig(vid, 'manual')
vid.FramesPerTrigger = s.DurationInSeconds*src.FrameRate ;
preview(vid);
disp('Preview started')
%pause(3)

%% Start acquisition -- run this section after initial set up
startBackground(s);
pause(1)
src.Strobe2 = 'On';
start(vid);
trigger(vid);
disp('Triggered!')
pause(s.DurationInSeconds+2) %this specifies how long camera will stay in strobe2=on mode
%above line should be +2 to enable saving
stop(vid)
src.Strobe2 = 'Off';

% saving data from memory
if saveFlag==1  % change to 1 to save mat files
    im = getdata(vid);
    save([ savePath fileID '.mat'], 'im');
%    clear im;   
end

stoppreview(vid);
closepreview(vid);

%%
function plotData(src,event)
    global fileID savePath s
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
    % convert strobe pulse to time stamp in seconds with four significant digits
    % only works on square pulse; pay attention to shutter width, signal must have a
    % zero crossing for this extraction to work properly
    %figure; plot(diff(data(:,1))); % shows all positive going pulse
    figure; plot(timestamps(2:end), diff(data(:,1))>1);
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    title('Camera pulse');
    cameraPulseInd=find(diff(data(:,1)>1)==1);
    acqSyncTimes=cameraPulseInd/s.Rate; % this will end up being syncInfo.acqSyncs
    % convert photodiode pulse into start time
    temp1=sgolayfilt(data(:,2),27,51);%27,51); 15,27
    temp2=temp1; temp2(temp1<1)=0; temp2(temp1>=1.5)=5; 
    PDchan=find(diff(temp2>1.5)==1);   
    dispSyncTimes=PDchan/s.Rate  %this will become syncInfo.dispSyncs
    figure; plot(timestamps(1:end), temp2, 'r');
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    title('Photodiode Pulse');
%create structure syncInfo
%syncInfo.dispSyncs
    dtg=char(datetime('now','TimeZone','local','Format','MMddHHmm'));
    syncInfo={};
        syncInfo=setfield(syncInfo, 'dispSyncs', dispSyncTimes);
        syncInfo=setfield(syncInfo, 'acqSyncs', acqSyncTimes);
    save([ savePath dtg '_' fileID 'syncInfo'], 'syncInfo' );
disp(['saving ...' fileID ])
end


%Proper commands to close out of video viewer in image acquisiton toolbox
%
%    stoppreview(vid);
%    closepreview(vid);




%Start acq
  
%data = startForeground(s);
%[data,timestamps] = startForeground(s);

