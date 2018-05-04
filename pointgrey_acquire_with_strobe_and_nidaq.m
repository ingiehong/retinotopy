%% Set up DAQ to listen for both Photo detector and camera trigger pulse
%
% Origination 3/2/2018
% Grace Hwang and Ingie Hong
%
daq.getDevices

%%
  s =daq.createSession('ni');
  s.Rate=5000;
  s.DurationInSeconds = 20; % 

  ch_camera = addAnalogInputChannel(s,'dev1', 'ai0', 'Voltage'); %camera pulse set up
  ch_camera.TerminalConfig = 'SingleEnded'; 
  ch_camera.Range = [0, 5];
  ch_stim = addAnalogInputChannel(s,'dev1','ai1', 'Voltage');     %Photodiode set up
  ch_stim.TerminalConfig = 'SingleEnded';
  ch_stim.Range = [0, 5];

%%
s.NotifyWhenDataAvailableExceeds = s.Rate*s.DurationInSeconds ; %50000;
lh = addlistener(s,'DataAvailable',@plotData); 
%vid = videoinput('pointgrey', 1, 'F7_Raw16_1920x1200_Mode7');
vid = videoinput('pointgrey', 1, 'F7_Mono16_480x300_Mode5');
src = getselectedsource(vid);
src.ExposureMode = 'Manual';
src.ShutterMode = 'Manual';
src.FrameRateMode = 'Manual';
src.GainMode = 'Manual';
src.Gain=10;
src.SharpnessMode = 'Manual';
src.FrameRate = 10;
src.Shutter=99.4;
if abs(src.Shutter-99.5003) > 1 
    error('Wrong framerate or shutter time. Run FlyCapture and set framerate to 10FPS.')
end

src.Strobe2 = 'Off';
%triggerconfig(vid, 'hardware', 'risingEdge', 'externalTriggerMode0-Source0');
triggerconfig(vid, 'manual')
vid.FramesPerTrigger = s.DurationInSeconds*src.FrameRate ;
preview(vid);
disp('Preview started')
%pause(3)
%start acquisition
startBackground(s);
pause(1)
src.Strobe2 = 'On';
start(vid);
trigger(vid);
disp('Triggered!')
pause(s.DurationInSeconds+2) %this specifies how long camera will stay in strobe2=on mode
stop(vid)
src.Strobe2 = 'Off';

%% saving data
saveFlag=1;
fileID='XX1_u000_000';
if saveFlag==1  % change to 1 to save mat files
    im = getdata(vid);
    save(['C:\Users\Ingie\Documents\imager_data\TEST\' fileID '.mat'], 'im');
    clear im;   
end

function plotData(src,event)
         %plot(event.TimeStamps, event.Data)
         s.Rate=5000; %redundant
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
    temp2=temp1; temp2(temp1<0.16)=0; temp2(temp1>=0.16)=5; 
    PDchan=find(diff(temp2>2.5)==1);   
    dispSyncTimes=PDchan/s.Rate ; %this will become syncInfo.dispSyncs
    figure; plot(timestamps(1:end), temp2, 'r');
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    title('Photodiode Pulse');

end


%Proper commands to close out of video viewer in image acquisiton toolbox
%
%    stoppreview(vid);
%    closepreview(vid);


%Start acq
  
%data = startForeground(s);
%[data,timestamps] = startForeground(s);

