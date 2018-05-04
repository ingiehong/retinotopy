%This script scans for DAQ and add an input channel from camera
daq.getDevices
s=daq.createSession('ni')
addAnalogInputChannel(s,'dev1','ai0','Voltage')


%addAnalogOutputChannel(s,'Dev1',0,'Voltage')

%outputSingleScan(s,0); %turns off LED
%outputSingleScan(s,2); %turns on LED