

%% Load analyzer
[ fName, pathname ]= uigetfile('*.analyzer', 'Select an analyzer file', pwd);
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName),'-mat');
end
[~,F1name,~] = fileparts(fName);

dataPath= pathname;
%load('180705_u000_000.analyzer', '-mat')

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
    [~,name,~] = fileparts(fName);
    %load('180705_u000_000_001.mat')
    im=squeeze(im);
    if isempty(F1{c})
        F1{c} = offlineAnalysis(1,syncInfo1, im, [pathname filesep F1name '_' sprintf('%03d',(trials)) '.tif'] );
    else
        F1{c} = F1{c}+offlineAnalysis(1,syncInfo1, im, [pathname filesep F1name '_' sprintf('%03d',(trials)) '.tif'] );
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

if conds*repeats ~= trials 
    error(['The expected number of image data files do not match conditions*repeats. '])
end
    
f1m = F1;
save(F1name,'f1m')
