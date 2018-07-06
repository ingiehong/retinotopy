function GrabSave(fname)

global Tens ROIcrop IMGSIZE GUIhandles FPS vid src

total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
N = ceil(total_time*FPS);

%pause(1)
src.Strobe2 = 'On';
start(vid);
trigger(vid);
disp('Video acquisition triggered!')

%% Stop acquisition
pause(total_time+0.1) %this specifies how long camera will stay in strobe2=on mode
%above line should be +2 to enable saving
stop(vid)
src.Strobe2 = 'Off';
%pause(1) % delay for analog data acquisition to finish.

im = squeeze(getdata(vid));
Tens = im;
save([ fname '.mat'], 'im');


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
% %    h.mildig.Grab; %GMH
% %    h.mildig.GrabWait(3); %GMH
% 
%     for n = 1:N
% 
%         %Wait for grab to finish before switching the buffers
%  %        h.mildig.GrabWait(3); %GMH
% 
%         %Switch destination, then grab to it (asynchronously)
%  %       h.mildig.Image = h.buf{bitand(n,1)+1}; %GMH
%  %       h.mildig.Grab; %GMH
% 
%         %TTL pulse
% %        putvalue(parport,1); putvalue(parport,0); %GMH
% 
%         %Pull into Matlab workspace and save to disk
%         im = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));
%         var = ['f' num2str(n)];
%         fnamedum = [fname '_' var];
%         save(fnamedum,'im')
% keyboard
% 
%     end
%     
%     
% else
%     
%     zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
% %    h.mildig.Grab; %GMH
% %    h.mildig.GrabWait(3); %GMH
% 
%     for n = 1:N
% 
%         %Wait for grab to finish before switching the buffers
% %         h.mildig.GrabWait(3); %GMH
% % 
% %         %Switch destination, then grab to it (asynchronously)
% %         h.mildig.Image = h.buf{bitand(n,1)+1}; %GMH
% %         h.mildig.Grab; %GMH
% % 
% %         %TTL pulse
% %         putvalue(parport,1); putvalue(parport,0);  %GMH
% 
%         %Pull into Matlab workspace (but wait to save it)
% %        Tens(:,:,n) = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));
% 
% 
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
