function calmon

%% calmon     A function to compute the linearized lookup tables and 
%%            cone directions given the luminance data (in Cd/m^2)
%%            and CIE (x,y) coordinates of each gun.
%%            
%%            'lumdata' should be a 256 by 3 matrix whose first column contains
%%            an integer value (index) for the gun, the next three columns 
%%            should contain the luminance value obtained for the red,
%%            green, and blue guns for that index value.
%%
%%            'xy' should be a 3 by 2 matrix.  The first row is the (x,y)
%%            CIE coordinates at half-amplitude for the red gun, and the
%%            second and third rows are (x,y) coords for the green and
%%            blue guns.
%%
%%            The function returns an N by 4 matrix with the linearizing
%%            lookup tables for the red, green, and blue guns, as well as
%%            a 3 by 3 matrix whose rows give the modulations of the guns
%%            required to produce cone isolating stimuli in the L, M, and
%%            S directions.

root = '/Matlab_code/calibration_stuff/measurements/';

%monitorSpec = 'CRT 6-9-10 PR701/'; %location of spectra data
%monitor = 'CRT 6-9-10 UDT/'; %location of luminance/power data

% monitorSpec = 'CRT (new) 7-8-11/'; %location of spectra data
% monitor = 'CRT (new) 7-8-11/'; %location of luminance/power data

% monitorSpec = 'CRT (new) 7-8-11 UDT/'; %location of spectra data
% monitor = 'CRT (new) 7-8-11 UDT/'; %location of luminance/power data

monitorSpec = 'CRT 7-9-11 UDT/'; %location of spectra data
monitor = 'CRT 7-9-11 UDT/'; %location of luminance/power data



%The following was created with makegammaLUT2.m:
load([root monitor 'LUT.mat'],'L')


figure, plot(0:255,L(:,1),'r',0:255,L(:,2),'g',0:255,L(:,3),'b');


fakeflag = 0;

%Location of sensitivity functions
if fakeflag
    Sens_root = '/Matlab_code/calibration_stuff/sensitivity data/fake cones/';
    UDT_root = '/Matlab_code/calibration_stuff/sensitivity data/UDT';
    load(UDT_root,'S','dom')
    UDTdom = dom;
    UDTSens = S;
else
    Sens_file = 'StockmanSharpe_10deg.txt'
    Sens_root = '/Matlab_code/calibration_stuff/sensitivity data/';
end


%% Now the spectral data

buff = '';

%I decided to start using the higher buffer value when computing the
%spectrum because it drowns out the background spectrum (i.e. the red residual)
%more effectively.

f = [root monitorSpec 'spectrum_red128' buff];  
load(f,'I','dom')
red = I;

f = [root monitorSpec 'spectrum_green128' buff];
load(f,'I','dom')
green = I;

f = [root monitorSpec 'spectrum_blue128' buff];
load(f,'I','dom')
blue = I;

f = [root monitorSpec 'spectrum_baseline' buff];
load(f,'I','dom')
baseline = I;

%Subtracting baseline spectrum definitely helps
red = red-baseline;
green = green-baseline;
blue = blue-baseline;

id = find(red<0); red(id) = 0; 
id = find(green<0); green(id) = 0;
id = find(blue<0); blue(id) = 0;

% red = red/sum(red)*L(end,1);
% green = green/sum(green)*L(end,2);
% blue = blue/sum(blue)*L(end,3);
% 


%Don't use the following if spectra were computed after linearizing the
%guns...
%buff = str2num(buff);
% buff = 128;
% red = red * L(end,1)/L(buff,1);
% green = green * L(end,2)/L(buff,2);
% blue = blue * L(end,3)/L(buff,3);


% load('/Matlab_code/calibration_stuff/sensitivity data/UDT.mat','S')
% 
% UDTdom = 380:2:780;

% redI = interp1(dom,red,UDTdom,'spline');
% greenI = interp1(dom,green,UDTdom,'spline');
% blueI = interp1(dom,blue,UDTdom,'spline');

% red = red/sum(red);  %normalize power of gun spectra
% green = green/sum(green);
% blue = blue/sum(blue);
% 
% figure,plot(UDTdom,[red green blue S])
% 
% ro = red(:)'*S(:);
% go = green(:)'*S(:);
% bo = blue(:)'*S(:);
% 
% ro = L(end,1)/ro;
% go = L(end,2)/go;
% bo = L(end,3)/bo;
% 
% red = red*ro;
% green = green*go;
% blue = blue*bo;


%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%

if fakeflag    
    lms = read_LMS_fake(Sens_root);  %% load fake cone spectral sensitivity data     
else    
    lms = read_LMS(Sens_root,Sens_file);    %Stockman and Sharp (2deg or 10deg)
end

%lms(1:60,2:3) = 0;

if fakeflag
    red = [0 red];
    blue = [0 blue];
    green = [0 green];
    baseline = [0 baseline];
    dom = [lms(1,1) dom];
    
    
else
    id = find(lms(:,1) > dom(end));
    lms(id,:) = [];
end

redi   = interp1(dom,red,lms(:,1),'spline');
greeni = interp1(dom,green,lms(:,1),'spline');
bluei  = interp1(dom,blue,lms(:,1),'spline');

id = find(redi<0); redi(id) = 0;
id = find(greeni<0); greeni(id) = 0;
id = find(bluei<0); bluei(id) = 0;

baselinei  = interp1(dom,baseline,lms(:,1),'spline');


if fakeflag  %I can't believe that I was initially not doing this?!?!
    
    UDTSensI  = interp1(UDTdom,UDTSens,lms(:,1),'spline');
    lms(:,2:end) = lms(:,2:end).*(UDTSensI*[1 1 1]);  %This doesn't actually do much
    
end

% lmsi(:,1) = dom;
% lmsi(:,2) = interp1(lms(:,1),lms(:,2),dom);
% lmsi(:,3) = interp1(lms(:,1),lms(:,3),dom);
% lmsi(:,4)  = interp1(lms(:,1),lms(:,4),dom);

dom = lms(:,1);

% lms = lmsi;
% redi = red';
% greeni = green';
% bluei = blue';

figure
subplot(2,1,1)
plot(dom,redi,'r',dom,greeni,'g',dom,bluei,'b');
subplot(2,1,2)
plot(dom,lms(:,2),'r',dom,lms(:,3),'g',dom,lms(:,4),'b');

%SSi = interp1(SS(:,1),SS(:,2),lms(:,1),'spline');

RGB = [redi greeni bluei];

% RGB = RGB/max(RGB(:));
% dum = lms(:,2:end);
% lms(:,2:end) = lms(:,2:end)/max(dum(:)); 
% 
% figure,plot(RGB)
% hold on
% plot(lms(:,2:end))
T = lms(:,2:end)'*RGB;
Ti=inv(T);

Liso = Ti*[1 0 0]';
Miso = Ti*[0 1 0]';
Siso = Ti*[0 0 1]';

Liso = Liso/max(abs(Liso));
Miso = Miso/max(abs(Miso));
Siso = Siso/max(abs(Siso));


disp(sprintf('L-cone isolating at: %f %f %f',Liso));
disp(sprintf('M-cone isolating at: %f %f %f',Miso));
disp(sprintf('S-cone isolating at: %f %f %f',Siso));

rg = (T(1,1)+T(1,2))/(T(2,1)+T(2,2));
disp(sprintf('Red/Green Isoluminance at ratio of: %f',rg)); 

%%%%%%%%%%%%%%%%%

%%%%%
%2 DEGREE CONE FUNDAMENTALS  (I haven't recomputed these 9/12/10)
%Null Luminance & S ("L+M direction"):  Magnitude of L to M contrast ratio
%made to equal that in the L-M isoluminant case
% dLMS = [1 .85 0];  gain = [.6617 1.0 -.1803]; LMScont = [.7940 .7963 0.0]; Totalcont = 1.1245;
% 
% %Null Luminance & S ("L-M direction"):  
% dLMS = [-1 .85 0];  gain = [1.0 -.3613 .0059]; LMScont = [.1165 -.1169 0.0]; Totalcont = 0.1650;
% 
% %Null Luminance ("S + (L-M)  direction"):  
% dLMS = [1 -.85 .6];  gain = [1.0 -.3849 .1517]; LMScont = [.1143 -.1148 0.1194]; Totalcont = 0.2012;
% 
% %"S isolation"  %use nullfuncs of lms
% dLMS = [0 0 1];  gain = [.1261 -.2071 1.0];  LMScont = [0 0 .8157]; Totalcont = 0.8157;
% 
% %Null Luminance (" S - (L-M)  direction"):  
% dLMS = [-1 .85 .6];  gain = [-1.0 .3369 .1455]; LMScont = [-.1188 .1190 .1239]; Totalcont = 0.2089;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%10 DEGREE CONE FUNDAMENTALS (7/9/10)
%Null Luminance & S ("L+M direction"):  Magnitude of L to M contrast ratio
%made to equal that in the L-M isoluminant case
dLMS = [1 .9 0];  gain = [.5084 1.0 -.1237]; LMScont = [.7387 .7513 0.0]; Totalcont = 1.0536;

%Null Luminance & S ("L-M direction"):  
dLMS = [1 -.9 0];  gain = [1.0 -.3394 -.0102]; LMScont = [.1089 -.1126 0.0]; Totalcont = 0.1567;

%"L isolation"  %use nullfuncs of lms
dLMS = [1 0 0];  gain = [1 -.1774 -.0076];  LMScont = [.2052 0 0]; Totalcont = 0.2052;

%"M isolation"  %use nullfuncs of lms
dLMS = [0 1 0];  gain = [-1 .5278 -.0309];  LMScont = [0 .2432 0]; Totalcont = 0.2432;

%"S isolation"  %use nullfuncs of lms
dLMS = [0 0 1];  gain = [.2106 -.2724 1.0];  LMScont = [0 0 .8584]; Totalcont = 0.8584;


%%%These were not updated because we weren't using them
%Null Luminance ("S + (L-M)  direction"):  
dLMS = [1 -.9 .55];  gain = [1.0 -.3629 .1338]; LMScont = [.1051 -.1067 0.1091]; Totalcont = 0.1798;

%Null Luminance (" S - (L-M)  direction"):  
dLMS = [-1 .9 .55];  gain = [-1.0 .3086 .1311]; LMScont = [-.1110 .1126 .1152]; Totalcont = 0.1956;

%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%


nullfuncs = lms(:,2:end)';


%nullfuncs = [SSi'; lms(:,2)'-lms(:,3)'; lms(:,4)'];  %lumSensitivity, L-M, S 

dLMS = [1 -.9 0]';  %Ratio of response differences for each cone

T = nullfuncs*RGB;   %% dot products
Ti=inv(T);
Liso = Ti*dLMS;
Liso = Liso/max(abs(Liso))  %ratio of gain values for gun modulaton

%%%%%


%This next stuff replicates (line-by-line) stimulus generation code (ImtoRGB.m)

Rlin = linspace(0,2,256) - 1; %[-1 1]
Glin = linspace(0,2,256) - 1;
Blin = linspace(0,2,256) - 1;

Rlin = Rlin*Liso(1); %[-1 1]
Glin = Glin*Liso(2);
Blin = Blin*Liso(3);

Rlin = (Rlin + 1)/2;  %[0 1]
Glin = (Glin + 1)/2;
Blin = (Blin + 1)/2;

%N.B. Rounding will create slightly imperfect isolation
Rlin = round(Rlin*255);  %[0 255]
Glin = round(Glin*255);
Blin = round(Blin*255);

%Estimate min/mid/max spectra using scaling coefficients  
%Spectra were computed at the maximum buffer value
SPECmin = RGB*[Rlin(1)  Glin(1)  Blin(1)]' - baselinei; %spectrum at trough (assumes baseline was subtracted up top)
SPECmax = RGB*[Rlin(end) Glin(end)  Blin(end)]' -baselinei; %spectrum at peak


Rmax = lms(:,2:end)'*SPECmax;
Rmin = lms(:,2:end)'*SPECmin;
Rmean = (Rmax+Rmin)/2;
LMSContrast = (Rmax-Rmin)./(2*Rmean)
TotalContrast = norm(LMSContrast)


%%%%%%%%%%%


%close all



function L = read_sensitivity(root);
f = [root 'SSfunc.txt'];
fid = fopen(f,'r');
L = [];

l = fgetl(fid);
while(l ~= -1)
    s = sscanf(l,'%f,%f');
    L = [L;s'];
    %l = fgetl(fid); %% emtpy line
    l = fgetl(fid);
end

function L = read_LMS(root,file)

f = [root file];
fid = fopen(f,'r');
L = [];

l = fgetl(fid);
while(l ~= -1)
    s = sscanf(l,'%f,%f,%f,%f');
    if length(s) == 3  
        s = [s; 0];
    end
    L = [L;s'];
    %l = fgetl(fid); %% emtpy line
    l = fgetl(fid);
end

function L = read_LMS_fake(root)

dom = 370:730;

type = 'Oriel59500-1';
load([root type '.mat'],'I')
I1 = I;

type = 'SchottBG40';
load([root type '.mat'],'I')
I2 = I;

Lcone = I1.*I2;

%%%

type = 'SchottVG9';
load([root type '.mat'],'I')
I1 = I;

Mcone = I1;

%%%

type = 'Oriel59814';
load([root type '.mat'],'I')
I1 = I;

type = 'Oriel59080';
load([root type '.mat'],'I')
I2 = I;

Scone = I1.*I2;

%%%

L = [dom' Lcone Mcone Scone];

