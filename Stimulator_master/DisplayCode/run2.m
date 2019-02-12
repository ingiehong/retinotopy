function run2
%% Acquires video and analog data in a loop 
%Revision 3-Oct-2018. G Hwang and I. Hong
%Added function plotdata that creates syncInfo.acqSyncs and syncInfo.dispSyncs
%both of which are mandatory for the *.analyzer file

global GUIhandles Pstate Mstate trialno syncInfo analogIN lh
disp('AcquisitionLoop(run2) starting')
if Mstate.running %otherwise 'getnotrials' won't be defined for play sample
    nt = getnotrials;
end

ScanImageBit = get(GUIhandles.main.twophotonflag,'value');  %Flag for the link with scanimage
ISIbit =  get(GUIhandles.main.intrinsicflag,'value');
Behaviorbit =  get(GUIhandles.main.mouseBehavior,'value');

if Mstate.running && trialno<=nt  %'trialno<nt' may be redundant.
    
    set(GUIhandles.main.showTrial,'string',['Trial ' num2str(trialno) ' of ' num2str(nt)] ), drawnow

    [c r] = getcondrep(trialno);  %get cond and rep for this trialno
    
    disp('Sending visual stimulus to slave computer...')
    buildStimulus(c,trialno)    %Tell stimulus to buffer the images (also controls shutter)
    waitforDisplayResp   %Wait for serial port to respond from display

    if ISIbit
        %start(analogIN)  %Start sampling acquistion and stimulus syncs 
        lh = addlistener(analogIN,'DataAvailable',@plotData); 
        disp('Photodiode/Frame strobe acquisition started!')
        startBackground(analogIN);
    end
    
    %%%Update ScanImage with Trial/Cond/Rep
    if ScanImageBit  %This gets sent before trial starts
        updateACQtrial(trialno)
    end
    %%%%%%%%%%%%%%%
    
    if Behaviorbit
       
        %Send stuff to Arduino
        %Wait for Arduino to say it received instructions                                                                                  
    end

    %%%Organization of commands is important for timing in this part of loop
   
    startStimulus      %Tell Display to show its buffered images. TTL from stimulus computer "feeds back" to trigger 2ph acquisition
    
    %In 2ph mode, we don't want anything significant to happen after startStimulus, so that
    %scanimage will be ready to accept TTL
    
    
    if ISIbit
        sendtoImager(sprintf(['S %d' 13],trialno-1))  %Matlab now enters the frame grabbing loop (I will also save it to disk)
        
        %%%Timing is not crucial for this last portion of the loop (both display and frame grabber/saving is inactive)...

        delete(lh) % Added to remove listener 
        stop(analogIN)  %Stop sampling acquistion and stimulus syncs  % 
        
        %[syncInfo.dispSyncs syncInfo.acqSyncs syncInfo.dSyncswave] = getSyncTimes;   
        %syncInfo.dSyncswave = [];  %Just empty it for now
        %saveSyncInfo(syncInfo)  %append .analyzer file
        
        %[looperInfo.conds{c}.repeats{r}.dispSyncs looperInfo.conds{c}.repeats{r}.acqSyncs looperInfo.conds{c}.repeats{r}.dSyncswave] = getSyncTimes;
        
        %onlineAnalysis(c,r,syncInfo)     %Compute F1


        
    end
    
    
    if Behaviorbit
       
        %Get stuff from Arduino - Can make it wait for matlab to signal it
        %is ready to receive data, then send to matlab
        
        %Append analyzer file - should put raw up/down here
        
    end
   
    trialno = trialno+1;
    
    %This would otherwise get called by Displaycb 
    if ISIbit
        disp('AcquisitionLoop(run2) recursively looping')
        run2  %Nothing should happen after this
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
    %Before, I had this in the 'mainwindow callback routine, which messed
    %things up on occasion.
    %This is executed at the end of experiment and when abort button is hit
    if get(GUIhandles.main.twophotonflag,'value')
        Stimulus_localCallback('abort'); %Tell ScanImage to hit 'abort' button
    end
    
    %set(GUIhandles.param.playSample,'enable','off')
    
    Mstate.running = 0;
    set(GUIhandles.main.runbutton,'string','Run')
    
    if get(GUIhandles.main.intrinsicflag,'value')
        %set(GUIhandles.param.playSample,'enable','off')
        saveOnlineAnalysis
    end

end
disp('AcquisitionLoop(run2) done')



%% run2.m and getsync
function plotData(src,event)
    disp('Starting daq listner...')    
    savePath = parseString(Mstate.analyzerRoot,';');    
    savePath=savePath{1};
    fname = [Mstate.anim '_' sprintf('u%s',Mstate.unit) '_' Mstate.expt '_' sprintf('%03d',trialno-1)];
    fileID = [savePath '\' Mstate.anim '\' fname ];
    % fileID=['' datestr(now, 'yymmdd_HHMMSS') ];
    if ~exist(savePath)
        mkdir(savePath)
    end
    timestamps=event.TimeStamps;
    data=event.Data;
    % Following lines of code are good for debugging uses
    % figure; plot(timestamps,data);
    % xlabel('Time (seconds)');
    % ylabel('voltage (volts)');
    % legend('camera','photodiode');
    % title('Raw data from photodiode and camera');
    cameraPulseInd=find(diff(data(:,1)>1)==1);
    acqSyncTimes=cameraPulseInd/analogIN.Rate; % this will end up being syncInfo.acqSyncs
    disp(['Analyzing ' num2str(size(acqSyncTimes,1)) ' seconds of analog data...'])
    % convert photodiode pulse into start time
    temp1=sgolayfilt(data(:,2),27,51); 
    temp2=temp1; temp2(temp1<1)=0; temp2(temp1>=1.5)=5; 
    PDchan=find(diff(temp2>1.5)==1);   
    dispSyncTimes=PDchan/analogIN.Rate  %this will become syncInfo.dispSyncs
    figure; plot(timestamps(2:end), diff(data(:,1))>1);
    hold on
    plot(timestamps(1:end), temp2>1, 'r')
    legend('camera','photodiode');
    xlabel('Time (seconds)');
    ylabel('voltage (volts)');
    title('Processed data from photodiode and camera');
    % create structure syncInfo
    syncInfo={};
        syncInfo=setfield(syncInfo, 'dispSyncs', dispSyncTimes);
        syncInfo=setfield(syncInfo, 'acqSyncs', acqSyncTimes);
        
    %% Check for extra flashes in photodiode pulses - this was an interim measure useful for debugging photodiode
    %     while abs(syncInfo.dispSyncs(2) - syncInfo.dispSyncs(1)-2) >0.1
    %         disp('Erroneous first photodiode flash found.. deleting.')
    %         syncInfo.dispSyncs=syncInfo.dispSyncs(2:end);       
    %     end
    %%    
    diff(syncInfo.dispSyncs)
    saveSyncInfo(syncInfo)  %append .analyzer file
    onlineAnalysis(c,r,syncInfo)     %Compute F1
        
    %Good debug statements
    %save([ fileID '_syncInfo'], 'syncInfo' );
    %disp(['saving ...' fileID '_syncInfo'])
end


end

