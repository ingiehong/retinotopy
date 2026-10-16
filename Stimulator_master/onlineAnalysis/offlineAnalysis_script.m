%% Script to reanalyze phase from raw retinotopy data and save trial-averaged tif file for visualization
clear all
close all

%% Load analyzer
[ fName, pathname ]= uigetfile('*.analyzer', 'Select an analyzer file', pwd);
if isequal(fName,0)
   error('User selected Cancel.')
else
   disp(['User selected: ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName),'-mat');
end
[~,F1name,~] = fileparts(fName);

dataPath= pathname;
%load('180705_u000_000.analyzer', '-mat')

%% Signal polarity: 'negative' (intrinsic imaging) or 'positive' (GCaMP).
% Newer acquisitions record it in the analyzer (Analyzer.M.signalPolarity); for older data set the override.
signalPolarity_override = '';   % '' = use the analyzer / default; 'positive' (GCaMP) or 'negative' (intrinsic) forces it
detrendMode = 'none';           % 'linear' removes each pixel's bleaching trend before the F1 projection
if isfield(Analyzer,'M') && isfield(Analyzer.M,'signalPolarity') && ~isempty(Analyzer.M.signalPolarity)
    signalPolarity = Analyzer.M.signalPolarity;
else
    signalPolarity = 'negative';
end
if ~isempty(signalPolarity_override), signalPolarity = signalPolarity_override; end
disp(['Signal polarity: ' signalPolarity '; detrend: ' detrendMode])

%% Parse Analyzer
conds=size(Analyzer.loops.conds,2);
repeats=Analyzer.L.reps;

%% Check how many trials are recorded in analyzer file
c=1;
r=1;
F1{conds}=[];

trials=0;
while exist(['syncInfo' num2str(trials+1)], 'var')
    
    trial_file = [pathname F1name '_' sprintf('%03d',(trials)) '.mat'];
    if ~exist( trial_file , 'file')
        error(['The expected image data file ' trial_file ' does not exist'])
    end
    disp(['Processing: condition ' num2str(c) ' repeat ' num2str(r) ': '   trial_file ])
    load(trial_file);
    syncInfoTrial = eval(sprintf('syncInfo%d', trials+1));   % this trial's own sync times (the old code used syncInfo1 for every trial)
    [~,name,~] = fileparts(fName);
    %load('180705_u000_000_001.mat')
    im=squeeze(im);
    if isempty(F1{c})
        [F1{c}, video] = offlineAnalysis(c,syncInfoTrial, im, [pathname filesep F1name '_' sprintf('%03d',(trials)) '.tif'], signalPolarity, detrendMode );
        F1trials{c,r} = F1{c};
    else
        [tempF1, video] = offlineAnalysis(c,syncInfoTrial, im, [pathname filesep F1name '_' sprintf('%03d',(trials)) '.tif'], signalPolarity, detrendMode );
        F1{c} = F1{c} + tempF1;
        F1trials{c,r} = tempF1;
    end
    if ~exist('avgvideo','var') || size(avgvideo,4)<c
        avgvideo(:,:,:,c) = double(video);
    else
        avgvideo(:,:,:,c) = avgvideo(:,:,:,c) + double(video);
    end
    
    % Now update indices
    trials=trials+1;
    
    if c==conds
        r=r+1;
        c=1;
    else
        c=c+1;
    end
    
end
avgvideo = avgvideo/repeats;
if conds*repeats ~= trials 
    error(['The expected number of image data files do not match conditions*repeats. '])
end
    
f1m = F1;
f1trials = F1trials; nrep = repeats;
save(fullfile(pathname,[F1name '_offline.mat']),'f1m','f1trials','nrep','signalPolarity','detrendMode') % polarity is stored so generatekret uses f1m as is
disp(['Saved ' fullfile(pathname,[F1name '_offline.mat']) '. To segment from it: getAreaBorders_Ingie(..., struct(''f1mSuffix'',''_offline''))'])

saveastiff(avgvideo(:,:,:,1), [pathname filesep F1name '_1_avg.tif']);
saveastiff(avgvideo(:,:,:,2), [pathname filesep F1name '_2_avg.tif']);

% saveastiff(avgvideo(:,:,:,1), [pathname filesep F1name '_alt1_avg.tif']);
% saveastiff(avgvideo(:,:,:,2), [pathname filesep F1name '_alt2_avg.tif']);

% saveastiff(avgvideo(:,:,:,1), [pathname filesep F1name '_azi1_avg.tif']);
% saveastiff(avgvideo(:,:,:,2), [pathname filesep F1name '_azi2_avg.tif']);