function onlineAnalysis(c,r,syncInfo)

global Tens looperInfo F1 GUIhandles
 
if get(GUIhandles.main.analysisFlag,'value')
    
    disp(['Starting online phase analysis...'])
    Grabtimes = syncInfo.acqSyncs;
    %Stimulus starts on 2nd sync, and ends on the second to last.  
    Disptimes = syncInfo.dispSyncs(2:end-2) 
    
    %T = getparam('t_period')/60;
    T = mean(diff(Disptimes)) %This one might be more accurate
    disp(['Detected ' num2str(length(Disptimes)-1) ' trials of visual stimulation. Average length: ' num2str(T) ])
    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));  %frames during stimulus

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec
    frameang = framest/T*2*pi;
    
    k = 1;
    for j=fidx(1):fidx(end)
        
        img = 2^16-double(Tens(:,:,j)); % Now 16bit rather than 12bit
%       img = double(Tens(:,:,j)); % Try not inverting
        
        if j==fidx(1)
            acc = zeros(size(img));
        end

        acc = acc + exp(1i*frameang(k)).*img;

        k = k+1;

    end
 
    F0 = 2^16-double(mean(Tens(:,:,fidx(1):fidx(2)),3)); % Now 16bit rather than 12bit
%    F0 = double(mean(Tens(:,:,fidx(1):fidx(2)),3)); % Try not inverting
 
    acc = acc - F0*sum(exp(1i*frameang)); %Subtract f0 leakage
    acc = 2*acc ./ (k-1);


    if r == 1
        F1{c} = acc;
    else
        F1{c} = F1{c} + acc;
    end

    nc = length(looperInfo.conds);
    figure(99)
    subplot(1,nc,c), imagesc(angle(F1{c})), drawnow    
    title([ 'Condition ' num2str(c) ])
    %set(gca,'CLim',pi/180*[-50 50])
    axis image
    
end

Tens = Tens*0;