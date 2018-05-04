function sendtoImager(cmd)
dbstop if error
global imagerhandles h;

switch(cmd(1))
    case 'A'  %% animal
        disp('In sendtoImager.m case A')
        set(findobj('Tag','animaltxt'),'String',deblank(cmd(3:end)));
        deblank(cmd(3:end))

    case 'E' %% expt      
        disp('In sendtoImager.m case E')
        set(findobj('Tag','expttxt'),...
            'String',num2str(deblank(cmd(3:end))));

    case 'U'  %% unit
        disp('In sendtoImager.m case U')
        set(findobj('Tag','unittxt'),...
            'String',num2str(deblank(cmd(3:end))));

%     case 'T'  %% time tag
%         set(findobj('Tag','tagtxt'),...
%             'String',deblank(sprintf('%03d',str2num(cmd(3:end)))));

    case 'M'  %% set mode
        disp('In sendtoImager.m case m')
        m = str2num(cmd(3:end-1));

    case 'I'  %% total_time
        disp('In sendtoImager.m case I')
        set(findobj('Tag','timetxt'),'String',deblank(cmd(3:end)));
        preallocateTensor
        
    case 'S'  %% start sampling...
        disp('In sendtoImager.m case S')
        trial = str2num(cmd(3:end));

        global nframes maxframes ...
            T imagerhandles fname running NBUF parport;


        animal = get(findobj('Tag','animaltxt'),'String');
        unit   = get(findobj('Tag','unittxt'),'String');
        expt   = get(findobj('Tag','expttxt'),'String');
        datadir= get(findobj('Tag','datatxt'),'String');
        tag    = get(findobj('Tag','tagtxt'),'String');

        dd = [datadir '\' lower(animal) '\u' unit '_' expt];
          
        fname = sprintf('%s\\u%s_%s',dd,unit,expt);
        fname = [fname  '_' sprintf('%03d',trial)];
        nframes = 1;
% 
%         h = imagerhandles;
%         h.mildig.set('GrabFrameEndEvent',0,'GrabEndEvent',...
%             0,'GrabStartEvent',0);
% 
%         set(1,'Name','imager :: Sampling ::');
%         drawnow;
        %h.mildig.Image = h.buf{1};

% 
     h = GrabSaveLoop(h,fname,parport);
% 
     set(1,'Name','imager');
     drawnow;

end