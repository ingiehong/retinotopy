function configAnalogOutput
% Sets up analog output port for use in controlling LED intensity
%
% Ingie Hong, 2018
% 

disp('Setting up analog output for LED intensity control...')
global analogOUT Mstate
daq.getDevices;
analogOUT =daq.createSession('ni');
analogOUT.Rate = 5000;
warning('off','daq:Session:onDemandOnlyChannelsAdded')
addAnalogOutputChannel(analogOUT, Mstate.DAQdevice, Mstate.analogOUT_LED_channel,'Voltage');

% outputSingleScan(analogOUT,0); %turns off LED
% outputSingleScan(analogOUT,1); %turns off LED
% outputSingleScan(analogOUT,0); %turns off LED
% outputSingleScan(analogOUT,5); %turns off LED
% outputSingleScan(analogOUT,0); %turns off LED
