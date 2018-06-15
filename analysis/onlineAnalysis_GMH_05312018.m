%function onlineAnalysis(c,r,syncInfo)
%c = conditions
%r=repeats (ALWAYS 1)
%global Tens looperInfo F1 GUIhandles
%This script is intended for May 31 2018 Data  collection
dataPath= 'C:\Users\hwanggm1\Documents\data\Retinopathy\ImagerData\05312018\';

%if get(GUIhandles.main.analysisFlag,'value')
%choose analyzer file to upload
%load('C:\Users\hwanggm1\Documents\data\Retinopathy\AnalyzerFiles\XX0\xx0_u000_001.analyzer', '-mat');
%load('C:\Users\hwanggm1\Documents\data\Retinopathy\AnalyzerFiles\XX0\xx0_u000_003.analyzer', '-mat');
syncInfo=syncInfo2; %update manually
%  
    %load file with syncInfo
    %Grabtimes = syncInfo.acqSyncs; % original code
    Grabtimes = syncInfo.acqSyncs; % GMH % expected dimension = 1870x1 double
    %Stimulus starts on 2nd sync, and ends on the second to last.  I also
    %get rid of the last bar rotation (dispSyncs(end-1)) in case it is not an integer multiple
    %of the stimulus trial length
    Disptimes = syncInfo.dispSyncs(2:end-2); %original code
%    Disptimes = syncInfo.dispSyncs(1:end-2);  %GMH for when first pulses is not captured  
    %T = getparam('t_period')/60; %commented out in original code
    T = mean(diff(Disptimes)); %This one might be more accurate. Expected T = 18.3.
    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));
    %frames during stimulus. Expected dimension: 1648x1 based on
    %L54_u000_003.analyzer

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec. Expected dimension 1648x1
    frameang = framest/T*2*pi; %Expected dimension 1648x1
    %GMH will now load raw images
    load([dataPath 'Widefield_2018-05-31_183657.mat']);
%   'Widefield_2018-05-31_175714.mat' % azimuth 0 deg
%   'Widefield_2018-05-31_180218.mat' % azimuth 180 deg
%   'Widefield_2018-05-31_181251.mat' % alt 0
%   'Widefield_2018-05-31_183657.mat' % alt 180
%    firstPos=floor(syncInfo.dispSyncs(1)*10); 
%    lastPos=firstPos+1870-1;

%    rowDim=[30 250]; %modify this if cropping down on original image
%    colDim=[100 350];%modify this if cropping down on original image
%    Tens=squeeze(im(rowDim(1):rowDim(2),colDim(1):colDim(2),1,:)); % 

%%


Tens=squeeze(im(:,:,1,:)); % 
 
    k = 1;
    for j=fidx(1):fidx(end)%original code
           
        img = 4096-double(Tens(:,:,j));
     
        if j==fidx(1) %original code
            acc = zeros(size(img));
        end

        acc = acc + exp(1i*frameang(k)).*img;

        k = k+1;

    end
    
    F0 = 4096-double(mean(Tens(:,:,fidx(1):fidx(2)),3));  %original code
    acc = acc - F0*sum(exp(1i*frameang)); %Subtract f0 leakage
    acc = 2*acc ./ (k-1);
%%
%GMH typed in values of c, r, and F1 to step thru GUI functionality
c=2; %update
r=2; %GMH update
%F1={}; %GMH update
    if r == 1
        F1{c} = acc;
    else
        F1{2} = acc; %F1{c} =  F1{c}+ acc; % manually set F1{2}=acc;
    end
%GMH is manually assigning looperInfo to Analyzer.loops
%looperInfo=Analyzer.loops; % this needs to be commented out to restore GUI functionality
nc=2;
   % nc = length(looperInfo.conds); %looper info is a struct with conds and formula
%nc=2; %temp measure
    figure(99)
    subplot(1,nc,c), imagesc(angle(F1{c})), drawnow    
    
%end
%% Check f1m after assigning F1 to it
f1m=F1;
figure(100)
subplot(1,2,1)
imagesc(angle(f1m{1})), drawnow
title('0 degrees ')
set(gca,'CLim',pi/180*[-50 50])
subplot(1,2,2)
imagesc(angle(f1m{2})), drawnow
title('180 degree ')
set(gca,'CLim',pi/180*[-50 50])
%Tens = Tens*0;
%save('XX0_000_003.mat', 'f1m') 
 