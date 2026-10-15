function [F1, avgvideo] = offlineAnalysis(c,syncInfo, Tens, output_tif_filename, signalPolarity)
% Imitates the function of onlineAnalysis, on recorded files 
% signalPolarity: 'negative' (intrinsic imaging, default: frames are negated, as the old
% hard-coded 2^16-x inversion did) or 'positive' (GCaMP: frames are used as recorded).
% See signalPolaritySign.m.
%
% Example of usage: (please see offlineAnlaysis_script.m)
% load('180705_u000_000_001.mat')
% im=squeeze(im);
% load('180705_u000_000.analyzer', '-mat')
% offlineAnalysis(2,syncInfo1, im)
%
% 
% Ingie Hong, Johns Hopkins Medical Institute, 2018
 
%global Tens looperInfo F1 GUIhandles
 
%if get(GUIhandles.main.analysisFlag,'value')
    
    if nargin < 5, signalPolarity = 'negative'; end
    signalSign = signalPolaritySign(signalPolarity); % -1 intrinsic, +1 GCaMP
    disp(['Starting offline phase analysis...'])
    Grabtimes = syncInfo.acqSyncs;
    %Stimulus starts on 2nd sync, and ends on the second to last.  I also
    %get rid of the last bar rotation (dispSyncs(end-1)) in case it is not an integer multiple
    %of the stimulus trial length
    Disptimes = syncInfo.dispSyncs(2:end-2) ;
    
    %T = getparam('t_period')/60;
    T = mean(diff(Disptimes)); %This one might be more accurate
    disp(['Detected ' num2str(length(Disptimes)-1) ' trials of visual stimulation. Average length: ' num2str(T) ])
    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));  %frames during stimulus

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec
    frameang = framest/T*2*pi;
    
    vidcell = cell(1,length(Disptimes)-1);
    l = 1; % Trial #
    k = 1; % Frame #
    for j=fidx(1):fidx(end) % For all frames during stimulus
        
        img = signalSign*double(Tens(:,:,j)); % sign applied once here (was the hard-coded 2^16-x inversion)
        
        if j==fidx(1)
            acc = zeros(size(img)); % Empty cache for phase calculation, acc
        end

        acc = acc + exp(1i*frameang(k)).*img;
        
        if framest(k)+Disptimes(1)>Disptimes(l+1) % If in next trial,
            l = l+1;
        end
        
        if isempty(vidcell{l})
            vidcell{l}(:,:,1) = Tens(:,:,j);
        else
            vidcell{l}(:,:,end+1) = Tens(:,:,j);
        end
        
        k = k+1;

    end
    size_vidcell=reshape(cell2mat(cellfun( @size, vidcell, 'UniformOutput',false) ),3,[]);
    

    avgvideo=uint16(zeros(size_vidcell(1,1), size_vidcell(2,1), min(size_vidcell(3,:))));
    for i=1:min(size_vidcell(3,:))
        avgframe = cellfun(@(c) c(:,:,i), vidcell ,'UniformOutput',false );
        avgframe = reshape(avgframe, 1,1,[]);
        avgframe = mean(cell2mat(avgframe),3);
        avgvideo(:,:,i) = avgframe;
    end
    if ~exist(output_tif_filename, 'file')
        saveastiff(avgvideo, output_tif_filename)   
    end
    
    F0 = signalSign*double(mean(Tens(:,:,fidx(1):fidx(2)),3)); % same sign as img
    
    acc = acc - F0*sum(exp(1i*frameang)); %Subtract f0 leakage
    acc = 2*acc ./ (k-1);

% 
%     if r == 1
         F1 = acc;
%     else
%         F1{c} = F1{c} + acc;
%     end

    %nc = length(looperInfo.conds);
    figure
    %subplot(1,nc,c), 
    imagesc(angle(F1)), drawnow    
    title([ 'Condition ' num2str(c) ])
    %set(gca,'CLim',pi/180*[-50 50])
    axis image
%end

%Tens = Tens*0;