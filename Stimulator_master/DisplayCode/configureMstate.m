function configureMstate
%revision 1-Oct.-2018 G. Hwang & I. Hong
%M.state.anim has been revised to reflect date; it can be arranged to
%reflect an animal designation number
global Mstate

Mstate.anim = datestr(now, 'yymmdd'); %Ingie  - can this be made to be either a date or an animal label?
Mstate.unit = '000'; %  intended for experiment type
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 10; %distance between rodent eye and screen

Mstate.monitor = 'LIN';  %This should match the default value in Display

updateMonitorValues

Mstate.syncSize = 51;  %Size of the screen sync in cm

Mstate.running = 0;

Mstate.analyzerRoot = 'C:\Users\Huganir lab\Documents\imager_data'; %This should point to where images will be stored

Mstate.stimulusIDP = '10.194.213.208'; %This point to slave computer

%% for autodetection IP on same computer if using same computer as both master and slave
% h = java.net.InetAddress.getLocalHost();
% ipAddress = char(h.getHostAddress().toString());
% Mstate.stimulusIDP = ipAddress; 
