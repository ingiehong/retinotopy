function configSyncInput
%Revision 1-Oct.-2018 G. Hwang & I. Hong
%Added code to automatically detect camera probe pulse and photodiode
%stimulus pulse from analog channels on a NIDAQ
%Settings in this function were custom selected based on specification of
%NI USB-6008

global analogIN

% analogIN = analoginput('nidaq','Dev1');
% set(analogIN, 'SampleRate', 10000);
% actualInputRate = get(analogIN, 'SampleRate');
% addchannel(analogIN,[0 1]);
% set(analogIN,'SamplesPerTrigger',inf); 

daq.getDevices;
analogIN =daq.createSession('ni');
analogIN.Rate=5000; 
analogIN.DurationInSeconds = 10; %str2num(get(findobj('Tag','timetxt'),'String'));  

ch_camera = addAnalogInputChannel(analogIN,'dev1', 'ai0', 'Voltage'); %camera pulse set up
ch_camera.TerminalConfig = 'SingleEnded'; 
ch_camera.Range = [-10, 10]; % Adjust according to DAQ employed
ch_stim = addAnalogInputChannel(analogIN,'dev1','ai1', 'Voltage');     %Photodiode set up
ch_stim.TerminalConfig = 'SingleEnded';
ch_stim.Range = [-10, 10]; %  Adjust according to DAQ employed

analogIN.NotifyWhenDataAvailableExceeds = analogIN.Rate*(analogIN.DurationInSeconds) ; %50000;

end