function sendtoImager(cmd)
% Revision 1-Oct. 2018 G. Hwang
% Commented out code exclusive to obsolete frame grabber

global imagerhandles h;

switch(cmd(1))
    case 'A'  %% animal
        set(findobj('Tag','animaltxt'),'String',deblank(cmd(3:end)));
        %deblank(cmd(3:end))

    case 'E' %% expt      
        set(findobj('Tag','expttxt'),...
            'String',num2str(deblank(cmd(3:end))));

    case 'U'  %% unit
        set(findobj('Tag','unittxt'),...
            'String',num2str(deblank(cmd(3:end))));

%     case 'T'  %% time tag
%         set(findobj('Tag','tagtxt'),...
%             'String',deblank(sprintf('%03d',str2num(cmd(3:end)))));

    case 'M'  %% set mode
        m = str2num(cmd(3:end-1));

    case 'I'  %% Set acquisition time to total_time
        total_time=deblank(cmd(3:end));
        set(findobj('Tag','timetxt'),'String',total_time);
        preallocateTensor
        
        global vid FPS analogIN
        total_time=str2num(total_time);
        vid.FramesPerTrigger = (total_time)*FPS ;        
        if ~isempty(analogIN)
            analogIN.DurationInSeconds = total_time + 1; % Add 1 second to record all analog activity
            analogIN.NotifyWhenDataAvailableExceeds = analogIN.Rate*(analogIN.DurationInSeconds) ;
            %Make sure analog in is not running
            stop(analogIN)
        else
            disp('No DAQ boards present, imaging without synchronization...')
        end
        
    case 'S'  %% start sampling...
        
        trial = str2num(cmd(3:end));

        global nframes maxframes ...
            T imagerhandles fname running NBUF parport;


        animal = get(findobj('Tag','animaltxt'),'String');
        unit   = get(findobj('Tag','unittxt'),'String');
        expt   = get(findobj('Tag','expttxt'),'String');
        datadir= get(findobj('Tag','datatxt'),'String');
        tag    = get(findobj('Tag','tagtxt'),'String');

        %dd = [datadir '\' lower(animal) '\' animal '_u' unit '_' expt];
        dd = [datadir '\' lower(animal) ];
          
        fname = sprintf('%s\\%s_u%s_%s',dd,animal,unit,expt);
        fname = [fname  '_' sprintf('%03d',trial)];

        nframes = 1;

%         h = imagerhandles;
%        h.mildig.set('GrabFrameEndEvent',0,'GrabEndEvent',...
%            0,'GrabStartEvent',0);

%        set(1,'Name','imager :: Sampling ::');
%        drawnow;
        %h.mildig.Image = h.buf{1};
        %h = GrabSaveLoop(h,fname,parport); %
        
        GrabSave(fname); %
        set(1,'Name','imager');
        drawnow;

end