function [h] = GrabSaveLoop(h,fname,parport)

global Tens ROIcrop IMGSIZE GUIhandles FPS


total_time =  str2num(get(findobj('Tag','timetxt'),'String'));
N = ceil(total_time*FPS);


if get(GUIhandles.main.streamFlag,'value')
    
    zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
    h.mildig.Grab;
    h.mildig.GrabWait(3);

    for n = 1:N

        %Wait for grab to finish before switching the buffers
        h.mildig.GrabWait(3);

        %Switch destination, then grab to it (asynchronously)
        h.mildig.Image = h.buf{bitand(n,1)+1};
        h.mildig.Grab;

        %TTL pulse
        putvalue(parport,1); putvalue(parport,0);

        %Pull into Matlab workspace and save to disk
        im = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));
        var = ['f' num2str(n)];
        fnamedum = [fname '_' var];
        save(fnamedum,'im')


    end
    
    
else
    
    zz = zeros(ROIcrop(3),ROIcrop(4),'uint16');
    h.mildig.Grab;
    h.mildig.GrabWait(3);

    for n = 1:N

        %Wait for grab to finish before switching the buffers
        h.mildig.GrabWait(3);

        %Switch destination, then grab to it (asynchronously)
        h.mildig.Image = h.buf{bitand(n,1)+1};
        h.mildig.Grab;

        %TTL pulse
        putvalue(parport,1); putvalue(parport,0);

        %Pull into Matlab workspace (but wait to save it)
        Tens(:,:,n) = h.buf{2-bitand(n,1)}.Get(zz,IMGSIZE^2,-1,ROIcrop(1),ROIcrop(2),ROIcrop(3),ROIcrop(4));


    end
    
    tic
    for n = 1:N        
        im = Tens(:,:,n);
        var = ['f' num2str(n)];
        fnamedum = [fname '_' var];
        save(fnamedum,'im')        
    end
    toc
    
    

end

