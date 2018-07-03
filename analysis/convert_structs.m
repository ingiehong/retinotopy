
%Use these commands to prune structures for insertion into the Callahan retinotopy protocol  
%% Select mat file
%fName='C:\Users\hwanggm1\Documents\data\Retinopathy\Sample Data\XX0\grab_XX0_000_001_31_May_2018_17_57_14.mat';

[ fName, pathname ]= uigetfile('*.mat', 'Select a MATLAB grab data file', 'C:\Users\Huganir lab\Documents\imager_data\');
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

%Creating grab file
tmp=squeeze(mean(im,4));
grab.img = tmp; %tmp is grab from collect
grab.clock = [2018 05 31 17 57 14];
grab.ROIcrop = [];%[40 260 155 250]; 
grab.comments = {};

[~,name,~]=fileparts(fName);
save([pathname name '_grab.mat'], 'grab');
%dataPath= 'C:\Users\hwanggm1\Documents\data\Retinopathy\ImagerData\05312018\'
 %   load([dataPath '05311800_Widefield_2018-05-31_175714syncInfo.mat']);
% '05311800_Widefield_2018-05-31_175714syncInfo.mat % azimuth 0
%    '05311805_Widefield_2018-05-31_180218syncInfo.mat' % azimuth 180
%'05311816_Widefield_2018-05-31_181251syncInfo.mat' %altitude 0
%'05311840_Widefield_2018-05-31_183657syncInfo.mat' %altitude 180

%% Select .analyzer file

% NEEDS SOME LOOP STRUCTURE TO SELECT azimuth/altitude/0/180deg analyzer files
[ fName, pathname ]= uigetfile('*.analyzer', 'Select a ANALYZER data file', pathname );
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName), '-mat'); % 
end

%% Basically trash...
%cd('C:\Users\Huganir lab\Documents\imager_data\05312018')
%xx0_u000_001.analyzer  xx0_u000_002.analyzer are azimuth files 0&180 deg
%xx0_u000_004.analyzer  xx0_u000_007.analyzer are altitude files 0&180 deg
%load('xx0_u000_004.analyzer', '-mat'); % 
% Analyzer.M= setfield(Analyzer.M, 'anim', 'xx0');
% Analyzer.M= setfield(Analyzer.M, 'unit', '000');
% Analyzer.M= setfield(Analyzer.M, 'expt', '001');
% Analyzer.M= setfield(Analyzer.M, 'hemi', 'left');
% Analyzer.M= setfield(Analyzer.M, 'screenDist', 10);
% Analyzer.M= setfield(Analyzer.M, 'monitor', 'LIN'); % double check this
% Analyzer.M= setfield(Analyzer.M, 'screenXcm', 121);  % update this
% Analyzer.M= setfield(Analyzer.M, 'screenXcm', 96); % update this 
% Analyzer.M= setfield(Analyzer.M, 'xpixels', 1280);
% Analyzer.M= setfield(Analyzer.M, 'ypixels', 720);
%  Analyzer.M= setfield(Analyzer.M, 'syncSize', 4); %appears to be incorrectly produced
%  Analyzer.M= setfield(Analyzer.M, 'running', 1);
% Analyzer.M= setfield(Analyzer.M, 'analyzerRoot', 'C:\Users\hwanggm1\Documents\data\Retinopathy\AnalyzerFiles'); %
 %Analyzer.M= setfield(Analyzer.M, 'stimulusIDP', '10.1.38.61'); %update
 
% Analyzer.P = setfield(Analyzer.P ,'altazimuth', 'altitude')
%Analyzer.P.param{12}{3}='altitude' %% or 'azimuth'

if Analyzer.P.param{3}{3} ~= 183 %ensure longer stimulus time is used for retonotopic analysis
  warning('Stimulus duration is not 183 seconds')
end
%     Analyzer.L.reps=1;
if Analyzer.L.rand==1
    warning('Random is on in Looper')
end
% Analyzer.L.param{1}{2}=0;
% Analyzer.loops.conds{1}.val{1}=0;
% Analyzer.loops.conds{1}.repeats{1}.trialno=1
% Analyzer.loops.conds{2}.symbol{1} = 'ori';
% Analyzer.loops.conds{2}.val{1}=180;
% Analyzer.loops.conds{2}.repeats{1}.trialno=2

%cd('C:\Users\hwanggm1\Documents\data\Retinopathy\ImagerData\05312018')
%load('05311816_Widefield_2018-05-31_181251syncInfo.mat')

%% Select first syncInfo mat file

[ fName, pathname ]= uigetfile('*.mat', 'Select first SyncInfo MATLAB data file', pathname );
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

%%
%Check for extra flashes in photo diode
while abs(syncInfo.dispSyncs(2) - syncInfo.dispSyncs(1)-2) >0.1
    syncInfo.dispSyncs=syncInfo.dispSyncs(2:end);       
end
diff(syncInfo.dispSyncs)

syncInfo1=syncInfo ;       
getStartframe=find(syncInfo1.dispSyncs(1)<syncInfo1.acqSyncs,1) % First frame after photodiode pulse
syncInfo1.acqSyncs=syncInfo1.acqSyncs(getStartframe:getStartframe+1869);
%syncInfo1.dispSyncs = [syncInfo1.dispSyncs(1)-2 ; syncInfo1.dispSyncs];
%%rare fix
clear syncInfo

%% Select syncInfo mat file
%load('05311840_Widefield_2018-05-31_183657syncInfo.mat')

[ fName, pathname ]= uigetfile('*.mat', 'Select second SyncInfo MATLAB data file', 'C:\Users\Huganir lab\Documents\imager_data\');
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

%Check for extra flashes in photo diode
while abs(syncInfo.dispSyncs(2) - syncInfo.dispSyncs(1)-2) >0.1
    syncInfo.dispSyncs=syncInfo.dispSyncs(2:end);       
end
       
       
diff(syncInfo.dispSyncs)
syncInfo2=syncInfo ;
getStartframe=find(syncInfo2.dispSyncs(1)<syncInfo2.acqSyncs,1); % First frame after photodiode pulse
%syncInfo2.dispSyncs=syncInfo2.dispSyncs(1:end); % add missing disp pulse and prune to 1870
syncInfo2.acqSyncs=syncInfo2.acqSyncs(getStartframe:getStartframe+1869);
clear syncInfo
 
%clear all other stuff, then 
%cd('C:\Users\hwanggm1\Documents\data\Retinopathy\AnalyzerFiles\XX0')
%cd(pathname)

outPath='C:\Users\Huganir lab\Documents\RetinotopyPipelineData\AnalyzerFiles\XX0\'
save([outPath 'XX0_u000_001.analyzer'], 'Analyzer', 'syncInfo1', 'syncInfo2')
clear all

load([outPath 'XX0_u000_001.analyzer'], '-mat')
 