function preallocateTensor
%this code is used to create max number of mat files
global FPS Tens ROIcrop GUIhandles

 total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
 maxframes = ceil(total_time*FPS);
 disp(['Acquiring ' num2str(total_time) ' seconds and ' num2str(maxframes) ' frames.'])

% GrabSave assigns the acquired frames to Tens directly (Tens = im), so preallocating a full-size
% array here only doubled the memory footprint; with large cameras (Blackfly S) that alone exhausted the PC.
Tens = 0;
