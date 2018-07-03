function preallocateTensor
%this code is used to create max number of mat files
global FPS Tens ROIcrop GUIhandles

 total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
 maxframes = ceil(total_time*FPS);
 disp(['Acquiring ' num2str(total_time) ' seconds and ' num2str(maxframes) ' frames.'])

if get(GUIhandles.main.analysisFlag,'value') || ~get(GUIhandles.main.streamFlag,'value')            
    Tens = zeros(ROIcrop(3),ROIcrop(4),maxframes,'uint16'); %array of zero images produced here
else
    Tens = 0;
end
