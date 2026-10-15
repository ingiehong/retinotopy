function [kmap_hor kmap_vert delay_hor delay_vert magS ang0 ang1 ang2 ang3 delayPool] = Gprocesskret_generatekmaps(f1,bw,hl,hh)

%f1 is a cell containing the result from 'f1meanimage'.  varargin is the optional
%filter kernel.  Each of the images are smoothed with a Gaussian with a std 
%dev of 'stdev' and a width of 'width'.
%
%delay_hor/delay_vert: per-pixel response delay (degrees of the stimulus cycle),
%each pixel unwrapped to within +/-90 deg of the pooled delay of the responsive
%pixels (diagnostic; the same values are used for kmap_hor/kmap_vert).
%delayPool.hor/.vert: the pooled delay (degrees) the per-pixel delays were unwrapped to.

ang1 = f1{2}; %two axes
ang3 = f1{4}; 
ang0 = f1{1};
ang2 = f1{3};

% ang1 = f1{1}; %for one axis
% ang3 = f1{2}; 
% ang0 = f1{1};
% ang2 = f1{2};


% ang0 = ang0*exp(-1i*180*pi/180);
% ang1 = ang1*exp(-1i*180*pi/180);
% ang2 = ang2*exp(-1i*180*pi/180);
% ang3 = ang3*exp(-1i*180*pi/180);

%The negative is to show where it peeks in the range of -180 to 180.
%i.e. -180 is the left most side of the stimulus.  Without the negative,
%an angle of -180 would have been the middle of the stimulus.
%angle(FourierTX(cos(wt-0))) == 0

if ~isempty(hh) %high pass filter
    ang1 = roifilt2(hh,ang1,bw,'same');
    ang3 = roifilt2(hh,ang3,bw,'same');
    ang0 = roifilt2(hh,ang0,bw,'same');
    ang2 = roifilt2(hh,ang2,bw,'same');
end
 
if ~isempty(hl) %else use standard smoothing
    ang1 = roifilt2(hl,-ang1,bw,'same');
    ang3 = roifilt2(hl,-ang3,bw,'same');
    ang0 = roifilt2(hl,-ang0,bw,'same');
    ang2 = roifilt2(hl,-ang2,bw,'same');
    
    mag1 = abs(ang1);
    mag3 = abs(ang3);
    mag0 = abs(ang0);
    mag2 = abs(ang2);
    magS.hor = (mag0+mag2)/2;
    magS.vert = (mag1+mag3)/2;
    
    ang1 = angle(ang1);
    ang3 = angle(ang3);
    ang0 = angle(ang0);
    ang2 = angle(ang2);
    
else %dont do anything, no LP filter
    mag1 = abs(ang1);
    mag3 = abs(ang3);
    mag0 = abs(ang0);
    mag2 = abs(ang2);
    magS.hor = (mag0+mag2)/2;
    magS.vert = (mag1+mag3)/2;
    
    ang1 = angle(-ang1);
    ang3 = angle(-ang3);
    ang0 = angle(-ang0);
    ang2 = angle(-ang2);
end


%Find delay as the angle of the bisector of the two opposite sweep directions.
%The bisector of two vectors is also the bisector of their negatives, so this
%per-pixel estimate is ambiguous by pi and has to be folded into a half circle.
delay_hor = angle(exp(1i*ang0) + exp(1i*ang2));
delay_vert = angle(exp(1i*ang1) + exp(1i*ang3));

%Fold: the old rule 'delay + pi/2*(1-sign(delay))' put every pixel into [0,pi),
%so a pixel whose true delay is close to zero but whose estimate came out
%slightly negative (typical for GCaMP, where the delay is a few degrees) was
%flipped by pi and its retinotopy shifted by half a cycle.  Instead, pool the
%delay over the responsive pixels (axial circular mean, which is immune to the
%pi ambiguity) and bring every pixel to within +/-pi/2 of that pooled delay.
[delay_hor delayPool.hor] = foldDelay(delay_hor,magS.hor);
[delay_vert delayPool.vert] = foldDelay(delay_vert,magS.vert);

%Use delay vector to calculate retinotopy.
kmap_hor = .5*(angle(exp(1i*(ang0-delay_hor))) - angle(exp(1i*(ang2-delay_hor))));
kmap_vert = .5*(angle(exp(1i*(ang1-delay_vert))) - angle(exp(1i*(ang3-delay_vert))));

%radians to degrees
delay_hor = delay_hor*180/pi.*bw;
kmap_hor = kmap_hor*180/pi.*bw;
delay_vert = delay_vert*180/pi.*bw;
kmap_vert = kmap_vert*180/pi.*bw;
delayPool.hor = delayPool.hor*180/pi;
delayPool.vert = delayPool.vert*180/pi;
% 
% %Create shadow of ROI coverage.
% x = bw.*floor(100/360*(kmap_hor+180))+1;
% y = bw.*floor(100/360*(-kmap_vert+180))+1;
% sh = shadow(x,y,100,100);

function [delay dpool] = foldDelay(raw,mag)
%raw: per-pixel delay estimate in (-pi,pi], ambiguous by pi.  mag: response magnitude.
hi = mag >= prctile(mag(:),80);           %responsive pixels
dpool = angle(mean(exp(2i*raw(hi))))/2;   %axial mean of the responsive pixels, in (-pi/2,pi/2]
%The response lags the stimulus, so place the pooled delay in [-pi/4,3*pi/4):
%small negative values are noise around a near-zero delay (GCaMP), values up
%to 135 deg of the cycle cover the slow intrinsic signal.
if dpool < -pi/4
    dpool = dpool + pi;
end
delay = raw - pi*round((raw-dpool)/pi);   %each pixel to within +/-pi/2 of the pooled delay

