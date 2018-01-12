function makeLUT_nofit


%%

root = '/Matlab_code/calibration_stuff/measurements/';

% fget = 'CRT (new) 7-8-11/Luminance.mat';
% fput = 'CRT (new) 7-8-11/LUT.mat';

% fget = 'CRT (new) 7-8-11 UDT/Luminance.mat';
% fput = 'CRT (new) 7-8-11 UDT/LUT.mat';

%fget = 'CRT 7-9-11 UDT/Luminance.mat';
%fput = 'CRT 7-9-11 UDT/LUT.mat';

fget = 'NEWTV 3-15-12/Luminance.mat';
fput = 'NEWTV 3-15-12/LUT.mat';


%load([root fget],'L','dom'); %Don't know why this used to be saved as 'L'
load([root fget],'Y','dom'); L = Y';

dom = dom';
domI = (0:255)';


Li(:,1) = interp1(dom,L(:,1),domI); 
Li(:,2) = interp1(dom,L(:,2),domI);
Li(:,3) = interp1(dom,L(:,3),domI);


figure,

plot(dom,L)
hold on
plot(domI,Li,'k')

%Lhat = Lhat-ones(length(Lhat(:,1)),1)*params(end,:);

clear bufLUT
bufLUT = zeros(256,3);
for gun = 1:3
    for i = 0:255;
        val = i/255 * (Li(end,gun)-Li(1,gun)) + Li(1,gun);  %desired luminance as fraction of max
        [dum id] = min(abs(val - Li(:,gun)));  %find gun value that outputs closest to the desired Lum
        bufLUT(i+1,gun) = id;
    end
end

bufLUT = (bufLUT-1)/255;  %PTB wants it to be between 0 and 1

figure,plot(bufLUT)


%Save raw values and look-up-table

L = Li;
save([root fput],'bufLUT','L')
