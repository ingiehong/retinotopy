function configSync

global daq

daq = DaqDeviceIndex;

if ~isempty(daq)
    
    DaqDConfigPort(daq,0,0);    
    
    DaqDOut(daq, 0, 0); 
    
else
    
   disp( 'Daq device does not appear to be connected')
   disp( 'This version of Stimulator does not use Slave-side signals to synchronize.')
    
end