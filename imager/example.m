clf
figure(1)

ctr = 0:20:160;   %% centers of tuning curves;
ori = 0:179;
                    
%% a family of equally spaced tuning curves
         
Q = exp(4*cos(2*pi/180*(ones(length(ctr),1)*ori-ctr'*ones(1,length(ori)))));
subplot(2,1,1)
plot(Q')

%% these are the centers after adaptation (no change in magnitude!)

ctra = [0 20 40 50 65 115 130 140 160];  %% peaks after adaptation
               
Qa= exp(4*cos(2*pi/180*(ones(length(ctr),1)*ori-ctra'*ones(1,length(ori)))));
subplot(2,1,2)
plot(Qa')

%% now for each angle, compute the estimate of the orientation angle given
%% the population activity in both cases, for all oris from 0 to 180, using
%% vector averaging

V = exp(i*2*pi*ctr/180)' * ones(1,length(ori));  

%% estimate using the activity of the unadapted population
ori_est  = -unwrap(angle(sum(V.*Q)))*180/2/pi;

%% estimate using the activity of the adapted population with the original
%% label of the cells

ori_esta = -unwrap(angle(sum(V.*Qa)))*180/2/pi;

figure(2)
plot(ori,ori_est -ori,'b-'), hold on
plot(ori,ori_esta-ori,'r-')
legend('before adaptation','after adaptation')
ylabel('Stimulus ori - Decoded (perceived) ori (in deg)')
xlabel('Stimulus ori (deg)')

