function Stimulator
dbstop if error
%Initialize stimulus parameter structures
configurePstate('PG')
configureMstate
configureLstate

%Host-Host communication
configDisplayCom    %stimulus computer

%NI USB input for ISI acquisition timing from frame grabber
configSyncInput  %GMH commented this out

%configEyeShutter %GMH comented this out

%Open GUIs
MainWindow
Looper 
paramSelect
