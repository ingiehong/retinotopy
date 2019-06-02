function Stimulator
%Revision 1-Oct-2018
 
%Initialize stimulus parameter structures
configurePstate('PG')
configureMstate
configureLstate

%Host-Host communication
configDisplayCom    %stimulus computer

%NI USB input for ISI acquisition timing from frame grabber or GiGE camaera
configSyncInput  %

%configShutter %no longer required in new implementation

%Open GUIs
MainWindow
Looper 
paramSelect
