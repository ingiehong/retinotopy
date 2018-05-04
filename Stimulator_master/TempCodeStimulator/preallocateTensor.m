function preallocateTensor

global FPS Tens ROIcrop GUIhandles
%From within C:\Users\Ingie\Documents\My Code\Callaway_ISI\Stimulator_master\TempCodeStimulator
 total_time =  str2num(get(findobj('Tag','timetxt'),'String'))

 maxframes = ceil(total_time*FPS)
 %keyboard
if get(GUIhandles.main.analysisFlag,'value') || ~get(GUIhandles.main.streamFlag,'value')            
    Tens = zeros(ROIcrop(3),ROIcrop(4),maxframes,'uint16');
else
    Tens = 0;
end
