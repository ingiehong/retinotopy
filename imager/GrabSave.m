function GrabSave(fname)
%Revision 1-Oct.-2018 G. Hwang and I. Hong
%Revision 16-Oct.-2026: camera profiles (imager/cameraConfig.m): Grasshopper3 via the pointgrey adaptor
%or Blackfly S via the gentl adaptor; strobe gated through cameraStrobe.m; frame count checked;
%large trials saved with -v7.3 and BigTIFF.

global Tens ROIcrop IMGSIZE GUIhandles FPS vid src

total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
N = ceil(total_time*FPS);
cfg = cameraConfig;

checkFrameMemory(vid, vid.FramesPerTrigger);   % errors with the fix before a trial that cannot fit in RAM
res = vid.VideoResolution;
fprintf('GrabSave: videoinput %d x %d px (ROI %s, %s), %d frames requested; %s\n', res(1), res(2), mat2str(vid.ROIPosition), vid.VideoFormat, vid.FramesPerTrigger, memoryReport());
cameraStrobe(src, true, cfg);   % strobe pulses only while frames are logged (the analysis indexes frames by pulse)
start(vid);
trigger(vid);
disp('Video acquisition triggered!')

%% Wait for logging to finish, then stop
try
    % returns as soon as FramesPerTrigger frames are logged, and in any case BEFORE the DAQ session's
    % DataAvailable callback (total_time + 1 s of analog data) runs the online analysis on Tens
    wait(vid, total_time + 0.5, 'logging');
catch
    if vid.FramesAvailable < 2, pause(total_time + 0.1); end   % adaptor without wait support: blind wait; a timeout just proceeds with the frames that arrived
end
stop(vid)
cameraStrobe(src, false, cfg);
nAvail = vid.FramesAvailable;
if nAvail ~= vid.FramesPerTrigger
    warning('GrabSave:frames', '%d frames available but %d were requested (dropped frames or memory?); the camera pulses recorded by the DAQ will not match the saved frames one to one', nAvail, vid.FramesPerTrigger);
end
[im, frameTimes] = getdata(vid, nAvail);
im = squeeze(im);
info = whos('im');
fprintf('GrabSave: %d frames of %d x %d %s received, %.2f MB per frame (%.2f GB); %s\n', nAvail, size(im, 2), size(im, 1), class(im), info.bytes / max(nAvail, 1) / 1e6, info.bytes / 2^30, memoryReport());
Tens = im;
tic
info = whos('im'); nbytes = info.bytes;
if nbytes > 2^31 - 1
    save([ fname '.mat'], 'im', 'frameTimes', '-v7.3');   % the default v7 format silently writes an empty file above 2 GB
else
    save([ fname '.mat'], 'im', 'frameTimes');
end
toc
tic
tifopts = struct('big', nbytes > 2^32 - 1);   % BigTIFF above 4 GB
saveastiff(im, [ fname '.tif'], tifopts)
toc
%Creating grab file
tmp=Tens(:,:,10);
grab.img = tmp; %tmp is grab from collect
grab.clock = round(datevec(now));
grab.ROIcrop = [];%[40 260 155 250]; 
grab.comments = {};

%[~,name,~]=fileparts(fName);
%save([fname '_grab.mat'], 'grab');

% if get(GUIhandles.main.streamFlag,'value')
%     
%     zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
% %    h.mildig.Grab; %
% %    h.mildig.GrabWait(3); %
% 
%     for n = 1:N
% 
%         %Wait for grab to finish before switching the buffers
%  %        h.mildig.GrabWait(3); %
% 
%         %Switch destination, then grab to it (asynchronously)
%  %       h.mildig.Image = h.buf{bitand(n,1)+1}; %
%  %       h.mildig.Grab; %
% 
%         %TTL pulse
% %        putvalue(parport,1); putvalue(parport,0); %
% 
%         %Pull into Matlab workspace and save to disk
%         im = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));
%         var = ['f' num2str(n)];
%         fnamedum = [fname '_' var];
%         save(fnamedum,'im')
% 
%     end
%     
%     
% else
%     
%     zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
% %    h.mildig.Grab; 
% %    h.mildig.GrabWait(3); 
% 
%     for n = 1:N
% 
%         %Wait for grab to finish before switching the buffers
% %         h.mildig.GrabWait(3); 
% % 
% %         %Switch destination, then grab to it (asynchronously)
% %         h.mildig.Image = h.buf{bitand(n,1)+1}; 
% %         h.mildig.Grab; 
% % 
% %         %TTL pulse
% %         putvalue(parport,1); putvalue(parport,0);  
% 
%         %Pull into Matlab workspace (but wait to save it)
% %        Tens(:,:,n) = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));
%     end
%     
%     tic
%     for n = 1:N        
%         im = Tens(:,:,n);
%         var = ['f' num2str(n)];
%         fnamedum = [fname '_' var];
%         save(fnamedum,'im')        
%     end
%     toc
%     
%     
% 
% end


function txt = memoryReport
% MATLAB's own memory use and the free physical memory (Windows only; elsewhere an empty string).
txt = '';
if ispc
    [u, sys] = memory;
    txt = sprintf('MATLAB using %.1f GB, %.1f GB physical free', u.MemUsedMATLAB / 2^30, sys.PhysicalMemory.Available / 2^30);
end
