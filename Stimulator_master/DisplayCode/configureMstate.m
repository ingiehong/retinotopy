function configureMstate

global Mstate

Mstate.anim = 'xx0';
Mstate.unit = '000';
Mstate.expt = '000';

Mstate.hemi = 'left';
Mstate.screenDist = 25;

Mstate.monitor = 'TEL';  %This should match the default value in Display

updateMonitorValues

Mstate.syncSize = 4;  %Size of the screen sync in cm

Mstate.running = 0;

%Mstate.analyzerRoot = ['C:\VStimFiles\AnalyzerFiles' ' ; ' '\\ACQUISITION\neurostuff\AnalyzerFiles'];
Mstate.analyzerRoot = 'C:\neurodata\AnalyzerFiles_new';

Mstate.stimulusIDP = '10.1.38.61';  %Neighbor (ISI computer)


