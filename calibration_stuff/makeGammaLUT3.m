
%2 doesn't assume 0:5:255.  I started using it with the UDT measurements

%IN 5/18/10  In this new version, it reads a .mat file instead of text
%file.  It doesn't have any interpolation of the raw data. And I fit a
%gamma function to smooth it.  The gamma turned out to be better than polynomial, mainly
%because it is always monotonic. The polynomials (and raw data because of
%noise)

%always give a nonmonotonic curve near the origin.
%%
root = '/Matlab_code/calibration_stuff/measurements/';

%fget = 'TELEV 9-29-10/luminance.mat';
%fput = 'TELEV 9-29-10/LUT.mat';

% fget = 'LCD (big) 1-8-11/Luminance.mat';
% fput = 'LCD (big) 1-8-11/LUT.mat';


fget = 'CRT (new) 7-6-11/Luminance.mat';
fput = 'CRT (new) 7-6-11/LUT.mat';

%load([root fget],'L','dom'); %Don't know why this used to be saved as 'L'
load([root fget],'Y','dom'); L = Y';

dom = dom';

domI = (0:255)';

clear E

gammaspace = 1.5:.01:3.5;
Ampspace = .95:.01:1.05;

amps = L(end,:);
L(:,1) = L(:,1)/amps(1); L(:,2) = L(:,2)/amps(2); L(:,3) = L(:,3)/amps(3);


for i = 1:3
    

    Basespace = mean(L(i,:))-.5 : .05: mean(L(i,:))+.5;
    id = find(Basespace<0); Basespace(id) = 0;
    
    
    
    for j = 1:length(gammaspace);
        for k = 1:length(Ampspace)
            for m = 1:length(Basespace)
                mod = Ampspace(k)*dom.^gammaspace(j) + Basespace(m);
                %mod = Ampspace(k)*mod*L(end,i)/mod(end);
                E(j,k,m,i) = mean((mod-L(end,i)).^2);
            end
        end
    end
    
    Emat = squeeze(E(:,:,:,i));
    [dum idm] = min(Emat,[],3);
    [idy idx] = find(dum == min(dum(:)));
    baseid = idm(idy,idx);
    Emat = Emat(:,:,baseid);
    [gammaid ampid] = find(Emat == min(Emat(:)));
    
    gamma(i) = gammaspace(gammaid);
    amp(i) = Ampspace(ampid);
    base(i) = Basespace(baseid);
    
    Lhat(:,i) = amp(i)*domI.^gamma(i) + base(i);
    %Lhat(:,i) = amp(i)*Lhat(:,i) + mean(L(1,:));
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

