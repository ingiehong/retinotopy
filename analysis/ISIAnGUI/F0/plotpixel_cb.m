function plotpixel_cb

fh = gcf;
%colorbar('YTick',[1 16:16:64],'YTickLabel',{'0','45','90','135','180'})

datacursormode on;
dcm_obj = datacursormode(fh);
set(dcm_obj,'DisplayStyle','window','SnapToDataVertex','on','UpdateFcn',@myupdatefcn);


function txt = myupdatefcn(empt,event_obj)

%Matlab doesn't like it when I try to input other things into myupdatefcn,
%this is why I have these globals
 
global ACQinfo Tens1 Tens2 f0m1 f0m2 pepANA

tdom = 0:length(Tens1{1}(1,1,:))-1;
tdom = tdom*ACQinfo.msPerLine*ACQinfo.linesPerFrame;
if isfield(ACQinfo,'stimPredelay')
    predelay = ACQinfo.stimPredelay;
    trialtime = ACQinfo.stimTrialtime;    
    tdom = tdom-predelay;
end

screenDist = pepANA.config.display.viewingDistance;
screenResX = pepANA.config.display.pixelspercm;
screenResY = (1022-380)/24;

[xpos ypos xsize ysize] = getPosSize;
x_size = (max(xpos)-min(xpos)+min(xsize))/screenResX;  %cm stimulus width
x_size = 2*atan2(x_size/2,screenDist)*180/pi;  %convert to deg
y_size = (max(ypos)-min(ypos)+min(ysize))/screenResY;  %cm stimulus width
y_size = 2*atan2(y_size/2,screenDist)*180/pi;  %convert to deg

rows = ACQinfo.linesPerFrame;
cols = ACQinfo.pixelsPerLine;
%  
pos = get(event_obj,'Position'); %pos(1) is column dimension (top left is origin)
W = 5;
xran = (pos(1)-floor(W/2)):(pos(1)+floor(W/2));
yran = (pos(2)-floor(W/2)):(pos(2)+floor(W/2));

tau = pos(2)*ACQinfo.msPerLine;
tdom = tdom + tau;

figure(99)

retorixy = [0 90];
for z = 1:2 %loop through x and y dimension
    clear phasedom
    tc1 = NaN*ones(1,length(f0m1));
    tc2 = NaN*ones(1,length(f0m1));
    k = 1;
    for(i=0:length(f0m1)-1)  %loop through each condition
        pepsetcondition(i)
        if(~pepblank)       %This loop filters out the blanks

            v = pepgetvalues;
            ori = round(90*v(2));
            
            if retorixy(z) == ori

                dum1 = f0m1{i+1}(yran,xran);
                dum2 = f0m2{i+1}(yran,xran);
                tc1(i+1) = mean(dum1(:));
                tc2(i+1) = mean(dum2(:));

                k = k+1;

            end

        end
    end
    
    if retorixy(z) == 0
        phasedom = xpos;
    else
        phasedom = ypos;
    end
    
    phasedom(isnan(phasedom)) = [];

    [ma1 idma1] = max(tc1);
    [mi1 idmi1] = min(tc1);
    [ma2 idma2] = max(tc2);
    [mi2 idmi2] = min(tc2);
    tc1(find(isnan(tc1))) = []; %Get rid of blank index
    tc2(find(isnan(tc2))) = [];

    [phasedom id] = sort(phasedom);

    subplot(2,4,1+(z-1))
    if z == 1
        plot(phasedom,tc1(id)) 
        xlabel('x position')
    else
        plot(phasedom+380,tc1(id))
        xlabel('y position')
    end
    title('Chan 1')
    
    subplot(2,4,3+(z-1))
    if z == 1
        plot(phasedom,tc2(id)) 
        xlabel('x position')
    else
        plot(phasedom+380,tc2(id))
        xlabel('y position')
    end
    title('Chan 2')
    
    nopix = length(yran)*length(xran);

    subplot(2,4,1+(z-1)+4)
    dum = squeeze(sum(sum(Tens1{idma1}(yran,xran,:),1),2))/nopix;
    plot(tdom(1:end-1),dum(1:end-1)), hold on, plot(tdom(1:end-1),dum(1:end-1),'o')
    hold on
    dum = squeeze(sum(sum(Tens1{idmi1}(yran,xran,:),1),2))/nopix;
    plot(tdom(1:end-1),dum(1:end-1),'r'), hold on, plot(tdom(1:end-1),dum(1:end-1),'or')
    if isfield(ACQinfo,'stimPredelay')
        ylimits = get(gca,'Ylim');
        hold on, plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
    end
    hold off
    xlabel('sec')

    subplot(2,4,3+(z-1)+4)
    dum = squeeze(sum(sum(Tens2{idma2}(yran,xran,:),1),2))/nopix;
    plot(tdom(1:end-1),dum(1:end-1)), hold on, plot(tdom(1:end-1),dum(1:end-1),'o')
    hold on
    dum = squeeze(sum(sum(Tens2{idmi2}(yran,xran,:),1),2))/nopix;
    plot(tdom(1:end-1),dum(1:end-1),'r'), hold on, plot(tdom(1:end-1),dum(1:end-1),'or')
    if isfield(ACQinfo,'stimPredelay')
        ylimits = get(gca,'Ylim');
        hold on, plot([0 trialtime],[ylimits(1) ylimits(1)]+(ylimits(2)-ylimits(1))/10,'k')
    end
    hold off
    xlabel('sec')

    tar = get(get(event_obj,'Target'));
    data = tar.CData;

    txt = {['X: ',num2str(pos(1))],...
        ['Y: ',num2str(pos(2))],...
        ['Pos: ' sprintf('%2.1f %%',data(round(pos(2)),round(pos(1)))/64*180) ' deg']};
end