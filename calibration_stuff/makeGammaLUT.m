
%IN 5/18/10  In this new version, it reads a .mat file instead of text
%file.  It doesn't have any interpolation of the raw data. And I fit a
%gamma function to smooth it.  The gamma turned out to be the best mainly
%because it is always monotonic. The polynomials (and raw data because of noise)
%always give a nonmonotonic curve near the origin.

root = '/Matlab_code/calibration_stuff/measurements/';

fget = 'TELEV 9-29-10/luminance.mat';
fput = 'TELEV 9-29-10/LUT.mat';

load([root fget],'Y','dom');

L = Y';  %luminance
dom = dom';

domI = 0:255;


clear E Lhat
gammaspace = 1.5:.01:3.5;
for i = 1:3
    for j = 1:length(gammaspace);
        mod = dom.^gammaspace(j);
        mod = mod*L(end,i)/mod(end);
        E(i,j) = mean((mod-L(:,i)).^2);
    end
    
    [dum id] = min(E(i,:));
    gamma(i) = gammaspace(id);
    Lhat(:,i) = domI.^gamma(i);
    Lhat(:,i) = Lhat(:,i)*L(end,i)/Lhat(end,i);
end



figure,plot(dom,L)
hold on
plot(domI,Lhat,'k')


%Convert to Look-up-table
Lhat = Lhat./(ones(256,1)*Lhat(end,:));

gammaLUT = linspace(0,1,256)';
for i = 1:3
    bufLUT(:,i) = 10.^(log10(gammaLUT)/gamma(i));
end
figure,plot(bufLUT)


%Save raw values and look up table

L = Lhat;
%save([root fput],'bufLUT','L')

