function configureMstate
% Revision 1-Oct.-2018 G. Hwang & I. Hong
% M.state.anim has been revised to default to date; it can be arranged to
% reflect an animal designation number
disp('Loading M(ain)state parameters...')
global Mstate

Mstate.anim = datestr(now, 'yymmdd'); %For default animal name, use date. Can be set to arbitrary name.
Mstate.unit = '000'; %  intended for experiment type
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 10; %distance between rodent eye and screen, in cm

Mstate.monitor = 'LIN';  %This should match the default value in Display

updateMonitorValues

Mstate.syncSize = 51;  %Size of the screen sync in cm

Mstate.running = 0;

Mstate.analyzerRoot = 'C:\Users\Huganir lab\Documents\imager_data'; %This should point to where images will be stored

Mstate.stimulusIDP = '10.194.190.56'; %This should be set to the slave computer's IP address

Mstate.DAQdevice='dev1';
Mstate.analogOUT_LED_channel='ao0';
Mstate.analogIN_camera_strobe_channel='ai0';
Mstate.analogIN_photodiode_channel='ai1';

%% for autodetection IP on same computer if using same computer as both master and slave
% h = java.net.InetAddress.getLocalHost();
% ipAddress = char(h.getHostAddress().toString());
% Mstate.stimulusIDP = ipAddress; 
