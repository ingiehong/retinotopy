

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

[ fName, pathname ]= uigetfile('*.mat', 'Select 1st image data MATLAB file', dataPath);
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

[~,name,~] = fileparts(fName);
%load('180705_u000_000_001.mat')
im=squeeze(im);

F1{1} = offlineAnalysis(1,syncInfo1, im, [pathname, name, '.tif'] );


[ fName, pathname ]= uigetfile('*.mat', 'Select 2nd image data MATLAB file', dataPath);
if isequal(fName,0)
   error('User selected Cancel')
else
   disp(['User selected ', fullfile(pathname, fName)])
   load(fullfile(pathname, fName));
end

[~,name,~] = fileparts(fName);
%load('180705_u000_000_001.mat')
im=squeeze(im);

F1{2} = offlineAnalysis(2,syncInfo2, im, [pathname, name, '.tif'] );
f1m = F1;
save(F1name,'f1m')
