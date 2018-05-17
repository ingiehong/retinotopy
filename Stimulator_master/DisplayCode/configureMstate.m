function configureMstate

global Mstate

Mstate.anim = 'xx0';
Mstate.unit = '000';
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 10; %GMH need to ask Ingie about correct screen distance

Mstate.monitor = 'LIN';  %This should match the default value in Display

updateMonitorValues

Mstate.syncSize = 51;  %Size of the screen sync in cm

Mstate.running = 0;

%Mstate.analyzerRoot = ['C:\VStimFiles\AnalyzerFiles' ' ; ' '\\ACQUISITION\neurostuff\AnalyzerFiles'];
%Mstate.analyzerRoot = 'C:\neurodata\AnalyzerFiles_new';
%Mstate.analyzerRoot = 'C:\Users\hwanggm1\Documents\data\Retinopathy\AnalyzerFiles' %GMH

Mstate.analyzerRoot = 'C:\Users\Ingie\Documents\imager_data';
%update path for Huganir system
%Mstate.stimulusIDP = '10.194.195.180';  %Neighbor (ISI computer) %GMH update this
%Mstate.stimulusIDP = '172.0.0.1';
Mstate.stimulusIDP = '10.194.132.250';

%% for autodetection IP on same computer
% h = java.net.InetAddress.getLocalHost();
% ipAddress = char(h.getHostAddress().toString());
% Mstate.stimulusIDP = ipAddress; % '192.168.159.3';  
