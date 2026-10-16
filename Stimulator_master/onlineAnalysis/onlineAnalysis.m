function onlineAnalysis(c,r,syncInfo)

global Tens looperInfo F1 F1trials GUIhandles Mstate
 
if get(GUIhandles.main.analysisFlag,'value')
    
    disp(['Starting online phase analysis...'])
    if isfield(Mstate,'signalPolarity'), signalPolarity = Mstate.signalPolarity; else, signalPolarity = 'negative'; end
    signalSign = signalPolaritySign(signalPolarity); % -1 intrinsic, +1 GCaMP (see signalPolaritySign.m)
    if isfield(Mstate,'detrend') && ~isempty(Mstate.detrend), detrendMode = Mstate.detrend; else, detrendMode = 'none'; end % 'none' | 'linear' (bleaching)
    Grabtimes = syncInfo.acqSyncs;
    %Stimulus starts on 2nd sync, and ends on the second to last.  
    Disptimes = syncInfo.dispSyncs(2:end-2) 
    
    %T = getparam('t_period')/60;
    T = mean(diff(Disptimes)) %This one might be more accurate
    disp(['Detected ' num2str(length(Disptimes)-1) ' trials of visual stimulation. Average length: ' num2str(T) ])
    fidx = find(Grabtimes>Disptimes(1) & Grabtimes<Disptimes(end));  %frames during stimulus
    nAvail = size(Tens,3);
    if any(fidx > nAvail)   % the camera kept pulsing after the acquisition stopped (dropped frames, out of memory)
        warning('onlineAnalysis:frames', '%d camera pulses fall within the stimulus but only %d frames were saved; analysing the saved frames only', numel(fidx), nnz(fidx <= nAvail));
        fidx = fidx(fidx <= nAvail);
    end
    if numel(fidx) < 2
        error('onlineAnalysis:noFrames', 'no saved frames fall within the stimulus period: check the camera strobe line and the frame memory');
    end

    framest = Grabtimes(fidx)-Disptimes(1);  % frame sampling times in sec
    frameang = framest/T*2*pi;
    
    vidcell = cell(1,length(Disptimes)-1);
    l = 1;
    k = 1;
    for j=fidx(1):fidx(end)
        
        img = signalSign*double(Tens(:,:,j)); % sign applied once here (was the hard-coded 2^16-x inversion)
        
        if j==fidx(1)
            acc = zeros(size(img));
        end

        acc = acc + exp(1i*frameang(k)).*img;
        if strcmpi(detrendMode,'linear')   % sums for the per-pixel linear trend (bleaching)
            if k == 1, Sx = zeros(size(img)); Stx = zeros(size(img)); end
            Sx = Sx + img; Stx = Stx + framest(k)*img;
        end

        if framest(k)+Disptimes(1)>Disptimes(l+1)
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
     
    animal = get(findobj('Tag','animaltxt'),'String');
    unit   = get(findobj('Tag','unittxt'),'String');
    expt   = get(findobj('Tag','expttxt'),'String');
    datadir= get(findobj('Tag','datatxt'),'String');
    tag    = get(findobj('Tag','tagtxt'),'String');
    dd = [datadir '\' lower(animal) ];
    fname = sprintf('%s\\%s_u%s_%s_%03d_%03d.tif',dd,animal,unit,expt,c,r);
    if ~exist(fname, 'file')
        save_tif(avgvideo, fname)   
        disp(['Saved average tif file as: ' fname])
    end


    
    F0 = signalSign*double(mean(Tens(:,:,fidx(1):fidx(2)),3)); % same sign as img
 
    if strcmpi(detrendMode,'linear')
        % remove the fitted linear trend a + b*t of every pixel from the F1 projection in closed form
        N = k-1; t = framest(1:N); e = exp(1i*frameang(1:N));
        T1 = sum(t); T2 = sum(t.^2); E0 = sum(e); E1 = sum(t.*e);
        b = (N*Stx - T1*Sx) / (N*T2 - T1^2);
        a = (Sx - b*T1) / N;
        acc = acc - a*E0 - b*E1;
    else
        acc = acc - F0*sum(exp(1i*frameang)); %Subtract f0 leakage
    end
    acc = 2*acc ./ (k-1);


    if r == 1
        F1{c} = acc;
    else
        F1{c} = F1{c} + acc;
    end
    F1trials{c,r} = acc;   % per-trial F1 is kept so that repeat coherence can be assessed offline

    nc = length(looperInfo.conds);
    figure(99)
    subplot(1,nc,c), imagesc(angle(F1{c})), drawnow    
    title([ 'Condition ' num2str(c) ])
    %set(gca,'CLim',pi/180*[-50 50])
    axis image
    
end

Tens = Tens*0;