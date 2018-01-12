function updateMonitorValues

global Mstate

%Putting in the right pixels is not important because the stimulus computer
%asks for the actual value anyway.  It only matters if the analysis needs
%the right number of pixels (like retinotopy stimuli).

switch Mstate.monitor
    
    case 'LCD' 
        
        Mstate.screenXcm = 33.7;
        Mstate.screenYcm = 27;
        Mstate.xpixels = 1024;
        Mstate.ypixels = 768;

    case 'CRT'

%         Mstate.screenXcm = 32.5;
%         Mstate.screenYcm = 24;
        
        Mstate.screenXcm = 30.5;
        Mstate.screenYcm = 22;
        
        Mstate.xpixels = 1024;
        Mstate.ypixels = 768;
        
     case 'TEL'

%         Mstate.screenXcm = 32.5;
%         Mstate.screenYcm = 24;
        
        Mstate.screenXcm = 121;
        Mstate.screenYcm = 68.3;
        
        Mstate.xpixels = 1024;
        Mstate.ypixels = 768;
        
end