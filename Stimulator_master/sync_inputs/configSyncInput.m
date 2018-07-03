function configSyncInput

global analogIN

% analogIN = analoginput('nidaq','Dev1');
% set(analogIN, 'SampleRate', 10000);
% actualInputRate = get(analogIN, 'SampleRate');
% addchannel(analogIN,[0 1]);
% set(analogIN,'SamplesPerTrigger',inf); 

daq.getDevices;
analogIN =daq.createSession('ni');
analogIN.Rate=5000;
analogIN.DurationInSeconds = 10; %str2num(get(findobj('Tag','timetxt'),'String'));  %  use 20 for debugging and 200 for ISI. Allow extra 15 second when doing data collect

ch_camera = addAnalogInputChannel(analogIN,'dev1', 'ai0', 'Voltage'); %camera pulse set up
ch_camera.TerminalConfig = 'SingleEnded'; 
ch_camera.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 
ch_stim = addAnalogInputChannel(analogIN,'dev1','ai1', 'Voltage');     %Photodiode set up
ch_stim.TerminalConfig = 'SingleEnded';
ch_stim.Range = [-10, 10]; % Changed to -10 to 10 due to error on NI USB-6008 

analogIN.NotifyWhenDataAvailableExceeds = analogIN.Rate*(analogIN.DurationInSeconds) ; %50000;

end