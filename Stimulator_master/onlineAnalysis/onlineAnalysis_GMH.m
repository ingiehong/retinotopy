function onlineAnalysis(c,r,syncInfo)
%c = conditions
%r=repeats (ALWAYS 1)
%This script is actively being modifed by GMH
global Tens looperInfo F1 GUIhandles
 
if get(GUIhandles.main.analysisFlag,'value')
%load('C:\Users\Ingie\Documents\ISI_Data\AnalyzerFiles\A71\A71_u000_001.analyzer', '-mat');
%A71_u000_001.analyzer is modified based on L54_000_001.analyzer
    %load('C:\Users\Ingie\Documents\imager_data\TEST\u004_020syncInfo');
    %load file with syncInfo
    %Grabtimes = syncInfo.acqSyncs; % original code
    Grabtimes = syncInfo.acqSyncs/10; % GMH % expected dimension = 1870x1 double
    %Stimulus starts on 2nd sync, and ends on the second to last.  I also
    %get rid of the last bar rotation (dispSyncs(end-1)) in case it is not an integer multiple
    %of the stimulus trial length
  %  Disptimes = syncInfo.dispSyncs(2:end-2); %original code
    Disptimes = syncInfo.dispSyncs(2:end-2);  %GMH 2 removes prestim and post stime pulses
    %T = getparam('t_period')/60; %commented out in original code
    T = mean(diff(Disptimes)); %This one might be more accurate. Expected T = 18.3, but yet emulated T ~16

    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));  %frames during stimulus. Expected dimension: 1648x1

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec. Expected dimension 1648x1
    frameang = framest/T*2*pi; %Expected dimension 1648x1
    %GMH will now load raw images
    Tens=zeros(300,480,1870);
    % cd('C:\Users\Ingie\Documents\ISI_Data\SampleData\A71\raw\u000_001_000\')
    %now populate Tens with raw data provided by Ashley - must do twice for
    %each condition    
    %The following loop was used to read in Callaway's example images
    % cd('C:\Users\Ingie\Documents\ISI_Data\SampleData\A71\raw\u000_001_000\')
    % cd('C:\Users\Ingie\Documents\ISI_Data\SampleData\A71\raw\u000_001_001\')
    %   for i=1:length(Tens)
    %       load(['u000_001_000_f' num2str(i)]);
    %       load(['u000_001_001_f' num2str(i)]);
    %       Tens(:,:,i)=im;
    %       clear im
    %   end
    
    load('C:\Users\Ingie\Documents\imager_data\TEST\test_u004_020.mat');
    firstPos=floor(syncInfo.dispSyncs(1)*10); %need to discuss this with Ingie. 15 second delay may be problematic
    lastPos=firstPos+1870-1;
   
    Tens=squeeze(im(:,:,1,firstPos:lastPos));  % need to think about how to locate 1870
    k = 1;
    for j=fidx(1):fidx(end)%original code
%    for j=1:180 
        %hardcoded 1870 to avoid index exceed matrix error; orig code looped to fidx(end)
        
        img = 4096-double(Tens(:,:,j));
     
        if j==fidx(1)
            acc = zeros(size(img));
        end

        acc = acc + exp(1i*frameang(k)).*img;

        k = k+1;

    end
    
    F0 = 4096-double(mean(Tens(:,:,fidx(1):fidx(2)),3));  %original code
 %   F0 = 4096-double(mean(Tens(:,:,1:180),3));
    acc = acc - F0*sum(exp(1i*frameang)); %Subtract f0 leakage
    acc = 2*acc ./ (k-1);

%GMH typed in values of c, r, and F1 to step thru GUI functionality
c=1; %update
r=1; %GMH update
F1={}; %GMH update
    if r == 1
        F1{c} = acc;
    else
        F1{c} = F1{c} + acc;
    end
%GMH is manually assigning looperInfo to Analyzer.loops
%looperInfo=Analyzer.loops; % this needs to be commented out to restore GUI functionality
nc=2;
   % nc = length(looperInfo.conds); %looper info is a struct with conds and formula
%nc=2; %temp measure
    figure(99)
    subplot(1,nc,c), imagesc(angle(F1{c})), drawnow    

end

Tens = Tens*0;