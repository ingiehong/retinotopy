function Stimulator

%Initialize stimulus parameter structures
configurePstate('PG')
configureMstate
configureLstate

%Host-Host communication
configDisplayCom    %stimulus computer

%NI USB input for ISI acquisition timing from frame grabber
configSyncInput  

%configEyeShutter

%Open GUIs
MainWindow
Looper 
paramSelect
