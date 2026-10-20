function GrabSave(fname)
%Revision 1-Oct.-2018 G. Hwang and I. Hong
%Revision 16-Oct.-2026: camera profiles (imager/cameraConfig.m): Grasshopper3 via the pointgrey adaptor
%or Blackfly S via the gentl adaptor; strobe gated through cameraStrobe.m; frame count checked;
%large trials saved with -v7.3 and BigTIFF.

global Tens ROIcrop IMGSIZE GUIhandles FPS vid src

total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
N = ceil(total_time*FPS);
cfg = cameraConfig;

checkFrameMemory(vid, vid.FramesPerTrigger);   % errors with the fix before a trial that cannot fit in physical RAM
sz = frameSize(vid); nReq = vid.FramesPerTrigger;
fprintf('GrabSave: frames %d x %d px (ROI %s, %s), %d requested; %s\n', sz(1), sz(2), mat2str(vid.ROIPosition), vid.VideoFormat, nReq, memoryReport());
cameraStrobe(src, true, cfg);   % strobe pulses only while frames are logged (the analysis indexes frames by pulse)
start(vid);
trigger(vid);
disp('Video acquisition triggered!')

%% Pull the frames out of the acquisition buffer WHILE they arrive, into one preallocated array, so the
% trial is held once (letting the buffer fill and copying it out at the end doubled the memory and ran a
% 16 GB PC dry). The loop ends at total_time + 0.5 s at the latest: before the DAQ session's
% DataAvailable callback (total_time + 1 s of analog data) runs the online analysis on Tens.
im = []; frameTimes = zeros(nReq, 1); k = 0; t0 = tic;
while k < nReq && toc(t0) < total_time + 0.5
    n = min(vid.FramesAvailable, nReq - k);
    if n > 0
        [fr, tt] = getdata(vid, n);                      % H x W x bands x n
        if isempty(im), im = zeros(size(fr, 1), size(fr, 2), nReq, class(fr)); end
        im(:, :, k+1:k+n) = reshape(fr, size(fr, 1), size(fr, 2), n);
        frameTimes(k+1:k+n) = tt(:); k = k + n;
    else
        pause(0.02);
    end
end
stop(vid)
cameraStrobe(src, false, cfg);
n = min(vid.FramesAvailable, nReq - k);                   % whatever arrived while stopping
if n > 0
    [fr, tt] = getdata(vid, n);
    if isempty(im), im = zeros(size(fr, 1), size(fr, 2), nReq, class(fr)); end
    im(:, :, k+1:k+n) = reshape(fr, size(fr, 1), size(fr, 2), n);
    frameTimes(k+1:k+n) = tt(:); k = k + n;
end
flushdata(vid);
nAvail = k;
if nAvail == 0
    error('GrabSave:noFrames', 'no frames arrived in %g s: check the camera, its USB link and the strobe/trigger settings', total_time + 0.5);
end
if nAvail ~= nReq
    warning('GrabSave:frames', '%d frames received but %d were requested (dropped frames or memory?); the camera pulses recorded by the DAQ will not match the saved frames one to one', nAvail, nReq);
    im(:, :, nAvail+1:end) = []; frameTimes(nAvail+1:end) = [];
end
info = whos('im');
sub = im(:, :, 1:max(1, floor(nAvail / 20)):nAvail);      % every ~20th frame for the saturation readout
top = double(intmax(class(im)));
fprintf('GrabSave: %d frames of %d x %d %s received, %.2f MB per frame (%.2f GB); max pixel %d of %d, %.2f%% of pixels at the top; %s\n', ...
    nAvail, size(im, 2), size(im, 1), class(im), info.bytes / nAvail / 1e6, info.bytes / 2^30, max(sub(:)), top, 100 * mean(sub(:) >= top - 1), memoryReport());
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
