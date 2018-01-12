function makeQuadraticLUT


%%

root = '/Matlab_code/calibration_stuff/measurements/';

% fget = 'CRT (new) 7-8-11/Luminance.mat';
% fput = 'CRT (new) 7-8-11/LUT.mat';

% fget = 'CRT (new) 7-8-11 UDT/Luminance.mat';
% fput = 'CRT (new) 7-8-11 UDT/LUT.mat';

fget = 'CRT 7-9-11 UDT/Luminance.mat';
fput = 'CRT 7-9-11 UDT/LUT.mat';

%load([root fget],'L','dom'); %Don't know why this used to be saved as 'L'
load([root fget],'Y','dom'); L = Y';

dom = dom';

H = [dom dom.^2 ones(size(dom))];

params = inv(H'*H)*H'*L;


domI = (0:255)';
H = [domI domI.^2 ones(size(domI))];
Lhat = H*params;

figure,

plot(dom,L)
hold on
plot(domI,Lhat,'k')

%Lhat = Lhat-ones(length(Lhat(:,1)),1)*params(end,:);

clear bufLUT
bufLUT = zeros(256,3);
for gun = 1:3
    for i = 0:255;
        val = i/255 * (Lhat(end,gun)-Lhat(1,gun)) + Lhat(1,gun);  %desired luminance as fraction of max
        [dum id] = min(abs(val - Lhat(:,gun)));  %find gun value that outputs closest to the desired Lum
        bufLUT(i+1,gun) = id;
    end
end

bufLUT = (bufLUT-1)/255;  %PTB wants it to be between 0 and 1

figure,plot(bufLUT)


%Save raw values and look-up-table

L = Lhat;
%save([root fput],'bufLUT','L')
